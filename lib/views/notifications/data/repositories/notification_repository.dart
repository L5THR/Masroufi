import 'package:dio/dio.dart';
import 'package:flutter_alinfo9/core/network/dio_client.dart';
import 'package:flutter_alinfo9/core/utils/endpoints.dart';
import 'package:flutter_alinfo9/views/notifications/data/models/notification.dart';

class NotificationRepository {
  final Dio _dioClient = DioClient.instance.dio;

  // ==================== GET NOTIFICATIONS ====================

  /// Get all notifications for the current user
  /// GET /api/notifications
  Future<List<Notification>> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    try {
      print('📡 Getting notifications...');
      print('📡 Page: $page, Size: $size');

      final response = await _dioClient.get(
        ApiEndpoints.notifications,
        queryParameters: {
          'page': page,
          'size': size,
          'sort': ['createdAt,desc'], // Newest first
        },
      );

      print('✅ Notifications retrieved successfully');
      final content = response.data['content'] as List;
      return content.map((json) => Notification.fromJson(json)).toList();
    } on DioException catch (e) {
      print('❌ Failed to get notifications: ${e.response?.statusCode}');
      print('❌ Error: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  // ==================== MARK AS READ ====================

  /// Mark a notification as read
  /// PUT /api/notifications/{notificationId}/read
  Future<Notification> markAsRead(int notificationId) async {
    try {
      print('📡 Marking notification $notificationId as read...');

      final response = await _dioClient.put(
        ApiEndpoints.markNotificationRead(notificationId),
      );

      print('✅ Notification marked as read');
      return Notification.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Failed to mark notification as read: ${e.response?.statusCode}');
      throw _handleError(e);
    }
  }

  // ==================== GET UNREAD COUNT ====================

  /// Get count of unread notifications
  /// This is a helper method that filters the notifications
  Future<int> getUnreadCount() async {
    try {
      // Get first page of notifications
      final notifications = await getNotifications(page: 0, size: 100);

      // Count unread notifications
      return notifications.where((n) => !n.read).length;
    } catch (e) {
      print('❌ Failed to get unread count: $e');
      return 0; // Return 0 on error instead of throwing
    }
  }

  // ==================== ERROR HANDLING ====================

  String _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      switch (statusCode) {
        case 400:
          if (data is Map && data.containsKey('message')) {
            return data['message'];
          }
          return 'Invalid request. Please try again.';
        case 401:
          return 'Authentication required. Please login again.';
        case 403:
          return 'Access denied.';
        case 404:
          return 'Notification not found.';
        case 500:
          String message = 'Server error. ';
          if (data is Map && data.containsKey('message')) {
            message += data['message'];
          } else {
            message += 'Could not load notifications. Please try again.';
          }
          return message;
        default:
          return 'Something went wrong (HTTP $statusCode). Please try again.';
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Make sure the backend is running.';
    }

    return 'An unexpected error occurred: ${error.message}';
  }
}
