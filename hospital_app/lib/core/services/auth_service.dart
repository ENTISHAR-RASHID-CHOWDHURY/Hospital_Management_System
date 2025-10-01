import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/auth_models.dart';
import '../utils/api_exceptions.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  /// Login with email and password
  Future<LoginResponse> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);

      final response = await _dio.post(
        ApiConfig.loginEndpoint,
        data: request.toJson(),
      );

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown(e.toString());
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await _dio.post(ApiConfig.logoutEndpoint);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown(e.toString());
    }
  }

  /// Refresh access token
  Future<TokenResponse> refreshToken(String refreshToken) async {
    try {
      final request = RefreshTokenRequest(refreshToken: refreshToken);

      final response = await _dio.post(
        ApiConfig.refreshTokenEndpoint,
        data: request.toJson(),
      );

      return TokenResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown(e.toString());
    }
  }

  /// Get current user information
  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiConfig.currentUserEndpoint);
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown(e.toString());
    }
  }

  /// Change user password
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      await _dio.post(
        ApiConfig.changePasswordEndpoint,
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown(e.toString());
    }
  }

  /// Validate if current token is still valid
  Future<bool> validateToken() async {
    try {
      await getCurrentUser();
      return true;
    } catch (e) {
      return false;
    }
  }
}
