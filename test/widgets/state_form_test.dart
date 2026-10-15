import 'package:flutter/material.dart';
import 'package:flutter_state/data/federative_unit.dart';
import 'package:flutter_state/widgets/state_form.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

final abbreviation = find.byKey(const Key('abbreviation'));
final name = find.byKey(const Key('name'));
final save = find.byKey(const Key('save'));

bool saveEnabled(WidgetTester tester) =>
    tester.widget<FilledButton>(save).onPressed != null;

Future<void> blur(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();
}

void main() {
  Widget form({
    NewFederativeUnit? initialValues,
    bool disabled = false,
    List<String> existing = const [],
    ValueChanged<NewFederativeUnit>? onSubmit,
  }) => StateForm(
    initialValues: initialValues,
    disabled: disabled,
    existingAbbreviations: existing,
    onSubmit: onSubmit ?? (_) {},
  );

  testWidgets('keeps Save disabled while the form is invalid', (tester) async {
    await pumpWidgetUnderTest(tester, form());
    expect(saveEnabled(tester), isFalse);
  });

  testWidgets('enables Save when abbreviation and name are valid', (
    tester,
  ) async {
    await pumpWidgetUnderTest(tester, form());
    await tester.enterText(abbreviation, 'SP');
    await tester.enterText(name, 'Sao Paulo');
    await tester.pump();
    expect(saveEnabled(tester), isTrue);
  });

  testWidgets('upper-cases the abbreviation as the user types', (tester) async {
    await pumpWidgetUnderTest(tester, form());
    await tester.enterText(abbreviation, 'sp');
    await tester.pump();
    expect(tester.widget<TextField>(abbreviation).controller!.text, 'SP');
  });

  testWidgets('limits the abbreviation to 2 characters', (tester) async {
    await pumpWidgetUnderTest(tester, form());
    await tester.enterText(abbreviation, 'SPX');
    await tester.pump();
    expect(tester.widget<TextField>(abbreviation).controller!.text, 'SP');
  });

  testWidgets('asks the keyboard for capitals on the abbreviation', (
    tester,
  ) async {
    await pumpWidgetUnderTest(tester, form());
    expect(
      tester.widget<TextField>(abbreviation).textCapitalization,
      TextCapitalization.characters,
    );
  });

  testWidgets('shows no error before a field has been left', (tester) async {
    await pumpWidgetUnderTest(tester, form());
    await tester.enterText(abbreviation, 'S');
    await tester.pump();
    expect(
      find.text('Enter the state abbreviation with 2 letters.'),
      findsNothing,
    );
  });

  testWidgets('flags the abbreviation once the field loses focus', (
    tester,
  ) async {
    await pumpWidgetUnderTest(tester, form());
    await tester.enterText(abbreviation, 'S');
    await blur(tester);
    expect(
      find.text('Enter the state abbreviation with 2 letters.'),
      findsOneWidget,
    );
  });

  testWidgets('then revalidates on every keystroke', (tester) async {
    await pumpWidgetUnderTest(tester, form());
    await tester.enterText(abbreviation, 'S');
    await blur(tester);
    await tester.enterText(abbreviation, 'SP');
    await tester.pump();
    expect(
      find.text('Enter the state abbreviation with 2 letters.'),
      findsNothing,
    );
  });

  testWidgets('shows the min and max name messages', (tester) async {
    await pumpWidgetUnderTest(tester, form());
    await tester.enterText(name, 'AB');
    await blur(tester);
    expect(
      find.text('Enter the state name with at least 3 characters.'),
      findsOneWidget,
    );

    await tester.enterText(name, 'A' * 101);
    await tester.pump();
    expect(
      find.text('Enter the state name with at most 100 characters.'),
      findsOneWidget,
    );
  });

  testWidgets('rejects an abbreviation that already exists', (tester) async {
    await pumpWidgetUnderTest(tester, form(existing: const ['SP']));
    await tester.enterText(abbreviation, 'SP');
    await tester.enterText(name, 'Another');
    await blur(tester);
    expect(
      find.text('A state with this abbreviation already exists.'),
      findsOneWidget,
    );
    expect(saveEnabled(tester), isFalse);
  });

  testWidgets('prefills initial values; Save waits for a change', (
    tester,
  ) async {
    await pumpWidgetUnderTest(
      tester,
      form(
        initialValues: const NewFederativeUnit(
          abbreviation: 'SP',
          name: 'Sao Paulo',
        ),
        existing: const ['SP'],
      ),
    );
    expect(tester.widget<TextField>(abbreviation).controller!.text, 'SP');
    expect(tester.widget<TextField>(name).controller!.text, 'Sao Paulo');
    expect(saveEnabled(tester), isFalse);

    await tester.enterText(name, 'Sao Paulo!');
    await tester.pump();
    expect(saveEnabled(tester), isTrue);
  });

  testWidgets('is disabled while the parent says a request is in flight', (
    tester,
  ) async {
    await pumpWidgetUnderTest(tester, form(disabled: true));
    await tester.enterText(abbreviation, 'SP');
    await tester.enterText(name, 'Sao Paulo');
    await tester.pump();
    expect(saveEnabled(tester), isFalse);
  });

  testWidgets('submits the trimmed, normalised values', (tester) async {
    NewFederativeUnit? submitted;
    await pumpWidgetUnderTest(tester, form(onSubmit: (v) => submitted = v));
    await tester.enterText(abbreviation, 'sp');
    await tester.enterText(name, '  Sao Paulo  ');
    await tester.pump();
    await tester.tap(save);
    await tester.pump();
    expect(submitted?.abbreviation, 'SP');
    expect(submitted?.name, 'Sao Paulo');
  });
}
