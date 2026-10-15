import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/token_store.dart';

class LoginResult {
  const LoginResult({required this.token, required this.expiresInSeconds});

  final String token;
  final int expiresInSeconds;
}

class AuthRepository {
  AuthRepository(this._dio, this._tokens);

  final Dio _dio;
  final TokenStore _tokens;

  /// Stores the token only once the backend has issued it.
  Future<LoginResult> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, Object?>>(
      loginPath,
      data: {'username': username, 'password': password},
    );
    final data = response.data!;
    final result = LoginResult(
      token: data['token']! as String,
      expiresInSeconds: data['expiresInSeconds']! as int,
    );
    await _tokens.save(result.token);
    return result;
  }

  Future<void> logout() => _tokens.clear();
}
