/// Public (testing) deployment of the same API, reached through the web app's
/// /api proxy. Fine for trying the app; point `--dart-define=API_URL=...` at
/// your own backend for anything real.
const defaultApiUrl = 'https://react-state-flax.vercel.app/api';

/// A native app has no origin and no CORS, so unlike the web frontends it talks
/// to the API directly: no BFF proxy. `String.fromEnvironment` is resolved at
/// build time and ends up inside the binary, which is why nothing secret may be
/// passed this way.
String resolveApiBaseUrl(String? raw) {
  final configured = raw?.trim() ?? '';
  if (configured.isEmpty) return defaultApiUrl;
  if (!RegExp(
    r'^https?://[^\s/]+',
    caseSensitive: false,
  ).hasMatch(configured)) {
    throw ArgumentError(
      'API_URL must be an absolute http(s) url, got "$configured"',
    );
  }
  return configured.replaceAll(RegExp(r'/+$'), '');
}

final String apiBaseUrl = resolveApiBaseUrl(
  const String.fromEnvironment('API_URL'),
);
