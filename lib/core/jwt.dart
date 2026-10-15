import 'dart:convert';

/// Decodes the `exp` claim client-side, no round trip. This is a UI hint only
/// (should the login screen show?), not an authorization check: the signature
/// is never verified, and the backend authorizes every real request. Do not
/// reuse this to read claims such as a role for access decisions.
DateTime? tokenExpiry(String token) {
  try {
    final parts = token.split('.');
    if (parts.length < 2) return null;
    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final decoded = jsonDecode(payload);
    if (decoded is! Map) return null;
    final exp = decoded['exp'];
    if (exp is! num) return null;
    return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000, isUtc: true);
  } on Object {
    return null;
  }
}

bool isTokenValid(String token, {DateTime? now}) {
  final expiry = tokenExpiry(token);
  return expiry != null && expiry.isAfter((now ?? DateTime.now()).toUtc());
}
