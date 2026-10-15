import 'dart:async';

import 'package:dio/dio.dart';

import 'token_store.dart';
import 'uuid.dart';

const requestIdHeader = 'X-Request-Id';
const loginPath = '/auth/login';
const timeout = Duration(seconds: 15);
const maxRetries = 2;
const retryBaseDelay = Duration(milliseconds: 500);

const _attemptKey = 'retryAttempt';

/// Builds the one HTTP client the app uses.
///
/// * every action carries an `X-Request-Id`, generated once and kept across
///   retries so all attempts correlate as a single action in the backend logs;
/// * the bearer token is attached only to requests aimed at the API itself;
/// * a failing GET is resent (twice, with exponential backoff);
/// * a 401 anywhere ends the session, and [onSessionExpired] is told once.
Dio createDio({
  required String baseUrl,
  required TokenStore tokens,
  required void Function() onSessionExpired,
  HttpClientAdapter? adapter,
  Future<void> Function(Duration)? delay,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
    ),
  );
  if (adapter != null) dio.httpClientAdapter = adapter;
  final wait = delay ?? (Duration d) => Future<void>.delayed(d);

  // A relative path is always resolved against baseUrl, so it is safe. An
  // absolute one bypasses it, so it is checked against a boundary (not just a
  // prefix): a neighbouring host like `${baseUrl}evil.com` is not the API.
  bool isApiRequest(String path) {
    if (!RegExp(r'^https?://', caseSensitive: false).hasMatch(path)) {
      return true;
    }
    return path == baseUrl || path.startsWith('$baseUrl/');
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers.putIfAbsent(requestIdHeader, uuidV4);
        final token = tokens.current;
        if (token != null &&
            !options.headers.containsKey('Authorization') &&
            isApiRequest(options.path)) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final options = error.requestOptions;
        final status = error.response?.statusCode;

        // Checked before the retry branch so a 401 is never retried. The login
        // request itself is excluded: a wrong password also answers 401, and that
        // is a normal form error. Only the first 401 to see a token announces the
        // loss; concurrent ones are no-ops (the token is already gone).
        if (status == 401 &&
            !options.path.endsWith(loginPath) &&
            tokens.current != null) {
          unawaited(tokens.clear());
          onSessionExpired();
          return handler.next(error);
        }

        final retryable =
            (status == null || status >= 500) &&
            error.type != DioExceptionType.cancel &&
            error.type != DioExceptionType.badCertificate;
        if (options.method.toUpperCase() != 'GET' || !retryable) {
          return handler.next(error);
        }

        final attempt = ((options.extra[_attemptKey] as int?) ?? 0) + 1;
        if (attempt > maxRetries) return handler.next(error);
        options.extra[_attemptKey] = attempt;

        await wait(retryBaseDelay * (1 << (attempt - 1)));
        try {
          handler.resolve(await dio.fetch<dynamic>(options));
        } on DioException catch (retryError) {
          handler.next(retryError);
        }
      },
    ),
  );

  return dio;
}
