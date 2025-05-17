import 'dart:async';

import 'package:eventati_book/models/notification_models/notification.dart';
import 'package:eventati_book/services/notification/notification_service.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling Supabase Realtime notifications
class RealtimeNotificationService extends ChangeNotifier {
  /// Supabase client
  final SupabaseClient _supabase;

  /// Notification service
  final NotificationService _notificationService;

  /// List of active realtime channels
  final List<RealtimeChannel> _channels = [];

  /// Stream controller for notifications
  final StreamController<Notification> _notificationStreamController =
      StreamController<Notification>.broadcast();

  /// Stream of notifications
  Stream<Notification> get notificationStream =>
      _notificationStreamController.stream;

  /// Constructor
  RealtimeNotificationService({
    SupabaseClient? supabase,
    NotificationService? notificationService,
  }) : _supabase = supabase ?? Supabase.instance.client,
       _notificationService =
           notificationService ??
           (throw ArgumentError('Notification service is required'));

  /// Initialize the service
  Future<void> initialize() async {
    try {
      // Subscribe to realtime channels if user is authenticated
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        await subscribeToUserChannels(userId);
      }

      // Listen for auth state changes
      _supabase.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;

        if (event == AuthChangeEvent.signedIn && session != null) {
          subscribeToUserChannels(session.user.id);
        } else if (event == AuthChangeEvent.signedOut) {
          unsubscribeFromAllChannels();
        }
      });

      Logger.i(
        'Realtime notification service initialized',
        tag: 'RealtimeNotificationService',
      );
    } catch (e) {
      Logger.e(
        'Error initializing realtime notification service: $e',
        tag: 'RealtimeNotificationService',
      );
    }
  }

  /// Subscribe to user-specific channels
  Future<void> subscribeToUserChannels(String userId) async {
    try {
      // Unsubscribe from any existing channels first
      await unsubscribeFromAllChannels();

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

      Logger.i(
        'Subscribed to user channels',
        tag: 'RealtimeNotificationService',
      );
    } catch (e) {
      Logger.e(
        'Error subscribing to user channels: $e',
        tag: 'RealtimeNotificationService',
      );
    }
  }

  /// Unsubscribe from all channels
  Future<void> unsubscribeFromAllChannels() async {
    try {
      for (final channel in _channels) {
        await channel.unsubscribe();
      }
      _channels.clear();
      Logger.i(
        'Unsubscribed from all channels',
        tag: 'RealtimeNotificationService',
      );
    } catch (e) {
      Logger.e(
        'Error unsubscribing from channels: $e',
        tag: 'RealtimeNotificationService',
      );
    }
  }

  /// Handle notification insert event
  void _handleNotificationInsert(PostgresChangePayload payload) {
    try {
      final data = payload.newRecord;
      final notification = Notification.fromDatabaseDoc(data);

      // Add to stream
      _notificationStreamController.add(notification);

      // Notify listeners
      notifyListeners();

      Logger.i(
        'New notification received: ${notification.title}',
        tag: 'RealtimeNotificationService',
      );
    } catch (e) {
      Logger.e(
        'Error handling notification insert: $e',
        tag: 'RealtimeNotificationService',
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

      Logger.i(
        'Booking change detected: $eventType',
        tag: 'RealtimeNotificationService',
      );

      // Create appropriate notification based on event type
      if (eventType == PostgresChangeEvent.insert) {
        _notificationService.createBookingConfirmationNotificationById(
          data['id'],
          data['user_id'],
        );
      } else if (eventType == PostgresChangeEvent.update) {
        _notificationService.createBookingUpdateNotificationById(
          data['id'],
          data['user_id'],
        );
      }
    } catch (e) {
      Logger.e(
        'Error handling booking changes: $e',
        tag: 'RealtimeNotificationService',
      );
    }
  }

  /// Handle task changes
  void _handleTaskChanges(PostgresChangePayload payload) {
    try {
      final eventType = payload.eventType;
      if (eventType != PostgresChangeEvent.update) return;

      final oldData = payload.oldRecord;
      final newData = payload.newRecord;

      // Only notify for specific changes
      if (oldData['completed'] == false && newData['completed'] == true) {
        // Task completed notification
        _notificationService.createTaskCompletedNotification(
          newData['id'],
          newData['user_id'],
          newData['title'],
        );
      } else if (oldData['due_date'] != newData['due_date']) {
        // Task due date changed notification
        _notificationService.createTaskUpdatedNotification(
          newData['id'],
          newData['user_id'],
          newData['title'],
        );
      }
    } catch (e) {
      Logger.e(
        'Error handling task changes: $e',
        tag: 'RealtimeNotificationService',
      );
    }
  }

  @override
  void dispose() {
    unsubscribeFromAllChannels();
    _notificationStreamController.close();
    super.dispose();
  }
}
