import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/federative_unit.dart';
import '../providers.dart';

/// The wire values are the backend's `sort` contract (sigla, nome); the labels
/// are what the user reads.
enum SortField {
  abbreviation('sigla'),
  name('nome');

  const SortField(this.wire);

  final String wire;
}

enum SortDirection { asc, desc }

class SortState {
  const SortState({this.field, this.direction = SortDirection.asc});

  final SortField? field;
  final SortDirection direction;

  /// `nome,asc`, or null when nothing is sorted (the backend then applies no
  /// explicit ordering).
  String? get wire => field == null ? null : '${field!.wire},${direction.name}';
}

final searchProvider = NotifierProvider<SearchNotifier, String>(
  SearchNotifier.new,
);

class SearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final sortProvider = NotifierProvider<SortNotifier, SortState>(
  SortNotifier.new,
);

class SortNotifier extends Notifier<SortState> {
  @override
  SortState build() => const SortState();

  /// Pressing the active field flips the direction; another field starts
  /// ascending.
  void toggle(SortField field) {
    if (state.field == field) {
      state = SortState(
        field: field,
        direction: state.direction == SortDirection.asc
            ? SortDirection.desc
            : SortDirection.asc,
      );
    } else {
      state = SortState(field: field);
    }
  }
}

/// Watching the search and sort providers makes this rebuild when they change.
/// A rebuild keeps the previous value while it loads (`isLoading` with a
/// `value`), so the rows stay on screen instead of flashing a spinner on every
/// keystroke.
final statesProvider =
    AsyncNotifierProvider<StatesNotifier, List<FederativeUnit>>(
      StatesNotifier.new,
    );

class StatesNotifier extends AsyncNotifier<List<FederativeUnit>> {
  @override
  Future<List<FederativeUnit>> build() {
    final search = ref.watch(searchProvider);
    final sort = ref.watch(sortProvider).wire;
    return ref
        .watch(stateRepositoryProvider)
        .list(search: search.isEmpty ? null : search, sort: sort);
  }
}

final federativeUnitProvider = FutureProvider.family<FederativeUnit, int>(
  (ref, id) => ref.watch(stateRepositoryProvider).get(id),
);

final stateActionsProvider = Provider<StateActions>(StateActions.new);

/// Every mutation invalidates the list and any open detail, so they refetch.
class StateActions {
  StateActions(this._ref);

  final Ref _ref;

  Future<FederativeUnit> create(NewFederativeUnit unit) async {
    final created = await _ref.read(stateRepositoryProvider).create(unit);
    _invalidate();
    return created;
  }

  Future<FederativeUnit> update(FederativeUnit unit) async {
    final updated = await _ref.read(stateRepositoryProvider).update(unit);
    _invalidate();
    return updated;
  }

  Future<void> delete(int id) async {
    await _ref.read(stateRepositoryProvider).delete(id);
    _invalidate();
  }

  void _invalidate() {
    _ref
      ..invalidate(statesProvider)
      ..invalidate(federativeUnitProvider);
  }
}
