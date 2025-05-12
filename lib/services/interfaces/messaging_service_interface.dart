/// Interface for messaging and notification services
abstract class MessagingServiceInterface {
  /// Initialize the messaging service
  Future<void> initialize();

  /// Get the messaging token for the current device
  Future<String?> getToken();

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic);

  /// Request notification permissions
  Future<bool> requestPermission();

  /// Check if notification permissions are granted
  Future<bool> checkPermission();

  /// Handle a received message when the app is in the foreground
  void handleForegroundMessage(Function(Map<String, dynamic>) onMessage);

  /// Handle a message that caused the app to open from a terminated state
  Future<void> handleInitialMessage(Function(Map<String, dynamic>) onMessage);

  /// Handle a message that caused the app to open from the background
  void handleBackgroundMessage(Function(Map<String, dynamic>) onMessage);

  /// Send a local notification
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
  });

  /// Cancel a local notification
  Future<void> cancelNotification(int id);

  /// Cancel all local notifications
  Future<void> cancelAllNotifications();

  /// Schedule a local notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  });

  /// Handle notification tap
  void handleNotificationTap(Function(String?) onTap);

  /// Save the messaging token to the user's profile
  Future<void> saveTokenToDatabase(String? token);

  /// Delete the messaging token from the user's profile
  Future<void> deleteToken();

  /// Send a message to a specific user
  Future<void> sendMessageToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });

  /// Send a message to a topic
  Future<void> sendMessageToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });

  /// Get the notification settings for the current user
  Future<Map<String, bool>> getNotificationSettings();

  /// Update the notification settings for the current user
  Future<void> updateNotificationSettings(Map<String, bool> settings);

  /// Enable or disable all notifications
  Future<void> setNotificationsEnabled(bool enabled);

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled();

  /// Get all active notification topics for the current user
  Future<List<String>> getActiveTopics();

  /// Register a device for push notifications
  Future<void> registerDevice({
    required String userId,
    required String deviceId,
    required String platform,
    required String token,
  });

  /// Unregister a device from push notifications
  Future<void> unregisterDevice({
    required String userId,
    required String deviceId,
  });
}
