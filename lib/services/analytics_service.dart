import 'package:eventati_book/services/interfaces/analytics_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// Implementation of AnalyticsServiceInterface using PostHog
class AnalyticsService implements AnalyticsServiceInterface {
  /// PostHog instance
  final Posthog _posthog = Posthog();

  /// Route observer for navigation tracking
  final RouteObserver<PageRoute> _routeObserver = RouteObserver<PageRoute>();

  /// Default event parameters
  Map<String, dynamic>? _defaultEventParameters;

  /// Whether analytics collection is enabled
  bool _analyticsEnabled = true;

  @override
  RouteObserver<PageRoute> get observer => _routeObserver;

  @override
  Future<void> initialize() async {
    try {
      // PostHog is initialized in main.dart via platform-specific configuration
      Logger.i('PostHog Analytics initialized', tag: 'AnalyticsService');
    } catch (e) {
      Logger.e('Error initializing analytics: $e', tag: 'AnalyticsService');
    }
  }

  @override
  Future<void> trackScreenView(
    String screenName, {
    Map<String, dynamic>? parameters,
  }) async {
    if (!_analyticsEnabled) return;

    try {
      final props = <String, Object>{};
      if (parameters != null) {
        props.addAll(Map<String, Object>.from(parameters));
      }

      await _posthog.screen(screenName: screenName, properties: props);
      Logger.i('Screen view tracked: $screenName', tag: 'AnalyticsService');
    } catch (e) {
      Logger.e('Error tracking screen view: $e', tag: 'AnalyticsService');
    }
  }

  @override
  Future<void> trackUserAction(
    String action, {
    Map<String, dynamic>? parameters,
  }) async {
    await _logEvent('user_action_$action', parameters: parameters);
  }

  @override
  Future<void> trackError(
    String error, {
    Map<String, dynamic>? parameters,
    StackTrace? stackTrace,
  }) async {
    final props = <String, Object>{'error': error};

    if (parameters != null) {
      props.addAll(Map<String, Object>.from(parameters));
    }

    if (stackTrace != null) {
      props['stackTrace'] = stackTrace.toString();
    }

    await _logEvent('error', parameters: props);
  }

  @override
  Future<void> trackLogin({String? method}) async {
    await _logEvent(
      'login',
      parameters: {if (method != null) 'method': method},
    );
  }

  @override
  Future<void> trackSignUp({String? method}) async {
    await _logEvent(
      'sign_up',
      parameters: {if (method != null) 'method': method},
    );
  }

  @override
  Future<void> trackSearch(String searchTerm) async {
    await _logEvent('search', parameters: {'search_term': searchTerm});
  }

  @override
  Future<void> trackBooking({
    required String serviceType,
    required String serviceId,
    required String serviceName,
    required double price,
  }) async {
    await _logEvent(
      'booking',
      parameters: {
        'service_type': serviceType,
        'service_id': serviceId,
        'service_name': serviceName,
        'price': price,
      },
    );
  }

  @override
  Future<void> trackComparison({
    required String serviceType,
    required List<String> serviceIds,
    required List<String> serviceNames,
  }) async {
    await _logEvent(
      'comparison',
      parameters: {
        'service_type': serviceType,
        'service_ids': serviceIds,
        'service_names': serviceNames,
      },
    );
  }

  @override
  Future<void> trackFilter({
    required String serviceType,
    required Map<String, dynamic> filters,
  }) async {
    final params = <String, Object>{'service_type': serviceType};

    // Add filters as individual properties
    params.addAll(Map<String, Object>.from(filters));

    await _logEvent('filter', parameters: params);
  }

  @override
  Future<void> trackSort({
    required String serviceType,
    required String sortBy,
    required bool ascending,
  }) async {
    await _logEvent(
      'sort',
      parameters: {
        'service_type': serviceType,
        'sort_by': sortBy,
        'ascending': ascending,
      },
    );
  }

