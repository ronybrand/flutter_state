import 'package:dio/dio.dart';

const apiUnavailableMessage =
    'The API is temporarily offline (paused to save cost). Please try again in a few minutes.';

const _gatewayStatuses = {502, 503, 504};

/// No usable backend answer: no response at all (network, DNS or timeout) or a
/// gateway error. With the EC2 turned off (deploy/aws-power.ps1 in the backend
/// repo) this is exactly what the user sees.
bool isApiUnavailable(Object error) {
  if (error is! DioException) return false;
  final status = error.response?.statusCode;
  return status == null || _gatewayStatuses.contains(status);
}

String apiErrorMessage(Object error, String fallback) =>
    isApiUnavailable(error) ? apiUnavailableMessage : fallback;
