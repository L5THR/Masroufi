import 'package:flutter/material.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import 'package:flutter_alinfo9/views/notifications/data/models/notification.dart'
    as models;
import 'package:timeago/timeago.dart' as timeago;

class NotificationCard extends StatelessWidget {
  final models.Notification notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: notification.read
              ? Colors.transparent
              : (isDark
                  ? AppTheme.accentBlue.withValues(alpha: 0.1)
                  : AppTheme.accentBlue.withValues(alpha: 0.05)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppTheme.tertiaryGrey
                    : AppTheme.lightGrey,
              ),
              child: Icon(
                _getNotificationIcon(),
                color: AppTheme.accentBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Notification Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          notification.read ? FontWeight.normal : FontWeight.w600,
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Timestamp
                  Text(
                    timeago.format(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                    ),
                  ),
                ],
              ),
            ),

            // Unread Indicator
            if (!notification.read)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6, left: 8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentBlue,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon() {
    final message = notification.message.toLowerCase();

    // Determine icon based on message content
    if (message.contains('application') || message.contains('applied')) {
      return Icons.work_outline;
    } else if (message.contains('message') || message.contains('chat')) {
      return Icons.chat_bubble_outline;
    } else if (message.contains('interview')) {
      return Icons.calendar_today;
    } else if (message.contains('accepted') || message.contains('approved')) {
      return Icons.check_circle_outline;
    } else if (message.contains('rejected') || message.contains('declined')) {
      return Icons.cancel_outlined;
    } else if (message.contains('profile')) {
      return Icons.person_outline;
    } else {
      return Icons.notifications_outlined;
    }
  }
}
