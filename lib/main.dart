import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/token_store.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The session is read from the keychain before the first frame, while the
  // native launch screen is still up. The app therefore starts already knowing
  // whether anyone is signed in, and no guard can misjudge a "not loaded yet"
  // state and bounce a signed-in user to the login screen.
  final tokens = SecureTokenStore(const PlatformKeyValueStore());
  await tokens.load();

  runApp(
    ProviderScope(
      // The HTTP client already retries failing GETs; Riverpod's own retry
      // (on by default in 3.x) would multiply the attempts.
      retry: (_, _) => null,
      overrides: [tokenStoreProvider.overrideWithValue(tokens)],
      child: const EstadosApp(),
    ),
  );
}
