// The same rules and messages as the web clients' zod schema.

String normalizeAbbreviation(String raw) => raw.trim().toUpperCase();

/// Returns the message to show, or null when the value is valid.
///
/// [existing] are the abbreviations already registered; [current] is the one
/// the unit being edited already owns (it may keep it).
String? validateAbbreviation(
  String? raw, {
  List<String> existing = const [],
  String? current,
}) {
  final value = normalizeAbbreviation(raw ?? '');
  if (value.length != 2) {
    return 'Enter the state abbreviation with 2 letters.';
  }
  if (!RegExp(r'^[A-Z]{2}$').hasMatch(value)) {
    return 'Enter the state abbreviation with 2 uppercase letters.';
  }
  if (value != current && existing.contains(value)) {
    return 'A state with this abbreviation already exists.';
  }
  return null;
}

String? validateName(String? raw) {
  final value = (raw ?? '').trim();
  if (value.length < 3) {
    return 'Enter the state name with at least 3 characters.';
  }
  if (value.length > 100) {
    return 'Enter the state name with at most 100 characters.';
  }
  return null;
}
