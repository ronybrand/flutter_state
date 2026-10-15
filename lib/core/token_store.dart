import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'jwt.dart';

const tokenKey = 'estado_jwt';

/// The tiny slice of a keychain this app uses, so tests can stand in for it.
abstract interface class KeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// iOS Keychain / Android Keystore through flutter_secure_storage.
class PlatformKeyValueStore implements KeyValueStore {
  const PlatformKeyValueStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

abstract interface class TokenStore {
  /// The token, read synchronously (the HTTP interceptor cannot await).
  String? get current;

  /// Called once at app start.
  Future<String?> load();

  Future<void> save(String token);

  Future<void> clear();
}

/// A keychain is the right home for a credential on a phone, but its API is
/// async; the value is mirrored in memory and written through.
class SecureTokenStore implements TokenStore {
  SecureTokenStore(this._keychain);

  final KeyValueStore _keychain;
  String? _current;

  @override
  String? get current => _current;

  /// An unreadable keychain is treated as "logged out", never as a crash on
  /// launch. An expired or malformed token is dropped and deleted.
  @override
  Future<String?> load() async {
    try {
      final stored = await _keychain.read(tokenKey);
      if (stored != null && isTokenValid(stored)) {
        return _current = stored;
      }
      _current = null;
      if (stored != null) await clear();
      return null;
    } on Object {
      _current = null;
      return null;
    }
  }

  /// The memory copy is updated first and synchronously, so concurrent requests
  /// see the new state at once; a failing keychain write only costs persistence
  /// across restarts, not the current session.
  @override
  Future<void> save(String token) async {
    _current = token;
    try {
      await _keychain.write(tokenKey, token);
    } on Object {
      // Session stays valid for this run only.
    }
  }

  @override
  Future<void> clear() async {
    _current = null;
    try {
      await _keychain.delete(tokenKey);
    } on Object {
      // Nothing to do: the in-memory token is already gone.
    }
  }
}
