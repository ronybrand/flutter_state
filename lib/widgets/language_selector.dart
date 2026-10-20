import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_locale.dart';
import '../l10n/generated/app_localizations.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  Future<void> _selectLocale(
    BuildContext context,
    WidgetRef ref,
    Locale locale,
    AppLocalizations strings,
  ) async {
    try {
      await ref.read(localeProvider.notifier).setLocale(locale);
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(strings.languageSaveError)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final selectedLocale = ref.watch(localeProvider);
    final currentLanguage =
        selectedLocale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return PopupMenuButton<Locale>(
      key: const Key('language-selector'),
      tooltip: strings.languageSwitchLabel,
      icon: const Icon(Icons.language),
      onSelected: (locale) => _selectLocale(context, ref, locale, strings),
      itemBuilder: (context) => [
        CheckedPopupMenuItem(
          value: const Locale('pt'),
          checked: currentLanguage == 'pt',
          child: Text(strings.languagePortuguese),
        ),
        CheckedPopupMenuItem(
          value: const Locale('en'),
          checked: currentLanguage == 'en',
          child: Text(strings.languageEnglish),
        ),
      ],
    );
  }
}
