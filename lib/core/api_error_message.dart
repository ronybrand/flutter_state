import 'package:dio/dio.dart';

const apiUnavailableMessage =
    'The API is offline (paused to save cost). Turn it on with the link below; it takes about 1 minute.';

/// Page served by the start-api Lambda (backend repo, ADR 0026): anti-bot
/// challenge, starts the EC2 and waits for the API to come back. Opened in the
/// browser, since the challenge widget needs one. The app sets the language
/// query parameter for the selected locale. No ?back: a native app has no web
/// page to return to.
const startApiUrl =
    'https://pizowbnhivr3vholalz5r7ajta0mkvqn.lambda-url.us-east-1.on.aws/?lang=en';

const _gatewayStatuses = {502, 503, 504};

/// No usable backend answer: no response at all (network, DNS or timeout) or a
/// gateway error. With the EC2 turned off (deploy/aws-power.ps1 in the backend
/// repo) this is exactly what the user sees.
bool isApiUnavailable(Object error) {
  if (error is! DioException) return false;
  final status = error.response?.statusCode;
  return status == null || _gatewayStatuses.contains(status);
}

String apiErrorMessage(
  Object error,
  String fallback, {
  String unavailableMessage = apiUnavailableMessage,
}) => isApiUnavailable(error) ? unavailableMessage : fallback;
