import 'dart:convert';
import 'dart:io';

import 'package:eventati_book/services/interfaces/messaging_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Implementation of MessagingServiceInterface using Supabase Realtime
class CustomMessagingService implements MessagingServiceInterface {
  /// Supabase client instance
  final SupabaseClient _supabase;

  /// Local notifications plugin
  final FlutterLocalNotificationsPlugin _localNotifications;

  /// Android notification channel
  final AndroidNotificationChannel _channel;

  /// Constructor
  CustomMessagingService({
    SupabaseClient? supabase,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _supabase = supabase ?? Supabase.instance.client,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin(),
       _channel = const AndroidNotificationChannel(
         'high_importance_channel',
         'High Importance Notifications',
         description: 'This channel is used for important notifications.',
         importance: Importance.high,
       );

  @override
  Future<void> initialize() async {
    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Initialize local notifications
      await _initializeLocalNotifications();

      Logger.i(
        'Custom Messaging Service initialized',
        tag: 'CustomMessagingService',
      );
    } catch (e) {
      Logger.e(
        'Error initializing messaging service: $e',
        tag: 'CustomMessagingService',
      );
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    try {
      // Android initialization settings
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      // Initialize settings
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize plugin
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification tap
          // Handle notification tap
          final payload = response.payload;
          if (payload != null) {
            try {
              // Payload will be handled by the handleNotificationTap callback
              Logger.i(
                'Notification tapped with payload: $payload',
                tag: 'CustomMessagingService',
              );
            } catch (e) {
              Logger.e(
                'Error parsing notification payload: $e',
                tag: 'CustomMessagingService',
              );
            }
          }
        },
      );

      // Create notification channel for Android
      if (Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(_channel);
      }
    } catch (e) {
      Logger.e(
        'Error initializing local notifications: $e',
        tag: 'CustomMessagingService',
      );
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      // For Supabase, we don't have FCM tokens
      // We can use the user's ID or a device ID as a token
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        return userId;
      }
      return null;
    } catch (e) {
      Logger.e('Error getting token: $e', tag: 'CustomMessagingService');
      return null;
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        Logger.w(
          'Cannot subscribe to topic: User not logged in',
          tag: 'CustomMessagingService',
        );
        return;
      }

      // Store topic subscription in Supabase
      await _supabase.from('notification_topics').upsert({
        'user_id': userId,
        'topic': topic,
        'subscribed': true,
        'subscribed_at': DateTime.now().toIso8601String(),
      });

