import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventati_book/services/interfaces/messaging_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
      // Initialize timezone
      tz.initializeTimeZones();

      // Request permission for iOS
      await requestPermission();

      // Initialize local notifications
      await _initializeLocalNotifications();

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
      }
    } catch (e) {
      Logger.e(
        'Error subscribing to topic: $e',
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
        _showNotificationFromMessage(message);
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
      // In a real implementation, this would use Firebase Cloud Functions or a server
      // to send the message. For now, we'll just log it.
      Logger.i(
        'Sending message to user $userId: $title - $body',
        tag: 'FirebaseMessagingService',
      );

      // Create a document in the messages collection
      await _firestore.collection('messages').add({
        'userId': userId,
        'title': title,
        'body': body,
        'data': data,
        'read': false,
        'sentAt': FieldValue.serverTimestamp(),
      });
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
      // In a real implementation, this would use Firebase Cloud Functions or a server
      // to send the message. For now, we'll just log it.
      Logger.i(
        'Sending message to topic $topic: $title - $body',
        tag: 'FirebaseMessagingService',
      );

      // Create a document in the topic_messages collection
      await _firestore.collection('topic_messages').add({
        'topic': topic,
        'title': title,
        'body': body,
        'data': data,
        'sentAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Logger.e(
        'Error sending message to topic: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  @override
  Future<Map<String, bool>> getNotificationSettings() async {
    try {
      // Check if user is logged in
      if (_auth.currentUser == null) {
        return {
          'eventReminders': true,
          'taskDeadlines': true,
          'messages': true,
          'updates': true,
        };
      }

      // Get user's notification settings
      final doc =
          await _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .collection('settings')
              .doc('notifications')
              .get();

      if (!doc.exists) {
        // Return default settings if document doesn't exist
        return {
          'eventReminders': true,
          'taskDeadlines': true,
          'messages': true,
          'updates': true,
        };
      }

      // Return user's settings
      final data = doc.data() as Map<String, dynamic>;
      return {
        'eventReminders': data['eventReminders'] ?? true,
        'taskDeadlines': data['taskDeadlines'] ?? true,
        'messages': data['messages'] ?? true,
        'updates': data['updates'] ?? true,
      };
    } catch (e) {
      Logger.e(
        'Error getting notification settings: $e',
        tag: 'FirebaseMessagingService',
      );

      // Return default settings on error
      return {
        'eventReminders': true,
        'taskDeadlines': true,
        'messages': true,
        'updates': true,
      };
    }
  }

  @override
  Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    try {
      // Check if user is logged in
      if (_auth.currentUser == null) return;

      // Update user's notification settings
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('settings')
          .doc('notifications')
          .set(settings, SetOptions(merge: true));

      // Subscribe or unsubscribe from topics based on settings
      if (settings['eventReminders'] == true) {
        await subscribeToTopic('event_reminders');
      } else {
        await unsubscribeFromTopic('event_reminders');
      }

      if (settings['taskDeadlines'] == true) {
        await subscribeToTopic('task_deadlines');
      } else {
        await unsubscribeFromTopic('task_deadlines');
      }

      if (settings['updates'] == true) {
        await subscribeToTopic('app_updates');
      } else {
        await unsubscribeFromTopic('app_updates');
      }
    } catch (e) {
      Logger.e(
        'Error updating notification settings: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      // Check if user is logged in
      if (_auth.currentUser == null) return;

      // Update user's notification settings
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('settings')
          .doc('notifications')
          .set({
            'enabled': enabled,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      // Subscribe or unsubscribe from all topics
      final topics = await getActiveTopics();

      for (final topic in topics) {
        if (enabled) {
          await subscribeToTopic(topic);
        } else {
          await unsubscribeFromTopic(topic);
        }
      }
    } catch (e) {
      Logger.e(
        'Error setting notifications enabled: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    try {
      // Check if user is logged in
      if (_auth.currentUser == null) return true;

      // Get user's notification settings
      final doc =
          await _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .collection('settings')
              .doc('notifications')
              .get();

      if (!doc.exists) return true;

      // Return enabled status
      final data = doc.data() as Map<String, dynamic>;
      return data['enabled'] ?? true;
    } catch (e) {
      Logger.e(
        'Error checking if notifications are enabled: $e',
        tag: 'FirebaseMessagingService',
      );
      return true;
    }
  }

  @override
  Future<List<String>> getActiveTopics() async {
    try {
      // Check if user is logged in
      if (_auth.currentUser == null) return [];

      // Get user's notification topics
      final snapshot =
          await _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .collection('notification_topics')
              .get();

      // Return topic IDs
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      Logger.e(
        'Error getting active topics: $e',
        tag: 'FirebaseMessagingService',
      );
      return [];
    }
  }

  @override
  Future<void> registerDevice({
    required String userId,
    required String deviceId,
    required String platform,
    required String token,
  }) async {
    try {
      // Register device in the devices collection
      await _firestore.collection('devices').doc(deviceId).set({
        'userId': userId,
        'platform': platform,
        'token': token,
        'lastSeen': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Add device to user's devices
      await _firestore.collection('users').doc(userId).update({
        'devices': FieldValue.arrayUnion([deviceId]),
      });
    } catch (e) {
      Logger.e('Error registering device: $e', tag: 'FirebaseMessagingService');
    }
  }

  @override
  Future<void> unregisterDevice({
    required String userId,
    required String deviceId,
  }) async {
    try {
      // Remove device from devices collection
      await _firestore.collection('devices').doc(deviceId).delete();

      // Remove device from user's devices
      await _firestore.collection('users').doc(userId).update({
        'devices': FieldValue.arrayRemove([deviceId]),
      });
    } catch (e) {
      Logger.e(
        'Error unregistering device: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }

  /// Show a local notification from a remote message
  void _showNotificationFromMessage(RemoteMessage message) {
    try {
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              icon: android.smallIcon,
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
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
      final title = data['title'];
      final body = data['body'];
      final payload = data['data'];

      Logger.i(
        'Handling notification data: $title - $body',
        tag: 'FirebaseMessagingService',
      );

      // Process notification data based on type
      if (payload != null && payload is Map<String, dynamic>) {
        final type = payload['type'];

        switch (type) {
          case 'event':
            // Handle event notification
            break;
          case 'task':
            // Handle task notification
            break;
          case 'message':
            // Handle message notification
            break;
          default:
            // Handle other notification types
            break;
        }
      }
    } catch (e) {
      Logger.e(
        'Error handling notification data: $e',
        tag: 'FirebaseMessagingService',
      );
    }
  }
}

/// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if needed
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Log the message
  // Using print here since Logger might not be initialized in the background
  // In a production app, you would use a different logging mechanism
  // Logger.i('Handling a background message: ${message.messageId}', tag: 'FCM_Background');

  // Process the message
  // This is a simple implementation. In a real app, you might want to store
  // the message in a local database or perform other actions.
}
