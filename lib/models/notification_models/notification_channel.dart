import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Class representing a notification channel
class NotificationChannel {
  /// Unique identifier for the channel
  final String id;

  /// Display name for the channel
  final String name;

  /// Description of the channel
  final String description;

  /// Importance level of the channel
  final Importance importance;

  /// Whether to enable lights for notifications in this channel
  final bool enableLights;

  /// Whether to enable vibration for notifications in this channel
  final bool enableVibration;

  /// Whether to show badge for notifications in this channel
  final bool showBadge;

  /// Constructor
  const NotificationChannel({
    required this.id,
    required this.name,
    required this.description,
    required this.importance,
    this.enableLights = true,
    this.enableVibration = true,
    this.showBadge = true,
  });

  /// Convert to AndroidNotificationChannel
  AndroidNotificationChannel toAndroidChannel() {
    return AndroidNotificationChannel(
      id,
      name,
      description: description,
      importance: importance,
      enableLights: enableLights,
      enableVibration: enableVibration,
      showBadge: showBadge,
    );
  }
}

/// Class containing predefined notification channels
class NotificationChannels {
  /// Private constructor to prevent instantiation
  NotificationChannels._();

  /// High importance channel for critical notifications
  static const NotificationChannel highImportance = NotificationChannel(
    id: 'high_importance_channel',
    name: 'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  /// Default channel for general notifications
  static const NotificationChannel general = NotificationChannel(
    id: 'general_channel',
    name: 'General Notifications',
    description: 'This channel is used for general notifications.',
    importance: Importance.defaultImportance,
  );

  /// Event reminders channel
  static const NotificationChannel eventReminders = NotificationChannel(
    id: 'event_reminders_channel',
    name: 'Event Reminders',
    description: 'This channel is used for event reminder notifications.',
    importance: Importance.high,
    enableLights: true,
    enableVibration: true,
    showBadge: true,
  );

  /// Task reminders channel
  static const NotificationChannel taskReminders = NotificationChannel(
    id: 'task_reminders_channel',
    name: 'Task Reminders',
    description: 'This channel is used for task reminder notifications.',
    importance: Importance.high,
    enableLights: true,
    enableVibration: true,
    showBadge: true,
  );

  /// Messages channel
  static const NotificationChannel messages = NotificationChannel(
    id: 'messages_channel',
    name: 'Messages',
    description: 'This channel is used for message notifications.',
    importance: Importance.high,
    enableLights: true,
    enableVibration: true,
    showBadge: true,
  );

  /// Updates channel
  static const NotificationChannel updates = NotificationChannel(
    id: 'updates_channel',
    name: 'Updates',
    description: 'This channel is used for update notifications.',
    importance: Importance.defaultImportance,
    enableLights: false,
    enableVibration: false,
    showBadge: true,
  );

  /// Marketing channel
  static const NotificationChannel marketing = NotificationChannel(
    id: 'marketing_channel',
    name: 'Marketing',
    description: 'This channel is used for marketing notifications.',
    importance: Importance.low,
    enableLights: false,
    enableVibration: false,
    showBadge: false,
  );

  /// Get all available channels
  static List<NotificationChannel> get all => [
    highImportance,
    general,
    eventReminders,
    taskReminders,
    messages,
    updates,
    marketing,
  ];

  /// Get channel by ID
  static NotificationChannel? getById(String id) {
    try {
      return all.firstWhere((channel) => channel.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get channel for notification type
  static NotificationChannel getForNotificationType(String type) {
    switch (type) {
      case 'event_reminder':
        return eventReminders;
      case 'task_due':
        return taskReminders;
      case 'rsvp_update':
        return eventReminders;
      case 'budget_alert':
        return highImportance;
      case 'vendor_message':
        return messages;
      case 'system_update':
        return updates;
      case 'marketing':
        return marketing;
      default:
        return general;
    }
  }
}
