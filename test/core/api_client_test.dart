import 'package:dio/dio.dart';
import 'package:flutter_state/core/api_client.dart';
import 'package:flutter_state/core/token_store.dart';
import 'package:flutter_state/core/uuid.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

const base = 'https://api.example.com/api';

void main() {
  late FakeKeyValueStore keychain;
  late SecureTokenStore tokens;
  late FakeAdapter adapter;
  late Dio dio;
  late int sessionExpiredCalls;
  late List<Duration> delays;

  setUp(() {
    keychain = FakeKeyValueStore();
    tokens = SecureTokenStore(keychain);
    sessionExpiredCalls = 0;
    delays = [];
    adapter = FakeAdapter((_) async => FakeResponse(200, []));
    dio = createDio(
      baseUrl: base,
      tokens: tokens,
      onSessionExpired: () => sessionExpiredCalls++,
      adapter: adapter,
      delay: (d) async => delays.add(d),
    );
  });

  test('talks to the configured base url with a 15s timeout', () {
    expect(dio.options.baseUrl, base);
    expect(dio.options.connectTimeout, const Duration(seconds: 15));
    expect(dio.options.receiveTimeout, const Duration(seconds: 15));
  });

  test('sends an X-Request-Id (uuid) on every request', () async {
    await dio.get('/estado/paginado');
    expect(
      isUuid('${adapter.requests.single.headers[requestIdHeader]}'),
      isTrue,
    );
  });

  test('keeps the same X-Request-Id across retry attempts of a GET', () async {
    adapter.handler = (_) async => FakeResponse(500);
    await expectLater(dio.get('/estado'), throwsA(isA<DioException>()));
    final ids = adapter.requests.map((r) => r.headers[requestIdHeader]).toSet();
    expect(adapter.requests, hasLength(3));
    expect(ids, hasLength(1));
  });

  test('resends a failing GET up to 2 times', () async {
    var attempts = 0;
    adapter.handler = (_) async {
      attempts++;
      return attempts <= 2 ? FakeResponse(500) : FakeResponse(200, ['ok']);
    };
    final response = await dio.get('/estado');
    expect(response.data, ['ok']);
    expect(attempts, 3);
  });

  test('waits longer between each retry (exponential backoff)', () async {
    adapter.handler = (_) async => FakeResponse(500);
    await expectLater(dio.get('/estado'), throwsA(isA<DioException>()));
    expect(delays, [
      const Duration(milliseconds: 500),
      const Duration(milliseconds: 1000),
    ]);
  });

  test(
    'retries a GET that failed without any response (network down)',
    () async {
      var attempts = 0;
      adapter.handler = (options) async {
        attempts++;
        if (attempts == 1) {
          throw DioException.connectionError(
            requestOptions: options,
            reason: 'offline',
          );
        }
        return FakeResponse(200, ['ok']);
      };
      final response = await dio.get('/estado');
      expect(response.data, ['ok']);
      expect(attempts, 2);
    },
  );

  test('does not resend a GET that failed with a 4xx status', () async {
    adapter.handler = (_) async => FakeResponse(404);
    await expectLater(dio.get('/estado/999'), throwsA(isA<DioException>()));
    expect(adapter.requests, hasLength(1));
  });

  test('does not resend a failing POST', () async {
    adapter.handler = (_) async => FakeResponse(500);
    await expectLater(
      dio.post('/estado/', data: {}),
      throwsA(isA<DioException>()),
    );
    expect(adapter.requests, hasLength(1));
  });

  group('Authorization', () {
    test('is attached when a token is stored', () async {
      await tokens.save('stored-token');
      await dio.post('/estado/', data: {});
      expect(
        adapter.requests.single.headers['Authorization'],
        'Bearer stored-token',
      );
    });

    test('is not attached without a token', () async {
      await dio.post('/estado/', data: {});
      expect(
        adapter.requests.single.headers.containsKey('Authorization'),
        isFalse,
      );
    });

    test(
      'is not attached to an absolute url outside the API boundary',
      () async {
        await tokens.save('stored-token');
        await dio.get('${base}evil.com/estado');
        expect(
          adapter.requests.single.headers.containsKey('Authorization'),
          isFalse,
        );
      },
    );

    test('is not attached to another host', () async {
      await tokens.save('stored-token');
      await dio.get('https://evil.example/estado');
      expect(
        adapter.requests.single.headers.containsKey('Authorization'),
        isFalse,
      );
    });

    test('is attached to an absolute url that is the API itself', () async {
      await tokens.save('stored-token');
      await dio.get('$base/estado');
      expect(
        adapter.requests.single.headers['Authorization'],
        'Bearer stored-token',
      );
    });
  });

  group('401', () {
    test(
      'clears the token and announces the session loss, without retrying',
      () async {
        await tokens.save('existing-token');
        adapter.handler = (_) async => FakeResponse(401);
        await expectLater(
          dio.post('/estado/', data: {}),
          throwsA(isA<DioException>()),
        );
        expect(adapter.requests, hasLength(1));
        expect(tokens.current, isNull);
        expect(sessionExpiredCalls, 1);
      },
    );

    test('only announces once when concurrent requests all 401', () async {
      await tokens.save('existing-token');
      adapter.handler = (_) async => FakeResponse(401);
      await Future.wait([
        dio.get('/estado/a').then<void>((_) {}, onError: (_) {}),
        dio.get('/estado/b').then<void>((_) {}, onError: (_) {}),
      ]);
      expect(tokens.current, isNull);
      expect(sessionExpiredCalls, 1);
    });

    test('ignores a 401 from the login request itself', () async {
      await tokens.save('existing-token');
      adapter.handler = (_) async => FakeResponse(401);
      await expectLater(
        dio.post('/auth/login', data: {}),
        throwsA(isA<DioException>()),
      );
      expect(tokens.current, 'existing-token');
      expect(sessionExpiredCalls, 0);
    });

    test('does not clear the token on a non-401 error', () async {
      await tokens.save('existing-token');
      adapter.handler = (_) async => FakeResponse(404);
      await expectLater(
        dio.post('/estado/999', data: {}),
        throwsA(isA<DioException>()),
      );
      expect(tokens.current, 'existing-token');
    });
  });
}
