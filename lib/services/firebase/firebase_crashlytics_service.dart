import 'dart:io';

import 'package:eventati_book/services/interfaces/crashlytics_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Implementation of CrashlyticsServiceInterface using Firebase Crashlytics
class FirebaseCrashlyticsService implements CrashlyticsServiceInterface {
  /// Firebase Crashlytics instance
  final FirebaseCrashlytics _crashlytics;

  /// Constructor
  FirebaseCrashlyticsService({FirebaseCrashlytics? crashlytics})
    : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  @override
  Future<void> initialize() async {
    try {
      // Check if platform is supported
      if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
        Logger.i(
          'Firebase Crashlytics is not supported on this platform',
          tag: 'FirebaseCrashlyticsService',
        );
        return;
      }

      // Enable collection of crash reports
      await _crashlytics.setCrashlyticsCollectionEnabled(true);

      // Pass all uncaught Flutter errors to Crashlytics
      FlutterError.onError = (FlutterErrorDetails details) {
        _crashlytics.recordFlutterError(details);
        // Forward to original handler
        FlutterError.presentError(details);
      };

      // Set up PlatformDispatcher error handler for non-Flutter errors
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics.recordError(error, stack, fatal: true);
        // Allow the error to propagate
        return false;
      };

      Logger.i(
        'Firebase Crashlytics initialized',
        tag: 'FirebaseCrashlyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error initializing Firebase Crashlytics: $e',
        tag: 'FirebaseCrashlyticsService',
      );
    }
  }

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    Iterable<DiagnosticsNode>? information,
    bool? printDetails,
    bool fatal = false,
  }) async {
    try {
      // Due to type compatibility issues, we'll just record the error without the information parameter
      await _crashlytics.recordError(
        exception,
        stack,
        reason: reason,
        fatal: fatal,
      );

      Logger.d('Error recorded: $exception', tag: 'FirebaseCrashlyticsService');
    } catch (e) {
      Logger.e('Error recording error: $e', tag: 'FirebaseCrashlyticsService');
    }
  }

  @override
  Future<void> recordFlutterError(
    FlutterErrorDetails flutterErrorDetails, {
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordFlutterError(flutterErrorDetails, fatal: fatal);

      Logger.d('Flutter error recorded', tag: 'FirebaseCrashlyticsService');
    } catch (e) {
      Logger.e(
        'Error recording Flutter error: $e',
        tag: 'FirebaseCrashlyticsService',
      );
    }
  }

  @override
  Future<void> log(String message) async {
    try {
      await _crashlytics.log(message);

      Logger.d(
        'Log added to Crashlytics: $message',
        tag: 'FirebaseCrashlyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error adding log to Crashlytics: $e',
        tag: 'FirebaseCrashlyticsService',
      );
    }
  }

  @override
  Future<void> setCustomKey(String key, dynamic value) async {
    try {
      if (value is String) {
        await _crashlytics.setCustomKey(key, value);
      } else if (value is bool) {
        await _crashlytics.setCustomKey(key, value);
      } else if (value is int) {
        await _crashlytics.setCustomKey(key, value);
      } else if (value is double) {
        await _crashlytics.setCustomKey(key, value);
      } else {
        await _crashlytics.setCustomKey(key, value.toString());
      }

      Logger.d(
        'Custom key set: $key = $value',
        tag: 'FirebaseCrashlyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error setting custom key: $e',
        tag: 'FirebaseCrashlyticsService',
      );
    }
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    try {
      await _crashlytics.setUserIdentifier(identifier);

      Logger.d(
        'User identifier set: $identifier',
        tag: 'FirebaseCrashlyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error setting user identifier: $e',
        tag: 'FirebaseCrashlyticsService',
      );
    }
  }

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(enabled);

      Logger.d(
        'Crashlytics collection enabled: $enabled',
        tag: 'FirebaseCrashlyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error setting Crashlytics collection enabled: $e',
        tag: 'FirebaseCrashlyticsService',
      );
    }
  }

  @override
  Future<bool> isCrashlyticsCollectionEnabled() async {
    try {
      // This method is not available in the current version of firebase_crashlytics
      // Return the default value
      const isEnabled = true;

      Logger.d(
        'Crashlytics collection enabled: $isEnabled',
        tag: 'FirebaseCrashlyticsService',
      );

      return isEnabled;
    } catch (e) {
      Logger.e(
        'Error checking if Crashlytics collection is enabled: $e',
        tag: 'FirebaseCrashlyticsService',
      );
      return false;
    }
  }

  @override
  Future<void> setCustomKeys(Map<String, dynamic> keys) async {
    try {
      for (final entry in keys.entries) {
        await setCustomKey(entry.key, entry.value);
      }

      Logger.d(
        'Custom keys set: ${keys.length} keys',
        tag: 'FirebaseCrashlyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error setting custom keys: $e',
        tag: 'FirebaseCrashlyticsService',
      );
    }
  }

  @override
  Future<void> recordCaughtException({
    required dynamic exception,
    required StackTrace stack,
    String? context,
    bool fatal = false,
  }) async {
    try {
      // Add context as a custom key if provided
      if (context != null) {
        await setCustomKey('exception_context', context);
      }

      await recordError(
        exception,
        stack,
        reason: 'Caught exception${context != null ? ' in $context' : ''}',
        fatal: fatal,
      );

      Logger.d(
        'Caught exception recorded: $exception',
        tag: 'FirebaseCrashlyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error recording caught exception: $e',
        tag: 'FirebaseCrashlyticsService',
      );
    }
  }

  @override
  Future<void> recordNetworkError({
    required dynamic exception,
    required StackTrace stack,
    required String url,
    required String method,
    int? statusCode,
    String? response,
    Map<String, dynamic>? headers,
    bool fatal = false,
  }) async {
    try {
      // Add network-specific custom keys
      await setCustomKey('network_url', url);
      await setCustomKey('network_method', method);

      if (statusCode != null) {
        await setCustomKey('network_status_code', statusCode);
      }

      if (response != null) {
        // Limit response size to avoid exceeding Crashlytics limits
        final limitedResponse =
            response.length > 1000
                ? '${response.substring(0, 997)}...'
                : response;
        await setCustomKey('network_response', limitedResponse);
      }

      if (headers != null) {
        // Remove sensitive headers
        final sanitizedHeaders =
            Map<String, dynamic>.from(headers)
              ..remove('Authorization')
              ..remove('Cookie')
              ..remove('X-Auth-Token');
        await setCustomKey('network_headers', sanitizedHeaders.toString());
      }

      await recordError(
        exception,
        stack,
        reason:
            'Network error: $method $url${statusCode != null ? ' ($statusCode)' : ''}',
        fatal: fatal,
      );

      Logger.d(
        'Network error recorded: $exception',
        tag: 'FirebaseCrashlyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error recording network error: $e',
        tag: 'FirebaseCrashlyticsService',
      );
    }
  }

  @override
  Future<void> recordDatabaseError({
    required dynamic exception,
    required StackTrace stack,
    required String operation,
    required String collection,
    String? document,
    bool fatal = false,
  }) async {
    try {
      // Add database-specific custom keys
      await setCustomKey('database_operation', operation);
      await setCustomKey('database_collection', collection);

      if (document != null) {
        await setCustomKey('database_document', document);
      }

      await recordError(
        exception,
        stack,
        reason:
            'Database error: $operation on $collection${document != null ? '/$document' : ''}',
        fatal: fatal,
      );

      Logger.d(
        'Database error recorded: $exception',
        tag: 'FirebaseCrashlyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error recording database error: $e',
        tag: 'FirebaseCrashlyticsService',
      );
    }
  }

  @override
  Future<void> recordAuthError({
    required dynamic exception,
    required StackTrace stack,
    required String method,
    String? userId,
    bool fatal = false,
  }) async {
    try {
      // Add auth-specific custom keys
      await setCustomKey('auth_method', method);

      if (userId != null) {
        await setCustomKey('auth_user_id', userId);
      }

      await recordError(
        exception,
        stack,
        reason: 'Authentication error: $method',
        fatal: fatal,
      );

      Logger.d(
        'Authentication error recorded: $exception',
        tag: 'FirebaseCrashlyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error recording authentication error: $e',
        tag: 'FirebaseCrashlyticsService',
      );
    }
  }

  @override
  Future<void> recordPermissionError({
    required dynamic exception,
    required StackTrace stack,
    required String permission,
    bool fatal = false,
  }) async {
    try {
      // Add permission-specific custom keys
      await setCustomKey('permission_type', permission);

      await recordError(
        exception,
        stack,
        reason: 'Permission error: $permission',
        fatal: fatal,
      );

      Logger.d(
        'Permission error recorded: $exception',
        tag: 'FirebaseCrashlyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error recording permission error: $e',
        tag: 'FirebaseCrashlyticsService',
      );
    }
  }

  @override
  Future<void> recordValidationError({
    required dynamic exception,
    required StackTrace stack,
    required String field,
    String? value,
    bool fatal = false,
  }) async {
    try {
      // Add validation-specific custom keys
      await setCustomKey('validation_field', field);

      if (value != null) {
        await setCustomKey('validation_value', value);
      }

      await recordError(
        exception,
        stack,
        reason: 'Validation error: $field',
        fatal: fatal,
      );

      Logger.d(
        'Validation error recorded: $exception',
        tag: 'FirebaseCrashlyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error recording validation error: $e',
        tag: 'FirebaseCrashlyticsService',
      );
    }
  }

  @override
  Future<void> recordStateError({
    required dynamic exception,
    required StackTrace stack,
    required String currentState,
    required String expectedState,
    bool fatal = false,
  }) async {
    try {
      // Add state-specific custom keys
      await setCustomKey('state_current', currentState);
      await setCustomKey('state_expected', expectedState);

      await recordError(
        exception,
        stack,
        reason: 'State error: Expected $expectedState, got $currentState',
        fatal: fatal,
      );

      Logger.d(
        'State error recorded: $exception',
        tag: 'FirebaseCrashlyticsService',
      );
    } catch (e) {
      Logger.e(
        'Error recording state error: $e',
        tag: 'FirebaseCrashlyticsService',
      );
    }
  }

  @override
  Future<void> crash() async {
    try {
      // Force a crash for testing purposes
      _crashlytics.crash();
    } catch (e) {
      Logger.e('Error forcing crash: $e', tag: 'FirebaseCrashlyticsService');
    }
  }
}
