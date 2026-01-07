import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import 'package:flutter_alinfo9/views/notifications/logic/notification_cubit.dart';
import 'package:flutter_alinfo9/views/notifications/logic/notification_state.dart';
import 'package:flutter_alinfo9/views/notifications/presentation/widgets/notification_card.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Load notifications when screen opens
    context.read<NotificationCubit>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded && state.unreadCount > 0) {
                return TextButton.icon(
                  onPressed: () {
                    context.read<NotificationCubit>().markAllAsRead();
                  },
                  icon: const Icon(Icons.done_all, size: 18),
                  label: const Text('Mark all read'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          // Show error messages
          if (state is NotificationError || state is NotificationMarkAsReadError) {
            final message = state is NotificationError
                ? state.message
                : (state as NotificationMarkAsReadError).message;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }

          // Show success message when marked as read
          if (state is NotificationMarkedAsRead) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notification marked as read'),
                backgroundColor: AppTheme.accentGreen,
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
        builder: (context, state) {
          return _buildBody(state, isDark);
        },
      ),
    );
  }

  Widget _buildBody(NotificationState state, bool isDark) {
    if (state is NotificationLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is NotificationError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<NotificationCubit>().loadNotifications();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is NotificationLoaded || state is NotificationMarkAsReadError) {
      final notifications = state is NotificationLoaded
          ? state.notifications
          : (state as NotificationMarkAsReadError).currentNotifications;

      if (notifications.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none,
                size: 80,
                color: isDark ? AppTheme.textGrey : AppTheme.lightGrey,
              ),
              const SizedBox(height: 24),
              Text(
                'No notifications yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You\'ll see notifications here when you have updates',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await context.read<NotificationCubit>().refreshNotifications();
        },
        child: ListView.separated(
          itemCount: notifications.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
          ),
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return NotificationCard(
              notification: notification,
              onTap: () {
                // Mark as read when tapped
                if (!notification.read) {
                  context
                      .read<NotificationCubit>()
                      .markAsRead(notification.id);
                }
                // TODO: Navigate to relevant screen based on notification type
              },
            );
          },
        ),
      );
    }

    // Default: Show empty state
    return Center(
      child: Text(
        'Loading notifications...',
        style: TextStyle(
          color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
        ),
      ),
    );
  }
}
