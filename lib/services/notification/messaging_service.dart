import 'package:eventati_book/services/interfaces/messaging_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementation of the MessagingServiceInterface
class MessagingService implements MessagingServiceInterface {
  /// Supabase client
  final SupabaseClient _supabase;

  /// Constructor
  MessagingService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<void> initialize() async {
    // Implementation will be added later
    Logger.i('Messaging service initialized', tag: 'MessagingService');
  }

  @override
  Future<String?> getToken() async {
    // Implementation will be added later
    return null;
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Add topic to user's subscribed topics
      await _supabase.from('user_notification_topics').upsert({
        'user_id': userId,
        'topic_id': topic,
        'subscribed': true,
      });

      Logger.i('Subscribed to topic: $topic', tag: 'MessagingService');
    } catch (e) {
      Logger.e('Error subscribing to topic: $e', tag: 'MessagingService');
      throw Exception('Failed to subscribe to topic: $e');
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Remove topic from user's subscribed topics
      await _supabase.from('user_notification_topics').upsert({
        'user_id': userId,
        'topic_id': topic,
        'subscribed': false,
      });

      Logger.i('Unsubscribed from topic: $topic', tag: 'MessagingService');
    } catch (e) {
      Logger.e('Error unsubscribing from topic: $e', tag: 'MessagingService');
      throw Exception('Failed to unsubscribe from topic: $e');
    }
  }

  @override
  Future<bool> requestPermission() async {
    // Implementation will be added later
    return true;
  }

  @override
  Future<bool> checkPermission() async {
    // Implementation will be added later
    return true;
  }

  @override
  void handleForegroundMessage(Function(Map<String, dynamic>) onMessage) {
    // Implementation will be added later
  }

  @override
  Future<void> handleInitialMessage(
    Function(Map<String, dynamic>) onMessage,
  ) async {
    // Implementation will be added later
  }

  @override
  void handleBackgroundMessage(Function(Map<String, dynamic>) onMessage) {
    // Implementation will be added later
  }

  @override
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
  }) async {
    // Implementation will be added later
    Logger.i('Local notification shown: $title', tag: 'MessagingService');
  }

  @override
  Future<void> cancelNotification(int id) async {
    // Implementation will be added later
  }

  @override
  Future<void> cancelAllNotifications() async {
    // Implementation will be added later
  }

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // Implementation will be added later
    Logger.i(
      'Notification scheduled for $scheduledDate: $title',
      tag: 'MessagingService',
    );
  }

  @override
  void handleNotificationTap(Function(String?) onTap) {
    // Implementation will be added later
  }

  @override
  Future<void> saveTokenToDatabase(String? token) async {
    // Implementation will be added later
  }

  @override
  Future<void> deleteToken() async {
    // Implementation will be added later
  }

  @override
  Future<void> sendMessageToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Implementation will be added later
    Logger.i('Message sent to user $userId: $title', tag: 'MessagingService');
  }

  @override
  Future<void> sendMessageToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Implementation will be added later
    Logger.i('Message sent to topic $topic: $title', tag: 'MessagingService');
  }

  @override
  Future<Map<String, bool>> getNotificationSettings() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response =
          await _supabase
              .from('user_notification_settings')
              .select()
              .eq('user_id', userId)
              .maybeSingle();

      if (response == null) {
        // Return default settings
        return {
          'allNotificationsEnabled': true,
          'pushNotificationsEnabled': true,
          'emailNotificationsEnabled': true,
          'inAppNotificationsEnabled': true,
        };
      }

      return {
        'allNotificationsEnabled':
            response['all_notifications_enabled'] ?? true,
        'pushNotificationsEnabled':
            response['push_notifications_enabled'] ?? true,
        'emailNotificationsEnabled':
            response['email_notifications_enabled'] ?? true,
        'inAppNotificationsEnabled':
            response['in_app_notifications_enabled'] ?? true,
      };
    } catch (e) {
      Logger.e(
        'Error getting notification settings: $e',
        tag: 'MessagingService',
      );
      // Return default settings
      return {
        'allNotificationsEnabled': true,
        'pushNotificationsEnabled': true,
        'emailNotificationsEnabled': true,
        'inAppNotificationsEnabled': true,
      };
    }
  }

  @override
  Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase.from('user_notification_settings').upsert({
        'user_id': userId,
        'all_notifications_enabled':
            settings['allNotificationsEnabled'] ?? true,
        'push_notifications_enabled':
            settings['pushNotificationsEnabled'] ?? true,
        'email_notifications_enabled':
            settings['emailNotificationsEnabled'] ?? true,
        'in_app_notifications_enabled':
            settings['inAppNotificationsEnabled'] ?? true,
      });

      Logger.i('Notification settings updated', tag: 'MessagingService');
    } catch (e) {
      Logger.e(
        'Error updating notification settings: $e',
        tag: 'MessagingService',
      );
      throw Exception('Failed to update notification settings: $e');
    }
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase.from('user_notification_settings').upsert({
        'user_id': userId,
        'all_notifications_enabled': enabled,
      });

      Logger.i(
        'Notifications ${enabled ? 'enabled' : 'disabled'}',
        tag: 'MessagingService',
      );
    } catch (e) {
      Logger.e(
        'Error setting notifications enabled: $e',
        tag: 'MessagingService',
      );
      throw Exception('Failed to set notifications enabled: $e');
    }
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response =
          await _supabase
              .from('user_notification_settings')
              .select('all_notifications_enabled')
              .eq('user_id', userId)
              .maybeSingle();

      return response?['all_notifications_enabled'] ?? true;
    } catch (e) {
      Logger.e(
        'Error checking if notifications are enabled: $e',
        tag: 'MessagingService',
      );
      return true; // Default to enabled
    }
  }

  @override
  Future<List<String>> getActiveTopics() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('user_notification_topics')
          .select('topic_id')
          .eq('user_id', userId)
          .eq('subscribed', true);

      return response
          .map<String>((item) => item['topic_id'] as String)
          .toList();
    } catch (e) {
      Logger.e('Error getting active topics: $e', tag: 'MessagingService');
      return []; // Return empty list on error
    }
  }

  @override
  Future<void> registerDevice({
    required String userId,
    required String deviceId,
    required String platform,
    required String token,
  }) async {
    // Implementation will be added later
  }

  @override
  Future<void> unregisterDevice({
    required String userId,
    required String deviceId,
  }) async {
    // Implementation will be added later
  }
}