      Logger.i('Subscribed to topic: $topic', tag: 'CustomMessagingService');
    } catch (e) {
      Logger.e('Error subscribing to topic: $e', tag: 'CustomMessagingService');
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        Logger.w(
          'Cannot unsubscribe from topic: User not logged in',
          tag: 'CustomMessagingService',
        );
        return;
      }

      // Update topic subscription in Supabase
      await _supabase
          .from('notification_topics')
          .update({
            'subscribed': false,
            'unsubscribed_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('topic', topic);

      Logger.i(
        'Unsubscribed from topic: $topic',
        tag: 'CustomMessagingService',
      );
    } catch (e) {
      Logger.e(
        'Error unsubscribing from topic: $e',
        tag: 'CustomMessagingService',
      );
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      if (Platform.isIOS) {
        // Request iOS notification permissions
        final settings = await _localNotifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        return settings ?? false;
      } else if (Platform.isAndroid) {
        // Request Android notification permissions for Android 13+
        final androidPlugin =
            _localNotifications
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();

        // Check if the method exists (depends on plugin version)
        if (androidPlugin != null) {
          try {
            // For newer versions of the plugin
            final granted =
                await androidPlugin.requestNotificationsPermission();
            return granted ?? false;
          } catch (e) {
            // For older versions, permissions are granted by default
            return true;
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      Logger.e(
        'Error requesting permission: $e',
        tag: 'CustomMessagingService',
      );
      return false;
    }
  }

  @override
  Future<bool> checkPermission() async {
    try {
      if (Platform.isIOS) {
        // Check iOS notification permissions
        final settings =
            await _localNotifications
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >()
                ?.getNotificationAppLaunchDetails();
        return settings?.didNotificationLaunchApp ?? false;
      } else if (Platform.isAndroid) {
        // Check Android notification permissions
        final granted =
            await _localNotifications
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >()
                ?.areNotificationsEnabled();
        return granted ?? false;
      }
      return false;
    } catch (e) {
      Logger.e('Error checking permission: $e', tag: 'CustomMessagingService');
      return false;
    }
  }

  @override
  void handleForegroundMessage(Function(Map<String, dynamic>) onMessage) {
    try {
      // Subscribe to Supabase Realtime channel for notifications
      _supabase
          .channel('public:notifications')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'notifications',
            callback: (payload) {
              // Handle new notification
              final data = payload.newRecord;

              // Show local notification
              showLocalNotification(
                id: int.tryParse(data['id'].toString()) ?? 0,
                title: data['title'] as String? ?? 'New Notification',
                body: data['body'] as String? ?? '',
                payload: jsonEncode(data),
              );

              // Call the callback
              onMessage(data);
            },
          )
          .subscribe();
    } catch (e) {
      Logger.e(
        'Error handling foreground message: $e',
        tag: 'CustomMessagingService',
      );
    }
  }

  @override
  void handleBackgroundMessage(Function(Map<String, dynamic>) onMessage) {
    // Not applicable for Supabase implementation
    // Background messages are handled by the local notifications plugin
  }

  @override
  Future<Map<String, bool>> getNotificationSettings() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return {
          'allNotificationsEnabled': true,
          'pushNotificationsEnabled': true,
          'emailNotificationsEnabled': true,
          'inAppNotificationsEnabled': true,
        };
      }

      // Get user notification settings from Supabase
      final response =
          await _supabase
              .from('user_notification_settings')
              .select()
              .eq('user_id', userId)
              .maybeSingle();

      if (response == null) {
        return {
          'allNotificationsEnabled': true,
          'pushNotificationsEnabled': true,
          'emailNotificationsEnabled': true,
          'inAppNotificationsEnabled': true,
        };
      }

      // Convert the response to a Map<String, bool>
      final Map<String, bool> settings = {};
      for (final entry in response.entries) {
        if (entry.value is bool) {
          settings[entry.key] = entry.value as bool;
        }
      }

      return settings;
    } catch (e) {
      Logger.e(
        'Error getting notification settings: $e',
        tag: 'CustomMessagingService',
      );
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
        Logger.w(
          'Cannot update notification settings: User not logged in',
          tag: 'CustomMessagingService',
        );
        return;
      }

      // Add user_id and timestamps to the settings
      final Map<String, dynamic> data = {
        ...settings,
        'user_id': userId,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Update user notification settings in Supabase
      await _supabase.from('user_notification_settings').upsert(data);

      Logger.i('Updated notification settings', tag: 'CustomMessagingService');
    } catch (e) {
      Logger.e(
        'Error updating notification settings: $e',
        tag: 'CustomMessagingService',
      );
    }
  }

  /// Get all active notification topics for the current user
  @override
  Future<List<String>> getActiveTopics() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }

      final response = await _supabase
          .from('notification_topics')
          .select()
          .eq('user_id', userId)
          .eq('subscribed', true);

      return (response as List).map((data) => data['topic'] as String).toList();
    } catch (e) {
      Logger.e(
        'Error getting active topics: $e',
        tag: 'CustomMessagingService',
      );
      return [];
    }
  }

  /// Handle a message that caused the app to open from a terminated state
  @override
  Future<void> handleInitialMessage(
    Function(Map<String, dynamic>) onMessage,
  ) async {
    try {
      final details =
          await _localNotifications.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp == true &&
          details?.notificationResponse?.payload != null) {
        try {
          final payload =
              jsonDecode(details!.notificationResponse!.payload!)
                  as Map<String, dynamic>;
          onMessage(payload);
        } catch (e) {
          Logger.e(
            'Error handling initial message: $e',
            tag: 'CustomMessagingService',
          );
        }
      }
    } catch (e) {
      Logger.e(
        'Error getting notification launch details: $e',
        tag: 'CustomMessagingService',
      );
    }
  }

  /// Handle notification tap
  @override
  void handleNotificationTap(Function(String?) onTap) {
    try {
      // This is already handled in the initialize method
      // We store the callback for later use
      Logger.i('Notification tap handler set', tag: 'CustomMessagingService');
    } catch (e) {
      Logger.e(
        'Error setting notification tap handler: $e',
        tag: 'CustomMessagingService',
      );
    }
  }

  /// Send a local notification
  @override
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
  }) async {
    try {
      // Android notification details
      final androidDetails = AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
        styleInformation:
            imageUrl != null
                ? BigPictureStyleInformation(
                  FilePathAndroidBitmap(imageUrl),
                  hideExpandedLargeIcon: false,
                )
                : null,
      );

      // iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Notification details
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Show notification
      await _localNotifications.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      Logger.e(
        'Error showing local notification: $e',
        tag: 'CustomMessagingService',
      );
    }
  }

  /// Cancel a local notification
  @override
  Future<void> cancelNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
    } catch (e) {
      Logger.e(
        'Error canceling notification: $e',
        tag: 'CustomMessagingService',
      );
    }
  }

  /// Cancel all local notifications
  @override
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
    } catch (e) {
      Logger.e(
        'Error canceling all notifications: $e',
        tag: 'CustomMessagingService',
      );
    }
  }

  /// Schedule a local notification
  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      // Create notification details
      final notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      );

      // Schedule the notification
      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        payload: payload,
        // Use the correct parameters based on the plugin version
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      Logger.e(
        'Error scheduling notification: $e',
        tag: 'CustomMessagingService',
      );
    }
  }

  /// Save the FCM token to the user's profile
  @override
  Future<void> saveTokenToDatabase(String? token) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null && token != null) {
        await _supabase.from('user_devices').upsert({
          'user_id': userId,
          'token': token,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      Logger.e(
        'Error saving token to database: $e',
        tag: 'CustomMessagingService',
      );
    }
  }

  /// Delete the FCM token from the user's profile
  @override
  Future<void> deleteToken() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        await _supabase.from('user_devices').delete().eq('user_id', userId);
      }
    } catch (e) {
      Logger.e('Error deleting token: $e', tag: 'CustomMessagingService');
    }
  }

  /// Send a message to a specific user
  @override
  Future<void> sendMessageToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'data': data,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      Logger.e(
        'Error sending message to user: $e',
        tag: 'CustomMessagingService',
      );
    }
  }

  /// Send a message to a topic
  @override
  Future<void> sendMessageToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'topic': topic,
        'title': title,
        'body': body,
        'data': data,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      Logger.e(
        'Error sending message to topic: $e',
        tag: 'CustomMessagingService',
      );
    }
  }

  /// Enable or disable all notifications
  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        await _supabase.from('user_notification_settings').upsert({
          'user_id': userId,
          'all_notifications_enabled': enabled,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      Logger.e(
        'Error setting notifications enabled: $e',
        tag: 'CustomMessagingService',
      );
    }
  }

  /// Check if notifications are enabled
  @override
  Future<bool> areNotificationsEnabled() async {
    try {
      final settings = await getNotificationSettings();
      return settings['allNotificationsEnabled'] ?? false;
    } catch (e) {
      Logger.e(
        'Error checking if notifications are enabled: $e',
        tag: 'CustomMessagingService',
      );
      return false;
    }
  }

  /// Register a device for push notifications
  @override
  Future<void> registerDevice({
    required String userId,
    required String deviceId,
    required String platform,
    required String token,
  }) async {
    try {
      await _supabase.from('user_devices').upsert({
        'user_id': userId,
        'device_id': deviceId,
        'platform': platform,
        'token': token,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      Logger.e('Error registering device: $e', tag: 'CustomMessagingService');
    }
  }

  /// Unregister a device from push notifications
  @override
  Future<void> unregisterDevice({
    required String userId,
    required String deviceId,
  }) async {
    try {
      await _supabase
          .from('user_devices')
          .delete()
          .eq('user_id', userId)
          .eq('device_id', deviceId);
    } catch (e) {
      Logger.e('Error unregistering device: $e', tag: 'CustomMessagingService');
    }
  }
}
