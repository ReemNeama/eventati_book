import 'package:eventati_book/models/notification_models/notification.dart'
    as notification_model;
import 'package:eventati_book/services/notification/notification_service.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Widget for displaying notifications in a dropdown
class NotificationCenter extends StatefulWidget {
  /// Constructor
  const NotificationCenter({super.key});

  @override
  State<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;
  List<notification_model.Notification> _notifications = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  /// Load notifications
  Future<void> _loadNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final notifications = await _notificationService.getNotifications();

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      Logger.e('Error loading notifications: $e', tag: 'NotificationCenter');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load notifications';
      });
    }
  }

  /// Mark a notification as read
  Future<void> _markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);

      setState(() {
        _notifications =
            _notifications.map((notification) {
              if (notification.id == notificationId) {
                return notification.markAsRead();
              }
              return notification;
            }).toList();
      });
    } catch (e) {
      Logger.e(
        'Error marking notification as read: $e',
        tag: 'NotificationCenter',
      );
    }
  }

  /// Mark all notifications as read
  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();

      setState(() {
        _notifications =
            _notifications
                .map((notification) => notification.markAsRead())
                .toList();
      });
    } catch (e) {
      Logger.e(
        'Error marking all notifications as read: $e',
        tag: 'NotificationCenter',
      );
    }
  }

  /// Delete a notification
  Future<void> _deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);

      setState(() {
        _notifications =
            _notifications
                .where((notification) => notification.id != notificationId)
                .toList();
      });
    } catch (e) {
      Logger.e('Error deleting notification: $e', tag: 'NotificationCenter');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final backgroundColor =
        isDarkMode ? AppColorsDark.background : AppColors.background;

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
          _buildHeader(primaryColor),
          Flexible(
            child:
                _isLoading
                    ? const LoadingIndicator(
                      message: 'Loading notifications...',
                    )
                    : _errorMessage != null
                    ? Center(
                      child: Text(_errorMessage!, style: TextStyles.error),
                    )
                    : _notifications.isEmpty
                    ? const EmptyState(
                      icon: Icons.notifications_none,
                      title: 'No Notifications',
                      message: 'You have no notifications at this time.',
                    )
                    : _buildNotificationList(),
          ),
        ],
      ),
    );
  }

  /// Build the header
  Widget _buildHeader(Color primaryColor) {
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
                onPressed: _markAllAsRead,
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
                onPressed: _loadNotifications,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build the notification list
  Widget _buildNotificationList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  /// Build a notification item
  Widget _buildNotificationItem(notification_model.Notification notification) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final unreadColor =
        isDarkMode
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
        _deleteNotification(notification.id);
      },
      child: InkWell(
        onTap: () {
          if (!notification.read) {
            _markAsRead(notification.id);
          }
          // Handle notification tap (navigate to related screen)
          _handleNotificationTap(notification);
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
                            notification.read
                                ? FontWeight.normal
                                : FontWeight.bold,
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
                      timeago.format(notification.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (!notification.read)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        isDarkMode ? AppColorsDark.primary : AppColors.primary,
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
  Widget _buildNotificationIcon(notification_model.NotificationType type) {
    IconData iconData = Icons.notifications; // Default icon
    Color iconColor = Colors.grey; // Default color

    if (type == notification_model.NotificationType.bookingConfirmation ||
        type == notification_model.NotificationType.bookingUpdate ||
        type == notification_model.NotificationType.bookingReminder ||
        type == notification_model.NotificationType.bookingCancellation) {
      iconData = Icons.calendar_today;
      iconColor = Colors.blue;
    } else if (type ==
            notification_model.NotificationType.paymentConfirmation ||
        type == notification_model.NotificationType.paymentReminder) {
      iconData = Icons.payment;
      iconColor = Colors.green;
    } else if (type == notification_model.NotificationType.eventReminder) {
      iconData = Icons.event;
      iconColor = Colors.purple;
    } else if (type == notification_model.NotificationType.taskReminder) {
      iconData = Icons.task_alt;
      iconColor = Colors.orange;
    } else if (type == notification_model.NotificationType.system) {
      iconData = Icons.info;
      iconColor = Colors.grey;
    } else if (type == notification_model.NotificationType.marketing) {
      iconData = Icons.campaign;
      iconColor = Colors.red;
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

  /// Handle notification tap
  void _handleNotificationTap(notification_model.Notification notification) {
    // Navigate to the appropriate screen based on notification type and data
    // This will be implemented based on the app's navigation structure
    Logger.i(
      'Notification tapped: ${notification.id}',
      tag: 'NotificationCenter',
    );
  }
}
