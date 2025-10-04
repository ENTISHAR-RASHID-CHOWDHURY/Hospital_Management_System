import 'package:dio/dio.dart';
import '../../../core/utils/api_exceptions.dart';
import '../notifications_screen.dart';

/// Service for notification-related API operations
class NotificationApiService {
  final Dio _dio;

  NotificationApiService(this._dio);

  /// Fetch all notifications for the current user
  Future<List<AppNotification>> getNotifications({
    int page = 1,
    int limit = 20,
    bool? isRead,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (isRead != null) 'isRead': isRead,
        if (type != null && type.isNotEmpty) 'type': type,
      };

      final response = await _dio.get(
        '/notifications',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> notificationsJson = response.data['data'];
        return notificationsJson
            .map((json) => AppNotification.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to fetch notifications: $e');
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/notifications/unread/count');

      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data']['count'] as int;
      }

      return 0;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to fetch unread count: $e');
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _dio.put('/notifications/$notificationId/read');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to mark notification as read: $e');
    }
  }

  /// Mark a notification as unread
  Future<void> markAsUnread(String notificationId) async {
    try {
      await _dio.put('/notifications/$notificationId/unread');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to mark notification as unread: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _dio.put('/notifications/read-all');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to mark all as read: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _dio.delete('/notifications/$notificationId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to delete notification: $e');
    }
  }

  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    try {
      await _dio.delete('/notifications/all');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to delete all notifications: $e');
    }
  }

  /// Get notification by ID
  Future<AppNotification?> getNotificationById(String id) async {
    try {
      final response = await _dio.get('/notifications/$id');

      if (response.data['success'] == true && response.data['data'] != null) {
        return AppNotification.fromJson(response.data['data']);
      }

      return null;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to fetch notification: $e');
    }
  }

  /// Get unread notifications
  Future<List<AppNotification>> getUnreadNotifications() async {
    return getNotifications(isRead: false, limit: 100);
  }

  /// Create a notification (admin only)
  Future<AppNotification> createNotification(
      Map<String, dynamic> notificationData) async {
    try {
      final response = await _dio.post(
        '/notifications',
        data: notificationData,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return AppNotification.fromJson(response.data['data']);
      }

      throw ApiException.unknown('Failed to create notification');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to create notification: $e');
    }
  }
}
