import 'package:flutter/foundation.dart';

/// Interface for crashlytics services
abstract class CrashlyticsServiceInterface {
  /// Initialize the crashlytics service
  Future<void> initialize();

  /// Record a non-fatal error
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    Iterable<DiagnosticsNode>? information,
    bool? printDetails,
    bool fatal = false,
  });

  /// Record a Flutter error
  Future<void> recordFlutterError(
    FlutterErrorDetails flutterErrorDetails, {
    bool fatal = false,
  });

  /// Log a message
  Future<void> log(String message);

  /// Set a custom key/value pair
  Future<void> setCustomKey(String key, dynamic value);

  /// Set user identifier
  Future<void> setUserIdentifier(String identifier);

  /// Enable/disable collection of crash reports
  Future<void> setCrashlyticsCollectionEnabled(bool enabled);

  /// Check if collection is enabled
  Future<bool> isCrashlyticsCollectionEnabled();

  /// Set custom keys from a map
  Future<void> setCustomKeys(Map<String, dynamic> keys);

  /// Record a caught exception
  Future<void> recordCaughtException({
    required dynamic exception,
    required StackTrace stack,
    String? context,
    bool fatal = false,
  });

  /// Record a network error
  Future<void> recordNetworkError({
    required dynamic exception,
    required StackTrace stack,
    required String url,
    required String method,
    int? statusCode,
    String? response,
    Map<String, dynamic>? headers,
    bool fatal = false,
  });

  /// Record a database error
  Future<void> recordDatabaseError({
    required dynamic exception,
    required StackTrace stack,
    required String operation,
    required String collection,
    String? document,
    bool fatal = false,
  });

  /// Record an authentication error
  Future<void> recordAuthError({
    required dynamic exception,
    required StackTrace stack,
    required String method,
    String? userId,
    bool fatal = false,
  });

  /// Record a permission error
  Future<void> recordPermissionError({
    required dynamic exception,
    required StackTrace stack,
    required String permission,
    bool fatal = false,
  });

  /// Record a validation error
  Future<void> recordValidationError({
    required dynamic exception,
    required StackTrace stack,
    required String field,
    String? value,
    bool fatal = false,
  });

  /// Record a state error
  Future<void> recordStateError({
    required dynamic exception,
    required StackTrace stack,
    required String currentState,
    required String expectedState,
    bool fatal = false,
  });

  /// Force a crash (for testing)
  Future<void> crash();
}
