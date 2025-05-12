import 'package:eventati_book/utils/database_utils.dart';
import 'package:eventati_book/models/notification_models/notification_topic.dart';

/// Class representing user notification settings
class NotificationSettings {
  /// Whether all notifications are enabled
  final bool allNotificationsEnabled;

  /// Map of topic IDs to enabled status
  final Map<String, bool> topicSettings;

  /// Whether push notifications are enabled
  final bool pushNotificationsEnabled;

  /// Whether email notifications are enabled
  final bool emailNotificationsEnabled;

  /// Whether in-app notifications are enabled
  final bool inAppNotificationsEnabled;

  /// Constructor
  NotificationSettings({
    this.allNotificationsEnabled = true,
    Map<String, bool>? topicSettings,
    this.pushNotificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.inAppNotificationsEnabled = true,
  }) : topicSettings = topicSettings ?? {};

  /// Create default notification settings
  factory NotificationSettings.defaultSettings() {
    final Map<String, bool> defaultTopicSettings = {};

    // Set default values for all topics
    for (final topic in NotificationTopics.all) {
      defaultTopicSettings[topic.id] = topic.defaultEnabled;
    }

    return NotificationSettings(
      allNotificationsEnabled: true,
      topicSettings: defaultTopicSettings,
      pushNotificationsEnabled: true,
      emailNotificationsEnabled: true,
      inAppNotificationsEnabled: true,
    );
  }

  /// Check if a specific topic is enabled
  bool isTopicEnabled(String topicId) {
    // If all notifications are disabled, return false
    if (!allNotificationsEnabled) return false;

    // If topic is not in settings, use default value
    if (!topicSettings.containsKey(topicId)) {
      final topic = NotificationTopics.getById(topicId);
      return topic?.defaultEnabled ?? false;
    }

    return topicSettings[topicId] ?? false;
  }

  /// Create a copy with updated values
  NotificationSettings copyWith({
    bool? allNotificationsEnabled,
    Map<String, bool>? topicSettings,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? inAppNotificationsEnabled,
  }) {
    return NotificationSettings(
      allNotificationsEnabled:
          allNotificationsEnabled ?? this.allNotificationsEnabled,
      topicSettings: topicSettings ?? Map.from(this.topicSettings),
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      inAppNotificationsEnabled:
          inAppNotificationsEnabled ?? this.inAppNotificationsEnabled,
    );
  }

  /// Update a specific topic setting
  NotificationSettings updateTopicSetting(String topicId, bool enabled) {
    final updatedSettings = Map<String, bool>.from(topicSettings);
    updatedSettings[topicId] = enabled;

    return copyWith(topicSettings: updatedSettings);
  }

  /// Convert to JSON data
  Map<String, dynamic> toJson() {
    return {
      'allNotificationsEnabled': allNotificationsEnabled,
      'topicSettings': topicSettings,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'inAppNotificationsEnabled': inAppNotificationsEnabled,
    };
  }

  /// Convert to database document
  Map<String, dynamic> toDatabaseDoc() {
    return toJson();
  }

  /// Create from JSON data
  factory NotificationSettings.fromJson(Map<String, dynamic>? data) {
    if (data == null) {
      return NotificationSettings.defaultSettings();
    }

    return NotificationSettings(
      allNotificationsEnabled: data['allNotificationsEnabled'] ?? true,
      topicSettings: Map<String, bool>.from(data['topicSettings'] ?? {}),
      pushNotificationsEnabled: data['pushNotificationsEnabled'] ?? true,
      emailNotificationsEnabled: data['emailNotificationsEnabled'] ?? true,
      inAppNotificationsEnabled: data['inAppNotificationsEnabled'] ?? true,
    );
  }

  /// Create from database document
  factory NotificationSettings.fromDatabaseDoc(Map<String, dynamic>? data) {
    return NotificationSettings.fromJson(data);
  }

  /// Create from database document
  factory NotificationSettings.fromDocumentSnapshot(
    DbDocumentSnapshot snapshot,
  ) {
    final data = snapshot.getData();
    return NotificationSettings.fromDatabaseDoc(data);
  }
}
