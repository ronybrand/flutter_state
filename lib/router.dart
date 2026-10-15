import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth/auth_controller.dart';
import 'screens/create_state_screen.dart';
import 'screens/edit_state_screen.dart';
import 'screens/login_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/state_list_screen.dart';

/// Where the router starts; tests override it to open a deep link.
final initialLocationProvider = Provider<String>((ref) => '/');

bool _isProtected(String location) => location.startsWith('/state/');

final routerProvider = Provider<GoRouter>((ref) {
  // The router re-runs `redirect` whenever the session changes, so a token that
  // expires or a 401 sends a protected screen back to login on the spot.
  final refresh = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    initialLocation: ref.read(initialLocationProvider),
    refreshListenable: refresh,
    // Only the mutating screens require a session, matching the backend's
    // "reads are public" rule. Guards run on the client only: they are a UX
    // hint, the backend authorizes every request.
    redirect: (context, state) {
      final signedIn =
          ref.read(authControllerProvider) == AuthStatus.authenticated;
      if (_isProtected(state.matchedLocation) && !signedIn) return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const StateListScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/state/new', builder: (_, _) => const CreateStateScreen()),
      GoRoute(
        path: '/state/:id/edit',
        builder: (_, state) =>
            EditStateScreen(rawId: state.pathParameters['id']),
      ),
    ],
    errorBuilder: (_, _) => const NotFoundScreen(),
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
