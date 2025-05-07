import 'dart:io';
import 'package:eventati_book/services/interfaces/analytics_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Implementation of AnalyticsServiceInterface using Firebase Analytics
class FirebaseAnalyticsService implements AnalyticsServiceInterface {
  /// Firebase Analytics instance
  final FirebaseAnalytics _analytics;

  /// Route observer for navigation tracking
  final RouteObserver<PageRoute> _routeObserver = RouteObserver<PageRoute>();

  /// Constructor
  FirebaseAnalyticsService({FirebaseAnalytics? analytics})
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  @override
  RouteObserver<PageRoute> get observer => _routeObserver;

  @override
  Future<void> initialize() async {
    try {
      // Check if platform is supported
      if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
        Logger.i(
          'Firebase Analytics is not supported on this platform',
          tag: 'FirebaseAnalyticsService',
        );
        return;
      }

      // Enable analytics collection
      await _analytics.setAnalyticsCollectionEnabled(true);

      // Log app open event
      await trackAppOpen();

      Logger.i(
        'Firebase Analytics initialized',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error initializing Firebase Analytics: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackScreenView(
    String screenName, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenName,
        parameters: parameters,
      );

      Logger.d(
        'Screen view tracked: $screenName',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error tracking screen view: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackUserAction(
    String action, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: action, parameters: parameters);

      Logger.d('User action tracked: $action', tag: 'FirebaseAnalyticsService');
    } catch (e) {
      Logger.e(
        'Error tracking user action: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackError(
    String error, {
    Map<String, dynamic>? parameters,
    StackTrace? stackTrace,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'app_error',
        parameters: {
          'error_message': error,
          'stack_trace': stackTrace?.toString(),
          ...?parameters,
        },
      );

      Logger.d('Error tracked: $error', tag: 'FirebaseAnalyticsService');
    } catch (e) {
      Logger.e('Error tracking error: $e', tag: 'FirebaseAnalyticsService');
    }
  }

  @override
  Future<void> trackLogin({String? method}) async {
    try {
      await _analytics.logLogin(loginMethod: method ?? 'email');

      Logger.d('Login tracked: $method', tag: 'FirebaseAnalyticsService');
    } catch (e) {
      Logger.e('Error tracking login: $e', tag: 'FirebaseAnalyticsService');
    }
  }

  @override
  Future<void> trackSignUp({String? method}) async {
    try {
      await _analytics.logSignUp(signUpMethod: method ?? 'email');

      Logger.d('Sign-up tracked: $method', tag: 'FirebaseAnalyticsService');
    } catch (e) {
      Logger.e('Error tracking sign-up: $e', tag: 'FirebaseAnalyticsService');
    }
  }

  @override
  Future<void> trackSearch(String searchTerm) async {
    try {
      await _analytics.logSearch(searchTerm: searchTerm);

      Logger.d('Search tracked: $searchTerm', tag: 'FirebaseAnalyticsService');
    } catch (e) {
      Logger.e('Error tracking search: $e', tag: 'FirebaseAnalyticsService');
    }
  }

  @override
  Future<void> trackBooking({
    required String serviceType,
    required String serviceId,
    required String serviceName,
    required double price,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'book_service',
        parameters: {
          'service_type': serviceType,
          'service_id': serviceId,
          'service_name': serviceName,
          'price': price,
        },
      );

      Logger.d(
        'Booking tracked: $serviceName',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e('Error tracking booking: $e', tag: 'FirebaseAnalyticsService');
    }
  }

  @override
  Future<void> trackComparison({
    required String serviceType,
    required List<String> serviceIds,
    required List<String> serviceNames,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'compare_services',
        parameters: {
          'service_type': serviceType,
          'service_ids': serviceIds.join(','),
          'service_names': serviceNames.join(','),
          'count': serviceIds.length,
        },
      );

      Logger.d(
        'Comparison tracked: $serviceType',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error tracking comparison: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackFilter({
    required String serviceType,
    required Map<String, dynamic> filters,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'filter_services',
        parameters: {
          'service_type': serviceType,
          'filters': filters.toString(),
          ...filters,
        },
      );

      Logger.d('Filter tracked: $serviceType', tag: 'FirebaseAnalyticsService');
    } catch (e) {
      Logger.e('Error tracking filter: $e', tag: 'FirebaseAnalyticsService');
    }
  }

  @override
  Future<void> trackSort({
    required String serviceType,
    required String sortBy,
    required bool ascending,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'sort_services',
        parameters: {
          'service_type': serviceType,
          'sort_by': sortBy,
          'ascending': ascending,
        },
      );

      Logger.d(
        'Sort tracked: $serviceType, $sortBy',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e('Error tracking sort: $e', tag: 'FirebaseAnalyticsService');
    }
  }

  @override
  Future<void> setUserProperties({
    String? userId,
    Map<String, String>? properties,
  }) async {
    try {
      if (userId != null) {
        await _analytics.setUserId(id: userId);
      }

      if (properties != null) {
        for (final entry in properties.entries) {
          await _analytics.setUserProperty(name: entry.key, value: entry.value);
        }
      }

      Logger.d('User properties set', tag: 'FirebaseAnalyticsService');
    } catch (e) {
      Logger.e(
        'Error setting user properties: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);

      Logger.d('User ID set: $userId', tag: 'FirebaseAnalyticsService');
    } catch (e) {
      Logger.e('Error setting user ID: $e', tag: 'FirebaseAnalyticsService');
    }
  }

  @override
  Future<void> setCurrentScreen(String screenName) async {
    try {
      // Use logScreenView instead of setCurrentScreen (which is deprecated)
      await _analytics.logScreenView(screenName: screenName);

      Logger.d(
        'Current screen set: $screenName',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error setting current screen: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);

      Logger.d('Event logged: $name', tag: 'FirebaseAnalyticsService');
    } catch (e) {
      Logger.e('Error logging event: $e', tag: 'FirebaseAnalyticsService');
    }
  }

  @override
  Future<void> resetAnalyticsData() async {
    try {
      await _analytics.resetAnalyticsData();

      Logger.d('Analytics data reset', tag: 'FirebaseAnalyticsService');
    } catch (e) {
      Logger.e(
        'Error resetting analytics data: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);

      Logger.d(
        'Analytics collection enabled: $enabled',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error setting analytics collection enabled: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<String?> getAppInstanceId() async {
    try {
      final appInstanceId = await _analytics.appInstanceId;

      Logger.d(
        'App instance ID: $appInstanceId',
        tag: 'FirebaseAnalyticsService',
      );

      return appInstanceId;
    } catch (e) {
      Logger.e(
        'Error getting app instance ID: $e',
        tag: 'FirebaseAnalyticsService',
      );
      return null;
    }
  }

  @override
  Future<void> setDefaultEventParameters(
    Map<String, dynamic>? parameters,
  ) async {
    try {
      await _analytics.setDefaultEventParameters(parameters);

      Logger.d('Default event parameters set', tag: 'FirebaseAnalyticsService');
    } catch (e) {
      Logger.e(
        'Error setting default event parameters: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackAppOpen() async {
    try {
      await _analytics.logAppOpen();

      Logger.d('App open tracked', tag: 'FirebaseAnalyticsService');
    } catch (e) {
      Logger.e('Error tracking app open: $e', tag: 'FirebaseAnalyticsService');
    }
  }

  @override
  Future<void> trackInAppPurchase({
    required String itemName,
    required String itemId,
    required double price,
    required String currency,
  }) async {
    try {
      await _analytics.logPurchase(
        currency: currency,
        value: price,
        items: [
          AnalyticsEventItem(itemId: itemId, itemName: itemName, price: price),
        ],
      );

      Logger.d(
        'In-app purchase tracked: $itemName',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error tracking in-app purchase: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackAddToCart({
    required String itemName,
    required String itemId,
    required double price,
    required String currency,
  }) async {
    try {
      await _analytics.logAddToCart(
        currency: currency,
        value: price,
        items: [
          AnalyticsEventItem(itemId: itemId, itemName: itemName, price: price),
        ],
      );

      Logger.d(
        'Add to cart tracked: $itemName',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error tracking add to cart: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackBeginCheckout({
    required List<String> itemIds,
    required List<String> itemNames,
    required double value,
    required String currency,
  }) async {
    try {
      final items = <AnalyticsEventItem>[];

      for (var i = 0; i < itemIds.length; i++) {
        items.add(
          AnalyticsEventItem(
            itemId: itemIds[i],
            itemName: i < itemNames.length ? itemNames[i] : null,
          ),
        );
      }

      await _analytics.logBeginCheckout(
        currency: currency,
        value: value,
        items: items,
      );

      Logger.d('Begin checkout tracked', tag: 'FirebaseAnalyticsService');
    } catch (e) {
      Logger.e(
        'Error tracking begin checkout: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackPurchase({
    required String transactionId,
    required double value,
    required String currency,
    required List<String> itemIds,
    required List<String> itemNames,
  }) async {
    try {
      final items = <AnalyticsEventItem>[];

      for (var i = 0; i < itemIds.length; i++) {
        items.add(
          AnalyticsEventItem(
            itemId: itemIds[i],
            itemName: i < itemNames.length ? itemNames[i] : null,
          ),
        );
      }

      await _analytics.logPurchase(
        transactionId: transactionId,
        currency: currency,
        value: value,
        items: items,
      );

      Logger.d(
        'Purchase tracked: $transactionId',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e('Error tracking purchase: $e', tag: 'FirebaseAnalyticsService');
    }
  }

  @override
  Future<void> trackAchievementUnlocked({
    required String achievementId,
    required String achievementName,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'achievement_unlocked',
        parameters: {
          'achievement_id': achievementId,
          'achievement_name': achievementName,
        },
      );

      Logger.d(
        'Achievement unlocked tracked: $achievementName',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error tracking achievement unlocked: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackTutorialComplete() async {
    try {
      await _analytics.logTutorialComplete();

      Logger.d('Tutorial complete tracked', tag: 'FirebaseAnalyticsService');
    } catch (e) {
      Logger.e(
        'Error tracking tutorial complete: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackTutorialBegin() async {
    try {
      await _analytics.logTutorialBegin();

      Logger.d('Tutorial begin tracked', tag: 'FirebaseAnalyticsService');
    } catch (e) {
      Logger.e(
        'Error tracking tutorial begin: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackLevelUp({required int level, String? character}) async {
    try {
      await _analytics.logLevelUp(level: level, character: character);

      Logger.d('Level up tracked: $level', tag: 'FirebaseAnalyticsService');
    } catch (e) {
      Logger.e('Error tracking level up: $e', tag: 'FirebaseAnalyticsService');
    }
  }

  @override
  Future<void> trackShare({
    required String contentType,
    required String itemId,
    required String method,
  }) async {
    try {
      await _analytics.logShare(
        contentType: contentType,
        itemId: itemId,
        method: method,
      );

      Logger.d('Share tracked: $itemId', tag: 'FirebaseAnalyticsService');
    } catch (e) {
      Logger.e('Error tracking share: $e', tag: 'FirebaseAnalyticsService');
    }
  }

  @override
  Future<void> trackAppCrash({
    required String error,
    required StackTrace stackTrace,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'app_crash',
        parameters: {
          'error_message': error,
          'stack_trace': stackTrace.toString(),
        },
      );

      Logger.d('App crash tracked', tag: 'FirebaseAnalyticsService');
    } catch (e) {
      Logger.e('Error tracking app crash: $e', tag: 'FirebaseAnalyticsService');
    }
  }

  @override
  Future<void> trackNotificationReceived({
    required String notificationId,
    required String notificationType,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'notification_received',
        parameters: {
          'notification_id': notificationId,
          'notification_type': notificationType,
        },
      );

      Logger.d(
        'Notification received tracked: $notificationId',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error tracking notification received: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackNotificationOpened({
    required String notificationId,
    required String notificationType,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'notification_opened',
        parameters: {
          'notification_id': notificationId,
          'notification_type': notificationType,
        },
      );

      Logger.d(
        'Notification opened tracked: $notificationId',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error tracking notification opened: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }
}
