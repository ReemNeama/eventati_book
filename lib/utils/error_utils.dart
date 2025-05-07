import 'package:eventati_book/di/service_locator.dart';
import 'package:eventati_book/services/interfaces/crashlytics_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';

/// Utility functions for error handling
class ErrorUtils {
  /// Get the crashlytics service
  static CrashlyticsServiceInterface get _crashlyticsService =>
      serviceLocator.crashlyticsService;

  /// Log an error
  static void logError(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    // Log to console
    Logger.e(message, error: error, stackTrace: stackTrace, tag: tag);

    // Report to crashlytics if available
    if (error != null) {
      _crashlyticsService.recordError(error, stackTrace, reason: message);
    } else {
      _crashlyticsService.log('ERROR: $message');
    }
  }

  /// Handle an exception
  static void handleException(
    dynamic exception, {
    StackTrace? stackTrace,
    String? context,
    bool fatal = false,
  }) {
    // Get stack trace if not provided
    final trace = stackTrace ?? StackTrace.current;

    // Log to console
    Logger.e(
      'Exception${context != null ? ' in $context' : ''}: $exception',
      error: exception,
      stackTrace: trace,
      tag: context,
    );

    // Report to crashlytics
    _crashlyticsService.recordCaughtException(
      exception: exception,
      stack: trace,
      context: context,
      fatal: fatal,
    );
  }

  /// Handle a network error
  static void handleNetworkError(
    dynamic exception, {
    required String url,
    required String method,
    StackTrace? stackTrace,
    int? statusCode,
    String? response,
    Map<String, dynamic>? headers,
    bool fatal = false,
  }) {
    // Get stack trace if not provided
    final trace = stackTrace ?? StackTrace.current;

    // Log to console
    Logger.e(
      'Network error: $method $url${statusCode != null ? ' ($statusCode)' : ''}',
      error: exception,
      stackTrace: trace,
      tag: 'Network',
    );

    // Report to crashlytics
    _crashlyticsService.recordNetworkError(
      exception: exception,
      stack: trace,
      url: url,
      method: method,
      statusCode: statusCode,
      response: response,
      headers: headers,
      fatal: fatal,
    );
  }

  /// Handle a database error
  static void handleDatabaseError(
    dynamic exception, {
    required String operation,
    required String collection,
    String? document,
    StackTrace? stackTrace,
    bool fatal = false,
  }) {
    // Get stack trace if not provided
    final trace = stackTrace ?? StackTrace.current;

    // Log to console
    Logger.e(
      'Database error: $operation on $collection${document != null ? '/$document' : ''}',
      error: exception,
      stackTrace: trace,
      tag: 'Database',
    );

    // Report to crashlytics
    _crashlyticsService.recordDatabaseError(
      exception: exception,
      stack: trace,
      operation: operation,
      collection: collection,
      document: document,
      fatal: fatal,
    );
  }

  /// Handle an authentication error
  static void handleAuthError(
    dynamic exception, {
    required String method,
    String? userId,
    StackTrace? stackTrace,
    bool fatal = false,
  }) {
    // Get stack trace if not provided
    final trace = stackTrace ?? StackTrace.current;

    // Log to console
    Logger.e(
      'Authentication error: $method',
      error: exception,
      stackTrace: trace,
      tag: 'Auth',
    );

    // Report to crashlytics
    _crashlyticsService.recordAuthError(
      exception: exception,
      stack: trace,
      method: method,
      userId: userId,
      fatal: fatal,
    );
  }

  /// Handle a permission error
  static void handlePermissionError(
    dynamic exception, {
    required String permission,
    StackTrace? stackTrace,
    bool fatal = false,
  }) {
    // Get stack trace if not provided
    final trace = stackTrace ?? StackTrace.current;

    // Log to console
    Logger.e(
      'Permission error: $permission',
      error: exception,
      stackTrace: trace,
      tag: 'Permission',
    );

    // Report to crashlytics
    _crashlyticsService.recordPermissionError(
      exception: exception,
      stack: trace,
      permission: permission,
      fatal: fatal,
    );
  }

  /// Handle a validation error
  static void handleValidationError(
    dynamic exception, {
    required String field,
    String? value,
    StackTrace? stackTrace,
    bool fatal = false,
  }) {
    // Get stack trace if not provided
    final trace = stackTrace ?? StackTrace.current;

    // Log to console
    Logger.e(
      'Validation error: $field',
      error: exception,
      stackTrace: trace,
      tag: 'Validation',
    );

    // Report to crashlytics
    _crashlyticsService.recordValidationError(
      exception: exception,
      stack: trace,
      field: field,
      value: value,
      fatal: fatal,
    );
  }

  /// Handle a state error
  static void handleStateError(
    dynamic exception, {
    required String currentState,
    required String expectedState,
    StackTrace? stackTrace,
    bool fatal = false,
  }) {
    // Get stack trace if not provided
    final trace = stackTrace ?? StackTrace.current;

    // Log to console
    Logger.e(
      'State error: Expected $expectedState, got $currentState',
      error: exception,
      stackTrace: trace,
      tag: 'State',
    );

    // Report to crashlytics
    _crashlyticsService.recordStateError(
      exception: exception,
      stack: trace,
      currentState: currentState,
      expectedState: expectedState,
      fatal: fatal,
    );
  }

  /// Set user identifier for error reporting
  static void setUserIdentifier(String? userId) {
    if (userId != null) {
      _crashlyticsService.setUserIdentifier(userId);
    }
  }

  /// Add custom key for error reporting
  static void setCustomKey(String key, dynamic value) {
    _crashlyticsService.setCustomKey(key, value);
  }

  /// Add log message for error reporting
  static void addLog(String message) {
    _crashlyticsService.log(message);
  }
}
