import 'dart:convert';

import 'package:flutter_state/core/jwt.dart';
import 'package:flutter_test/flutter_test.dart';

String tokenWith(Object? payload) {
  final encoded = base64Url.encode(utf8.encode(jsonEncode(payload)));
  return 'header.${encoded.replaceAll('=', '')}.signature';
}

void main() {
  group('tokenExpiry', () {
    test('returns exp as a UTC DateTime', () {
      expect(
        tokenExpiry(tokenWith({'exp': 1800000000})),
        DateTime.fromMillisecondsSinceEpoch(1800000000 * 1000, isUtc: true),
      );
    });

    for (final entry in {
      'not a jwt': 'nope',
      'a payload that is not base64': 'a.%%%.c',
      'a payload that is not json': 'a.${base64Url.encode(utf8.encode('x'))}.c',
      'no exp claim': tokenWith({'sub': 'admin'}),
      'a non-numeric exp': tokenWith({'exp': 'soon'}),
      'an empty string': '',
    }.entries) {
      test('returns null for ${entry.key}', () {
        expect(tokenExpiry(entry.value), isNull);
      });
    }
  });

  group('isTokenValid', () {
    final now = DateTime.utc(2026, 1, 1, 12);
    int secondsFromNow(int s) =>
        now.add(Duration(seconds: s)).millisecondsSinceEpoch ~/ 1000;

    test('is true before exp', () {
      expect(
        isTokenValid(tokenWith({'exp': secondsFromNow(60)}), now: now),
        isTrue,
      );
    });

    test('is false at and after exp', () {
      expect(
        isTokenValid(tokenWith({'exp': secondsFromNow(0)}), now: now),
        isFalse,
      );
      expect(
        isTokenValid(tokenWith({'exp': secondsFromNow(-1)}), now: now),
        isFalse,
      );
    });

    test('is false for anything that cannot be decoded', () {
      expect(isTokenValid('garbage', now: now), isFalse);
    });
  });
}
