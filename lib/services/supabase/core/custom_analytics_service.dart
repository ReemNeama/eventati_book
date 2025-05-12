import 'package:eventati_book/services/interfaces/analytics_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementation of AnalyticsServiceInterface using PostHog
class CustomAnalyticsService implements AnalyticsServiceInterface {
  /// Supabase client instance
  final SupabaseClient _supabase;

  /// PostHog instance
  final Posthog _posthog = Posthog();

  /// Route observer for navigation tracking
  final RouteObserver<PageRoute> _routeObserver = RouteObserver<PageRoute>();

  /// Default event parameters
  Map<String, dynamic>? _defaultEventParameters;

  /// Constructor
  CustomAnalyticsService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  @override
  RouteObserver<PageRoute> get observer => _routeObserver;

  @override
  Future<void> initialize() async {
    try {
      // PostHog is initialized in main.dart via platform-specific configuration
      Logger.i('PostHog Analytics initialized', tag: 'CustomAnalyticsService');
    } catch (e) {
      Logger.e(
        'Error initializing analytics: $e',
        tag: 'CustomAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackScreenView(
    String screenName, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _logEvent(
        'screen_view',
        parameters: {'screen_name': screenName, ...?parameters},
      );
    } catch (e) {
      Logger.e('Error tracking screen view: $e', tag: 'CustomAnalyticsService');
    }
  }

  @override
  Future<void> trackUserAction(
    String action, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _logEvent(
        'user_action',
        parameters: {'action': action, ...?parameters},
      );
    } catch (e) {
      Logger.e('Error tracking user action: $e', tag: 'CustomAnalyticsService');
    }
  }

  @override
  Future<void> trackError(
    String error, {
    Map<String, dynamic>? parameters,
    StackTrace? stackTrace,
  }) async {
    try {
      await _logEvent(
        'error',
        parameters: {
          'error': error,
          'stack_trace': stackTrace?.toString(),
          ...?parameters,
        },
      );
    } catch (e) {
      Logger.e('Error tracking error: $e', tag: 'CustomAnalyticsService');
    }
  }

