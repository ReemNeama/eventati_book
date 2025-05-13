import 'package:uuid/uuid.dart';

/// Enum representing different notification types
enum NotificationType {
  /// Booking confirmation
  bookingConfirmation,

  /// Booking update
  bookingUpdate,

  /// Booking reminder
  bookingReminder,

  /// Booking cancellation
  bookingCancellation,

  /// Payment confirmation
  paymentConfirmation,

  /// Payment reminder
  paymentReminder,

  /// Event reminder
  eventReminder,

  /// Task reminder
  taskReminder,

  /// System notification
  system,

  /// Marketing notification
  marketing,
}

/// Extension methods for NotificationType
extension NotificationTypeExtension on NotificationType {
  /// Get the display name for the notification type
  String get displayName {
    switch (this) {
      case NotificationType.bookingConfirmation:
        return 'Booking Confirmation';
      case NotificationType.bookingUpdate:
        return 'Booking Update';
      case NotificationType.bookingReminder:
        return 'Booking Reminder';
      case NotificationType.bookingCancellation:
        return 'Booking Cancellation';
      case NotificationType.paymentConfirmation:
        return 'Payment Confirmation';
      case NotificationType.paymentReminder:
        return 'Payment Reminder';
      case NotificationType.eventReminder:
        return 'Event Reminder';
      case NotificationType.taskReminder:
        return 'Task Reminder';
      case NotificationType.system:
        return 'System Notification';
      case NotificationType.marketing:
        return 'Marketing';
    }
  }

  /// Get the topic ID for the notification type
  String get topicId {
    switch (this) {
      case NotificationType.bookingConfirmation:
      case NotificationType.bookingUpdate:
      case NotificationType.bookingCancellation:
      case NotificationType.bookingReminder:
        return 'booking_notifications';
      case NotificationType.paymentConfirmation:
      case NotificationType.paymentReminder:
        return 'payment_notifications';
      case NotificationType.eventReminder:
        return 'event_reminders';
      case NotificationType.taskReminder:
        return 'task_reminders';
      case NotificationType.system:
        return 'system_updates';
      case NotificationType.marketing:
        return 'promotions';
    }
  }
}

/// Class representing a notification
class Notification {
  /// Unique identifier for the notification
  final String id;

  /// User ID that the notification is for
  final String userId;

  /// Title of the notification
  final String title;

  /// Body content of the notification
  final String body;

  /// Type of notification
  final NotificationType type;

  /// Additional data associated with the notification
  final Map<String, dynamic>? data;

  /// Whether the notification has been read
  final bool read;

  /// When the notification was created
  final DateTime createdAt;

  /// Related entity ID (e.g., booking ID, event ID)
  final String? relatedEntityId;

  /// Constructor
  Notification({
    String? id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    this.read = false,
    DateTime? createdAt,
    this.relatedEntityId,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  /// Create a copy of this notification with updated fields
  Notification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, dynamic>? data,
    bool? read,
    DateTime? createdAt,
    String? relatedEntityId,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
    );
  }

  /// Mark the notification as read
  Notification markAsRead() {
    return copyWith(read: true);
  }

  /// Convert to JSON data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.index,
      'data': data,
      'read': read,
      'createdAt': createdAt.toIso8601String(),
      'relatedEntityId': relatedEntityId,
    };
  }

  /// Convert to database document
  Map<String, dynamic> toDatabaseDoc() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type.index,
      'data': data,
      'read': read,
      'created_at': createdAt.toIso8601String(),
      'related_entity_id': relatedEntityId,
    };
  }

  /// Create from JSON data
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      body: json['body'],
      type: NotificationType.values[json['type']],
      data: json['data'],
      read: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      relatedEntityId: json['relatedEntityId'],
    );
  }

  /// Create from database document
  factory Notification.fromDatabaseDoc(Map<String, dynamic> doc) {
    return Notification(
      id: doc['id'],
      userId: doc['user_id'],
      title: doc['title'],
      body: doc['body'],
      type: NotificationType.values[doc['type']],
      data: doc['data'],
      read: doc['read'] ?? false,
      createdAt: DateTime.parse(doc['created_at']),
      relatedEntityId: doc['related_entity_id'],
    );
  }
}
