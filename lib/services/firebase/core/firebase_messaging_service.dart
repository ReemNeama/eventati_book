import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventati_book/models/event_models/event.dart';
import 'package:eventati_book/models/notification_models/notification_channel.dart';
import 'package:eventati_book/models/notification_models/notification_settings.dart'
    as app_settings;
import 'package:eventati_book/models/notification_models/notification_topic.dart';
import 'package:eventati_book/services/interfaces/messaging_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

/// Implementation of MessagingServiceInterface using Firebase Cloud Messaging
class FirebaseMessagingService implements MessagingServiceInterface {
  /// Firebase Messaging instance
  final FirebaseMessaging _messaging;

  /// Firebase Auth instance
  final FirebaseAuth _auth;

  /// Firestore instance
  final FirebaseFirestore _firestore;

  /// Local notifications plugin
  final FlutterLocalNotificationsPlugin _localNotifications;

  /// Android notification channel
  final AndroidNotificationChannel _channel;

  /// Function to handle notification tap
  Function(String?)? _onNotificationTap;

  /// User notification settings
  app_settings.NotificationSettings? _userNotificationSettings;

  /// Constructor
  FirebaseMessagingService({
    FirebaseMessaging? messaging,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
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
      // Check if platform is supported
      if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
        Logger.i(
          'Firebase Messaging is not supported on this platform',
          tag: 'FirebaseMessagingService',
        );
        return;
      }

      // Initialize timezone
      tz.initializeTimeZones();

      // Request permission for iOS
      await requestPermission();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Create notification channels
      await _createNotificationChannels();

      // Load user notification settings
      await _loadUserNotificationSettings();

      // Get the initial FCM token
      final token = await getToken();
      Logger.i('FCM Token: $token', tag: 'FirebaseMessagingService');

      // Save token to database if user is logged in
      if (_auth.currentUser != null) {
        await saveTokenToDatabase(token);
      }

      // Set up token refresh listener
      _messaging.onTokenRefresh.listen((newToken) {
        saveTokenToDatabase(newToken);
      });

      // Handle notification tap when app is terminated
      await handleInitialMessage((message) {
        _handleNotificationData(message);
      });

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    } catch (e) {
      Logger.e(
        'Error initializing messaging service: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  /// Create notification channels
  Future<void> _createNotificationChannels() async {
    try {
      if (Platform.isAndroid) {
        // Create all predefined channels
        for (final channel in NotificationChannels.all) {
          await _localNotifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.createNotificationChannel(channel.toAndroidChannel());
        }

        Logger.i(
          'Created ${NotificationChannels.all.length} notification channels',
          tag: 'FirebaseMessagingService',
        );
      }
    } catch (e) {
      Logger.e(
        'Error creating notification channels: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  /// Load user notification settings
  Future<void> _loadUserNotificationSettings() async {
    try {
      if (_auth.currentUser != null) {
        final settingsDoc =
            await _firestore
                .collection('users')
                .doc(_auth.currentUser!.uid)
                .collection('settings')
                .doc('notifications')
                .get();

        _userNotificationSettings = app_settings
            .NotificationSettings.fromDocumentSnapshot(settingsDoc);

        Logger.i(
          'Loaded user notification settings',
          tag: 'FirebaseMessagingService',
        );
      } else {
        _userNotificationSettings =
            app_settings.NotificationSettings.defaultSettings();
      }
    } catch (e) {
      Logger.e(
        'Error loading user notification settings: $e',
        tag: 'FirebaseMessagingService',
      );
      _userNotificationSettings =
          app_settings.NotificationSettings.defaultSettings();
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    try {
      // Initialize Android settings
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // Initialize iOS settings
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

      // Initialize local notifications plugin
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (_onNotificationTap != null) {
            _onNotificationTap!(response.payload);
          }
        },
      );

      // Create Android notification channel
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
        tag: 'FirebaseMessagingService',
      );
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      Logger.e('Error getting FCM token: $e', tag: 'FirebaseMessagingService');
      return null;
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);

      // Save topic subscription to user's profile if logged in
      if (_auth.currentUser != null) {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('notification_topics')
            .doc(topic)
            .set({
              'subscribed': true,
              'subscribedAt': FieldValue.serverTimestamp(),
            });

        // Update user notification settings
        if (_userNotificationSettings != null) {
          _userNotificationSettings = _userNotificationSettings!
              .updateTopicSetting(topic, true);

          // Save updated settings to Firestore
          await _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .collection('settings')
              .doc('notifications')
              .set(_userNotificationSettings!.toFirestore());
        }
      }

      Logger.i('Subscribed to topic: $topic', tag: 'FirebaseMessagingService');
    } catch (e) {
      Logger.e(
        'Error subscribing to topic: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  /// Subscribe to topics for event type
  Future<void> subscribeToEventTypeTopics(String eventType) async {
    try {
      // Get topics for event type
      final EventType type;
      switch (eventType.toLowerCase()) {
        case 'wedding':
          type = EventType.wedding;
          break;
        case 'business_event':
        case 'business':
          type = EventType.business;
          break;
        case 'celebration':
          type = EventType.celebration;
          break;
        default:
          Logger.w(
            'Unknown event type: $eventType',
            tag: 'FirebaseMessagingService',
          );
          return;
      }

      final topics = NotificationTopics.getForEventType(type);

      // Subscribe to each topic
      for (final topic in topics) {
        await subscribeToTopic(topic.topicId);
      }

      Logger.i(
        'Subscribed to ${topics.length} topics for event type: ${type.name}',
        tag: 'FirebaseMessagingService',
      );
    } catch (e) {
      Logger.e(
        'Error subscribing to event type topics: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);

      // Remove topic subscription from user's profile if logged in
      if (_auth.currentUser != null) {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('notification_topics')
            .doc(topic)
            .delete();
      }
    } catch (e) {
      Logger.e(
        'Error unsubscribing from topic: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      Logger.e(
        'Error requesting permission: $e',
        tag: 'FirebaseMessagingService',
      );
      return false;
    }
  }

  @override
  Future<bool> checkPermission() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      Logger.e(
        'Error checking permission: $e',
        tag: 'FirebaseMessagingService',
      );
      return false;
    }
  }

  @override
  void handleForegroundMessage(Function(Map<String, dynamic>) onMessage) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Logger.i(
        'Got a message whilst in the foreground!',
        tag: 'FirebaseMessagingService',
      );

      // Extract message data
      final data = <String, dynamic>{
        'title': message.notification?.title,
        'body': message.notification?.body,
        'data': message.data,
      };

      // Show local notification
      if (message.notification != null) {
        _showLocalNotificationFromMessage(message);
      }

      // Call the callback
      onMessage(data);
    });
  }

  @override
  Future<void> handleInitialMessage(
    Function(Map<String, dynamic>) onMessage,
  ) async {
    try {
      // Get any messages which caused the application to open
      final initialMessage = await _messaging.getInitialMessage();

      if (initialMessage != null) {
        Logger.i(
          'Application opened from terminated state by notification',
          tag: 'FirebaseMessagingService',
        );

        // Extract message data
        final data = <String, dynamic>{
          'title': initialMessage.notification?.title,
          'body': initialMessage.notification?.body,
          'data': initialMessage.data,
        };

        // Call the callback
        onMessage(data);
      }
    } catch (e) {
      Logger.e(
        'Error handling initial message: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  @override
  void handleBackgroundMessage(Function(Map<String, dynamic>) onMessage) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Logger.i(
        'Application opened from background state by notification',
        tag: 'FirebaseMessagingService',
      );

      // Extract message data
      final data = <String, dynamic>{
        'title': message.notification?.title,
        'body': message.notification?.body,
        'data': message.data,
      };

      // Call the callback
      onMessage(data);
    });
  }

  /// Show a local notification from a Firebase message
  Future<void> _showLocalNotificationFromMessage(RemoteMessage message) async {
    try {
      // Get notification details
      final notification = message.notification;
      final android = message.notification?.android;
      final apple = message.notification?.apple;

      if (notification == null) return;

      // Show notification
      await showLocalNotification(
        id: notification.hashCode,
        title: notification.title ?? 'New Notification',
        body: notification.body ?? '',
        payload: jsonEncode(message.data),
        imageUrl: android?.imageUrl ?? apple?.imageUrl,
      );
    } catch (e) {
      Logger.e(
        'Error showing notification from message: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  /// Handle notification data
  void _handleNotificationData(Map<String, dynamic> data) {
    try {
      // Extract notification data
      final title = data['title'] as String?;
      final body = data['body'] as String?;
      final payload = data['data'] as Map<String, dynamic>?;

      Logger.i(
        'Handling notification data: $title, $body, $payload',
        tag: 'FirebaseMessagingService',
      );

      // Process notification data based on type
      final String notificationType = payload?['type'] as String? ?? 'general';

      switch (notificationType) {
        case 'event_reminder':
          _handleEventReminder(title, body, payload);
          break;
        case 'task_due':
          _handleTaskDue(title, body, payload);
          break;
        case 'rsvp_update':
          _handleRsvpUpdate(title, body, payload);
          break;
        case 'budget_alert':
          _handleBudgetAlert(title, body, payload);
          break;
        default:
          _handleGeneralNotification(title, body, payload);
          break;
      }
    } catch (e) {
      Logger.e(
        'Error handling notification data: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

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
        ticker: 'ticker',
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
        tag: 'FirebaseMessagingService',
      );
    }
  }

  @override
  Future<void> cancelNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
    } catch (e) {
      Logger.e(
        'Error canceling notification: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  @override
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
    } catch (e) {
      Logger.e(
        'Error canceling all notifications: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      // Android notification details
      final androidDetails = AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
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

      // Show notification immediately instead of scheduling
      // This is a simplified implementation due to compatibility issues
      await _localNotifications.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      Logger.e(
        'Error scheduling notification: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  @override
  void handleNotificationTap(Function(String?) onTap) {
    _onNotificationTap = onTap;
  }

  @override
  Future<void> saveTokenToDatabase(String? token) async {
    try {
      // Check if user is logged in and token is not null
      if (_auth.currentUser == null || token == null) return;

      // Save token to user's profile
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Logger.e(
        'Error saving token to database: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      // Get current token
      final token = await getToken();

      // Check if user is logged in and token is not null
      if (_auth.currentUser == null || token == null) return;

      // Remove token from user's profile
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });

      // Delete the token from FCM
      await _messaging.deleteToken();
    } catch (e) {
      Logger.e('Error deleting token: $e', tag: 'FirebaseMessagingService');
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
      // Get user's FCM tokens
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final tokens = userDoc.data()?['fcmTokens'] as List<dynamic>?;

      if (tokens == null || tokens.isEmpty) {
        Logger.w(
          'No FCM tokens found for user: $userId',
          tag: 'FirebaseMessagingService',
        );
        return;
      }

      // Create message data
      final messageData = <String, dynamic>{
        'title': title,
        'body': body,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'sender': _auth.currentUser?.uid ?? 'system',
        ...?data,
      };

      // Save message to Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('messages')
          .add(messageData);

      Logger.i(
        'Message sent to user: $userId',
        tag: 'FirebaseMessagingService',
      );
    } catch (e) {
      Logger.e(
        'Error sending message to user: $e',
        tag: 'FirebaseMessagingService',
      );
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
      // Create message data
      final messageData = <String, dynamic>{
        'title': title,
        'body': body,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'sender': _auth.currentUser?.uid ?? 'system',
        'topic': topic,
        ...?data,
      };

      // Save message to Firestore
      await _firestore
          .collection('topics')
          .doc(topic)
          .collection('messages')
          .add(messageData);

      Logger.i(
        'Message sent to topic: $topic',
        tag: 'FirebaseMessagingService',
      );
    } catch (e) {
      Logger.e(
        'Error sending message to topic: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  @override
  Future<List<String>> getActiveTopics() async {
    try {
      if (_auth.currentUser == null) return [];

      // Get user's subscribed topics
      final topicsSnapshot =
          await _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .collection('notification_topics')
              .where('subscribed', isEqualTo: true)
              .get();

      return topicsSnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      Logger.e(
        'Error getting active topics: $e',
        tag: 'FirebaseMessagingService',
      );
      return [];
    }
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      Logger.e(
        'Error checking if notifications are enabled: $e',
        tag: 'FirebaseMessagingService',
      );
      return false;
    }
  }

  @override
  Future<Map<String, bool>> getNotificationSettings() async {
    try {
      // Get Firebase Messaging notification settings
      final messagingSettings = await _messaging.getNotificationSettings();
      final authorizationMap = {
        'authorized':
            messagingSettings.authorizationStatus ==
            AuthorizationStatus.authorized,
        'provisional':
            messagingSettings.authorizationStatus ==
            AuthorizationStatus.provisional,
        'denied':
            messagingSettings.authorizationStatus == AuthorizationStatus.denied,
        'notDetermined':
            messagingSettings.authorizationStatus ==
            AuthorizationStatus.notDetermined,
      };

      // Get user notification settings from Firestore
      if (_auth.currentUser != null) {
        try {
          final settingsDoc =
              await _firestore
                  .collection('users')
                  .doc(_auth.currentUser!.uid)
                  .collection('settings')
                  .doc('notifications')
                  .get();

          if (settingsDoc.exists) {
            final userSettings = app_settings
                .NotificationSettings.fromDocumentSnapshot(settingsDoc);
            _userNotificationSettings = userSettings;

            // Convert topic settings to a flat map
            final Map<String, bool> topicSettings = {};
            for (final entry in userSettings.topicSettings.entries) {
              topicSettings[entry.key] = entry.value;
            }

            // Combine authorization and user settings
            return {
              ...authorizationMap,
              'allNotificationsEnabled': userSettings.allNotificationsEnabled,
              'pushNotificationsEnabled': userSettings.pushNotificationsEnabled,
              'emailNotificationsEnabled':
                  userSettings.emailNotificationsEnabled,
              'inAppNotificationsEnabled':
                  userSettings.inAppNotificationsEnabled,
              ...topicSettings,
            };
          }
        } catch (e) {
          Logger.e(
            'Error getting user notification settings: $e',
            tag: 'FirebaseMessagingService',
          );
        }
      }

      return authorizationMap;
    } catch (e) {
      Logger.e(
        'Error getting notification settings: $e',
        tag: 'FirebaseMessagingService',
      );
      return {};
    }
  }

  @override
  Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('User not logged in');
      }

      // Extract topic settings
      final Map<String, bool> topicSettings = {};
      final keysToRemove = <String>[];

      for (final entry in settings.entries) {
        // Skip non-topic settings
        if ([
          'allNotificationsEnabled',
          'pushNotificationsEnabled',
          'emailNotificationsEnabled',
          'inAppNotificationsEnabled',
          'authorized',
          'provisional',
          'denied',
          'notDetermined',
        ].contains(entry.key)) {
          continue;
        }

        // Add to topic settings
        topicSettings[entry.key] = entry.value;
        keysToRemove.add(entry.key);
      }

      // Remove topic settings from main settings
      final Map<String, bool> mainSettings = Map.from(settings);
      for (final key in keysToRemove) {
        mainSettings.remove(key);
      }

      // Create notification settings object
      final userSettings = app_settings.NotificationSettings(
        allNotificationsEnabled:
            mainSettings['allNotificationsEnabled'] ?? true,
        topicSettings: topicSettings,
        pushNotificationsEnabled:
            mainSettings['pushNotificationsEnabled'] ?? true,
        emailNotificationsEnabled:
            mainSettings['emailNotificationsEnabled'] ?? true,
        inAppNotificationsEnabled:
            mainSettings['inAppNotificationsEnabled'] ?? true,
      );

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('settings')
          .doc('notifications')
          .set(userSettings.toFirestore());

      // Update local settings
      _userNotificationSettings = userSettings;

      // Subscribe/unsubscribe to topics based on settings
      await _syncTopicSubscriptions();

      Logger.i(
        'Notification settings updated',
        tag: 'FirebaseMessagingService',
      );
    } catch (e) {
      Logger.e(
        'Error updating notification settings: $e',
        tag: 'FirebaseMessagingService',
      );
      rethrow;
    }
  }

  /// Sync topic subscriptions based on user settings
  Future<void> _syncTopicSubscriptions() async {
    try {
      if (_auth.currentUser == null || _userNotificationSettings == null) {
        return;
      }

      // Get all topics
      final allTopics = NotificationTopics.all;

      // Subscribe or unsubscribe based on settings
      for (final topic in allTopics) {
        final isEnabled = _userNotificationSettings!.isTopicEnabled(topic.id);

        if (isEnabled) {
          await _messaging.subscribeToTopic(topic.topicId);
        } else {
          await _messaging.unsubscribeFromTopic(topic.topicId);
        }
      }

      Logger.i('Topic subscriptions synced', tag: 'FirebaseMessagingService');
    } catch (e) {
      Logger.e(
        'Error syncing topic subscriptions: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  // Additional methods not in the interface but useful for the implementation

  // This method is not used but kept for future implementation
  Future<void> setBadgeCount(int count) async {
    try {
      // Badge count setting is not directly supported in the current version
      // of flutter_local_notifications
      Logger.w(
        'Setting badge count is not supported directly',
        tag: 'FirebaseMessagingService',
      );
    } catch (e) {
      Logger.e(
        'Error setting badge count: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  Future<void> clearBadgeCount() async {
    try {
      await setBadgeCount(0);
    } catch (e) {
      Logger.e(
        'Error clearing badge count: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  // Handle event reminder notifications
  void _handleEventReminder(
    String? title,
    String? body,
    Map<String, dynamic>? payload,
  ) {
    try {
      final eventId = payload?['eventId'] as String?;
      final eventDate = payload?['eventDate'] as String?;

      Logger.i(
        'Handling event reminder: $eventId, $eventDate',
        tag: 'FirebaseMessagingService',
      );

      // Here you would typically update UI or trigger an action
      // For now, we'll just log the information
    } catch (e) {
      Logger.e(
        'Error handling event reminder: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  // Handle task due notifications
  void _handleTaskDue(
    String? title,
    String? body,
    Map<String, dynamic>? payload,
  ) {
    try {
      final taskId = payload?['taskId'] as String?;
      final dueDate = payload?['dueDate'] as String?;

      Logger.i(
        'Handling task due: $taskId, $dueDate',
        tag: 'FirebaseMessagingService',
      );

      // Here you would typically update UI or trigger an action
      // For now, we'll just log the information
    } catch (e) {
      Logger.e('Error handling task due: $e', tag: 'FirebaseMessagingService');
    }
  }

  // Handle RSVP update notifications
  void _handleRsvpUpdate(
    String? title,
    String? body,
    Map<String, dynamic>? payload,
  ) {
    try {
      final guestId = payload?['guestId'] as String?;
      final status = payload?['status'] as String?;

      Logger.i(
        'Handling RSVP update: $guestId, $status',
        tag: 'FirebaseMessagingService',
      );

      // Here you would typically update UI or trigger an action
      // For now, we'll just log the information
    } catch (e) {
      Logger.e(
        'Error handling RSVP update: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  // Handle budget alert notifications
  void _handleBudgetAlert(
    String? title,
    String? body,
    Map<String, dynamic>? payload,
  ) {
    try {
      final budgetId = payload?['budgetId'] as String?;
      final amount = payload?['amount'] as String?;
      final threshold = payload?['threshold'] as String?;

      Logger.i(
        'Handling budget alert: $budgetId, $amount, $threshold',
        tag: 'FirebaseMessagingService',
      );

      // Here you would typically update UI or trigger an action
      // For now, we'll just log the information
    } catch (e) {
      Logger.e(
        'Error handling budget alert: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  // Handle general notifications
  void _handleGeneralNotification(
    String? title,
    String? body,
    Map<String, dynamic>? payload,
  ) {
    try {
      Logger.i(
        'Handling general notification: $title, $body, $payload',
        tag: 'FirebaseMessagingService',
      );

      // Here you would typically update UI or trigger an action
      // For now, we'll just log the information
    } catch (e) {
      Logger.e(
        'Error handling general notification: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  Future<void> createNotificationChannel({
    required String id,
    required String name,
    required String description,
    required int importance,
    bool enableLights = true,
    bool enableVibration = true,
    bool showBadge = true,
  }) async {
    try {
      if (Platform.isAndroid) {
        final channel = AndroidNotificationChannel(
          id,
          name,
          description: description,
          importance: Importance.values[importance],
          enableLights: enableLights,
          enableVibration: enableVibration,
          showBadge: showBadge,
        );

        await _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(channel);
      }
    } catch (e) {
      Logger.e(
        'Error creating notification channel: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  Future<void> deleteNotificationChannel(String channelId) async {
    try {
      if (Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.deleteNotificationChannel(channelId);
      }
    } catch (e) {
      Logger.e(
        'Error deleting notification channel: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      // This is not directly supported by Firebase Messaging
      // We would need to use platform-specific code
      Logger.w(
        'Setting notifications enabled is not supported directly',
        tag: 'FirebaseMessagingService',
      );
    } catch (e) {
      Logger.e(
        'Error setting notifications enabled: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  // This method is replaced by the implementation above
  // Keeping this comment to avoid confusion

  @override
  Future<void> registerDevice({
    required String deviceId,
    required String platform,
    required String token,
    required String userId,
  }) async {
    try {
      // Save device information to Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('devices')
          .doc(deviceId)
          .set({
            'platform': platform,
            'token': token,
            'lastSeen': FieldValue.serverTimestamp(),
            'isActive': true,
          });

      Logger.i('Device registered: $deviceId', tag: 'FirebaseMessagingService');
    } catch (e) {
      Logger.e('Error registering device: $e', tag: 'FirebaseMessagingService');
    }
  }

  @override
  Future<void> unregisterDevice({
    required String deviceId,
    required String userId,
  }) async {
    try {
      // Mark device as inactive in Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('devices')
          .doc(deviceId)
          .update({
            'isActive': false,
            'unregisteredAt': FieldValue.serverTimestamp(),
          });

      Logger.i(
        'Device unregistered: $deviceId',
        tag: 'FirebaseMessagingService',
      );
    } catch (e) {
      Logger.e(
        'Error unregistering device: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }
}

/// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase
  // await Firebase.initializeApp();

  // Log the message
  // Using print here because Logger might not be initialized in the background
  // This is acceptable for background handlers
  // In a production app, you might want to use a platform channel to log to a file

  // Handle the background message
  // For now, we just show a notification if the message contains a notification payload
  if (message.notification != null) {
    // In a real app, you would use a platform channel to show a notification
    // or store the message for later processing when the app is opened
  }
}
