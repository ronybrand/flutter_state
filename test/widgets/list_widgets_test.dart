import 'package:flutter/material.dart';
import 'package:flutter_state/state/states_providers.dart';
import 'package:flutter_state/widgets/sort_bar.dart';
import 'package:flutter_state/widgets/state_list_item.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/mocks.dart';
import '../support/pump.dart';

void main() {
  group('SortBar', () {
    testWidgets('offers both fields, none selected at first', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        SortBar(sort: const SortState(), onSort: (_) {}),
      );
      final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip));
      expect(chips, hasLength(2));
      expect(chips.every((c) => !c.selected), isTrue);
      expect(find.text('Abbreviation'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('reports which field was pressed', (tester) async {
      final pressed = <SortField>[];
      await pumpWidgetUnderTest(
        tester,
        SortBar(sort: const SortState(), onSort: pressed.add),
      );
      await tester.tap(find.text('Abbreviation'));
      await tester.tap(find.text('Name'));
      expect(pressed, [SortField.abbreviation, SortField.name]);
    });

    testWidgets('marks the active field and shows the direction', (
      tester,
    ) async {
      await pumpWidgetUnderTest(
        tester,
        SortBar(
          sort: const SortState(
            field: SortField.abbreviation,
            direction: SortDirection.desc,
          ),
          onSort: (_) {},
        ),
      );
      final chips = tester
          .widgetList<ChoiceChip>(find.byType(ChoiceChip))
          .toList();
      expect(chips[0].selected, isTrue);
      expect(chips[1].selected, isFalse);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('says the direction out loud to screen readers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpWidgetUnderTest(
        tester,
        SortBar(
          sort: const SortState(field: SortField.name),
          onSort: (_) {},
        ),
      );
      expect(find.bySemanticsLabel(RegExp('Name.*ascending')), findsOneWidget);
      handle.dispose();
    });
  });

  group('StateListItem', () {
    final item = unit(
      id: 7,
      name: 'São Paulo',
      abbreviation: 'SP',
      createdAt: DateTime(2026, 1, 2, 3, 4, 5),
    );

    testWidgets('shows abbreviation, name and dates', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        StateListItem(unit: item, onEdit: (_) {}, onDelete: (_) {}),
      );
      expect(find.text('SP'), findsOneWidget);
      expect(find.text('São Paulo'), findsOneWidget);
      expect(find.text('Created: 01/02/2026, 03:04:05 AM'), findsOneWidget);
      expect(find.text('Updated: -'), findsOneWidget);
    });

    testWidgets('has per-row actions labelled with the abbreviation', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      FederativeUnitCalls calls = FederativeUnitCalls();
      await pumpWidgetUnderTest(
        tester,
        StateListItem(
          unit: item,
          onEdit: (u) => calls.edited = u,
          onDelete: (u) => calls.deleted = u,
        ),
      );
      await tester.tap(find.bySemanticsLabel('Edit SP'));
      await tester.tap(find.bySemanticsLabel('Delete SP'));
      expect(calls.edited, item);
      expect(calls.deleted, item);
      handle.dispose();
    });

    testWidgets('disables delete while a deletion is running', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        StateListItem(
          unit: item,
          onEdit: (_) {},
          onDelete: (_) {},
          deleting: true,
        ),
      );
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('delete-7')))
            .onPressed,
        isNull,
      );
    });
  });
}

class FederativeUnitCalls {
  Object? edited;
  Object? deleted;
}
