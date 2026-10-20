import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_locale.dart';
import 'l10n/generated/app_localizations.dart';
import 'router.dart';
import 'theme.dart';

class EstadosApp extends ConsumerWidget {
  const EstadosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: ref.watch(localeProvider),
      supportedLocales: supportedAppLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
