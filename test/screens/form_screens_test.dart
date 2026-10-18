import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_state/core/api_error_message.dart';
import 'package:flutter_state/data/federative_unit.dart';
import 'package:flutter_state/providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../support/app_harness.dart';
import '../support/fakes.dart';
import '../support/mocks.dart';

void main() {
  late MockStateRepository repository;

  final abbreviation = find.byKey(const Key('abbreviation'));
  final name = find.byKey(const Key('name'));
  final save = find.byKey(const Key('save'));
  final sp = unit(id: 3);

  List<Override> overrides() => [
    stateRepositoryProvider.overrideWithValue(repository),
  ];

  AppHarness signedIn() => AppHarness(token: fakeJwt(), overrides: overrides());

  setUpAll(registerFallbacks);

  setUp(() {
    repository = MockStateRepository();
    when(
      () => repository.list(
        search: any(named: 'search'),
        sort: any(named: 'sort'),
      ),
    ).thenAnswer((_) async => [sp]);
  });

  group('create', () {
    Future<void> fillAndSave(WidgetTester tester) async {
      await tester.enterText(abbreviation, 'mg');
      await tester.enterText(name, 'Minas Gerais');
      await tester.pump();
      await tester.tap(save);
      await tester.pumpAndSettle();
    }

    testWidgets('renders the form under a "New state" heading', (tester) async {
      await signedIn().pump(tester, location: '/state/new');
      expect(find.text('New state'), findsWidgets);
      expect(abbreviation, findsOneWidget);
    });

    testWidgets('creates the state and goes back to the list', (tester) async {
      when(() => repository.create(any())).thenAnswer((_) async => unit(id: 9));
      final harness = signedIn();
      await harness.pump(tester); // list first, so there is a stack to pop
      await tester.tap(find.byKey(const Key('new-state')));
      await tester.pumpAndSettle();

      await fillAndSave(tester);

      final created =
          verify(() => repository.create(captureAny())).captured.single
              as NewFederativeUnit;
      expect(created.abbreviation, 'MG');
      expect(created.name, 'Minas Gerais');
      expect(abbreviation, findsNothing);
      expect(find.byKey(const Key('search')), findsOneWidget);
    });

    testWidgets('opened cold (nothing to go back to) it lands on the list', (
      tester,
    ) async {
      when(() => repository.create(any())).thenAnswer((_) async => unit(id: 9));
      await signedIn().pump(tester, location: '/state/new');

      await fillAndSave(tester);

      expect(find.byKey(const Key('search')), findsOneWidget);
    });

    testWidgets('blocks an abbreviation that is already in the list', (
      tester,
    ) async {
      await signedIn().pump(tester, location: '/state/new');
      await tester.enterText(abbreviation, 'SP');
      await tester.enterText(name, 'Another');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(
        find.text('A state with this abbreviation already exists.'),
        findsOneWidget,
      );
    });

    testWidgets('stays and shows an error when creation fails', (tester) async {
      when(() => repository.create(any())).thenThrow(serverError('/estado/'));
      await signedIn().pump(tester, location: '/state/new');

      await fillAndSave(tester);

      expect(find.text('Failed to create state.'), findsOneWidget);
      expect(abbreviation, findsOneWidget);
    });

    testWidgets('says the API is unavailable when there is no response', (
      tester,
    ) async {
      when(() => repository.create(any())).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/estado/')),
      );
      await signedIn().pump(tester, location: '/state/new');

      await fillAndSave(tester);

      expect(find.text(apiUnavailableMessage), findsOneWidget);
    });

    testWidgets('meets the tap target, label and contrast rules', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await signedIn().pump(tester, location: '/state/new');
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  group('edit', () {
    setUp(() {
      when(() => repository.get(3)).thenAnswer((_) async => sp);
    });

    TextField field(WidgetTester tester, Finder finder) =>
        tester.widget<TextField>(finder);

    testWidgets('loads the unit and prefills the form', (tester) async {
      await signedIn().pump(tester, location: '/state/3/edit');
      verify(() => repository.get(3)).called(1);
      expect(field(tester, abbreviation).controller!.text, 'SP');
      expect(field(tester, name).controller!.text, 'São Paulo');
    });

    testWidgets('saves the merged unit and goes back', (tester) async {
      when(() => repository.update(any())).thenAnswer((_) async => sp);
      await signedIn().pump(tester, location: '/state/3/edit');

      await tester.enterText(name, 'São Paulo Capital');
      await tester.pump();
      await tester.tap(save);
      await tester.pumpAndSettle();

      final updated =
          verify(() => repository.update(captureAny())).captured.single
              as FederativeUnit;
      expect(updated.id, 3);
      expect(updated.name, 'São Paulo Capital');
      expect(updated.abbreviation, 'SP');
      expect(abbreviation, findsNothing);
    });

    testWidgets('shows an error when saving fails', (tester) async {
      when(() => repository.update(any())).thenThrow(serverError('/estado/3'));
      await signedIn().pump(tester, location: '/state/3/edit');
      await tester.enterText(name, 'São Paulo!');
      await tester.pump();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.text('Failed to update state.'), findsOneWidget);
    });

    testWidgets('shows an error when the unit cannot be loaded', (
      tester,
    ) async {
      when(() => repository.get(3)).thenThrow(serverError('/estado/3'));
      await signedIn().pump(tester, location: '/state/3/edit');
      expect(find.text('Failed to fetch state.'), findsOneWidget);
    });

    for (final id in ['abc', '0', '-2', '1.5']) {
      testWidgets('rejects id "$id" without calling the API', (tester) async {
        await signedIn().pump(tester, location: '/state/$id/edit');
        expect(find.text('Invalid state.'), findsOneWidget);
        verifyNever(() => repository.get(any()));
      });
    }
  });
}
