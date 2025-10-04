import 'package:dio/dio.dart';
import '../../../core/utils/api_exceptions.dart';

class AccountApiService {
  final Dio _dio;

  AccountApiService(this._dio);

  // Register new account
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'role': role,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Login to account
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'rememberMe': rememberMe,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Logout from account
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Delete account
  Future<void> deleteAccount({
    required String password,
    required String reason,
    String? additionalInfo,
  }) async {
    try {
      await _dio.delete(
        '/auth/account',
        data: {
          'password': password,
          'reason': reason,
          'additionalInfo': additionalInfo,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/auth/profile');
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    String? dateOfBirth,
    String? profileImage,
  }) async {
    try {
      final response = await _dio.put(
        '/auth/profile',
        data: {
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
          if (phone != null) 'phone': phone,
          if (address != null) 'address': address,
          if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
          if (profileImage != null) 'profileImage': profileImage,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Request password reset
  Future<void> requestPasswordReset({
    required String email,
  }) async {
    try {
      await _dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Reset password with token
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        '/auth/reset-password',
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Verify email
  Future<void> verifyEmail({
    required String token,
  }) async {
    try {
      await _dio.post(
        '/auth/verify-email',
        data: {'token': token},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      await _dio.post('/auth/resend-verification');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Get active sessions
  Future<List<Map<String, dynamic>>> getActiveSessions() async {
    try {
      final response = await _dio.get('/auth/sessions');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Revoke session
  Future<void> revokeSession({
    required String sessionId,
  }) async {
    try {
      await _dio.delete('/auth/sessions/$sessionId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Revoke all sessions except current
  Future<void> revokeAllOtherSessions() async {
    try {
      await _dio.delete('/auth/sessions/revoke-all');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Get trusted devices
  Future<List<Map<String, dynamic>>> getTrustedDevices() async {
    try {
      final response = await _dio.get('/auth/devices');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Remove trusted device
  Future<void> removeTrustedDevice({
    required String deviceId,
  }) async {
    try {
      await _dio.delete('/auth/devices/$deviceId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Enable two-factor authentication
  Future<Map<String, dynamic>> enableTwoFactor() async {
    try {
      final response = await _dio.post('/auth/2fa/enable');
      return response.data; // Returns QR code and secret
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Verify and confirm two-factor authentication
  Future<void> verifyTwoFactor({
    required String code,
  }) async {
    try {
      await _dio.post(
        '/auth/2fa/verify',
        data: {'code': code},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Disable two-factor authentication
  Future<void> disableTwoFactor({
    required String password,
  }) async {
    try {
      await _dio.post(
        '/auth/2fa/disable',
        data: {'password': password},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Get login history
  Future<List<Map<String, dynamic>>> getLoginHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/auth/login-history',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return List<Map<String, dynamic>>.from(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Update notification preferences
  Future<void> updateNotificationPreferences({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    bool? appointmentReminders,
    bool? promotionalEmails,
  }) async {
    try {
      await _dio.put(
        '/auth/notification-preferences',
        data: {
          if (emailNotifications != null)
            'emailNotifications': emailNotifications,
          if (pushNotifications != null) 'pushNotifications': pushNotifications,
          if (smsNotifications != null) 'smsNotifications': smsNotifications,
          if (appointmentReminders != null)
            'appointmentReminders': appointmentReminders,
          if (promotionalEmails != null) 'promotionalEmails': promotionalEmails,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Get notification preferences
  Future<Map<String, dynamic>> getNotificationPreferences() async {
    try {
      final response = await _dio.get('/auth/notification-preferences');
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Update privacy settings
  Future<void> updatePrivacySettings({
    bool? profileVisibility,
    bool? showEmail,
    bool? showPhone,
    bool? allowAnalytics,
    bool? allowMarketingCommunications,
  }) async {
    try {
      await _dio.put(
        '/auth/privacy-settings',
        data: {
          if (profileVisibility != null) 'profileVisibility': profileVisibility,
          if (showEmail != null) 'showEmail': showEmail,
          if (showPhone != null) 'showPhone': showPhone,
          if (allowAnalytics != null) 'allowAnalytics': allowAnalytics,
          if (allowMarketingCommunications != null)
            'allowMarketingCommunications': allowMarketingCommunications,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Get privacy settings
  Future<Map<String, dynamic>> getPrivacySettings() async {
    try {
      final response = await _dio.get('/auth/privacy-settings');
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Export user data (GDPR compliance)
  Future<String> requestDataExport() async {
    try {
      final response = await _dio.post('/auth/export-data');
      return response.data['exportUrl']; // Returns download URL
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Get data export history
  Future<List<Map<String, dynamic>>> getDataExportHistory() async {
    try {
      final response = await _dio.get('/auth/export-history');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Deactivate account temporarily
  Future<void> deactivateAccount({
    required String password,
    String? reason,
  }) async {
    try {
      await _dio.post(
        '/auth/deactivate',
        data: {
          'password': password,
          if (reason != null) 'reason': reason,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Reactivate account
  Future<Map<String, dynamic>> reactivateAccount({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/reactivate',
        data: {
          'email': email,
          'password': password,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Refresh access token
  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Check email availability
  Future<bool> checkEmailAvailability({
    required String email,
  }) async {
    try {
      final response = await _dio.get(
        '/auth/check-email',
        queryParameters: {'email': email},
      );
      return response.data['available'] as bool;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Upload profile picture
  Future<String> uploadProfilePicture({
    required String imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.post(
        '/auth/upload-profile-picture',
        data: formData,
      );
      return response.data['imageUrl'];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Delete profile picture
  Future<void> deleteProfilePicture() async {
    try {
      await _dio.delete('/auth/profile-picture');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
