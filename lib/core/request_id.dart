import 'package:dio/dio.dart';

import 'uuid.dart';

/// The backend only ever echoes a valid uuid, but the client should not blindly
/// trust that either: a proxy in between could answer something else on a
/// gateway error. Validating the format avoids showing the user something that
/// is not really a correlation id.
String? extractRequestId(Object error) {
  if (error is! DioException) return null;
  final body = error.response?.data;
  if (body is! Map) return null;
  final requestId = body['requestId'];
  if (requestId is! String) return null;
  final trimmed = requestId.trim();
  return isUuid(trimmed) ? trimmed : null;
}
