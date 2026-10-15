import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_state/core/session_events.dart';
import 'package:flutter_state/providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../support/app_harness.dart';
import '../support/fakes.dart';
import '../support/mocks.dart';

void main() {
  late MockStateRepository stateRepository;
  late MockAuthRepository authRepository;
  late SessionEvents events;

  List<Override> overrides() => [
    stateRepositoryProvider.overrideWithValue(stateRepository),
    authRepositoryProvider.overrideWithValue(authRepository),
    sessionEventsProvider.overrideWithValue(events),
  ];

  setUp(() {
    stateRepository = MockStateRepository();
    authRepository = MockAuthRepository();
    events = SessionEvents();
    addTearDown(events.dispose);
    when(
      () => stateRepository.list(
        search: any(named: 'search'),
        sort: any(named: 'sort'),
      ),
    ).thenAnswer((_) async => [unit()]);
    when(() => stateRepository.get(any())).thenAnswer((_) async => unit());
    when(() => authRepository.logout()).thenAnswer((_) async {});
  });

  group('guard', () {
    testWidgets('the list and login are public', (tester) async {
      final harness = AppHarness(overrides: overrides());
      await harness.pump(tester);
      expect(find.byKey(const Key('search')), findsOneWidget);
    });

    for (final path in ['/state/new', '/state/3/edit']) {
      testWidgets('redirects $path to login without a session', (tester) async {
        await AppHarness(overrides: overrides()).pump(tester, location: path);
        expect(find.byKey(const Key('username')), findsOneWidget);
        expect(find.byKey(const Key('abbreviation')), findsNothing);
      });

      testWidgets('allows $path with a session', (tester) async {
        await AppHarness(
          token: fakeJwt(),
          overrides: overrides(),
        ).pump(tester, location: path);
        expect(find.byKey(const Key('abbreviation')), findsOneWidget);
      });

      testWidgets('treats an expired stored token as no session ($path)', (
        tester,
      ) async {
        await AppHarness(
          token: fakeJwt(expiresIn: const Duration(minutes: -5)),
          overrides: overrides(),
        ).pump(tester, location: path);
        expect(find.byKey(const Key('username')), findsOneWidget);
      });
    }

    testWidgets('a 401 mid-session sends a protected screen back to login', (
      tester,
    ) async {
      await AppHarness(
        token: fakeJwt(),
        overrides: overrides(),
      ).pump(tester, location: '/state/new');
      expect(find.byKey(const Key('abbreviation')), findsOneWidget);

      events.notifyExpired();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('username')), findsOneWidget);
    });
  });

  testWidgets('an unknown route shows a not-found screen with a way home', (
    tester,
  ) async {
    await AppHarness(overrides: overrides()).pump(tester, location: '/nope');
    expect(find.text('Page not found'), findsOneWidget);

    await tester.tap(find.text('Back to home'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('search')), findsOneWidget);
  });
}
