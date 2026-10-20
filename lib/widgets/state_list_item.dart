import 'package:flutter/material.dart';

import '../core/format_date.dart';
import '../data/federative_unit.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme.dart';

class StateListItem extends StatelessWidget {
  const StateListItem({
    required this.unit,
    required this.onEdit,
    required this.onDelete,
    this.deleting = false,
    super.key,
  });

  final FederativeUnit unit;
  final ValueChanged<FederativeUnit> onEdit;
  final ValueChanged<FederativeUnit> onDelete;
  final bool deleting;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    const meta = TextStyle(fontSize: 12, color: AppColors.muted);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  unit.abbreviation,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brand,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(unit.name, style: const TextStyle(fontSize: 17)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              strings.created(formatDate(unit.createdAt, locale: locale)),
              style: meta,
            ),
            Text(
              strings.updated(formatDate(unit.updatedAt, locale: locale)),
              style: meta,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Semantics(
                  label: strings.editState(unit.abbreviation),
                  button: true,
                  excludeSemantics: true,
                  child: FilledButton.icon(
                    key: Key('edit-${unit.id}'),
                    onPressed: () => onEdit(unit),
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text(strings.edit),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  label: strings.deleteState(unit.abbreviation),
                  button: true,
                  excludeSemantics: true,
                  child: FilledButton.icon(
                    key: Key('delete-${unit.id}'),
                    onPressed: deleting ? null : () => onDelete(unit),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.danger,
                    ),
                    icon: const Icon(Icons.delete, size: 18),
                    label: Text(strings.delete),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
