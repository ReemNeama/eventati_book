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
  Future<void> setUserProfileProperties({
    required String userId,
    String? displayName,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    Map<String, dynamic>? additionalProperties,
  }) async {
    try {
      // Set user ID
      await setUserId(userId);

      // Set standard profile properties
      final properties = <String, String>{};

      if (displayName != null) {
        properties['display_name'] = displayName;
      }

      if (email != null) {
        properties['email'] = email;
      }

      if (photoUrl != null) {
        properties['photo_url'] = photoUrl;
      }

      if (createdAt != null) {
        properties['created_at'] = createdAt.toIso8601String();

        // Calculate account age in days
        final accountAgeDays = DateTime.now().difference(createdAt).inDays;
        properties['account_age_days'] = accountAgeDays.toString();
      }

      // Add additional properties
      if (additionalProperties != null) {
        for (final entry in additionalProperties.entries) {
          properties[entry.key] = entry.value.toString();
        }
      }

      // Set all properties
      await setUserProperties(properties: properties);

      Logger.d(
        'User profile properties set for user: $userId',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error setting user profile properties: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> setUserPreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      // Set user ID
      await setUserId(userId);

      // Convert preferences to string values
      final properties = <String, String>{};

      for (final entry in preferences.entries) {
        // Prefix preference keys to avoid collisions
        properties['pref_${entry.key}'] = entry.value.toString();
      }

      // Set all properties
      await setUserProperties(properties: properties);

      // Log an event for preference changes
      await _analytics.logEvent(
        name: 'user_preferences_updated',
        parameters: {
          'user_id': userId,
          'preference_count': preferences.length,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      Logger.d(
        'User preferences set for user: $userId',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error setting user preferences: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> setUserSegment({
    required String userId,
    required String segmentName,
    Map<String, dynamic>? segmentProperties,
  }) async {
    try {
      // Set user ID
      await setUserId(userId);

      // Set segment as a user property
      await _analytics.setUserProperty(name: 'segment', value: segmentName);

      // Set segment-specific properties
      if (segmentProperties != null) {
        final properties = <String, String>{};

        for (final entry in segmentProperties.entries) {
          // Prefix segment properties to avoid collisions
          properties['segment_${entry.key}'] = entry.value.toString();
        }

        // Set all properties
        await setUserProperties(properties: properties);
      }

      // Log an event for segment assignment
      await _analytics.logEvent(
        name: 'user_segment_assigned',
        parameters: {
          'user_id': userId,
          'segment_name': segmentName,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      Logger.d(
        'User segment set for user: $userId - Segment: $segmentName',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error setting user segment: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackUserLifecycleEvent({
    required String userId,
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      // Set user ID
      await setUserId(userId);

      // Create parameters map with user ID
      final eventParameters = <String, dynamic>{
        'user_id': userId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Add additional parameters
      if (parameters != null) {
        eventParameters.addAll(parameters);
      }

      // Log the lifecycle event
      await _analytics.logEvent(
        name: 'user_lifecycle_${eventName.toLowerCase()}',
        parameters: eventParameters,
      );

      Logger.d(
        'User lifecycle event tracked: $eventName for user: $userId',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error tracking user lifecycle event: $e',
        tag: 'FirebaseAnalyticsService',
      );
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
  Future<void> trackConversion({
    required String conversionName,
    required String conversionType,
    double? value,
    String? currency,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final eventParameters = <String, dynamic>{
        'conversion_name': conversionName,
        'conversion_type': conversionType,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      if (value != null) {
        eventParameters['value'] = value;
      }

      if (currency != null) {
        eventParameters['currency'] = currency;
      }

      if (parameters != null) {
        eventParameters.addAll(parameters);
      }

      await _analytics.logEvent(
        name: 'conversion',
        parameters: eventParameters,
      );

      Logger.d(
        'Conversion tracked: $conversionName ($conversionType)',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error tracking conversion: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackFunnelStep({
    required String funnelName,
    required int stepNumber,
    required String stepName,
    required bool completed,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final eventParameters = <String, dynamic>{
        'funnel_name': funnelName,
        'step_number': stepNumber,
        'step_name': stepName,
        'completed': completed,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      if (parameters != null) {
        eventParameters.addAll(parameters);
      }

      await _analytics.logEvent(
        name: 'funnel_step',
        parameters: eventParameters,
      );

      Logger.d(
        'Funnel step tracked: $funnelName - Step $stepNumber: $stepName (Completed: $completed)',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error tracking funnel step: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackAttribution({
    required String campaign,
    required String source,
    required String medium,
    String? term,
    String? content,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final eventParameters = <String, dynamic>{
        'campaign': campaign,
        'source': source,
        'medium': medium,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      if (term != null) {
        eventParameters['term'] = term;
      }

      if (content != null) {
        eventParameters['content'] = content;
      }

      if (parameters != null) {
        eventParameters.addAll(parameters);
      }

      await _analytics.logEvent(
        name: 'attribution',
        parameters: eventParameters,
      );

      Logger.d(
        'Attribution tracked: $campaign / $source / $medium',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error tracking attribution: $e',
        tag: 'FirebaseAnalyticsService',
      );
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

  @override
  Future<void> trackFeatureUsage({
    required String featureName,
    required String action,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'feature_usage',
        parameters: {
          'feature_name': featureName,
          'action': action,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          ...?parameters,
        },
      );

      Logger.d(
        'Feature usage tracked: $featureName - $action',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error tracking feature usage: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackUserEngagement({
    required String activityType,
    required int timeSpentMs,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'user_engagement',
        parameters: {
          'activity_type': activityType,
          'time_spent_ms': timeSpentMs,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          ...?parameters,
        },
      );

      Logger.d(
        'User engagement tracked: $activityType - ${timeSpentMs}ms',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error tracking user engagement: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackFormSubmission({
    required String formName,
    required bool success,
    String? errorMessage,
    Map<String, dynamic>? formData,
  }) async {
    try {
      final parameters = <String, dynamic>{
        'form_name': formName,
        'success': success,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      if (errorMessage != null) {
        parameters['error_message'] = errorMessage;
      }

      if (formData != null) {
        // Add form data fields individually to avoid nested objects
        for (final entry in formData.entries) {
          // Prefix form data keys to avoid collisions
          parameters['form_data_${entry.key}'] = entry.value.toString();
        }
      }

      await _analytics.logEvent(
        name: 'form_submission',
        parameters: parameters,
      );

      Logger.d(
        'Form submission tracked: $formName - Success: $success',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error tracking form submission: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackContentView({
    required String contentType,
    required String itemId,
    required String itemName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'content_view',
        parameters: {
          'content_type': contentType,
          'item_id': itemId,
          'item_name': itemName,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          ...?parameters,
        },
      );

      Logger.d(
        'Content view tracked: $contentType - $itemName',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error tracking content view: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackPerformanceMetric({
    required String metricName,
    required int valueMs,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'performance_metric',
        parameters: {
          'metric_name': metricName,
          'value_ms': valueMs,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          ...?parameters,
        },
      );

      Logger.d(
        'Performance metric tracked: $metricName - ${valueMs}ms',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error tracking performance metric: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackWizardCompletion({
    required String wizardName,
    required bool completed,
    required int stepsCompleted,
    required int totalSteps,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'wizard_completion',
        parameters: {
          'wizard_name': wizardName,
          'completed': completed,
          'steps_completed': stepsCompleted,
          'total_steps': totalSteps,
          'completion_percentage':
              totalSteps > 0 ? (stepsCompleted / totalSteps * 100).round() : 0,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          ...?parameters,
        },
      );

      Logger.d(
        'Wizard completion tracked: $wizardName - Completed: $completed ($stepsCompleted/$totalSteps)',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error tracking wizard completion: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackEventPlanningAction({
    required String eventId,
    required String eventType,
    required String actionType,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'event_planning_action',
        parameters: {
          'event_id': eventId,
          'event_type': eventType,
          'action_type': actionType,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          ...?parameters,
        },
      );

      Logger.d(
        'Event planning action tracked: $eventType - $actionType',
        tag: 'FirebaseAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error tracking event planning action: $e',
        tag: 'FirebaseAnalyticsService',
      );
    }
  }
}
