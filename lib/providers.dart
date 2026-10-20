import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'core/api_client.dart';
import 'core/config.dart';
import 'core/session_events.dart';
import 'core/token_store.dart';
import 'data/ask_repository.dart';
import 'data/auth_repository.dart';
import 'data/info_repository.dart';
import 'data/state_repository.dart';

/// Overridden in main(): the token is read from the keychain before the first
/// frame, so the app never has to render a "not known yet" state.
final tokenStoreProvider = Provider<TokenStore>(
  (ref) => throw UnimplementedError('tokenStoreProvider must be overridden'),
);

final apiBaseUrlProvider = Provider<String>((ref) => apiBaseUrl);

/// Injectable so tests can move time.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final sessionEventsProvider = Provider<SessionEvents>((ref) {
  final events = SessionEvents();
  ref.onDispose(events.dispose);
  return events;
});

final dioProvider = Provider<Dio>(
  (ref) => createDio(
    baseUrl: ref.watch(apiBaseUrlProvider),
    tokens: ref.watch(tokenStoreProvider),
    onSessionExpired: ref.watch(sessionEventsProvider).notifyExpired,
  ),
);

final stateRepositoryProvider = Provider<StateRepository>(
  (ref) => StateRepository(ref.watch(dioProvider)),
);

final askRepositoryProvider = Provider<AskRepository>(
  (ref) => AskRepository(ref.watch(dioProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) =>
      AuthRepository(ref.watch(dioProvider), ref.watch(tokenStoreProvider)),
);

final infoRepositoryProvider = Provider<InfoRepository>(
  (ref) => InfoRepository(ref.watch(dioProvider)),
);

/// The footer is informational, not critical: if the backend does not answer
/// the provider just errors and that part of the footer hides.
final backendInfoProvider = FutureProvider<BackendInfo>(
  (ref) => ref.watch(infoRepositoryProvider).backendInfo(),
);

/// A mobile binary carries its version in pubspec.yaml; the web apps show the
/// commit of the build instead.
final appVersionProvider = FutureProvider<String>(
  (ref) async => (await PackageInfo.fromPlatform()).version,
);
