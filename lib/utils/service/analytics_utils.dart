import 'package:flutter/foundation.dart';

/// Utility functions for analytics and tracking
class AnalyticsUtils {
  /// Log a screen view event
  static void logScreenView(String screenName) {
    // In a real app, this would send data to an analytics service
    // For now, we'll just print to the console in debug mode
    if (kDebugMode) {
      print('Screen View: $screenName');
    }

    // TODO: Implement actual analytics service integration
    // Example with Firebase Analytics:
    // FirebaseAnalytics.instance.logScreenView(screenName: screenName);
  }

  /// Log a user action event
  static void logEvent(String eventName, {Map<String, dynamic>? parameters}) {
    // In a real app, this would send data to an analytics service
    // For now, we'll just print to the console in debug mode
    if (kDebugMode) {
      print('Event: $eventName, Parameters: $parameters');
    }

    // TODO: Implement actual analytics service integration
    // Example with Firebase Analytics:
    // FirebaseAnalytics.instance.logEvent(name: eventName, parameters: parameters);
  }

  /// Log an error event
  static void logError(
    String errorMessage, {
    StackTrace? stackTrace,
    String? errorCode,
  }) {
    // In a real app, this would send data to an analytics service
    // For now, we'll just print to the console in debug mode
    if (kDebugMode) {
      print('Error: $errorMessage, Code: $errorCode');
      if (stackTrace != null) {
        print('Stack Trace: $stackTrace');
      }
    }

    // TODO: Implement actual analytics service integration
    // Example with Firebase Crashlytics:
    // FirebaseCrashlytics.instance.recordError(
    //   errorMessage,
    //   stackTrace,
    //   reason: errorCode,
    // );
  }

  /// Log a user login event
  static void logLogin({required String method}) {
    logEvent('login', parameters: {'method': method});

    // TODO: Implement actual analytics service integration
    // Example with Firebase Analytics:
    // FirebaseAnalytics.instance.logLogin(loginMethod: method);
  }

  /// Log a user signup event
  static void logSignUp({required String method}) {
    logEvent('sign_up', parameters: {'method': method});

    // TODO: Implement actual analytics service integration
    // Example with Firebase Analytics:
    // FirebaseAnalytics.instance.logSignUp(signUpMethod: method);
  }

  /// Log a search event
  static void logSearch({required String searchTerm}) {
    logEvent('search', parameters: {'search_term': searchTerm});

    // TODO: Implement actual analytics service integration
    // Example with Firebase Analytics:
    // FirebaseAnalytics.instance.logSearch(searchTerm: searchTerm);
  }

  /// Log a service selection event
  static void logServiceSelection({
    required String serviceType,
    required String serviceName,
  }) {
    logEvent(
      'select_service',
      parameters: {'service_type': serviceType, 'service_name': serviceName},
    );
  }

  /// Log a milestone completion event
  static void logMilestoneCompletion({
    required String milestoneId,
    required String milestoneName,
  }) {
    logEvent(
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
    logEvent(
      'create_budget_item',
      parameters: {'category': category, 'amount': amount},
    );
  }

  /// Log a guest list addition event
  static void logGuestAddition({required int guestCount}) {
    logEvent('add_guest', parameters: {'guest_count': guestCount});
  }

  /// Log a task completion event
  static void logTaskCompletion({
    required String taskId,
    required String taskName,
  }) {
    logEvent(
      'complete_task',
      parameters: {'task_id': taskId, 'task_name': taskName},
    );
  }

  /// Log app performance metrics
  static void logPerformanceMetric({
    required String metricName,
    required double value,
  }) {
    logEvent(
      'performance_metric',
      parameters: {'metric_name': metricName, 'value': value},
    );

    // TODO: Implement actual performance monitoring
    // Example with Firebase Performance Monitoring:
    // final metric = FirebasePerformance.instance.newHttpMetric(url, HttpMethod.Get);
    // await metric.start();
    // // ... perform operation ...
    // await metric.stop();
  }
}
