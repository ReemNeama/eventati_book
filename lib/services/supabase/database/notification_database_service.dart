import 'package:eventati_book/models/notification_models/notification.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling notification-related database operations with Supabase
class NotificationDatabaseService {
  /// Supabase client
  final SupabaseClient _supabase;

  /// Table name for notifications
  static const String _notificationsTable = 'notifications';

  /// Constructor
  NotificationDatabaseService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Get all notifications for a user
  Future<List<Notification>> getNotifications(String userId) async {
    try {
      final response = await _supabase
          .from(_notificationsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response
          .map<Notification>((data) => Notification.fromDatabaseDoc(data))
          .toList();
    } catch (e) {
      Logger.e('Error getting notifications: $e',
          tag: 'NotificationDatabaseService');
      return [];
    }
  }

  /// Get unread notifications for a user
  Future<List<Notification>> getUnreadNotifications(String userId) async {
    try {
      final response = await _supabase
          .from(_notificationsTable)
          .select()
          .eq('user_id', userId)
          .eq('read', false)
          .order('created_at', ascending: false);

      return response
          .map<Notification>((data) => Notification.fromDatabaseDoc(data))
          .toList();
    } catch (e) {
      Logger.e('Error getting unread notifications: $e',
          tag: 'NotificationDatabaseService');
      return [];
    }
  }

  /// Get a specific notification by ID
  Future<Notification?> getNotification(String notificationId) async {
    try {
      final response = await _supabase
          .from(_notificationsTable)
          .select()
          .eq('id', notificationId)
          .single();

      return Notification.fromDatabaseDoc(response);
    } catch (e) {
      Logger.e('Error getting notification: $e',
          tag: 'NotificationDatabaseService');
      return null;
    }
  }

  /// Create a new notification
  Future<String> createNotification(Notification notification) async {
    try {
      final response = await _supabase
          .from(_notificationsTable)
          .insert(notification.toDatabaseDoc())
          .select()
          .single();

      return response['id'];
    } catch (e) {
      Logger.e('Error creating notification: $e',
          tag: 'NotificationDatabaseService');
      throw Exception('Failed to create notification: $e');
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from(_notificationsTable)
          .update({'read': true})
          .eq('id', notificationId);
    } catch (e) {
      Logger.e('Error marking notification as read: $e',
          tag: 'NotificationDatabaseService');
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase
          .from(_notificationsTable)
          .update({'read': true})
          .eq('user_id', userId)
          .eq('read', false);
    } catch (e) {
      Logger.e('Error marking all notifications as read: $e',
          tag: 'NotificationDatabaseService');
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from(_notificationsTable)
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      Logger.e('Error deleting notification: $e',
          tag: 'NotificationDatabaseService');
      throw Exception('Failed to delete notification: $e');
    }
  }

  /// Delete all notifications for a user
  Future<void> deleteAllNotifications(String userId) async {
    try {
      await _supabase
          .from(_notificationsTable)
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      Logger.e('Error deleting all notifications: $e',
          tag: 'NotificationDatabaseService');
      throw Exception('Failed to delete all notifications: $e');
    }
  }

  /// Get notifications by type for a user
  Future<List<Notification>> getNotificationsByType(
      String userId, NotificationType type) async {
    try {
      final response = await _supabase
          .from(_notificationsTable)
          .select()
          .eq('user_id', userId)
          .eq('type', type.index)
          .order('created_at', ascending: false);

      return response
          .map<Notification>((data) => Notification.fromDatabaseDoc(data))
          .toList();
    } catch (e) {
      Logger.e('Error getting notifications by type: $e',
          tag: 'NotificationDatabaseService');
      return [];
    }
  }

  /// Get notifications for a specific entity
  Future<List<Notification>> getNotificationsForEntity(
      String userId, String entityId) async {
    try {
      final response = await _supabase
          .from(_notificationsTable)
          .select()
          .eq('user_id', userId)
          .eq('related_entity_id', entityId)
          .order('created_at', ascending: false);

      return response
          .map<Notification>((data) => Notification.fromDatabaseDoc(data))
          .toList();
    } catch (e) {
      Logger.e('Error getting notifications for entity: $e',
          tag: 'NotificationDatabaseService');
      return [];
    }
  }
}
