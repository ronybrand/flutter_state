import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_state/auth/auth_controller.dart';
import 'package:flutter_state/core/session_events.dart';
import 'package:flutter_state/core/token_store.dart';
import 'package:flutter_state/data/auth_repository.dart';
import 'package:flutter_state/providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../support/fakes.dart';
import '../support/mocks.dart';

void main() {
  late SecureTokenStore tokens;
  late MockAuthRepository repository;
  late SessionEvents events;

  ProviderContainer containerFor() {
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        tokenStoreProvider.overrideWithValue(tokens),
        authRepositoryProvider.overrideWithValue(repository),
        sessionEventsProvider.overrideWithValue(events),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    tokens = SecureTokenStore(FakeKeyValueStore());
    repository = MockAuthRepository();
    events = SessionEvents();
    when(() => repository.logout()).thenAnswer((_) => tokens.clear());
    addTearDown(events.dispose);
  });

  test('starts unauthenticated without a stored token', () {
    expect(
      containerFor().read(authControllerProvider),
      AuthStatus.unauthenticated,
    );
  });

  test('starts authenticated with a token restored at launch', () async {
    await tokens.save(fakeJwt());
    expect(
      containerFor().read(authControllerProvider),
      AuthStatus.authenticated,
    );
  });

  test('signIn authenticates after a successful login', () async {
    final token = fakeJwt();
    when(
      () => repository.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {
      await tokens.save(token);
      return LoginResult(token: token, expiresInSeconds: 3600);
    });
    final container = containerFor();

    await container
        .read(authControllerProvider.notifier)
        .signIn(username: 'admin', password: 'secret');

    expect(container.read(authControllerProvider), AuthStatus.authenticated);
    verify(() => repository.login(username: 'admin', password: 'secret'))
        .called(1);
  });

  test('signIn rethrows and stays unauthenticated when login fails', () async {
    when(
      () => repository.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 401,
        ),
      ),
    );
    final container = containerFor();

    await expectLater(
      container
          .read(authControllerProvider.notifier)
          .signIn(username: 'admin', password: 'wrong'),
      throwsA(isA<DioException>()),
    );
    expect(container.read(authControllerProvider), AuthStatus.unauthenticated);
  });

  test('signOut clears the token and flips to unauthenticated', () async {
    await tokens.save(fakeJwt());
    final container = containerFor();
    expect(container.read(authControllerProvider), AuthStatus.authenticated);

    await container.read(authControllerProvider.notifier).signOut();

    expect(container.read(authControllerProvider), AuthStatus.unauthenticated);
    expect(tokens.current, isNull);
  });

  test('flips to unauthenticated when a request reports a 401', () async {
    await tokens.save(fakeJwt());
    final container = containerFor();
    container.listen(authControllerProvider, (_, _) {});
    expect(container.read(authControllerProvider), AuthStatus.authenticated);

    events.notifyExpired();
    await Future<void>.delayed(Duration.zero);

    expect(container.read(authControllerProvider), AuthStatus.unauthenticated);
  });

  test('logs out by itself when the token reaches its expiry', () {
    fakeAsync((async) {
      final base = DateTime.utc(2026, 1, 1, 12);
      var now = base;
      tokens.save(fakeJwt(now: base, expiresIn: const Duration(seconds: 30)));
      async.flushMicrotasks();
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          tokenStoreProvider.overrideWithValue(tokens),
          authRepositoryProvider.overrideWithValue(repository),
          sessionEventsProvider.overrideWithValue(events),
          clockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);
      container.listen(authControllerProvider, (_, _) {});
      expect(container.read(authControllerProvider), AuthStatus.authenticated);

      now = base.add(const Duration(seconds: 31));
      async.elapse(const Duration(seconds: 31));

      expect(
        container.read(authControllerProvider),
        AuthStatus.unauthenticated,
      );
      verify(() => repository.logout()).called(1);
    });
  });
}
