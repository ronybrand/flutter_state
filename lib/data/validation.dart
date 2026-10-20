// The same validation rules as the web clients' schema.

enum StateValidationError {
  abbreviationLength,
  abbreviationFormat,
  duplicateAbbreviation,
  nameTooShort,
  nameTooLong,
}

String normalizeAbbreviation(String raw) => raw.trim().toUpperCase();

/// Returns the validation failure, or null when the value is valid.
///
/// [existing] are the abbreviations already registered; [current] is the one
/// the unit being edited already owns (it may keep it).
StateValidationError? validateAbbreviation(
  String? raw, {
  List<String> existing = const [],
  String? current,
}) {
  final value = normalizeAbbreviation(raw ?? '');
  if (value.length != 2) {
    return StateValidationError.abbreviationLength;
  }
  if (!RegExp(r'^[A-Z]{2}$').hasMatch(value)) {
    return StateValidationError.abbreviationFormat;
  }
  if (value != current && existing.contains(value)) {
    return StateValidationError.duplicateAbbreviation;
  }
  return null;
}

StateValidationError? validateName(String? raw) {
  final value = (raw ?? '').trim();
  if (value.length < 3) {
    return StateValidationError.nameTooShort;
  }
  if (value.length > 100) {
    return StateValidationError.nameTooLong;
  }
  return null;
}
