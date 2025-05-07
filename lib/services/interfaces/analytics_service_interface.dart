import 'package:flutter/material.dart';

/// Interface for analytics services
abstract class AnalyticsServiceInterface {
  /// Get an observer for navigation tracking
  RouteObserver<PageRoute> get observer;

  /// Track a screen view
  Future<void> trackScreenView(
    String screenName, {
    Map<String, dynamic>? parameters,
  });

  /// Track a user action
  Future<void> trackUserAction(
    String action, {
    Map<String, dynamic>? parameters,
  });

  /// Track an error
  Future<void> trackError(
    String error, {
    Map<String, dynamic>? parameters,
    StackTrace? stackTrace,
  });

  /// Track a login event
  Future<void> trackLogin({String? method});

  /// Track a sign-up event
  Future<void> trackSignUp({String? method});

  /// Track a search event
  Future<void> trackSearch(String searchTerm);

  /// Track a booking event
  Future<void> trackBooking({
    required String serviceType,
    required String serviceId,
    required String serviceName,
    required double price,
  });

  /// Track a comparison event
  Future<void> trackComparison({
    required String serviceType,
    required List<String> serviceIds,
    required List<String> serviceNames,
  });

  /// Track a filter event
  Future<void> trackFilter({
    required String serviceType,
    required Map<String, dynamic> filters,
  });

  /// Track a sort event
  Future<void> trackSort({
    required String serviceType,
    required String sortBy,
    required bool ascending,
  });

  /// Set user properties
  Future<void> setUserProperties({
    String? userId,
    Map<String, String>? properties,
  });

  /// Set user ID
  Future<void> setUserId(String? userId);

  /// Set current screen
  Future<void> setCurrentScreen(String screenName);

  /// Log event
  Future<void> logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  });

  /// Reset analytics data
  Future<void> resetAnalyticsData();

  /// Enable analytics collection
  Future<void> setAnalyticsCollectionEnabled(bool enabled);

  /// Get app instance ID
  Future<String?> getAppInstanceId();

  /// Set default event parameters
  Future<void> setDefaultEventParameters(Map<String, dynamic>? parameters);

  /// Initialize the analytics service
  Future<void> initialize();

  /// Track app open event
  Future<void> trackAppOpen();

  /// Track in-app purchase
  Future<void> trackInAppPurchase({
    required String itemName,
    required String itemId,
    required double price,
    required String currency,
  });

  /// Track add to cart event
  Future<void> trackAddToCart({
    required String itemName,
    required String itemId,
    required double price,
    required String currency,
  });

  /// Track begin checkout event
  Future<void> trackBeginCheckout({
    required List<String> itemIds,
    required List<String> itemNames,
    required double value,
    required String currency,
  });

  /// Track purchase event
  Future<void> trackPurchase({
    required String transactionId,
    required double value,
    required String currency,
    required List<String> itemIds,
    required List<String> itemNames,
  });

  /// Track share event
  Future<void> trackShare({
    required String contentType,
    required String itemId,
    required String method,
  });

  /// Track tutorial begin event
  Future<void> trackTutorialBegin();

  /// Track tutorial complete event
  Future<void> trackTutorialComplete();

  /// Track level up event
  Future<void> trackLevelUp({
    required int level,
    required String character,
  });

  /// Track achievement unlocked event
  Future<void> trackAchievementUnlocked({
    required String achievementId,
    required String achievementName,
  });

  /// Track app crash event
  Future<void> trackAppCrash({
    required String error,
    required StackTrace stackTrace,
  });

  /// Track notification received event
  Future<void> trackNotificationReceived({
    required String notificationId,
    required String notificationType,
  });

  /// Track notification opened event
  Future<void> trackNotificationOpened({
    required String notificationId,
    required String notificationType,
  });
}
