import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'expiry_timer.dart';

enum AuthStatus { authenticated, unauthenticated }

/// The session, as the UI sees it. The initial status comes from the token
/// already loaded from the keychain in main(), so there is no "loading" state
/// for a guard to misjudge.
final authControllerProvider = NotifierProvider<AuthController, AuthStatus>(
  AuthController.new,
);

class AuthController extends Notifier<AuthStatus> {
  late ExpiryTimer _expiry;

  @override
  AuthStatus build() {
    final tokens = ref.watch(tokenStoreProvider);
    _expiry = ExpiryTimer(tokens, _endSession, now: ref.read(clockProvider))
      ..schedule();
    // The HTTP client's 401 handler runs outside the widget tree; it clears the
    // token and announces here, which updates the state the router reads.
    final subscription = ref
        .watch(sessionEventsProvider)
        .expired
        .listen((_) => _endSession());
    ref.onDispose(() {
      subscription.cancel();
      _expiry.cancel();
    });
    return tokens.current != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
  }

  void _endSession() {
    _expiry.cancel();
    state = AuthStatus.unauthenticated;
    unawaited(ref.read(authRepositoryProvider).logout());
  }

  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    await ref
        .read(authRepositoryProvider)
        .login(username: username, password: password);
    state = AuthStatus.authenticated;
    _expiry.schedule();
  }

  Future<void> signOut() async {
    _expiry.cancel();
    state = AuthStatus.unauthenticated;
    await ref.read(authRepositoryProvider).logout();
  }
}
