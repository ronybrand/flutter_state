import 'package:dio/dio.dart';
import 'package:flutter_state/core/api_error_message.dart';
import 'package:flutter_test/flutter_test.dart';

DioException errorWithStatus(int? status) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    response: status == null
        ? null
        : Response(requestOptions: options, statusCode: status),
  );
}

void main() {
  test('treats an error with no response (network/timeout) as unavailable', () {
    expect(isApiUnavailable(errorWithStatus(null)), isTrue);
  });

  for (final status in [502, 503, 504]) {
    test('treats HTTP $status as unavailable', () {
      expect(
        apiErrorMessage(errorWithStatus(status), 'Failed.'),
        apiUnavailableMessage,
      );
    });
  }

  for (final status in [400, 401, 404, 500]) {
    test('keeps the fallback for HTTP $status', () {
      expect(apiErrorMessage(errorWithStatus(status), 'Failed.'), 'Failed.');
    });
  }

  test('keeps the fallback for a non-Dio error', () {
    expect(apiErrorMessage(StateError('boom'), 'Failed.'), 'Failed.');
  });
}
