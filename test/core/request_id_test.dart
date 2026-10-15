import 'package:dio/dio.dart';
import 'package:flutter_state/core/request_id.dart';
import 'package:flutter_test/flutter_test.dart';

DioException errorWith(Object? data) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: 500, data: data),
  );
}

void main() {
  const id = '123e4567-e89b-12d3-a456-426614174000';

  test('extracts a valid requestId from the error body', () {
    expect(extractRequestId(errorWith({'requestId': id})), id);
  });

  test('trims whitespace around it', () {
    expect(extractRequestId(errorWith({'requestId': '  $id  '})), id);
  });

  test(
    'ignores a requestId that is not a uuid (a proxy may answer anything)',
    () {
      expect(extractRequestId(errorWith({'requestId': '<script>'})), isNull);
    },
  );

  test('ignores a body without requestId or of another shape', () {
    expect(extractRequestId(errorWith({'message': 'x'})), isNull);
    expect(extractRequestId(errorWith('plain text')), isNull);
    expect(extractRequestId(errorWith(null)), isNull);
  });

  test('ignores errors that are not HTTP errors', () {
    expect(extractRequestId(StateError('boom')), isNull);
    expect(
      extractRequestId(DioException(requestOptions: RequestOptions(path: '/'))),
      isNull,
    );
  });
}
