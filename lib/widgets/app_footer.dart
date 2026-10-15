import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/format_date.dart';
import '../providers.dart';
import '../theme.dart';

class AppFooter extends ConsumerWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionProvider).value;
    final backend = ref.watch(backendInfoProvider).value;
    const style = TextStyle(fontSize: 11, color: AppColors.muted);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        children: [
          if (version != null) Text('app $version', style: style),
          if (version != null && backend != null) const Text('|', style: style),
          if (backend != null)
            Text(
              'back ${backend.commit} · ${formatDate(backend.time)}',
              style: style,
            ),
        ],
      ),
    );
  }
}
