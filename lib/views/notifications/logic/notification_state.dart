import 'package:equatable/equatable.dart';
import 'package:flutter_alinfo9/views/notifications/data/models/notification.dart';

// ==================== BASE NOTIFICATION STATE ====================

abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== INITIAL STATE ====================

class NotificationInitial extends NotificationState {}

// ==================== LOADING STATES ====================

class NotificationLoading extends NotificationState {}

class NotificationMarkingAsRead extends NotificationState {
  final int notificationId;

  NotificationMarkingAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

// ==================== SUCCESS STATES ====================

class NotificationLoaded extends NotificationState {
  final List<Notification> notifications;
  final int unreadCount;
  final bool hasMore;

  NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [notifications, unreadCount, hasMore];

  NotificationLoaded copyWith({
    List<Notification>? notifications,
    int? unreadCount,
    bool? hasMore,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class NotificationMarkedAsRead extends NotificationState {
  final Notification notification;

  NotificationMarkedAsRead(this.notification);

  @override
  List<Object?> get props => [notification];
}

// ==================== ERROR STATES ====================

class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationMarkAsReadError extends NotificationState {
  final String message;
  final List<Notification> currentNotifications;

  NotificationMarkAsReadError(this.message, this.currentNotifications);

  @override
  List<Object?> get props => [message, currentNotifications];
}