  @override
  Future<void> setUserProperties({
    String? userId,
    Map<String, String>? properties,
  }) async {
    if (!_analyticsEnabled) return;

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
          tag: 'AnalyticsService',
        );
      }

      Logger.i('User properties set', tag: 'AnalyticsService');
    } catch (e) {
      Logger.e('Error setting user properties: $e', tag: 'AnalyticsService');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    if (!_analyticsEnabled) return;

    try {
      if (userId != null) {
        await _posthog.identify(
          userId: userId,
          userProperties: {'userId': userId},
        );
        Logger.i('User ID set: $userId', tag: 'AnalyticsService');
      } else {
        await _posthog.reset();
        Logger.i('User ID reset', tag: 'AnalyticsService');
      }
    } catch (e) {
      Logger.e('Error setting user ID: $e', tag: 'AnalyticsService');
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
    if (!_analyticsEnabled) return;

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
        tag: 'AnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error setting user profile properties: $e',
        tag: 'AnalyticsService',
      );
    }
  }

  @override
  Future<void> setUserPreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    if (!_analyticsEnabled) return;

    try {
      final properties = <String, Object>{
        'preferences': Map<String, Object>.from(preferences),
      };

      await _posthog.identify(userId: userId, userProperties: properties);

      Logger.i('User preferences set for $userId', tag: 'AnalyticsService');
    } catch (e) {
      Logger.e('Error setting user preferences: $e', tag: 'AnalyticsService');
    }
  }

  @override
  Future<void> setUserSegment({
    required String userId,
    required String segmentName,
    Map<String, dynamic>? segmentProperties,
  }) async {
    if (!_analyticsEnabled) return;

    try {
      final properties = <String, Object>{'segment': segmentName};

      if (segmentProperties != null) {
        properties.addAll(Map<String, Object>.from(segmentProperties));
      }

      await _posthog.identify(userId: userId, userProperties: properties);

      Logger.i(
        'User segment set for $userId: $segmentName',
        tag: 'AnalyticsService',
      );
    } catch (e) {
      Logger.e('Error setting user segment: $e', tag: 'AnalyticsService');
    }
  }

  @override
  Future<void> trackUserLifecycleEvent({
    required String userId,
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    final params = <String, Object>{
      'user_id': userId,
      'lifecycle_event': eventName,
    };

    if (parameters != null) {
      params.addAll(Map<String, Object>.from(parameters));
    }

    await _logEvent('user_lifecycle', parameters: params);
  }

  @override
  Future<void> setCurrentScreen(String screenName) async {
    await trackScreenView(screenName);
  }

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    await _logEvent(name, parameters: parameters);
  }

  @override
  Future<void> resetAnalyticsData() async {
    if (!_analyticsEnabled) return;

    try {
      await _posthog.reset();
      Logger.i('Analytics data reset', tag: 'AnalyticsService');
    } catch (e) {
      Logger.e('Error resetting analytics data: $e', tag: 'AnalyticsService');
    }
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    _analyticsEnabled = enabled;
    Logger.i('Analytics collection enabled: $enabled', tag: 'AnalyticsService');
  }

  @override
  Future<String?> getAppInstanceId() async {
    try {
      // PostHog doesn't have a direct equivalent to getAppInstanceId
      // We'll return a placeholder value
      return 'posthog-instance';
    } catch (e) {
      Logger.e('Error getting app instance ID: $e', tag: 'AnalyticsService');
      return null;
    }
  }

  @override
  Future<void> setDefaultEventParameters(
    Map<String, dynamic>? parameters,
  ) async {
    try {
      _defaultEventParameters = parameters;
      Logger.i(
        'Default event parameters set: $parameters',
        tag: 'AnalyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error setting default event parameters: $e',
        tag: 'AnalyticsService',
      );
    }
  }

  @override
  Future<void> trackAppOpen() async {
    await _logEvent('app_open');
  }

  @override
  Future<void> trackInAppPurchase({
    required String itemName,
    required String itemId,
    required double price,
    required String currency,
  }) async {
    await _logEvent(
      'in_app_purchase',
      parameters: {
        'item_name': itemName,
        'item_id': itemId,
        'price': price,
        'currency': currency,
      },
    );
  }

  @override
  Future<void> trackAddToCart({
    required String itemName,
    required String itemId,
    required double price,
    required String currency,
  }) async {
    await _logEvent(
      'add_to_cart',
      parameters: {
        'item_name': itemName,
        'item_id': itemId,
        'price': price,
        'currency': currency,
      },
    );
  }

  @override
  Future<void> trackBeginCheckout({
    required List<String> itemIds,
    required List<String> itemNames,
    required double value,
    required String currency,
  }) async {
    await _logEvent(
      'begin_checkout',
      parameters: {
        'item_ids': itemIds,
        'item_names': itemNames,
        'value': value,
        'currency': currency,
      },
    );
  }

  @override
  Future<void> trackPurchase({
    required String transactionId,
    required double value,
    required String currency,
    required List<String> itemIds,
    required List<String> itemNames,
  }) async {
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
  }

  @override
  Future<void> trackConversion({
    required String conversionName,
    required String conversionType,
    double? value,
    String? currency,
    Map<String, dynamic>? parameters,
  }) async {
    final params = <String, Object>{
      'conversion_name': conversionName,
      'conversion_type': conversionType,
    };

    if (value != null) params['value'] = value;
    if (currency != null) params['currency'] = currency;

    if (parameters != null) {
      params.addAll(Map<String, Object>.from(parameters));
    }

    await _logEvent('conversion', parameters: params);
  }

  @override
  Future<void> trackFunnelStep({
    required String funnelName,
    required int stepNumber,
    required String stepName,
    required bool completed,
    Map<String, dynamic>? parameters,
  }) async {
    final params = <String, Object>{
      'funnel_name': funnelName,
      'step_number': stepNumber,
      'step_name': stepName,
      'completed': completed,
    };

    if (parameters != null) {
      params.addAll(Map<String, Object>.from(parameters));
    }

    await _logEvent('funnel_step', parameters: params);
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
    final params = <String, Object>{
      'campaign': campaign,
      'source': source,
      'medium': medium,
    };

    if (term != null) params['term'] = term;
    if (content != null) params['content'] = content;

    if (parameters != null) {
      params.addAll(Map<String, Object>.from(parameters));
    }

    await _logEvent('attribution', parameters: params);
  }

  @override
  Future<void> trackShare({
    required String contentType,
    required String itemId,
    required String method,
  }) async {
    await _logEvent(
      'share',
      parameters: {
        'content_type': contentType,
        'item_id': itemId,
        'method': method,
      },
    );
  }

  @override
  Future<void> trackTutorialBegin() async {
    await _logEvent('tutorial_begin');
  }

  @override
  Future<void> trackTutorialComplete() async {
    await _logEvent('tutorial_complete');
  }

  @override
  Future<void> trackLevelUp({
    required int level,
    required String character,
  }) async {
    await _logEvent(
      'level_up',
      parameters: {'level': level, 'character': character},
    );
  }

  @override
  Future<void> trackAchievementUnlocked({
    required String achievementId,
    required String achievementName,
  }) async {
    await _logEvent(
      'achievement_unlocked',
      parameters: {
        'achievement_id': achievementId,
        'achievement_name': achievementName,
      },
    );
  }

  @override
  Future<void> trackAppCrash({
    required String error,
    required StackTrace stackTrace,
  }) async {
    await _logEvent(
      'app_crash',
      parameters: {'error': error, 'stack_trace': stackTrace.toString()},
    );
  }

  @override
  Future<void> trackNotificationReceived({
    required String notificationId,
    required String notificationType,
  }) async {
    await _logEvent(
      'notification_received',
      parameters: {
        'notification_id': notificationId,
        'notification_type': notificationType,
      },
    );
  }

  @override
  Future<void> trackNotificationOpened({
    required String notificationId,
    required String notificationType,
  }) async {
    await _logEvent(
      'notification_opened',
      parameters: {
        'notification_id': notificationId,
        'notification_type': notificationType,
      },
    );
  }

  @override
  Future<void> trackFeatureUsage({
    required String featureName,
    required String action,
    Map<String, dynamic>? parameters,
  }) async {
    final params = <String, Object>{
      'feature_name': featureName,
      'action': action,
    };

    if (parameters != null) {
      params.addAll(Map<String, Object>.from(parameters));
    }

    await _logEvent('feature_usage', parameters: params);
  }

  @override
  Future<void> trackUserEngagement({
    required String activityType,
    required int timeSpentMs,
    Map<String, dynamic>? parameters,
  }) async {
    final params = <String, Object>{
      'activity_type': activityType,
      'time_spent_ms': timeSpentMs,
    };

    if (parameters != null) {
      params.addAll(Map<String, Object>.from(parameters));
    }

    await _logEvent('user_engagement', parameters: params);
  }

  @override
  Future<void> trackFormSubmission({
    required String formName,
    required bool success,
    String? errorMessage,
    Map<String, dynamic>? formData,
  }) async {
    final params = <String, Object>{'form_name': formName, 'success': success};

    if (errorMessage != null) params['error_message'] = errorMessage;

    if (formData != null) {
      params.addAll(Map<String, Object>.from(formData));
    }

    await _logEvent('form_submission', parameters: params);
  }

  @override
  Future<void> trackContentView({
    required String contentType,
    required String itemId,
    required String itemName,
    Map<String, dynamic>? parameters,
  }) async {
    final params = <String, Object>{
      'content_type': contentType,
      'item_id': itemId,
      'item_name': itemName,
    };

    if (parameters != null) {
      params.addAll(Map<String, Object>.from(parameters));
    }

    await _logEvent('content_view', parameters: params);
  }

  @override
  Future<void> trackPerformanceMetric({
    required String metricName,
    required int valueMs,
    Map<String, dynamic>? parameters,
  }) async {
    final params = <String, Object>{
      'metric_name': metricName,
      'value_ms': valueMs,
    };

    if (parameters != null) {
      params.addAll(Map<String, Object>.from(parameters));
    }

    await _logEvent('performance_metric', parameters: params);
  }

  @override
  Future<void> trackWizardCompletion({
    required String wizardName,
    required bool completed,
    required int stepsCompleted,
    required int totalSteps,
    Map<String, dynamic>? parameters,
  }) async {
    final params = <String, Object>{
      'wizard_name': wizardName,
      'completed': completed,
      'steps_completed': stepsCompleted,
      'total_steps': totalSteps,
    };

    if (parameters != null) {
      params.addAll(Map<String, Object>.from(parameters));
    }

    await _logEvent('wizard_completion', parameters: params);
  }

  @override
  Future<void> trackEventPlanningAction({
    required String eventId,
    required String eventType,
    required String actionType,
    Map<String, dynamic>? parameters,
  }) async {
    final params = <String, Object>{
      'event_id': eventId,
      'event_type': eventType,
      'action_type': actionType,
    };

    if (parameters != null) {
      params.addAll(Map<String, Object>.from(parameters));
    }

    await _logEvent('event_planning_action', parameters: params);
  }

  /// Track a deep link event
  Future<void> trackDeepLink(String deepLink) async {
    await _logEvent('deep_link', parameters: {'url': deepLink});
  }

  /// Track a navigation event
  Future<void> trackNavigation(
    String routeName, {
    Map<String, dynamic>? arguments,
  }) async {
    final params = <String, Object>{'route': routeName};

    if (arguments != null) {
      params['arguments'] = arguments.toString();
    }

    await _logEvent('navigation', parameters: params);
  }

  /// Track a dynamic link event
  Future<void> trackDynamicLink(String dynamicLink) async {
    await _logEvent('dynamic_link', parameters: {'url': dynamicLink});
  }

  /// Track a web URL share event
  Future<void> trackWebUrlShare(
    String url, {
    String? contentType,
    String? itemId,
    String? method,
  }) async {
    final params = <String, Object>{'url': url};

    if (contentType != null) params['content_type'] = contentType;
    if (itemId != null) params['item_id'] = itemId;
    if (method != null) params['method'] = method;

    await _logEvent('web_url_share', parameters: params);
  }

  /// Log an event to PostHog
  Future<void> _logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    if (!_analyticsEnabled) return;

    try {
      // Combine default parameters with event-specific parameters
      final eventParameters = <String, dynamic>{
        ...?_defaultEventParameters,
        ...?parameters,
      };

      // Convert to a Map<String, Object> for PostHog
      final safeProperties = Map<String, Object>.from(eventParameters);

      // Track the event in PostHog
      await _posthog.capture(eventName: name, properties: safeProperties);

      Logger.i('Event logged: $name', tag: 'AnalyticsService');
    } catch (e) {
      Logger.e('Error logging event: $e', tag: 'AnalyticsService');
    }
  }
}
