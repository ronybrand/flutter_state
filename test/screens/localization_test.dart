import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';

void main() {
  testWidgets('changes the app language and persists the selection', (
    tester,
  ) async {
    final harness = AppHarness();
    await harness.pump(tester, location: '/login');
    expect(find.text('Username'), findsOneWidget);

    await tester.tap(find.byKey(const Key('language-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Português'));
    await tester.pumpAndSettle();

    expect(find.text('Usuário'), findsOneWidget);
    expect(harness.localePreferences.language, 'pt');

    await harness.pump(tester, location: '/login');
    expect(find.text('Usuário'), findsOneWidget);
  });

  testWidgets(
    'reports a failed language preference save and keeps current UI',
    (tester) async {
      final harness = AppHarness()..localePreferences.failWrites = true;
      await harness.pump(tester, location: '/login');

      await tester.tap(find.byKey(const Key('language-selector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Português'));
      await tester.pumpAndSettle();

      expect(find.text('Username'), findsOneWidget);
      expect(
        find.text('Could not save the language preference.'),
        findsOneWidget,
      );
    },
  );
}
