import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../state/states_providers.dart';
import '../theme.dart';

class SortBar extends StatelessWidget {
  const SortBar({required this.sort, required this.onSort, super.key});

  final SortState sort;
  final ValueChanged<SortField> onSort;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final abbreviation = strings.sortAbbreviation;
    final name = strings.sortName;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        Text(strings.sortBy, style: const TextStyle(color: AppColors.muted)),
        for (final field in SortField.values)
          _chip(
            field,
            field == SortField.abbreviation ? abbreviation : name,
            sort.direction == SortDirection.asc
                ? strings.sortAscending
                : strings.sortDescending,
          ),
      ],
    );
  }

  Widget _chip(SortField field, String label, String direction) {
    final selected = sort.field == field;
    final ascending = sort.direction == SortDirection.asc;
    return Semantics(
      button: true,
      selected: selected,
      // Read as "Name, ascending": the visual arrow alone says nothing to a
      // screen reader.
      label: selected ? '$label, $direction' : label,
      excludeSemantics: true,
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        avatar: selected
            ? Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward)
            : null,
        onSelected: (_) => onSort(field),
      ),
    );
  }
}
