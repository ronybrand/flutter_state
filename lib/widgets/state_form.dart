import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/federative_unit.dart';
import '../data/validation.dart';
import '../l10n/generated/app_localizations.dart';

class _UpperCase extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}

/// Create/edit form. Errors appear once a field has been left, then follow every
/// keystroke (the "onTouched" behaviour of the web clients). Save stays disabled
/// until the form is valid and changed.
class StateForm extends StatefulWidget {
  const StateForm({
    required this.onSubmit,
    this.initialValues,
    this.disabled = false,
    this.existingAbbreviations = const [],
    super.key,
  });

  final NewFederativeUnit? initialValues;
  final bool disabled;
  final List<String> existingAbbreviations;
  final ValueChanged<NewFederativeUnit> onSubmit;

  @override
  State<StateForm> createState() => _StateFormState();
}

class _StateFormState extends State<StateForm> {
  late final TextEditingController _abbreviation;
  late final TextEditingController _name;
  final _abbreviationFocus = FocusNode();
  final _nameFocus = FocusNode();
  bool _abbreviationTouched = false;
  bool _nameTouched = false;

  @override
  void initState() {
    super.initState();
    _abbreviation = TextEditingController(
      text: widget.initialValues?.abbreviation ?? '',
    );
    _name = TextEditingController(text: widget.initialValues?.name ?? '');
    for (final controller in [_abbreviation, _name]) {
      controller.addListener(() => setState(() {}));
    }
    _abbreviationFocus.addListener(() {
      if (!_abbreviationFocus.hasFocus) {
        setState(() => _abbreviationTouched = true);
      }
    });
    _nameFocus.addListener(() {
      if (!_nameFocus.hasFocus) setState(() => _nameTouched = true);
    });
  }

  @override
  void dispose() {
    _abbreviation.dispose();
    _name.dispose();
    _abbreviationFocus.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  StateValidationError? get _abbreviationError => validateAbbreviation(
    _abbreviation.text,
    existing: widget.existingAbbreviations,
    current: widget.initialValues?.abbreviation,
  );

  StateValidationError? get _nameError => validateName(_name.text);

  bool get _isDirty =>
      _abbreviation.text != (widget.initialValues?.abbreviation ?? '') ||
      _name.text != (widget.initialValues?.name ?? '');

  bool get _canSave =>
      _abbreviationError == null &&
      _nameError == null &&
      _isDirty &&
      !widget.disabled;

  void _submit() => widget.onSubmit(
    NewFederativeUnit(
      abbreviation: normalizeAbbreviation(_abbreviation.text),
      name: _name.text.trim(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final abbreviationError = switch (_abbreviationError) {
      StateValidationError.abbreviationLength =>
        strings.abbreviationLengthError,
      StateValidationError.abbreviationFormat =>
        strings.abbreviationFormatError,
      StateValidationError.duplicateAbbreviation =>
        strings.duplicateAbbreviationError,
      _ => null,
    };
    final nameError = switch (_nameError) {
      StateValidationError.nameTooShort => strings.nameMinLengthError,
      StateValidationError.nameTooLong => strings.nameMaxLengthError,
      _ => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('abbreviation'),
          controller: _abbreviation,
          focusNode: _abbreviationFocus,
          textCapitalization: TextCapitalization.characters,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          inputFormatters: [_UpperCase(), LengthLimitingTextInputFormatter(2)],
          decoration: InputDecoration(
            labelText: strings.abbreviation,
            errorText: _abbreviationTouched ? abbreviationError : null,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('name'),
          controller: _name,
          focusNode: _nameFocus,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: strings.name,
            hintText: strings.nameHint,
            errorText: _nameTouched ? nameError : null,
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            key: const Key('save'),
            onPressed: _canSave ? _submit : null,
            icon: const Icon(Icons.check, size: 18),
            label: Text(strings.save),
          ),
        ),
      ],
    );
  }
}