  @override
  Future<void> setCurrentScreen(String screenName) async {
    try {
      await trackScreenView(screenName);
    } catch (e) {
      Logger.e(
        'Error setting current screen: $e',
        tag: 'CustomAnalyticsService',
      );
    }
  }

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    try {
      await _logEvent(name, parameters: parameters);
    } catch (e) {
      Logger.e('Error logging event: $e', tag: 'CustomAnalyticsService');
    }
  }

  @override
  Future<void> resetAnalyticsData() async {
    try {
      await _posthog.reset();
      Logger.i('Analytics data reset', tag: 'CustomAnalyticsService');
    } catch (e) {
      Logger.e(
        'Error resetting analytics data: $e',
        tag: 'CustomAnalyticsService',
      );
    }
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    try {
      // PostHog doesn't have a direct method to enable/disable collection
      // We'll just log the action
      Logger.i(
        'Analytics collection enabled: $enabled',
        tag: 'CustomAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error setting analytics collection: $e',
        tag: 'CustomAnalyticsService',
      );
    }
  }

  @override
  Future<String?> getAppInstanceId() async {
    try {
      // Return a placeholder value
      return 'posthog-instance';
    } catch (e) {
      Logger.e(
        'Error getting app instance ID: $e',
        tag: 'CustomAnalyticsService',
      );
      return null;
    }
  }

  @override
  Future<void> trackLogin({String? method}) async {
    try {
      await _logEvent(
        'login',
        parameters: {if (method != null) 'method': method},
      );
    } catch (e) {
      Logger.e('Error tracking login: $e', tag: 'CustomAnalyticsService');
    }
  }

  @override
  Future<void> trackSignUp({String? method}) async {
    try {
      await _logEvent(
        'sign_up',
        parameters: {if (method != null) 'method': method},
      );
    } catch (e) {
      Logger.e('Error tracking sign up: $e', tag: 'CustomAnalyticsService');
    }
  }

  @override
  Future<void> trackSearch(String searchTerm) async {
    try {
      await _logEvent('search', parameters: {'search_term': searchTerm});
    } catch (e) {
      Logger.e('Error tracking search: $e', tag: 'CustomAnalyticsService');
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
      await _logEvent(
        'booking',
        parameters: {
          'service_type': serviceType,
          'service_id': serviceId,
          'service_name': serviceName,
          'price': price,
        },
      );
    } catch (e) {
      Logger.e('Error tracking booking: $e', tag: 'CustomAnalyticsService');
    }
  }

  @override
  Future<void> trackComparison({
    required String serviceType,
    required List<String> serviceIds,
    required List<String> serviceNames,
  }) async {
    try {
      await _logEvent(
        'comparison',
        parameters: {
          'service_type': serviceType,
          'service_ids': serviceIds,
          'service_names': serviceNames,
        },
      );
    } catch (e) {
      Logger.e('Error tracking comparison: $e', tag: 'CustomAnalyticsService');
    }
  }

  @override
  Future<void> trackFilter({
    required String serviceType,
    required Map<String, dynamic> filters,
  }) async {
    try {
      final params = <String, dynamic>{'service_type': serviceType};

      // Add filters as individual properties
      params.addAll(filters);

      await _logEvent('filter', parameters: params);
    } catch (e) {
      Logger.e('Error tracking filter: $e', tag: 'CustomAnalyticsService');
    }
  }

  @override
  Future<void> trackSort({
    required String serviceType,
    required String sortBy,
    required bool ascending,
  }) async {
    try {
      await _logEvent(
        'sort',
        parameters: {
          'service_type': serviceType,
          'sort_by': sortBy,
          'ascending': ascending,
        },
      );
    } catch (e) {
      Logger.e('Error tracking sort: $e', tag: 'CustomAnalyticsService');
    }
  }

  @override
  Future<void> setUserProperties({
    String? userId,
    Map<String, String>? properties,
  }) async {
    try {
      final userProps = <String, Object>{};

      if (properties != null) {
        userProps.addAll(Map<String, Object>.from(properties));
      }

      if (userId != null) {
        await _posthog.identify(userId: userId, userProperties: userProps);
      } else {
        // If no userId is provided, we can't use identify
        // Just log the attempt
        Logger.i(
          'No userId provided for identify call',
          tag: 'CustomAnalyticsService',
        );
      }

      Logger.i('User properties set', tag: 'CustomAnalyticsService');
    } catch (e) {
      Logger.e(
        'Error setting user properties: $e',
        tag: 'CustomAnalyticsService',
      );
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    try {
      if (userId != null) {
        await _posthog.identify(
          userId: userId,
          userProperties: {'userId': userId},
        );
        Logger.i('User ID set: $userId', tag: 'CustomAnalyticsService');
      } else {
        await _posthog.reset();
        Logger.i('User ID reset', tag: 'CustomAnalyticsService');
      }
    } catch (e) {
      Logger.e('Error setting user ID: $e', tag: 'CustomAnalyticsService');
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
      final properties = <String, Object>{};

      if (displayName != null) {
        properties['displayName'] = displayName;
      }
      if (email != null) {
        properties['email'] = email;
      }
      if (photoUrl != null) {
        properties['photoUrl'] = photoUrl;
      }
      if (createdAt != null) {
        properties['createdAt'] = createdAt.toIso8601String();
      }

      if (additionalProperties != null) {
        properties.addAll(Map<String, Object>.from(additionalProperties));
      }

      await _posthog.identify(userId: userId, userProperties: properties);

      Logger.i(
        'User profile properties set for $userId',
        tag: 'CustomAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error setting user profile properties: $e',
        tag: 'CustomAnalyticsService',
      );
    }
  }

  @override
  Future<void> setUserPreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      final properties = <String, Object>{
        'preferences': Map<String, Object>.from(preferences),
      };

      await _posthog.identify(userId: userId, userProperties: properties);

      Logger.i(
        'User preferences set for $userId',
        tag: 'CustomAnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error setting user preferences: $e',
        tag: 'CustomAnalyticsService',
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
      final properties = <String, Object>{'segment': segmentName};

      if (segmentProperties != null) {
        properties.addAll(Map<String, Object>.from(segmentProperties));
      }

      await _posthog.identify(userId: userId, userProperties: properties);

      Logger.i(
        'User segment set for $userId: $segmentName',
        tag: 'CustomAnalyticsService',
      );
    } catch (e) {
      Logger.e('Error setting user segment: $e', tag: 'CustomAnalyticsService');
    }
  }

  @override
  Future<void> trackUserLifecycleEvent({
    required String userId,
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final params = <String, dynamic>{
        'user_id': userId,
        'lifecycle_event': eventName,
      };

      if (parameters != null) {
        params.addAll(parameters);
      }

      await _logEvent('user_lifecycle', parameters: params);
    } catch (e) {
      Logger.e(
        'Error tracking user lifecycle event: $e',
        tag: 'CustomAnalyticsService',
      );
    }
  }

  @override
  Future<void> setDefaultEventParameters(
    Map<String, dynamic>? parameters,
  ) async {
    _defaultEventParameters = parameters;
  }

  @override
  Future<void> trackAppOpen() async {
    try {
      await _logEvent('app_open');
    } catch (e) {
      Logger.e('Error tracking app open: $e', tag: 'CustomAnalyticsService');
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
      await _logEvent(
        'in_app_purchase',
        parameters: {
          'item_name': itemName,
          'item_id': itemId,
          'price': price,
          'currency': currency,
        },
      );
    } catch (e) {
      Logger.e(
        'Error tracking in-app purchase: $e',
        tag: 'CustomAnalyticsService',
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
      await _logEvent(
        'add_to_cart',
        parameters: {
          'item_name': itemName,
          'item_id': itemId,
          'price': price,
          'currency': currency,
        },
      );
    } catch (e) {
      Logger.e('Error tracking add to cart: $e', tag: 'CustomAnalyticsService');
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
      await _logEvent(
        'begin_checkout',
        parameters: {
          'item_ids': itemIds,
          'item_names': itemNames,
          'value': value,
          'currency': currency,
        },
      );
    } catch (e) {
      Logger.e(
        'Error tracking begin checkout: $e',
        tag: 'CustomAnalyticsService',
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
      await _logEvent(
        'purchase',
        parameters: {
          'transaction_id': transactionId,
          'value': value,
          'currency': currency,
          'item_ids': itemIds,
          'item_names': itemNames,
        },
      );
    } catch (e) {
      Logger.e('Error tracking purchase: $e', tag: 'CustomAnalyticsService');
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
      await _logEvent(
        'conversion',
        parameters: {
          'conversion_name': conversionName,
          'conversion_type': conversionType,
          if (value != null) 'value': value,
          if (currency != null) 'currency': currency,
          ...?parameters,
        },
      );
    } catch (e) {
      Logger.e('Error tracking conversion: $e', tag: 'CustomAnalyticsService');
    }
  }

  @override
  Future<void> trackTutorialBegin() async {
    try {
      await _logEvent('tutorial_begin');
    } catch (e) {
      Logger.e(
        'Error tracking tutorial begin: $e',
        tag: 'CustomAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackTutorialComplete() async {
    try {
      await _logEvent('tutorial_complete');
    } catch (e) {
      Logger.e(
        'Error tracking tutorial complete: $e',
        tag: 'CustomAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackLevelUp({
    required int level,
    required String character,
  }) async {
    try {
      await _logEvent(
        'level_up',
        parameters: {'level': level, 'character': character},
      );
    } catch (e) {
      Logger.e('Error tracking level up: $e', tag: 'CustomAnalyticsService');
    }
  }

  @override
  Future<void> trackAchievementUnlocked({
    required String achievementId,
    required String achievementName,
  }) async {
    try {
      await _logEvent(
        'achievement_unlocked',
        parameters: {
          'achievement_id': achievementId,
          'achievement_name': achievementName,
        },
      );
    } catch (e) {
      Logger.e(
        'Error tracking achievement unlocked: $e',
        tag: 'CustomAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackAppCrash({
    required String error,
    required StackTrace stackTrace,
  }) async {
    try {
      await _logEvent(
        'app_crash',
        parameters: {'error': error, 'stack_trace': stackTrace.toString()},
      );
    } catch (e) {
      Logger.e('Error tracking app crash: $e', tag: 'CustomAnalyticsService');
    }
  }

  @override
  Future<void> trackNotificationReceived({
    required String notificationId,
    required String notificationType,
  }) async {
    try {
      await _logEvent(
        'notification_received',
        parameters: {
          'notification_id': notificationId,
          'notification_type': notificationType,
        },
      );
    } catch (e) {
      Logger.e(
        'Error tracking notification received: $e',
        tag: 'CustomAnalyticsService',
      );
    }
  }

  @override
  Future<void> trackNotificationOpened({
    required String notificationId,
    required String notificationType,
  }) async {
    try {
      await _logEvent(
        'notification_opened',
        parameters: {
          'notification_id': notificationId,
          'notification_type': notificationType,
        },
      );
    } catch (e) {
      Logger.e(
        'Error tracking notification opened: $e',
        tag: 'CustomAnalyticsService',
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
      final params = <String, dynamic>{
        'feature_name': featureName,
        'action': action,
      };

      if (parameters != null) {
        params.addAll(parameters);
      }

      await _logEvent('feature_usage', parameters: params);
    } catch (e) {
      Logger.e(
        'Error tracking feature usage: $e',
        tag: 'CustomAnalyticsService',
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
      final params = <String, dynamic>{
        'activity_type': activityType,
        'time_spent_ms': timeSpentMs,
      };

      if (parameters != null) {
        params.addAll(parameters);
      }

      await _logEvent('user_engagement', parameters: params);
    } catch (e) {
      Logger.e(
        'Error tracking user engagement: $e',
        tag: 'CustomAnalyticsService',
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
      final params = <String, dynamic>{
        'form_name': formName,
        'success': success,
      };

      if (errorMessage != null) params['error_message'] = errorMessage;

      if (formData != null) {
        params.addAll(formData);
      }

      await _logEvent('form_submission', parameters: params);
    } catch (e) {
      Logger.e(
        'Error tracking form submission: $e',
        tag: 'CustomAnalyticsService',
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
      final params = <String, dynamic>{
        'funnel_name': funnelName,
        'step_number': stepNumber,
        'step_name': stepName,
        'completed': completed,
      };

      if (parameters != null) {
        params.addAll(parameters);
      }

      await _logEvent('funnel_step', parameters: params);
    } catch (e) {
      Logger.e('Error tracking funnel step: $e', tag: 'CustomAnalyticsService');
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
      final params = <String, dynamic>{
        'campaign': campaign,
        'source': source,
        'medium': medium,
      };

      if (term != null) params['term'] = term;
      if (content != null) params['content'] = content;

      if (parameters != null) {
        params.addAll(parameters);
      }

      await _logEvent('attribution', parameters: params);
    } catch (e) {
      Logger.e('Error tracking attribution: $e', tag: 'CustomAnalyticsService');
    }
  }

  @override
  Future<void> trackShare({
    required String contentType,
    required String itemId,
    required String method,
  }) async {
    try {
      await _logEvent(
        'share',
        parameters: {
          'content_type': contentType,
          'item_id': itemId,
          'method': method,
        },
      );
    } catch (e) {
      Logger.e('Error tracking share: $e', tag: 'CustomAnalyticsService');
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
      await _logEvent(
        'content_view',
        parameters: {
          'content_type': contentType,
          'item_id': itemId,
          'item_name': itemName,
          ...?parameters,
        },
      );
    } catch (e) {
      Logger.e(
        'Error tracking content view: $e',
        tag: 'CustomAnalyticsService',
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
      await _logEvent(
        'performance_metric',
        parameters: {
          'metric_name': metricName,
          'value_ms': valueMs,
          ...?parameters,
        },
      );
    } catch (e) {
      Logger.e(
        'Error tracking performance metric: $e',
        tag: 'CustomAnalyticsService',
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
      await _logEvent(
        'wizard_completion',
        parameters: {
          'wizard_name': wizardName,
          'completed': completed,
          'steps_completed': stepsCompleted,
          'total_steps': totalSteps,
          ...?parameters,
        },
      );
    } catch (e) {
      Logger.e(
        'Error tracking wizard completion: $e',
        tag: 'CustomAnalyticsService',
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
      await _logEvent(
        'event_planning_action',
        parameters: {
          'event_id': eventId,
          'event_type': eventType,
          'action_type': actionType,
          ...?parameters,
        },
      );
    } catch (e) {
      Logger.e(
        'Error tracking event planning action: $e',
        tag: 'CustomAnalyticsService',
      );
    }
  }

  /// Log an event to PostHog
  Future<void> _logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      // Combine default parameters with event-specific parameters
      final eventParameters = {...?_defaultEventParameters, ...?parameters};

      // Get the current user ID if available
      final userId = _supabase.auth.currentUser?.id;

      // If we have a user ID but haven't identified them yet, do so
      if (userId != null) {
        final email = _supabase.auth.currentUser?.email;
        await _posthog.identify(
          userId: userId,
          userProperties: {'userId': userId, if (email != null) 'email': email},
        );
      }

      // Track the event in PostHog
      final safeProperties = Map<String, Object>.from(eventParameters);
      await _posthog.capture(eventName: name, properties: safeProperties);

      // Also store the event in Supabase for our own analytics if needed
      try {
        // Create the analytics event
        final event = {
          'event_name': name,
          'event_params': eventParameters,
          'user_id': userId,
          'timestamp': DateTime.now().toIso8601String(),
          'session_id': _getSessionId(),
        };

        // Store the event in Supabase
        await _supabase.from('analytics_events').insert(event);
      } catch (e) {
        // Just log the error but don't fail the whole tracking
        Logger.e(
          'Error storing event in Supabase: $e',
          tag: 'CustomAnalyticsService',
        );
      }
    } catch (e) {
      Logger.e('Error logging event: $e', tag: 'CustomAnalyticsService');
    }
  }

  /// Get the current session ID
  String _getSessionId() {
    // In a real implementation, you would maintain a session ID
    // For now, we'll use a timestamp-based ID
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
