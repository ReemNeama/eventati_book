import 'package:eventati_book/services/interfaces/crashlytics_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// Implementation of CrashlyticsServiceInterface using PostHog
class PostHogCrashlyticsService implements CrashlyticsServiceInterface {
  /// Whether collection is enabled
  bool _isEnabled = true;

  /// PostHog instance
  final Posthog _posthog = Posthog();

  @override
  Future<void> initialize() async {
    try {
      // PostHog is initialized in main.dart
      _isEnabled = true;
      Logger.i('PostHog initialized', tag: 'PostHogCrashlyticsService');
    } catch (e) {
      Logger.e(
        'Error initializing PostHog: $e',
        tag: 'PostHogCrashlyticsService',
      );
      _isEnabled = false;
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
    if (!_isEnabled) return;

    try {
      final properties = <String, Object>{
        'exception': exception.toString(),
        'fatal': fatal,
      };

      if (stack != null) {
        properties['stackTrace'] = stack.toString();
      }

      if (reason != null) {
        properties['reason'] = reason;
      }

      await _posthog.capture(eventName: 'error', properties: properties);

      if (printDetails ?? kDebugMode) {
        Logger.e(
          'Error: $exception\nReason: $reason\nStack: $stack',
          tag: 'PostHogCrashlyticsService',
        );
      }
    } catch (e) {
      Logger.e('Error recording error: $e', tag: 'PostHogCrashlyticsService');
    }
  }

  @override
  Future<void> recordFlutterError(
    FlutterErrorDetails flutterErrorDetails, {
    bool fatal = false,
  }) async {
    if (!_isEnabled) return;

    try {
      final properties = <String, Object>{
        'exception': flutterErrorDetails.exception.toString(),
        'fatal': fatal,
      };

      if (flutterErrorDetails.stack != null) {
        properties['stackTrace'] = flutterErrorDetails.stack.toString();
      }

      if (flutterErrorDetails.context != null) {
        properties['context'] = flutterErrorDetails.context.toString();
      }

      await _posthog.capture(
        eventName: 'flutter_error',
        properties: properties,
      );
    } catch (e) {
      Logger.e(
        'Error recording Flutter error: $e',
        tag: 'PostHogCrashlyticsService',
      );
    }
  }

  @override
  Future<void> log(String message) async {
    if (!_isEnabled) return;

    try {
      await _posthog.capture(
        eventName: 'log',
        properties: {'message': message},
      );
    } catch (e) {
      Logger.e('Error logging message: $e', tag: 'PostHogCrashlyticsService');
    }
  }

  // This method is not part of the interface but used internally
  Future<void> _setUserIdInternal(String? userId) async {
    if (!_isEnabled) return;

    try {
      if (userId != null) {
        await _posthog.identify(
          userId: userId,
          userProperties: {'userId': userId},
        );
      } else {
        await _posthog.reset();
      }
    } catch (e) {
      Logger.e('Error setting user ID: $e', tag: 'PostHogCrashlyticsService');
    }
  }

  @override
  Future<void> setUserIdentifier(String? identifier) async {
    await _setUserIdInternal(identifier);
  }

  @override
  Future<void> setCustomKey(String key, dynamic value) async {
    if (!_isEnabled) return;

    try {
      // PostHog doesn't have a direct equivalent to setCustomKey
      // We'll use a capture event with a special name
      await _posthog.capture(
        eventName: 'set_custom_property',
        properties: {key: value},
      );
    } catch (e) {
      Logger.e(
        'Error setting custom key: $e',
        tag: 'PostHogCrashlyticsService',
      );
    }
  }

  @override
  Future<void> setCustomKeys(Map<String, dynamic> keys) async {
    if (!_isEnabled) return;

    try {
      // PostHog doesn't have a direct equivalent to setCustomKeys
      // We'll use a capture event with a special name
      final safeProperties = Map<String, Object>.from(keys);
      await _posthog.capture(
        eventName: 'set_custom_properties',
        properties: safeProperties,
      );
    } catch (e) {
      Logger.e(
        'Error setting custom keys: $e',
        tag: 'PostHogCrashlyticsService',
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
    if (!_isEnabled) return;

    try {
      await _posthog.capture(
        eventName: 'caught_exception',
        properties: {
          'exception': exception.toString(),
          'stackTrace': stack.toString(),
          if (context != null) 'context': context,
          'fatal': fatal,
        },
      );
    } catch (e) {
      Logger.e(
        'Error recording caught exception: $e',
        tag: 'PostHogCrashlyticsService',
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
    if (!_isEnabled) return;

    try {
      await _posthog.capture(
        eventName: 'network_error',
        properties: {
          'exception': exception.toString(),
          'stackTrace': stack.toString(),
          'url': url,
          'method': method,
          if (statusCode != null) 'statusCode': statusCode,
          if (response != null) 'response': response,
          if (headers != null) 'headers': headers,
          'fatal': fatal,
        },
      );
    } catch (e) {
      Logger.e(
        'Error recording network error: $e',
        tag: 'PostHogCrashlyticsService',
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
    if (!_isEnabled) return;

    try {
      await _posthog.capture(
        eventName: 'database_error',
        properties: {
          'exception': exception.toString(),
          'stackTrace': stack.toString(),
          'operation': operation,
          'collection': collection,
          if (document != null) 'document': document,
          'fatal': fatal,
        },
      );
    } catch (e) {
      Logger.e(
        'Error recording database error: $e',
        tag: 'PostHogCrashlyticsService',
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
    if (!_isEnabled) return;

    try {
      await _posthog.capture(
        eventName: 'auth_error',
        properties: {
          'exception': exception.toString(),
          'stackTrace': stack.toString(),
          'method': method,
          if (userId != null) 'userId': userId,
          'fatal': fatal,
        },
      );
    } catch (e) {
      Logger.e(
        'Error recording auth error: $e',
        tag: 'PostHogCrashlyticsService',
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
    if (!_isEnabled) return;

    try {
      await _posthog.capture(
        eventName: 'validation_error',
        properties: {
          'exception': exception.toString(),
          'stackTrace': stack.toString(),
          'field': field,
          if (value != null) 'value': value,
          'fatal': fatal,
        },
      );
    } catch (e) {
      Logger.e(
        'Error recording validation error: $e',
        tag: 'PostHogCrashlyticsService',
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
    if (!_isEnabled) return;

    try {
      await _posthog.capture(
        eventName: 'state_error',
        properties: {
          'exception': exception.toString(),
          'stackTrace': stack.toString(),
          'currentState': currentState,
          'expectedState': expectedState,
          'fatal': fatal,
        },
      );
    } catch (e) {
      Logger.e(
        'Error recording state error: $e',
        tag: 'PostHogCrashlyticsService',
      );
    }
  }

  @override
  Future<void> crash() async {
    if (!_isEnabled) return;

    throw Exception('Forced crash for testing PostHog integration');
  }

  @override
  Future<bool> isCrashlyticsCollectionEnabled() async {
    return _isEnabled;
  }

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    _isEnabled = enabled;
  }

  @override
  Future<void> recordPermissionError({
    required dynamic exception,
    required StackTrace stack,
    required String permission,
    String? context,
    bool fatal = false,
  }) async {
    if (!_isEnabled) return;

    try {
      final properties = <String, Object>{
        'exception': exception.toString(),
        'stackTrace': stack.toString(),
        'permission': permission,
        'fatal': fatal,
      };

      if (context != null) {
        properties['context'] = context;
      }

      await _posthog.capture(
        eventName: 'permission_error',
        properties: properties,
      );
    } catch (e) {
      Logger.e(
        'Error recording permission error: $e',
        tag: 'PostHogCrashlyticsService',
      );
    }
  }
}
