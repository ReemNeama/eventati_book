import 'dart:async';
import 'dart:convert';

import 'package:eventati_book/models/notification_models/notification.dart';
import 'package:eventati_book/services/interfaces/messaging_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementation of the MessagingServiceInterface
class MessagingService implements MessagingServiceInterface {
  /// Supabase client
  final SupabaseClient _supabase;

  /// Local notifications plugin
  final FlutterLocalNotificationsPlugin _localNotifications;

  /// List of active realtime channels
  final List<RealtimeChannel> _channels = [];

  /// Constructor
  MessagingService({
    SupabaseClient? supabase,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _supabase = supabase ?? Supabase.instance.client,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    try {
      // Initialize local notifications
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification tap
          Logger.i(
            'Notification tapped: ${response.payload}',
            tag: 'MessagingService',
          );
        },
      );

      // Subscribe to realtime channels if user is authenticated
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        _subscribeToRealtimeChannels(userId);
      }

      Logger.i('Messaging service initialized', tag: 'MessagingService');
    } catch (e) {
      Logger.e(
        'Error initializing messaging service: $e',
        tag: 'MessagingService',
      );
    }
  }

  /// Subscribe to realtime channels for the user
  void _subscribeToRealtimeChannels(String userId) {
    try {
      // Subscribe to notifications channel
      final notificationsChannel =
          _supabase
              .channel('public:notifications')
              .onPostgresChanges(
                event: PostgresChangeEvent.insert,
                schema: 'public',
                table: 'notifications',
                filter: PostgresChangeFilter(
                  type: PostgresChangeFilterType.eq,
                  column: 'user_id',
                  value: userId,
                ),
                callback: _handleNotificationInsert,
              )
              .subscribe();

      _channels.add(notificationsChannel);

      // Subscribe to bookings channel
      final bookingsChannel =
          _supabase
              .channel('public:bookings')
              .onPostgresChanges(
                event: PostgresChangeEvent.all,
                schema: 'public',
                table: 'bookings',
                filter: PostgresChangeFilter(
                  type: PostgresChangeFilterType.eq,
                  column: 'user_id',
                  value: userId,
                ),
                callback: _handleBookingChanges,
              )
              .subscribe();

      _channels.add(bookingsChannel);

      // Subscribe to tasks channel
      final tasksChannel =
          _supabase
              .channel('public:tasks')
              .onPostgresChanges(
                event: PostgresChangeEvent.all,
                schema: 'public',
                table: 'tasks',
                filter: PostgresChangeFilter(
                  type: PostgresChangeFilterType.eq,
                  column: 'user_id',
                  value: userId,
                ),
                callback: _handleTaskChanges,
              )
              .subscribe();

      _channels.add(tasksChannel);

      Logger.i('Subscribed to realtime channels', tag: 'MessagingService');
    } catch (e) {
      Logger.e(
        'Error subscribing to realtime channels: $e',
        tag: 'MessagingService',
      );
    }
  }

  /// Handle notification insert event
  void _handleNotificationInsert(PostgresChangePayload payload) {
    try {
      final data = payload.newRecord;
      final notification = Notification.fromDatabaseDoc(data);

      // Show local notification
      _showLocalNotification(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        payload: jsonEncode(data),
      );

      Logger.i(
        'New notification received: ${notification.title}',
        tag: 'MessagingService',
      );
    } catch (e) {
      Logger.e(
        'Error handling notification insert: $e',
        tag: 'MessagingService',
      );
    }
  }

  /// Handle booking changes
  void _handleBookingChanges(PostgresChangePayload payload) {
    try {
      final eventType = payload.eventType;
      final data =
          eventType == PostgresChangeEvent.delete
              ? payload.oldRecord
              : payload.newRecord;

      Logger.i('Booking change detected: $eventType', tag: 'MessagingService');

      // Handle different event types
      switch (eventType) {
        case PostgresChangeEvent.insert:
          // New booking created
          _showLocalNotification(
            id: data['id'].hashCode,
            title: 'New Booking',
            body: 'A new booking has been created',
            payload: jsonEncode(data),
          );
          break;
        case PostgresChangeEvent.update:
          // Booking updated
          _showLocalNotification(
            id: data['id'].hashCode,
            title: 'Booking Updated',
            body: 'Your booking has been updated',
            payload: jsonEncode(data),
          );
          break;
        case PostgresChangeEvent.delete:
          // Booking deleted
          _showLocalNotification(
            id: data['id'].hashCode,
            title: 'Booking Cancelled',
            body: 'A booking has been cancelled',
            payload: jsonEncode(data),
          );
          break;
        default:
          break;
      }
    } catch (e) {
      Logger.e('Error handling booking changes: $e', tag: 'MessagingService');
    }
  }

  /// Handle task changes
  void _handleTaskChanges(PostgresChangePayload payload) {
    try {
      final eventType = payload.eventType;
      final data =
          eventType == PostgresChangeEvent.delete
              ? payload.oldRecord
              : payload.newRecord;

      Logger.i('Task change detected: $eventType', tag: 'MessagingService');

      // Only notify for specific changes
      if (eventType == PostgresChangeEvent.update) {
        // Check if task was completed
        final oldData = payload.oldRecord;
        final newData = payload.newRecord;

        if (oldData['completed'] == false && newData['completed'] == true) {
          _showLocalNotification(
            id: data['id'].hashCode,
            title: 'Task Completed',
            body: 'Task "${data['title']}" has been completed',
            payload: jsonEncode(data),
          );
        } else if (oldData['due_date'] != newData['due_date']) {
          _showLocalNotification(
            id: data['id'].hashCode,
            title: 'Task Updated',
            body: 'Due date for task "${data['title']}" has changed',
            payload: jsonEncode(data),
          );
        }
      }
    } catch (e) {
      Logger.e('Error handling task changes: $e', tag: 'MessagingService');
    }
  }

  /// Show a local notification
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      Logger.i('Local notification shown: $title', tag: 'MessagingService');
    } catch (e) {
      Logger.e('Error showing local notification: $e', tag: 'MessagingService');
    }
  }

  @override
  Future<String?> getToken() async {
    // Not needed for Supabase implementation
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
    await _showLocalNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
    );
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
    // Unsubscribe from all channels
    await _unsubscribeFromAllChannels();
  }

  /// Unsubscribe from all Realtime channels
  Future<void> _unsubscribeFromAllChannels() async {
    try {
      for (final channel in _channels) {
        await channel.unsubscribe();
      }
      _channels.clear();
      Logger.i('Unsubscribed from all channels', tag: 'MessagingService');
    } catch (e) {
      Logger.e(
        'Error unsubscribing from channels: $e',
        tag: 'MessagingService',
      );
    }
  }

  @override
  Future<void> sendMessageToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Create notification in database
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'data': data,
        'read': false,
        'created_at': DateTime.now().toIso8601String(),
        'type': data?['type'] ?? 0,
        'related_entity_id': data?['related_entity_id'],
        'related_entity_type': data?['related_entity_type'],
        'action_url': data?['action_url'],
      });

      Logger.i('Message sent to user $userId: $title', tag: 'MessagingService');
    } catch (e) {
      Logger.e('Error sending message to user: $e', tag: 'MessagingService');
      throw Exception('Failed to send message to user: $e');
    }
  }

  @override
  Future<void> sendMessageToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get all users subscribed to this topic
      final response = await _supabase
          .from('notification_topics')
          .select('user_id')
          .eq('topic', topic)
          .eq('subscribed', true);

      final userIds =
          response.map<String>((item) => item['user_id'] as String).toList();

      // Send notification to each user
      for (final userId in userIds) {
        await sendMessageToUser(
          userId: userId,
          title: title,
          body: body,
          data: {...?data, 'topic': topic},
        );
      }

      Logger.i('Message sent to topic $topic: $title', tag: 'MessagingService');
    } catch (e) {
      Logger.e('Error sending message to topic: $e', tag: 'MessagingService');
      throw Exception('Failed to send message to topic: $e');
    }
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
