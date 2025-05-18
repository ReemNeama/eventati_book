import 'package:eventati_book/models/notification_models/notification.dart'
    as notification_model;
import 'package:eventati_book/services/notification/notification_service.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:eventati_book/utils/ui/ui_utils.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Screen for displaying all notifications
class NotificationListScreen extends StatefulWidget {
  /// Constructor
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;
  List<notification_model.Notification> _notifications = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();

    // Track screen view
    Posthog().screen(screenName: 'Notification List Screen');
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
      Logger.e(
        'Error loading notifications: $e',
        tag: 'NotificationListScreen',
      );
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

      if (!mounted) return;

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
        tag: 'NotificationListScreen',
      );
      if (!mounted) return;
      UIUtils.showErrorSnackBar(context, 'Failed to mark notification as read');
    }
  }

  /// Mark all notifications as read
  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();

      if (!mounted) return;

      setState(() {
        _notifications =
            _notifications
                .map((notification) => notification.markAsRead())
                .toList();
      });

      UIUtils.showSuccessSnackBar(context, 'All notifications marked as read');
    } catch (e) {
      Logger.e(
        'Error marking all notifications as read: $e',
        tag: 'NotificationListScreen',
      );
      if (!mounted) return;
      UIUtils.showErrorSnackBar(
        context,
        'Failed to mark all notifications as read',
      );
    }
  }

  /// Delete a notification
  Future<void> _deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);

      if (!mounted) return;

      setState(() {
        _notifications =
            _notifications
                .where((notification) => notification.id != notificationId)
                .toList();
      });

      UIUtils.showSuccessSnackBar(context, 'Notification deleted');
    } catch (e) {
      Logger.e(
        'Error deleting notification: $e',
        tag: 'NotificationListScreen',
      );
      if (!mounted) return;
      UIUtils.showErrorSnackBar(context, 'Failed to delete notification');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: primaryColor,
        actions: [
          if (!_isLoading && _notifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('Mark All Read'),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          _isLoading
              ? const LoadingIndicator(message: 'Loading notifications...')
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: TextStyles.error))
              : _notifications.isEmpty
              ? const EmptyState(
                icon: Icons.notifications_none,
                title: 'No Notifications',
                message: 'You have no notifications at this time.',
              )
              : _buildNotificationList(),
    );
  }

  /// Build the notification list
  Widget _buildNotificationList() {
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  /// Build a notification item
  Widget _buildNotificationItem(notification_model.Notification notification) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final unreadColor =
        isDarkMode
            ? AppColorsDark.primary.withAlpha(30)
            : Color.fromRGBO(
              AppColors.primary.r.toInt(),
              AppColors.primary.g.toInt(),
              AppColors.primary.b.toInt(),
              0.12,
            );

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppColors.error,
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
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationIcon(notification.type),
              const SizedBox(width: 16),
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
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(notification.body, style: TextStyles.bodyMedium),
                    const SizedBox(height: 8),
                    Text(
                      timeago.format(notification.createdAt),
                      style: TextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              if (!notification.read)
                Container(
                  width: 10,
                  height: 10,
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
    Color iconColor = AppColors.disabled; // Default color

    if (type == notification_model.NotificationType.bookingConfirmation ||
        type == notification_model.NotificationType.bookingUpdate ||
        type == notification_model.NotificationType.bookingReminder ||
        type == notification_model.NotificationType.bookingCancellation) {
      iconData = Icons.calendar_today;
      iconColor = AppColors.primary;
    } else if (type ==
            notification_model.NotificationType.paymentConfirmation ||
        type == notification_model.NotificationType.paymentReminder) {
      iconData = Icons.payment;
      iconColor = AppColors.success;
    } else if (type == notification_model.NotificationType.eventReminder) {
      iconData = Icons.event;
      iconColor = Colors.purple;
    } else if (type == notification_model.NotificationType.taskReminder) {
      iconData = Icons.task_alt;
      iconColor = AppColors.warning;
    } else if (type == notification_model.NotificationType.system) {
      iconData = Icons.info;
      iconColor = AppColors.disabled;
    } else if (type == notification_model.NotificationType.marketing) {
      iconData = Icons.campaign;
      iconColor = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withAlpha(30),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, size: 24, color: iconColor),
    );
  }

  /// Handle notification tap
  void _handleNotificationTap(notification_model.Notification notification) {
    // Navigate to the appropriate screen based on notification type and data
    // This will be implemented based on the app's navigation structure
    Logger.i(
      'Notification tapped: ${notification.id}',
      tag: 'NotificationListScreen',
    );
  }
}
