import 'package:eventati_book/di/service_locator.dart';
import 'package:eventati_book/services/interfaces/analytics_service_interface.dart';
import 'package:flutter/foundation.dart';

/// Utility functions for analytics and tracking
class AnalyticsUtils {
  /// Get the analytics service
  static AnalyticsServiceInterface get _analyticsService =>
      serviceLocator.analyticsService;

  /// Log a screen view event
  static void logScreenView(String screenName) {
    // Log to console in debug mode
    if (kDebugMode) {
      print('Screen View: $screenName');
    }

    // Send to analytics service
    _analyticsService.trackScreenView(screenName);
  }

  /// Log a user action event
  static void logEvent(String eventName, {Map<String, dynamic>? parameters}) {
    // Log to console in debug mode
    if (kDebugMode) {
      print('Event: $eventName, Parameters: $parameters');
    }

    // Send to analytics service
    _analyticsService.logEvent(eventName, parameters: parameters);
  }

  /// Log an error event
  static void logError(
    String errorMessage, {
    StackTrace? stackTrace,
    String? errorCode,
  }) {
    // Log to console in debug mode
    if (kDebugMode) {
      print('Error: $errorMessage, Code: $errorCode');
      if (stackTrace != null) {
        print('Stack Trace: $stackTrace');
      }
    }

    // Send to analytics service
    _analyticsService.trackError(
      errorMessage,
      parameters: errorCode != null ? {'error_code': errorCode} : null,
      stackTrace: stackTrace,
    );
  }

  /// Log a user login event
  static void logLogin({required String method}) {
    // Send to analytics service
    _analyticsService.trackLogin(method: method);
  }

  /// Log a user signup event
  static void logSignUp({required String method}) {
    // Send to analytics service
    _analyticsService.trackSignUp(method: method);
  }

  /// Log a search event
  static void logSearch({required String searchTerm}) {
    // Send to analytics service
    _analyticsService.trackSearch(searchTerm);
  }

  /// Log a service selection event
  static void logServiceSelection({
    required String serviceType,
    required String serviceName,
  }) {
    // Send to analytics service
    _analyticsService.logEvent(
      'select_service',
      parameters: {'service_type': serviceType, 'service_name': serviceName},
    );
  }

  /// Log a milestone completion event
  static void logMilestoneCompletion({
    required String milestoneId,
    required String milestoneName,
  }) {
    // Send to analytics service
    _analyticsService.logEvent(
      'complete_milestone',
      parameters: {
        'milestone_id': milestoneId,
        'milestone_name': milestoneName,
      },
    );
  }

  /// Log a budget item creation event
  static void logBudgetItemCreation({
    required String category,
    required double amount,
  }) {
    // Send to analytics service
    _analyticsService.logEvent(
      'create_budget_item',
      parameters: {'category': category, 'amount': amount},
    );
  }

  /// Log a guest list addition event
  static void logGuestAddition({required int guestCount}) {
    // Send to analytics service
    _analyticsService.logEvent(
      'add_guest',
      parameters: {'guest_count': guestCount},
    );
  }

  /// Log a task completion event
  static void logTaskCompletion({
    required String taskId,
    required String taskName,
  }) {
    // Send to analytics service
    _analyticsService.logEvent(
      'complete_task',
      parameters: {'task_id': taskId, 'task_name': taskName},
    );
  }

  /// Log app performance metrics
  static void logPerformanceMetric({
    required String metricName,
    required double value,
  }) {
    // Send to analytics service
    _analyticsService.logEvent(
      'performance_metric',
      parameters: {'metric_name': metricName, 'value': value},
    );
  }
}
