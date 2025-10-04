import 'package:dio/dio.dart';

import '../../../core/services/local_storage_service.dart';
import '../../../core/models/auth_models.dart';
import 'auth_session.dart';
import 'auth_user.dart';

abstract class AuthRepository {
  Future<AuthSession> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  });

  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  AuthSession? restoreSession();
}

class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository(this._dio, this._storageService);

  final Dio _dio;
  final AuthStorage _storageService;

  static const _authHeaderKey = 'Authorization';

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'displayName': displayName,
          'role': role.code,
        },
      );

      final session = _sessionFromResponse(response.data);
      await _persistSession(session);
      return session;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final session = _sessionFromResponse(response.data);
      await _persistSession(session);
      return session;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<void> logout() async {
    _dio.options.headers.remove(_authHeaderKey);
    await _storageService.clearSession();
  }

  @override
  AuthSession? restoreSession() {
    final session = _storageService.getPersistedSession();
    if (session != null) {
      _dio.options.headers[_authHeaderKey] = 'Bearer ${session.accessToken}';
    }
    return session;
  }

  Future<void> _persistSession(AuthSession session) async {
    await _storageService.persistSession(session);
    _dio.options.headers[_authHeaderKey] = 'Bearer ${session.accessToken}';
  }

  AuthSession _sessionFromResponse(Map<String, dynamic>? data) {
    if (data == null) {
      throw const AuthException('Invalid response from server');
    }

    final userJson = data['user'] as Map<String, dynamic>?;
    final token = data['accessToken'] as String?;
    if (userJson == null || token == null) {
      throw const AuthException('Malformed authentication payload');
    }

    return AuthSession(
      user: AuthUser.fromJson(userJson),
      accessToken: token,
      refreshToken: data['refreshToken'] as String?,
    );
  }

  AuthException _mapDioException(DioException exception) {
    final response = exception.response;
    if (response != null) {
      final message = response.data is Map<String, dynamic>
          ? (response.data['message'] as String? ?? 'Authentication failed')
          : 'Authentication failed';
      return AuthException(message);
    }

    return const AuthException('Unable to reach server');
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
