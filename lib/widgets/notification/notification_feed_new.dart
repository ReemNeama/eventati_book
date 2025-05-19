import 'package:flutter/material.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/routing/route_names.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';

/// A widget that displays a feed of notifications
class NotificationFeedNew extends StatelessWidget {
  /// The title of the feed
  final String title;

  /// The maximum number of notifications to display
  final int maxNotifications;

  /// Whether to show the "See All" button
  final bool showSeeAllButton;

  /// Constructor
  const NotificationFeedNew({
    super.key,
    this.title = 'Notifications',
    this.maxNotifications = 3,
    this.showSeeAllButton = true,
  });

  @override
  Widget build(BuildContext context) {
    // Mock notifications for demonstration
    final List<Map<String, dynamic>> mockNotifications = [
      {
        'title': 'Booking Confirmed',
        'body': 'Your booking for Grand Hotel has been confirmed.',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'read': false,
        'icon': Icons.check_circle,
      },
      {
        'title': 'New Message',
        'body': 'You have a new message from Sunset Beach Resort.',
        'time': DateTime.now().subtract(const Duration(days: 1)),
        'read': true,
        'icon': Icons.message,
      },
      {
        'title': 'Event Reminder',
        'body': 'Your event "Company Annual Meeting" is in 3 days.',
        'time': DateTime.now().subtract(const Duration(days: 2)),
        'read': false,
        'icon': Icons.event,
      },
    ];

    if (mockNotifications.isEmpty) {
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
            if (showSeeAllButton && mockNotifications.length > maxNotifications)
              TextButton(
                onPressed: () {
                  // Navigate to notifications screen
                  NavigationUtils.navigateToNamed(
                    context,
                    RouteNames.profile, // Temporary, should be notifications
                  );
                },
                child: const Text('See All'),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Notification cards
        ...mockNotifications
            .take(maxNotifications)
            .map(
              (notification) => _buildNotificationCard(context, notification),
            ),
      ],
    );
  }

  /// Build a card for a single notification
  Widget _buildNotificationCard(
    BuildContext context,
    Map<String, dynamic> notification,
  ) {
    // Format the timestamp
    final DateTime time = notification['time'] as DateTime;
    final String formattedTime = _formatTimeAgo(time);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // In a real implementation, this would mark the notification as read
          // and navigate to the relevant screen
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
                  color: Color.fromRGBO(
                    Theme.of(context).primaryColor.r.toInt(),
                    Theme.of(context).primaryColor.g.toInt(),
                    Theme.of(context).primaryColor.b.toInt(),
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  notification['icon'] as IconData,
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
                            notification['title'] as String,
                            style: TextStyles.bodyLarge.copyWith(
                              fontWeight:
                                  notification['read'] as bool
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!(notification['read'] as bool))
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
                      notification['body'] as String,
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

  /// Format a timestamp into a human-readable string
  String _formatTimeAgo(DateTime timestamp) {
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
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
