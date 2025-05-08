import 'dart:async';

import 'package:eventati_book/services/interfaces/analytics_service_interface.dart';
import 'package:eventati_book/di/service_locator.dart';
import 'package:eventati_book/utils/analytics/conversion_funnels.dart';
import 'package:eventati_book/utils/logger.dart';

/// Utility class for tracking analytics events
class AnalyticsUtils {
  /// Get the analytics service
  static AnalyticsServiceInterface get _analytics =>
      serviceLocator.get<AnalyticsServiceInterface>();

  /// Track a screen view
  static Future<void> trackScreenView(
    String screenName, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.trackScreenView(screenName, parameters: parameters);
    } catch (e) {
      Logger.e('Error tracking screen view: $e', tag: 'AnalyticsUtils');
    }
  }

  /// Track a user action
  static Future<void> trackUserAction(
    String action, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.trackUserAction(action, parameters: parameters);
    } catch (e) {
      Logger.e('Error tracking user action: $e', tag: 'AnalyticsUtils');
    }
  }

  /// Track an error
  static Future<void> trackError(
    String error, {
    Map<String, dynamic>? parameters,
    StackTrace? stackTrace,
  }) async {
    try {
      await _analytics.trackError(
        error,
        parameters: parameters,
        stackTrace: stackTrace,
      );
    } catch (e) {
      Logger.e('Error tracking error: $e', tag: 'AnalyticsUtils');
    }
  }

  /// Track feature usage
  static Future<void> trackFeatureUsage({
    required String featureName,
    required String action,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.trackFeatureUsage(
        featureName: featureName,
        action: action,
        parameters: parameters,
      );
    } catch (e) {
      Logger.e('Error tracking feature usage: $e', tag: 'AnalyticsUtils');
    }
  }

  /// Track user engagement
  static Future<void> trackUserEngagement({
    required String activityType,
    required int timeSpentMs,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.trackUserEngagement(
        activityType: activityType,
        timeSpentMs: timeSpentMs,
        parameters: parameters,
      );
    } catch (e) {
      Logger.e('Error tracking user engagement: $e', tag: 'AnalyticsUtils');
    }
  }

  /// Track form submission
  static Future<void> trackFormSubmission({
    required String formName,
    required bool success,
    String? errorMessage,
    Map<String, dynamic>? formData,
  }) async {
    try {
      await _analytics.trackFormSubmission(
        formName: formName,
        success: success,
        errorMessage: errorMessage,
        formData: formData,
      );
    } catch (e) {
      Logger.e('Error tracking form submission: $e', tag: 'AnalyticsUtils');
    }
  }

  /// Track content view
  static Future<void> trackContentView({
    required String contentType,
    required String itemId,
    required String itemName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.trackContentView(
        contentType: contentType,
        itemId: itemId,
        itemName: itemName,
        parameters: parameters,
      );
    } catch (e) {
      Logger.e('Error tracking content view: $e', tag: 'AnalyticsUtils');
    }
  }

  /// Track performance metric
  static Future<void> trackPerformanceMetric({
    required String metricName,
    required int valueMs,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.trackPerformanceMetric(
        metricName: metricName,
        valueMs: valueMs,
        parameters: parameters,
      );
    } catch (e) {
      Logger.e('Error tracking performance metric: $e', tag: 'AnalyticsUtils');
    }
  }

  /// Track wizard completion
  static Future<void> trackWizardCompletion({
    required String wizardName,
    required bool completed,
    required int stepsCompleted,
    required int totalSteps,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.trackWizardCompletion(
        wizardName: wizardName,
        completed: completed,
        stepsCompleted: stepsCompleted,
        totalSteps: totalSteps,
        parameters: parameters,
      );
    } catch (e) {
      Logger.e('Error tracking wizard completion: $e', tag: 'AnalyticsUtils');
    }
  }

  /// Track event planning action
  static Future<void> trackEventPlanningAction({
    required String eventId,
    required String eventType,
    required String actionType,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.trackEventPlanningAction(
        eventId: eventId,
        eventType: eventType,
        actionType: actionType,
        parameters: parameters,
      );
    } catch (e) {
      Logger.e(
        'Error tracking event planning action: $e',
        tag: 'AnalyticsUtils',
      );
    }
  }

  /// Track booking
  static Future<void> trackBooking({
    required String serviceType,
    required String serviceId,
    required String serviceName,
    required double price,
  }) async {
    try {
      await _analytics.trackBooking(
        serviceType: serviceType,
        serviceId: serviceId,
        serviceName: serviceName,
        price: price,
      );
    } catch (e) {
      Logger.e('Error tracking booking: $e', tag: 'AnalyticsUtils');
    }
  }

  /// Track search
  static Future<void> trackSearch(String searchTerm) async {
    try {
      await _analytics.trackSearch(searchTerm);
    } catch (e) {
      Logger.e('Error tracking search: $e', tag: 'AnalyticsUtils');
    }
  }

  /// Set user profile properties
  static Future<void> setUserProfileProperties({
    required String userId,
    String? displayName,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    Map<String, dynamic>? additionalProperties,
  }) async {
    try {
      await _analytics.setUserProfileProperties(
        userId: userId,
        displayName: displayName,
        email: email,
        photoUrl: photoUrl,
        createdAt: createdAt,
        additionalProperties: additionalProperties,
      );
    } catch (e) {
      Logger.e(
        'Error setting user profile properties: $e',
        tag: 'AnalyticsUtils',
      );
    }
  }

  /// Set user preferences
  static Future<void> setUserPreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      await _analytics.setUserPreferences(
        userId: userId,
        preferences: preferences,
      );
    } catch (e) {
      Logger.e('Error setting user preferences: $e', tag: 'AnalyticsUtils');
    }
  }

  /// Set user segment
  static Future<void> setUserSegment({
    required String userId,
    required String segmentName,
    Map<String, dynamic>? segmentProperties,
  }) async {
    try {
      await _analytics.setUserSegment(
        userId: userId,
        segmentName: segmentName,
        segmentProperties: segmentProperties,
      );
    } catch (e) {
      Logger.e('Error setting user segment: $e', tag: 'AnalyticsUtils');
    }
  }

  /// Track user lifecycle event
  static Future<void> trackUserLifecycleEvent({
    required String userId,
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.trackUserLifecycleEvent(
        userId: userId,
        eventName: eventName,
        parameters: parameters,
      );
    } catch (e) {
      Logger.e(
        'Error tracking user lifecycle event: $e',
        tag: 'AnalyticsUtils',
      );
    }
  }

  /// Set user ID
  static Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(userId);
    } catch (e) {
      Logger.e('Error setting user ID: $e', tag: 'AnalyticsUtils');
    }
  }

  /// Track conversion event
  static Future<void> trackConversion({
    required String conversionName,
    required String conversionType,
    double? value,
    String? currency,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.trackConversion(
        conversionName: conversionName,
        conversionType: conversionType,
        value: value,
        currency: currency,
        parameters: parameters,
      );
    } catch (e) {
      Logger.e('Error tracking conversion: $e', tag: 'AnalyticsUtils');
    }
  }

  /// Track funnel step
  static Future<void> trackFunnelStep({
    required String funnelName,
    required int stepNumber,
    required String stepName,
    required bool completed,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      // Get step name from ConversionFunnels if not provided
      final String finalStepName =
          stepName.isEmpty
              ? ConversionFunnels.getStepName(funnelName, stepNumber)
              : stepName;

      await _analytics.trackFunnelStep(
        funnelName: funnelName,
        stepNumber: stepNumber,
        stepName: finalStepName,
        completed: completed,
        parameters: parameters,
      );
    } catch (e) {
      Logger.e('Error tracking funnel step: $e', tag: 'AnalyticsUtils');
    }
  }

  /// Track attribution
  static Future<void> trackAttribution({
    required String campaign,
    required String source,
    required String medium,
    String? term,
    String? content,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.trackAttribution(
        campaign: campaign,
        source: source,
        medium: medium,
        term: term,
        content: content,
        parameters: parameters,
      );
    } catch (e) {
      Logger.e('Error tracking attribution: $e', tag: 'AnalyticsUtils');
    }
  }
}
