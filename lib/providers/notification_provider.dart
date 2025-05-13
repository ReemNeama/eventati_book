import 'dart:async';

import 'package:eventati_book/models/notification_models/notification.dart';
import 'package:eventati_book/services/notification/notification_service.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for managing notification state
class NotificationProvider extends ChangeNotifier {
  /// Notification service
  final NotificationService _notificationService;
  
  /// Supabase client
  final SupabaseClient _supabase;
  
  /// List of notifications
  List<Notification> _notifications = [];
  
  /// Whether notifications are loading
  bool _isLoading = false;
  
  /// Error message if loading fails
  String? _errorMessage;
  
  /// Stream subscription for notifications
  StreamSubscription? _notificationSubscription;
  
  /// Constructor
  NotificationProvider({
    NotificationService? notificationService,
    SupabaseClient? supabase,
  }) : _notificationService = notificationService ?? NotificationService(),
       _supabase = supabase ?? Supabase.instance.client {
    _initializeNotifications();
  }
  
  /// Get the list of notifications
  List<Notification> get notifications => _notifications;
  
  /// Get whether notifications are loading
  bool get isLoading => _isLoading;
  
  /// Get the error message
  String? get errorMessage => _errorMessage;
  
  /// Get the number of unread notifications
  int get unreadCount => _notifications.where((n) => !n.read).length;
  
  /// Initialize notifications
  Future<void> _initializeNotifications() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _errorMessage = 'User not authenticated';
      return;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Load initial notifications
      _notifications = await _notificationService.getNotifications();
      
      // Subscribe to notification updates
      _subscribeToNotifications(user.id);
      
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      Logger.e('Error initializing notifications: $e', tag: 'NotificationProvider');
      _isLoading = false;
      _errorMessage = 'Failed to load notifications';
      notifyListeners();
    }
  }
  
  /// Subscribe to notification updates
  void _subscribeToNotifications(String userId) {
    _notificationSubscription?.cancel();
    
    _notificationSubscription = _notificationService
        .getNotificationsStream(userId)
        .listen(
          (notifications) {
            _notifications = notifications;
            notifyListeners();
          },
          onError: (error) {
            Logger.e('Error in notification stream: $error', tag: 'NotificationProvider');
          },
        );
  }
  
  /// Refresh notifications
  Future<void> refreshNotifications() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _notifications = await _notificationService.getNotifications();
      
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      Logger.e('Error refreshing notifications: $e', tag: 'NotificationProvider');
      _isLoading = false;
      _errorMessage = 'Failed to refresh notifications';
      notifyListeners();
    }
  }
  
  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      
      // Update local state
      _notifications = _notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.markAsRead();
        }
        return notification;
      }).toList();
      
      notifyListeners();
    } catch (e) {
      Logger.e('Error marking notification as read: $e', tag: 'NotificationProvider');
      throw Exception('Failed to mark notification as read');
    }
  }
  
  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      
      // Update local state
      _notifications = _notifications
          .map((notification) => notification.markAsRead())
          .toList();
      
      notifyListeners();
    } catch (e) {
      Logger.e('Error marking all notifications as read: $e', tag: 'NotificationProvider');
      throw Exception('Failed to mark all notifications as read');
    }
  }
  
  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      
      // Update local state
      _notifications = _notifications
          .where((notification) => notification.id != notificationId)
          .toList();
      
      notifyListeners();
    } catch (e) {
      Logger.e('Error deleting notification: $e', tag: 'NotificationProvider');
      throw Exception('Failed to delete notification');
    }
  }
  
  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }
}
