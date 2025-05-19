import 'package:flutter/material.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/routing/route_names.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';
import 'package:intl/intl.dart';

/// A widget that displays a feed of notifications
class NotificationFeed extends StatelessWidget {
  /// The title of the feed
  final String title;

  /// The maximum number of notifications to display
  final int maxNotifications;

  /// Whether to show the "See All" button
  final bool showSeeAllButton;

  /// Constructor
  const NotificationFeed({
    super.key,
    this.title = 'Notifications',
    this.maxNotifications = 3,
    this.showSeeAllButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const LoadingIndicator(message: 'Loading notifications...');
        }

        if (provider.errorMessage != null) {
          return EmptyState(
            icon: Icons.error_outline,
            title: 'Error',
            message: provider.errorMessage!,
          );
        }

        final notifications = provider.notifications;

        if (notifications.isEmpty) {
          return const EmptyState(
            icon: Icons.notifications_none,
            title: 'No Notifications',
            message: 'You don\'t have any notifications yet.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyles.subtitle),
                if (showSeeAllButton && notifications.length > maxNotifications)
                  TextButton(
                    onPressed: () {
                      // Navigate to all notifications screen
                      NavigationUtils.navigateToNamed(
                        context,
                        RouteNames.notifications,
                      );
                    },
                    child: const Text('See All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Notification cards
            ...notifications
                .take(maxNotifications)
                .map(
                  (notification) =>
                      _buildNotificationCard(context, notification),
                ),
          ],
        );
      },
    );
  }

  /// Build a card for a single notification
  Widget _buildNotificationCard(
    BuildContext context,
    Notification notification,
  ) {
    // Get icon based on notification type
    IconData icon = _getNotificationIcon(notification.type);

    // Format the timestamp
    final formattedTime = _formatTimestamp(notification.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Mark as read
          Provider.of<NotificationProvider>(
            context,
            listen: false,
          ).markAsRead(notification.id);

          // Navigate to the notification's route if available
          if (notification.actionUrl != null) {
            NavigationUtils.navigateToUrl(context, notification.actionUrl!);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),

              // Notification details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyles.bodyLarge.copyWith(
                              fontWeight:
                                  notification.read
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.read)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedTime,
                      style: TextStyles.bodySmall.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get an icon based on notification type
  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.eventReminder:
        return Icons.event;
      case NotificationType.bookingConfirmation:
        return Icons.check_circle;
      case NotificationType.bookingCancellation:
        return Icons.cancel;
      case NotificationType.paymentConfirmation:
        return Icons.payment;
      case NotificationType.taskReminder:
        return Icons.task_alt;
      case NotificationType.systemNotification:
        return Icons.info;
      case NotificationType.messageNotification:
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }

  /// Format a timestamp into a human-readable string
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }
}
