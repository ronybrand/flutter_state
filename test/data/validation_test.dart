import 'package:flutter_state/data/validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateAbbreviation', () {
    test('accepts two letters, any case, around whitespace', () {
      expect(validateAbbreviation('SP'), isNull);
      expect(validateAbbreviation('sp'), isNull);
      expect(validateAbbreviation(' sp '), isNull);
    });

    test('asks for 2 letters when the length is wrong', () {
      expect(
        validateAbbreviation(null),
        StateValidationError.abbreviationLength,
      );
      expect(validateAbbreviation(''), StateValidationError.abbreviationLength);
      expect(
        validateAbbreviation('S'),
        StateValidationError.abbreviationLength,
      );
      expect(
        validateAbbreviation('SPX'),
        StateValidationError.abbreviationLength,
      );
    });

    test('asks for uppercase letters when the characters are wrong', () {
      expect(
        validateAbbreviation('S1'),
        StateValidationError.abbreviationFormat,
      );
      expect(
        validateAbbreviation('--'),
        StateValidationError.abbreviationFormat,
      );
    });

    test('rejects an abbreviation that already exists', () {
      expect(
        validateAbbreviation('sp', existing: const ['SP', 'RJ']),
        StateValidationError.duplicateAbbreviation,
      );
    });

    test('the unit being edited may keep its own abbreviation', () {
      expect(
        validateAbbreviation('SP', existing: const ['SP'], current: 'SP'),
        isNull,
      );
    });

    test('another unit may not take it even while editing', () {
      expect(
        validateAbbreviation('RJ', existing: const ['SP', 'RJ'], current: 'SP'),
        StateValidationError.duplicateAbbreviation,
      );
    });
  });

  group('validateName', () {
    test('accepts 3 to 100 characters after trimming', () {
      expect(validateName('Rio'), isNull);
      expect(validateName('  Rio  '), isNull);
      expect(validateName('A' * 100), isNull);
    });

    test('asks for at least 3 characters', () {
      expect(validateName(null), StateValidationError.nameTooShort);
      expect(validateName(''), StateValidationError.nameTooShort);
      expect(validateName('  AB  '), StateValidationError.nameTooShort);
    });

    test('asks for at most 100 characters', () {
      expect(validateName('A' * 101), StateValidationError.nameTooLong);
    });
  });

  test('normalizeAbbreviation trims and upper-cases', () {
    expect(normalizeAbbreviation('  sp '), 'SP');
  });
}
