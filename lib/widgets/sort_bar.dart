import 'package:flutter/material.dart';

import '../state/states_providers.dart';
import '../theme.dart';

class SortBar extends StatelessWidget {
  const SortBar({required this.sort, required this.onSort, super.key});

  final SortState sort;
  final ValueChanged<SortField> onSort;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        const Text('Sort by', style: TextStyle(color: AppColors.muted)),
        for (final field in SortField.values) _chip(field),
      ],
    );
  }

  Widget _chip(SortField field) {
    final selected = sort.field == field;
    final ascending = sort.direction == SortDirection.asc;
    final direction = ascending ? 'ascending' : 'descending';
    return Semantics(
      button: true,
      selected: selected,
      // Read as "Name, ascending": the visual arrow alone says nothing to a
      // screen reader.
      label: selected ? '${field.label}, $direction' : field.label,
      excludeSemantics: true,
      child: ChoiceChip(
        label: Text(field.label),
        selected: selected,
        avatar: selected
            ? Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward)
            : null,
        onSelected: (_) => onSort(field),
      ),
    );
  }
}
