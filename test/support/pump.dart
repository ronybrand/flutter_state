import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_state/app.dart';
import 'package:flutter_state/core/token_store.dart';
import 'package:flutter_state/data/info_repository.dart';
import 'package:flutter_state/providers.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// A single widget on its own, with a Material shell around it.
Future<void> pumpWidgetUnderTest(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child))),
  );
}

/// The whole app: real router and providers, with the network replaced by
/// whatever [overrides] provide.
class AppHarness {
  AppHarness({String? token, List<Override> overrides = const []})
    : keychain = FakeKeyValueStore(),
      _overrides = overrides {
    tokens = SecureTokenStore(keychain);
    if (token != null) keychain.values[tokenKey] = token;
  }

  final FakeKeyValueStore keychain;
  late final SecureTokenStore tokens;
  final List<Override> _overrides;

  Future<void> pump(WidgetTester tester, {String location = '/'}) async {
    await tokens.load();
    await tester.pumpWidget(
      ProviderScope(
        // The HTTP client already retries; Riverpod must not retry on top of it.
        retry: (_, _) => null,
        overrides: [
          tokenStoreProvider.overrideWithValue(tokens),
          initialLocationProvider.overrideWithValue(location),
          appVersionProvider.overrideWith((ref) async => '1.0.0'),
          backendInfoProvider.overrideWith(
            (ref) async =>
                BackendInfo(commit: 'def5678', time: DateTime(2026, 1, 2, 3)),
          ),
          ..._overrides,
        ],
        child: const EstadosApp(),
      ),
    );
    await tester.pumpAndSettle();
  }
}
