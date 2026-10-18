import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_state/providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../support/app_harness.dart';
import '../support/fakes.dart';
import '../support/mocks.dart';

void main() {
  late MockStateRepository repository;
  late MockAuthRepository authRepository;

  final sp = unit();
  final rj = unit(id: 2, name: 'Rio de Janeiro', abbreviation: 'RJ');

  List<Override> overrides() => [
    stateRepositoryProvider.overrideWithValue(repository),
    authRepositoryProvider.overrideWithValue(authRepository),
  ];

  void stubList(List<dynamic> units) {
    when(
      () => repository.list(
        search: any(named: 'search'),
        sort: any(named: 'sort'),
      ),
    ).thenAnswer((_) async => List.of(units.cast()));
  }

  setUpAll(registerFallbacks);

  setUp(() {
    repository = MockStateRepository();
    authRepository = MockAuthRepository();
    stubList([sp, rj]);
  });

  testWidgets('shows a loading indicator, then the states', (tester) async {
    final pending = Completer<List<dynamic>>();
    when(
      () => repository.list(
        search: any(named: 'search'),
        sort: any(named: 'sort'),
      ),
    ).thenAnswer((_) async => (await pending.future).cast());
    await AppHarness(overrides: overrides()).pump(tester, settle: false);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    pending.complete([sp, rj]);
    await tester.pumpAndSettle();

    expect(find.text('São Paulo'), findsOneWidget);
    expect(find.text('Rio de Janeiro'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('offers to create the first state when there are none', (
    tester,
  ) async {
    stubList([]);
    final harness = AppHarness(token: fakeJwt(), overrides: overrides());
    await harness.pump(tester);
    expect(find.text('No states registered.'), findsOneWidget);

    await tester.tap(find.text('Create the first state'));
    await tester.pumpAndSettle();

    expect(find.text('New state'), findsWidgets);
    expect(find.byKey(const Key('abbreviation')), findsOneWidget);
  });

  testWidgets('shows the error with its reference id when loading fails', (
    tester,
  ) async {
    const id = '123e4567-e89b-12d3-a456-426614174000';
    when(
      () => repository.list(
        search: any(named: 'search'),
        sort: any(named: 'sort'),
      ),
    ).thenAnswer(
      (_) => Future.error(
        DioException(
          requestOptions: RequestOptions(path: '/estado/paginado'),
          response: Response(
            requestOptions: RequestOptions(path: '/estado/paginado'),
            statusCode: 500,
            data: {'requestId': id},
          ),
        ),
      ),
    );
    await AppHarness(overrides: overrides()).pump(tester);
    expect(find.text('Failed to fetch states.'), findsOneWidget);
    expect(find.text('Reference ID: $id'), findsOneWidget);
    // An error is not an empty list, and must not look like one (nor spin forever).
    expect(find.text('No states registered.'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('lets the user retry after a load failure', (tester) async {
    when(
      () => repository.list(
        search: any(named: 'search'),
        sort: any(named: 'sort'),
      ),
    ).thenAnswer(
      (_) => Future.error(
        DioException(requestOptions: RequestOptions(path: '/estado/paginado')),
      ),
    );
    await AppHarness(overrides: overrides()).pump(tester);
    expect(find.byKey(const Key('retry')), findsOneWidget);

    stubList([sp, rj]);
    await tester.tap(find.byKey(const Key('retry')));
    await tester.pumpAndSettle();

    expect(find.text('São Paulo'), findsOneWidget);
    expect(find.byKey(const Key('retry')), findsNothing);
  });

  testWidgets('opens the create screen from "New state" (with a session)', (
    tester,
  ) async {
    await AppHarness(token: fakeJwt(), overrides: overrides()).pump(tester);
    await tester.tap(find.byKey(const Key('new-state')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('abbreviation')), findsOneWidget);
  });

  testWidgets('"New state" without a session lands on the login screen', (
    tester,
  ) async {
    await AppHarness(overrides: overrides()).pump(tester);
    await tester.tap(find.byKey(const Key('new-state')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('username')), findsOneWidget);
  });

  testWidgets('opens the edit screen of the pressed row', (tester) async {
    when(() => repository.get(1)).thenAnswer((_) async => sp);
    await AppHarness(token: fakeJwt(), overrides: overrides()).pump(tester);
    await tester.tap(find.byKey(const Key('edit-1')));
    await tester.pumpAndSettle();
    verify(() => repository.get(1)).called(1);
    expect(find.byKey(const Key('abbreviation')), findsOneWidget);
  });

  testWidgets('debounces the search by 300ms and sends it as busca', (
    tester,
  ) async {
    await AppHarness(overrides: overrides()).pump(tester);
    await tester.enterText(find.byKey(const Key('search')), 'rio');
    await tester.pump(const Duration(milliseconds: 299));
    verifyNever(() => repository.list(search: 'rio', sort: null));

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();

    verify(() => repository.list(search: 'rio', sort: null)).called(1);
  });

  testWidgets('sorts by a field, toggling the direction on a second press', (
    tester,
  ) async {
    await AppHarness(overrides: overrides()).pump(tester);

    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();
    verify(() => repository.list(search: null, sort: 'nome,asc')).called(1);

    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();
    verify(() => repository.list(search: null, sort: 'nome,desc')).called(1);
  });

  testWidgets('keeps the rows on screen while a new sort loads', (
    tester,
  ) async {
    await AppHarness(overrides: overrides()).pump(tester);
    when(
      () => repository.list(
        search: any(named: 'search'),
        sort: any(named: 'sort'),
      ),
    ).thenAnswer(
      (_) => Completer<List<dynamic>>().future.then((v) => v.cast()),
    );

    await tester.tap(find.text('Name'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('São Paulo'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('refetches on pull to refresh', (tester) async {
    await AppHarness(overrides: overrides()).pump(tester);
    verify(() => repository.list(search: null, sort: null)).called(1);

    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    verify(() => repository.list(search: null, sort: null)).called(1);
  });

  group('deleting', () {
    Future<void> pressDeleteSp(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('delete-1')));
      await tester.pumpAndSettle();
    }

    testWidgets('asks for confirmation in a dialog before deleting', (
      tester,
    ) async {
      await AppHarness(overrides: overrides()).pump(tester);
      await pressDeleteSp(tester);
      expect(find.text('Are you sure you want to delete SP?'), findsOneWidget);
      verifyNever(() => repository.delete(any()));
    });

    testWidgets('does not delete when cancelled', (tester) async {
      await AppHarness(overrides: overrides()).pump(tester);
      await pressDeleteSp(tester);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      verifyNever(() => repository.delete(any()));
      expect(find.text('Are you sure you want to delete SP?'), findsNothing);
    });

    testWidgets('deletes and refreshes the list once confirmed', (
      tester,
    ) async {
      when(() => repository.delete(1)).thenAnswer((_) async {});
      await AppHarness(overrides: overrides()).pump(tester);
      await pressDeleteSp(tester);

      await tester.tap(find.byKey(const Key('confirm-delete')));
      await tester.pumpAndSettle();

      verify(() => repository.delete(1)).called(1);
      verify(() => repository.list(search: null, sort: null)).called(2);
    });

    testWidgets('shows an error when deleting fails', (tester) async {
      when(() => repository.delete(1)).thenThrow(serverError('/estado/1'));
      await AppHarness(overrides: overrides()).pump(tester);
      await pressDeleteSp(tester);
      await tester.tap(find.byKey(const Key('confirm-delete')));
      await tester.pumpAndSettle();
      expect(find.text('Failed to delete state.'), findsOneWidget);
    });
  });

  group('session control', () {
    testWidgets('offers "Log in" when logged out', (tester) async {
      await AppHarness(overrides: overrides()).pump(tester);
      expect(find.byKey(const Key('log-in')), findsOneWidget);
      expect(find.byKey(const Key('log-out')), findsNothing);
      await tester.tap(find.byKey(const Key('log-in')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('username')), findsOneWidget);
    });

    testWidgets('offers "Log out" when logged in, and signs out', (
      tester,
    ) async {
      when(() => authRepository.logout()).thenAnswer((_) async {});
      await AppHarness(token: fakeJwt(), overrides: overrides()).pump(tester);
      expect(find.byKey(const Key('log-out')), findsOneWidget);

      await tester.tap(find.byKey(const Key('log-out')));
      await tester.pumpAndSettle();

      verify(() => authRepository.logout()).called(1);
      expect(find.byKey(const Key('log-in')), findsOneWidget);
    });
  });

  group('accessibility', () {
    testWidgets('meets the platform tap target, label and contrast rules', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await AppHarness(overrides: overrides()).pump(tester);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });
}
