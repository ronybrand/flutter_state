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
      const message = 'Enter the state abbreviation with 2 letters.';
      expect(validateAbbreviation(null), message);
      expect(validateAbbreviation(''), message);
      expect(validateAbbreviation('S'), message);
      expect(validateAbbreviation('SPX'), message);
    });

    test('asks for uppercase letters when the characters are wrong', () {
      const message = 'Enter the state abbreviation with 2 uppercase letters.';
      expect(validateAbbreviation('S1'), message);
      expect(validateAbbreviation('--'), message);
    });

    test('rejects an abbreviation that already exists', () {
      expect(
        validateAbbreviation('sp', existing: const ['SP', 'RJ']),
        'A state with this abbreviation already exists.',
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
        'A state with this abbreviation already exists.',
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
      const message = 'Enter the state name with at least 3 characters.';
      expect(validateName(null), message);
      expect(validateName(''), message);
      expect(validateName('  AB  '), message);
    });

    test('asks for at most 100 characters', () {
      expect(
        validateName('A' * 101),
        'Enter the state name with at most 100 characters.',
      );
    });
  });

  test('normalizeAbbreviation trims and upper-cases', () {
    expect(normalizeAbbreviation('  sp '), 'SP');
  });
}
