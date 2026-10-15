import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_state/data/federative_unit.dart';
import 'package:flutter_state/providers.dart';
import 'package:flutter_state/state/states_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../support/mocks.dart';

void main() {
  late MockStateRepository repository;

  ProviderContainer containerFor() {
    final container = ProviderContainer(
      // The HTTP client already retries; Riverpod must not retry on top of it.
      retry: (_, _) => null,
      overrides: [stateRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUpAll(registerFallbacks);

  setUp(() {
    repository = MockStateRepository();
    when(
      () => repository.list(
        search: any(named: 'search'),
        sort: any(named: 'sort'),
      ),
    ).thenAnswer((_) async => [unit(), unit(id: 2, abbreviation: 'RJ')]);
  });

  group('statesProvider', () {
    test('loads the list with no filter and no ordering at first', () async {
      final container = containerFor();
      final units = await container.read(statesProvider.future);
      expect(units.map((u) => u.abbreviation), ['SP', 'RJ']);
      verify(() => repository.list(search: null, sort: null)).called(1);
    });

    test('a new search is sent as the filter', () async {
      final container = containerFor();
      await container.read(statesProvider.future);

      container.read(searchProvider.notifier).set('rio');
      await container.read(statesProvider.future);

      verify(() => repository.list(search: 'rio', sort: null)).called(1);
    });

    test('an emptied search goes back to no filter', () async {
      final container = containerFor();
      container.read(searchProvider.notifier).set('rio');
      await container.read(statesProvider.future);

      container.read(searchProvider.notifier).set('');
      await container.read(statesProvider.future);

      verify(() => repository.list(search: null, sort: null)).called(1);
    });

    test('keeps the previous rows while a new search loads', () async {
      final container = containerFor();
      container.listen(statesProvider, (_, _) {});
      await container.read(statesProvider.future);
      final pending = Completer<List<FederativeUnit>>();
      when(
        () => repository.list(
          search: any(named: 'search'),
          sort: any(named: 'sort'),
        ),
      ).thenAnswer((_) => pending.future);

      container.read(searchProvider.notifier).set('rio');
      await Future<void>.delayed(Duration.zero);

      final state = container.read(statesProvider);
      expect(state.isLoading, isTrue);
      expect(state.value, hasLength(2), reason: 'rows stay on screen');
      pending.complete([]);
    });

    test('surfaces a failure as an error', () async {
      when(
        () => repository.list(
          search: any(named: 'search'),
          sort: any(named: 'sort'),
        ),
      ).thenThrow(Exception('boom'));
      final container = containerFor();
      container.listen(statesProvider, (_, _) {});

      await expectLater(
        container.read(statesProvider.future),
        throwsA(isA<Exception>()),
      );
      expect(container.read(statesProvider).hasError, isTrue);
    });
  });

  group('sortProvider', () {
    test('starts unsorted', () {
      final sort = containerFor().read(sortProvider);
      expect(sort.field, isNull);
      expect(sort.wire, isNull);
    });

    test('a first press sorts ascending, a second one toggles', () {
      final container = containerFor();
      final notifier = container.read(sortProvider.notifier);

      notifier.toggle(SortField.name);
      expect(container.read(sortProvider).wire, 'nome,asc');
      notifier.toggle(SortField.name);
      expect(container.read(sortProvider).wire, 'nome,desc');
      notifier.toggle(SortField.name);
      expect(container.read(sortProvider).wire, 'nome,asc');
    });

    test('another field starts ascending again', () {
      final container = containerFor();
      final notifier = container.read(sortProvider.notifier);
      notifier
        ..toggle(SortField.name)
        ..toggle(SortField.name)
        ..toggle(SortField.abbreviation);
      expect(container.read(sortProvider).wire, 'sigla,asc');
    });

    test('is sent to the repository as the wire value', () async {
      final container = containerFor();
      await container.read(statesProvider.future);

      container.read(sortProvider.notifier).toggle(SortField.abbreviation);
      await container.read(statesProvider.future);

      verify(() => repository.list(search: null, sort: 'sigla,asc')).called(1);
    });
  });

  group('federativeUnitProvider', () {
    test('fetches one unit by id', () async {
      when(() => repository.get(7)).thenAnswer((_) async => unit(id: 7));
      final loaded = await containerFor().read(
        federativeUnitProvider(7).future,
      );
      expect(loaded.id, 7);
    });
  });

  group('stateActionsProvider (mutations invalidate the list)', () {
    test('create posts and refetches the list', () async {
      when(() => repository.create(any())).thenAnswer((_) async => unit(id: 9));
      final container = containerFor();
      container.listen(statesProvider, (_, _) {});
      await container.read(statesProvider.future);

      await container
          .read(stateActionsProvider)
          .create(const NewFederativeUnit(abbreviation: 'MG', name: 'Minas'));
      await container.read(statesProvider.future);

      verify(() => repository.create(any())).called(1);
      verify(() => repository.list(search: null, sort: null)).called(2);
    });

    test('update puts and refetches both the list and the unit', () async {
      when(() => repository.update(any())).thenAnswer((_) async => unit());
      when(() => repository.get(1)).thenAnswer((_) async => unit());
      final container = containerFor();
      container
        ..listen(statesProvider, (_, _) {})
        ..listen(federativeUnitProvider(1), (_, _) {});
      await container.read(statesProvider.future);
      await container.read(federativeUnitProvider(1).future);

      await container.read(stateActionsProvider).update(unit());
      await container.read(statesProvider.future);
      await container.read(federativeUnitProvider(1).future);

      verify(() => repository.list(search: null, sort: null)).called(2);
      verify(() => repository.get(1)).called(2);
    });

    test('delete removes and refetches the list', () async {
      when(() => repository.delete(1)).thenAnswer((_) async {});
      final container = containerFor();
      container.listen(statesProvider, (_, _) {});
      await container.read(statesProvider.future);

      await container.read(stateActionsProvider).delete(1);
      await container.read(statesProvider.future);

      verify(() => repository.delete(1)).called(1);
      verify(() => repository.list(search: null, sort: null)).called(2);
    });

    test('a failing mutation rethrows and does not refetch', () async {
      when(() => repository.delete(1)).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/estado/1')),
      );
      final container = containerFor();
      container.listen(statesProvider, (_, _) {});
      await container.read(statesProvider.future);

      await expectLater(
        container.read(stateActionsProvider).delete(1),
        throwsA(isA<DioException>()),
      );
      verify(() => repository.list(search: null, sort: null)).called(1);
    });
  });
}
