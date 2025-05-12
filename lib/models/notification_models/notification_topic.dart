import 'package:eventati_book/models/event_models/event.dart';

/// Enum representing different notification topic categories
enum NotificationTopicCategory {
  /// Event type related topics
  eventType,

  /// Feature related topics
  feature,

  /// Marketing related topics
  marketing,

  /// System related topics
  system,
}

/// Class representing a notification topic
class NotificationTopic {
  /// Unique identifier for the topic
  final String id;

  /// Display name for the topic
  final String name;

  /// Description of the topic
  final String description;

  /// Category of the topic
  final NotificationTopicCategory category;

  /// Whether the topic is enabled by default
  final bool defaultEnabled;

  /// Constructor
  const NotificationTopic({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.defaultEnabled = true,
  });

  /// Create from JSON data
  factory NotificationTopic.fromJson(Map<String, dynamic> json) {
    return NotificationTopic(
      id: json['topic'] ?? json['id'] ?? '',
      name: json['display_name'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      category: _categoryFromString(json['category'] ?? 'system'),
      defaultEnabled: json['default_enabled'] ?? true,
    );
  }

  /// Convert category string to enum
  static NotificationTopicCategory _categoryFromString(String category) {
    switch (category.toLowerCase()) {
      case 'event_type':
      case 'eventtype':
        return NotificationTopicCategory.eventType;
      case 'feature':
        return NotificationTopicCategory.feature;
      case 'marketing':
        return NotificationTopicCategory.marketing;
      case 'system':
      default:
        return NotificationTopicCategory.system;
    }
  }

  /// Get the topic ID with prefix based on category
  String get topicId {
    switch (category) {
      case NotificationTopicCategory.eventType:
        return 'event_type_$id';
      case NotificationTopicCategory.feature:
        return 'feature_$id';
      case NotificationTopicCategory.marketing:
        return 'marketing_$id';
      case NotificationTopicCategory.system:
        return 'system_$id';
    }
  }
}

/// Class containing predefined notification topics
class NotificationTopics {
  /// Private constructor to prevent instantiation
  NotificationTopics._();

  /// Event type topics
  static const NotificationTopic wedding = NotificationTopic(
    id: 'wedding',
    name: 'Wedding',
    description: 'Notifications related to wedding events',
    category: NotificationTopicCategory.eventType,
  );

  static const NotificationTopic businessEvent = NotificationTopic(
    id: 'business_event',
    name: 'Business Event',
    description: 'Notifications related to business events',
    category: NotificationTopicCategory.eventType,
  );

  static const NotificationTopic celebration = NotificationTopic(
    id: 'celebration',
    name: 'Celebration',
    description: 'Notifications related to celebration events',
    category: NotificationTopicCategory.eventType,
  );

  /// Feature topics
  static const NotificationTopic budgetUpdates = NotificationTopic(
    id: 'budget_updates',
    name: 'Budget Updates',
    description: 'Notifications about budget changes and updates',
    category: NotificationTopicCategory.feature,
  );

  static const NotificationTopic guestListUpdates = NotificationTopic(
    id: 'guest_list_updates',
    name: 'Guest List Updates',
    description: 'Notifications about guest list changes and RSVPs',
    category: NotificationTopicCategory.feature,
  );

  static const NotificationTopic taskReminders = NotificationTopic(
    id: 'task_reminders',
    name: 'Task Reminders',
    description: 'Reminders about upcoming tasks and deadlines',
    category: NotificationTopicCategory.feature,
  );

  static const NotificationTopic vendorMessages = NotificationTopic(
    id: 'vendor_messages',
    name: 'Vendor Messages',
    description: 'Notifications about new messages from vendors',
    category: NotificationTopicCategory.feature,
  );

  /// Marketing topics
  static const NotificationTopic promotions = NotificationTopic(
    id: 'promotions',
    name: 'Promotions',
    description: 'Promotional offers and discounts',
    category: NotificationTopicCategory.marketing,
    defaultEnabled: false,
  );

  static const NotificationTopic newFeatures = NotificationTopic(
    id: 'new_features',
    name: 'New Features',
    description: 'Announcements about new app features',
    category: NotificationTopicCategory.marketing,
    defaultEnabled: true,
  );

  /// System topics
  static const NotificationTopic systemUpdates = NotificationTopic(
    id: 'system_updates',
    name: 'System Updates',
    description: 'Important system updates and announcements',
    category: NotificationTopicCategory.system,
    defaultEnabled: true,
  );

  /// Get all available topics
  static List<NotificationTopic> get all => [
    wedding,
    businessEvent,
    celebration,
    budgetUpdates,
    guestListUpdates,
    taskReminders,
    vendorMessages,
    promotions,
    newFeatures,
    systemUpdates,
  ];

  /// Get topics by category
  static List<NotificationTopic> getByCategory(
    NotificationTopicCategory category,
  ) {
    return all.where((topic) => topic.category == category).toList();
  }

  /// Get topic by ID
  static NotificationTopic? getById(String id) {
    try {
      return all.firstWhere((topic) => topic.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get topics for event type
  static List<NotificationTopic> getForEventType(EventType eventType) {
    switch (eventType) {
      case EventType.wedding:
        return [wedding];
      case EventType.business:
        return [businessEvent];
      case EventType.celebration:
        return [celebration];
      default:
        return [];
    }
  }
}
