import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_state/app.dart';
import 'package:flutter_state/core/app_locale.dart';
import 'package:flutter_state/core/token_store.dart';
import 'package:flutter_state/data/info_repository.dart';
import 'package:flutter_state/providers.dart';
import 'package:flutter_state/router.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// The whole app: real router and providers, with the network replaced by
/// whatever [overrides] provide.
class AppHarness {
  AppHarness({String? token, this.overrides = const []})
    : keychain = FakeKeyValueStore(),
      localePreferences = FakeLocalePreferenceStore() {
    tokens = SecureTokenStore(keychain);
    if (token != null) keychain.values[tokenKey] = token;
  }

  final FakeKeyValueStore keychain;
  final FakeLocalePreferenceStore localePreferences;
  late final SecureTokenStore tokens;
  final List<Override> overrides;

  Future<void> pump(
    WidgetTester tester, {
    String location = '/',
    bool settle = true,
  }) async {
    await tokens.load();
    await tester.pumpWidget(
      ProviderScope(
        // The HTTP client already retries; Riverpod must not retry on top of it.
        retry: (_, _) => null,
        overrides: [
          tokenStoreProvider.overrideWithValue(tokens),
          localePreferenceStoreProvider.overrideWithValue(localePreferences),
          initialLocationProvider.overrideWithValue(location),
          appVersionProvider.overrideWith((ref) async => '1.0.0'),
          backendInfoProvider.overrideWith(
            (ref) async =>
                BackendInfo(commit: 'def5678', time: DateTime(2026, 1, 2, 3)),
          ),
          ...overrides,
        ],
        child: const EstadosApp(),
      ),
    );
    if (settle) await tester.pumpAndSettle();
  }
}
