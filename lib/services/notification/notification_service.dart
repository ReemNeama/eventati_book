import 'package:eventati_book/models/notification_models/notification.dart';
import 'package:eventati_book/models/service_models/booking.dart';
import 'package:eventati_book/services/interfaces/messaging_service_interface.dart';
import 'package:eventati_book/services/supabase/database/notification_database_service.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling notification operations
class NotificationService {
  /// Supabase client
  final SupabaseClient _supabase;

  /// Notification database service
  final NotificationDatabaseService _notificationDatabaseService;

  /// Messaging service
  final MessagingServiceInterface _messagingService;

  /// Constructor
  NotificationService({
    SupabaseClient? supabase,
    NotificationDatabaseService? notificationDatabaseService,
    MessagingServiceInterface? messagingService,
  }) : _supabase = supabase ?? Supabase.instance.client,
       _notificationDatabaseService =
           notificationDatabaseService ?? NotificationDatabaseService(),
       _messagingService =
           messagingService ??
           (throw ArgumentError('Messaging service is required'));

  /// Get the current user ID
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Get all notifications for the current user
  Future<List<Notification>> getNotifications() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      return await _notificationDatabaseService.getNotifications(userId);
    } catch (e) {
      Logger.e('Error getting notifications: $e', tag: 'NotificationService');
      return [];
    }
  }

  /// Get unread notifications for the current user
  Future<List<Notification>> getUnreadNotifications() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      return await _notificationDatabaseService.getUnreadNotifications(userId);
    } catch (e) {
      Logger.e(
        'Error getting unread notifications: $e',
        tag: 'NotificationService',
      );
      return [];
    }
  }

  /// Get a stream of notifications for a user
  Stream<List<Notification>> getNotificationsStream(String userId) {
    try {
      // Create a stream that emits notifications when they change
      return _supabase
          .from('notifications') // Use the table name directly
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .map(
            (data) =>
                data
                    .map<Notification>(
                      (item) => Notification.fromDatabaseDoc(item),
                    )
                    .toList(),
          );
    } catch (e) {
      Logger.e(
        'Error getting notifications stream: $e',
        tag: 'NotificationService',
      );
      // Return an empty stream
      return Stream.value([]);
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationDatabaseService.markAsRead(notificationId);
    } catch (e) {
      Logger.e(
        'Error marking notification as read: $e',
        tag: 'NotificationService',
      );
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _notificationDatabaseService.markAllAsRead(userId);
    } catch (e) {
      Logger.e(
        'Error marking all notifications as read: $e',
        tag: 'NotificationService',
      );
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationDatabaseService.deleteNotification(notificationId);
    } catch (e) {
      Logger.e('Error deleting notification: $e', tag: 'NotificationService');
      throw Exception('Failed to delete notification: $e');
    }
  }

  /// Create a booking confirmation notification
  Future<void> createBookingConfirmationNotification(Booking booking) async {
    try {
      final userId = booking.userId;

      final notification = Notification(
        userId: userId,
        title: 'Booking Confirmed',
        body:
            'Your booking for ${booking.serviceName} on ${_formatDate(booking.bookingDateTime)} has been confirmed.',
        type: NotificationType.bookingConfirmation,
        data: {
          'bookingId': booking.id,
          'serviceId': booking.serviceId,
          'serviceName': booking.serviceName,
          'bookingDateTime': booking.bookingDateTime.toIso8601String(),
        },
        relatedEntityId: booking.id,
      );

      // Create notification in database
      await _notificationDatabaseService.createNotification(notification);

      // Send push notification
      await _messagingService.sendMessageToUser(
        userId: userId,
        title: notification.title,
        body: notification.body,
        data: notification.data,
      );

      // Send email notification (will be implemented in EmailService)
      await _sendEmailNotification(
        userId: userId,
        subject: notification.title,
        body: notification.body,
        data: notification.data,
      );

      Logger.i(
        'Booking confirmation notification created',
        tag: 'NotificationService',
      );
    } catch (e) {
      Logger.e(
        'Error creating booking confirmation notification: $e',
        tag: 'NotificationService',
      );
    }
  }

  /// Create a booking update notification
  Future<void> createBookingUpdateNotification(
    Booking booking,
    String updateMessage,
  ) async {
    try {
      final userId = booking.userId;

      final notification = Notification(
        userId: userId,
        title: 'Booking Updated',
        body: updateMessage,
        type: NotificationType.bookingUpdate,
        data: {
          'bookingId': booking.id,
          'serviceId': booking.serviceId,
          'serviceName': booking.serviceName,
          'bookingDateTime': booking.bookingDateTime.toIso8601String(),
        },
        relatedEntityId: booking.id,
      );

      // Create notification in database
      await _notificationDatabaseService.createNotification(notification);

      // Send push notification
      await _messagingService.sendMessageToUser(
        userId: userId,
        title: notification.title,
        body: notification.body,
        data: notification.data,
      );

      // Send email notification
      await _sendEmailNotification(
        userId: userId,
        subject: notification.title,
        body: notification.body,
        data: notification.data,
      );

      Logger.i(
        'Booking update notification created',
        tag: 'NotificationService',
      );
    } catch (e) {
      Logger.e(
        'Error creating booking update notification: $e',
        tag: 'NotificationService',
      );
    }
  }

  /// Create a booking reminder notification
  Future<void> createBookingReminderNotification(
    Booking booking,
    int daysBeforeEvent,
  ) async {
    try {
      final userId = booking.userId;

      final notification = Notification(
        userId: userId,
        title: 'Upcoming Booking Reminder',
        body:
            'Reminder: Your booking for ${booking.serviceName} is in $daysBeforeEvent ${daysBeforeEvent == 1 ? 'day' : 'days'} on ${_formatDate(booking.bookingDateTime)}.',
        type: NotificationType.bookingReminder,
        data: {
          'bookingId': booking.id,
          'serviceId': booking.serviceId,
          'serviceName': booking.serviceName,
          'bookingDateTime': booking.bookingDateTime.toIso8601String(),
          'daysBeforeEvent': daysBeforeEvent,
        },
        relatedEntityId: booking.id,
      );

      // Create notification in database
      await _notificationDatabaseService.createNotification(notification);

      // Send push notification
      await _messagingService.sendMessageToUser(
        userId: userId,
        title: notification.title,
        body: notification.body,
        data: notification.data,
      );

      // Send email notification
      await _sendEmailNotification(
        userId: userId,
        subject: notification.title,
        body: notification.body,
        data: notification.data,
      );

      Logger.i(
        'Booking reminder notification created',
        tag: 'NotificationService',
      );
    } catch (e) {
      Logger.e(
        'Error creating booking reminder notification: $e',
        tag: 'NotificationService',
      );
    }
  }

  /// Create a booking cancellation notification
  Future<void> createBookingCancellationNotification(Booking booking) async {
    try {
      final userId = booking.userId;

      final notification = Notification(
        userId: userId,
        title: 'Booking Cancelled',
        body:
            'Your booking for ${booking.serviceName} on ${_formatDate(booking.bookingDateTime)} has been cancelled.',
        type: NotificationType.bookingCancellation,
        data: {
          'bookingId': booking.id,
          'serviceId': booking.serviceId,
          'serviceName': booking.serviceName,
          'bookingDateTime': booking.bookingDateTime.toIso8601String(),
        },
        relatedEntityId: booking.id,
      );

      // Create notification in database
      await _notificationDatabaseService.createNotification(notification);

      // Send push notification
      await _messagingService.sendMessageToUser(
        userId: userId,
        title: notification.title,
        body: notification.body,
        data: notification.data,
      );

      // Send email notification
      await _sendEmailNotification(
        userId: userId,
        subject: notification.title,
        body: notification.body,
        data: notification.data,
      );

      Logger.i(
        'Booking cancellation notification created',
        tag: 'NotificationService',
      );
    } catch (e) {
      Logger.e(
        'Error creating booking cancellation notification: $e',
        tag: 'NotificationService',
      );
    }
  }

  /// Format a date for display in notifications
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year at $hour:$minute';
  }

  /// Send an email notification (placeholder for now)
  Future<void> _sendEmailNotification({
    required String userId,
    required String subject,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // This will be implemented in the EmailService
    // For now, just log the email that would be sent
    Logger.i(
      'Would send email to user $userId: $subject',
      tag: 'NotificationService',
    );
  }
}
