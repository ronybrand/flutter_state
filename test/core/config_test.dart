import 'package:flutter_state/core/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveApiBaseUrl', () {
    test('falls back to the default when nothing is configured', () {
      expect(resolveApiBaseUrl(null), defaultApiUrl);
      expect(resolveApiBaseUrl(''), defaultApiUrl);
      expect(resolveApiBaseUrl('   '), defaultApiUrl);
    });

    test('uses the configured url', () {
      expect(
        resolveApiBaseUrl('https://api.example.com/api'),
        'https://api.example.com/api',
      );
    });

    test('drops trailing slashes so paths append with a single slash', () {
      expect(
        resolveApiBaseUrl('https://api.example.com/api///'),
        'https://api.example.com/api',
      );
    });

    for (final bad in [
      'ftp://example.com',
      'javascript:alert(1)',
      'not a url',
      '/relative',
    ]) {
      test(
        'rejects "$bad": a native app has no origin to resolve it against',
        () {
          expect(
            () => resolveApiBaseUrl(bad),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains('API_URL'),
              ),
            ),
          );
        },
      );
    }
  });
}
