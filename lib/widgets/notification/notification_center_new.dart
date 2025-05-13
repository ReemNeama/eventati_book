import 'package:eventati_book/models/notification_models/notification.dart';
import 'package:eventati_book/providers/notification_provider.dart';
import 'package:eventati_book/routing/route_names.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

/// Widget for displaying notifications in a dropdown
class NotificationCenter extends StatelessWidget {
  /// Constructor
  const NotificationCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        return _buildNotificationCenter(context, notificationProvider);
      },
    );
  }
  
  /// Build the notification center
  Widget _buildNotificationCenter(BuildContext context, NotificationProvider notificationProvider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final backgroundColor = isDarkMode ? AppColorsDark.background : AppColors.background;
    
    return Container(
      width: 350,
      constraints: const BoxConstraints(maxHeight: 500),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, primaryColor, notificationProvider),
          Flexible(
            child: notificationProvider.isLoading
                ? const LoadingIndicator(message: 'Loading notifications...')
                : notificationProvider.errorMessage != null
                    ? Center(
                        child: Text(notificationProvider.errorMessage!,
                            style: TextStyles.error),
                      )
                    : notificationProvider.notifications.isEmpty
                        ? const EmptyState(
                            icon: Icons.notifications_none,
                            title: 'No Notifications',
                            message: 'You have no notifications at this time.',
                          )
                        : _buildNotificationList(context, notificationProvider),
          ),
        ],
      ),
    );
  }
  
  /// Build the header
  Widget _buildHeader(BuildContext context, Color primaryColor, NotificationProvider notificationProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => notificationProvider.markAllAsRead(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Mark All Read'),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                onPressed: () => notificationProvider.refreshNotifications(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 20,
              ),
              IconButton(
                icon: const Icon(Icons.open_in_new, color: Colors.white, size: 20),
                onPressed: () => Navigator.pushNamed(context, RouteNames.notifications),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 20,
                tooltip: 'View All',
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build the notification list
  Widget _buildNotificationList(BuildContext context, NotificationProvider notificationProvider) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: notificationProvider.notifications.length > 5 
          ? 5 // Show only the 5 most recent notifications
          : notificationProvider.notifications.length,
      itemBuilder: (context, index) {
        final notification = notificationProvider.notifications[index];
        return _buildNotificationItem(context, notification, notificationProvider);
      },
    );
  }
  
  /// Build a notification item
  Widget _buildNotificationItem(BuildContext context, Notification notification, NotificationProvider notificationProvider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final unreadColor = isDarkMode
        ? AppColorsDark.primary.withAlpha(30)
        : AppColors.primary.withAlpha(30);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        notificationProvider.deleteNotification(notification.id);
      },
      child: InkWell(
        onTap: () {
          if (!notification.read) {
            notificationProvider.markAsRead(notification.id);
          }
          // Handle notification tap (navigate to related screen)
          _handleNotificationTap(context, notification);
        },
        child: Container(
          color: notification.read ? null : unreadColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationIcon(notification.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight:
                            notification.read ? FontWeight.normal : FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.read)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColorsDark.primary : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build an icon for a notification type
  Widget _buildNotificationIcon(NotificationType type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case NotificationType.bookingConfirmation:
      case NotificationType.bookingUpdate:
      case NotificationType.bookingReminder:
      case NotificationType.bookingCancellation:
        iconData = Icons.calendar_today;
        iconColor = Colors.blue;
        break;
      case NotificationType.paymentConfirmation:
      case NotificationType.paymentReminder:
        iconData = Icons.payment;
        iconColor = Colors.green;
        break;
      case NotificationType.eventReminder:
        iconData = Icons.event;
        iconColor = Colors.purple;
        break;
      case NotificationType.taskReminder:
        iconData = Icons.task_alt;
        iconColor = Colors.orange;
        break;
      case NotificationType.system:
        iconData = Icons.info;
        iconColor = Colors.grey;
        break;
      case NotificationType.marketing:
        iconData = Icons.campaign;
        iconColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withAlpha(30),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, size: 20, color: iconColor),
    );
  }
  
  /// Format a date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 1) {
      // Today
      return DateFormat.jm().format(date); // e.g., 3:30 PM
    } else if (difference.inDays < 2) {
      // Yesterday
      return 'Yesterday, ${DateFormat.jm().format(date)}';
    } else if (difference.inDays < 7) {
      // This week
      return DateFormat.E().format(date); // e.g., Mon, Tue
    } else {
      // Older
      return DateFormat.yMd().format(date); // e.g., 1/1/2021
    }
  }
  
  /// Handle notification tap
  void _handleNotificationTap(BuildContext context, Notification notification) {
    // Navigate to the appropriate screen based on notification type and data
    // This will be implemented based on the app's navigation structure
    Logger.i('Notification tapped: ${notification.id}', tag: 'NotificationCenter');
    
    // For now, just navigate to the notification list screen
    Navigator.pushNamed(context, RouteNames.notifications);
  }
}
