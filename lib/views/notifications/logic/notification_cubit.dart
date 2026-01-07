import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/views/notifications/data/models/notification.dart';
import 'package:flutter_alinfo9/views/notifications/data/repositories/notification_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;

  NotificationCubit(this._repository) : super(NotificationInitial());

  // ==================== LOAD NOTIFICATIONS ====================

  /// Load all notifications
  Future<void> loadNotifications({int page = 0}) async {
    try {
      emit(NotificationLoading());

      final notifications = await _repository.getNotifications(
        page: page,
        size: 20,
      );

      // Calculate unread count
      final unreadCount = notifications.where((n) => !n.read).length;

      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
        hasMore: notifications.length >= 20,
      ));
    } catch (e) {
      print('❌ Error loading notifications: $e');
      emit(NotificationError(e.toString()));
    }
  }

  // ==================== MARK AS READ ====================

  /// Mark a notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      // Get current notifications if available
      List<Notification> currentNotifications = [];
      if (state is NotificationLoaded) {
        currentNotifications = (state as NotificationLoaded).notifications;
      }

      emit(NotificationMarkingAsRead(notificationId));

      final updatedNotification = await _repository.markAsRead(notificationId);

      // Update the notification in the list
      final updatedNotifications = currentNotifications.map((notification) {
        if (notification.id == notificationId) {
          return updatedNotification;
        }
        return notification;
      }).toList();

      // Recalculate unread count
      final unreadCount = updatedNotifications.where((n) => !n.read).length;

      emit(NotificationLoaded(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      ));

      // Briefly show confirmation
      emit(NotificationMarkedAsRead(updatedNotification));

      // Return to loaded state
      emit(NotificationLoaded(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      print('❌ Error marking notification as read: $e');

      // Preserve current notifications on error
      List<Notification> currentNotifications = [];
      if (state is NotificationLoaded) {
        currentNotifications = (state as NotificationLoaded).notifications;
      }

      emit(NotificationMarkAsReadError(e.toString(), currentNotifications));

      // After showing error, return to loaded state
      if (currentNotifications.isNotEmpty) {
        final unreadCount = currentNotifications.where((n) => !n.read).length;
        emit(NotificationLoaded(
          notifications: currentNotifications,
          unreadCount: unreadCount,
        ));
      }
    }
  }

  // ==================== MARK ALL AS READ ====================

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      if (state is! NotificationLoaded) return;

      final currentState = state as NotificationLoaded;
      final notifications = currentState.notifications;

      // Mark each unread notification as read
      for (final notification in notifications) {
        if (!notification.read) {
          await _repository.markAsRead(notification.id);
        }
      }

      // Reload notifications
      await loadNotifications();
    } catch (e) {
      print('❌ Error marking all as read: $e');
      emit(NotificationError(e.toString()));
    }
  }

  // ==================== LOAD MORE NOTIFICATIONS ====================

  /// Load more notifications (pagination)
  Future<void> loadMoreNotifications(int currentPage) async {
    try {
      if (state is! NotificationLoaded) return;

      final currentState = state as NotificationLoaded;
      final currentNotifications = currentState.notifications;

      final moreNotifications = await _repository.getNotifications(
        page: currentPage + 1,
        size: 20,
      );

      // Combine all notifications
      final allNotifications = [...currentNotifications, ...moreNotifications];

      // Calculate unread count
      final unreadCount = allNotifications.where((n) => !n.read).length;

      emit(NotificationLoaded(
        notifications: allNotifications,
        unreadCount: unreadCount,
        hasMore: moreNotifications.length >= 20,
      ));
    } catch (e) {
      print('❌ Error loading more notifications: $e');
      // Keep current state on error
    }
  }

  // ==================== REFRESH NOTIFICATIONS ====================

  /// Refresh notifications (pull-to-refresh)
  Future<void> refreshNotifications() async {
    await loadNotifications(page: 0);
  }

  // ==================== GET UNREAD COUNT ====================

  /// Get count of unread notifications (for badge)
  Future<int> getUnreadCount() async {
    try {
      return await _repository.getUnreadCount();
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return 0;
    }
  }

  // ==================== CLEAR NOTIFICATIONS ====================

  /// Clear notifications state
  void clearNotifications() {
    emit(NotificationInitial());
  }
}
