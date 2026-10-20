import 'package:flutter/material.dart';
import 'package:flutter_state/core/app_locale.dart';
import 'package:flutter_state/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// A single widget on its own, with a Material shell around it.
Future<void> pumpWidgetUnderTest(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      supportedLocales: supportedAppLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}
