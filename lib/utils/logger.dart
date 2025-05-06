import 'package:flutter/foundation.dart';

/// Log levels for the application
enum LogLevel {
  /// Debug level for detailed information
  debug,

  /// Info level for general information
  info,

  /// Warning level for potential issues
  warning,

  /// Error level for errors
  error,

  /// None level to disable logging
  none,
}

/// Logger utility for the application
class Logger {
  /// Minimum log level to display
  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// Whether to include timestamps in logs
  static bool _includeTimestamps = true;

  /// Whether to include log levels in logs
  static bool _includeLevels = true;

  /// Configure the logger
  static void configure({
    LogLevel? minLevel,
    bool? includeTimestamps,
    bool? includeLevels,
  }) {
    if (minLevel != null) _minLevel = minLevel;
    if (includeTimestamps != null) _includeTimestamps = includeTimestamps;
    if (includeLevels != null) _includeLevels = includeLevels;
  }

  /// Log a debug message
  static void d(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  /// Log an info message
  static void i(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  /// Log a warning message
  static void w(String message, {String? tag}) {
    _log(LogLevel.warning, message, tag: tag);
  }

  /// Log an error message
  static void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Internal logging method
  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Skip if level is below minimum
    if (level.index < _minLevel.index) return;

    // Build log message
    final buffer = StringBuffer();

    // Add timestamp if enabled
    if (_includeTimestamps) {
      buffer.write('[${DateTime.now().toIso8601String()}] ');
    }

    // Add level if enabled
    if (_includeLevels) {
      buffer.write('[${level.toString().toUpperCase()}] ');
    }

    // Add tag if provided
    if (tag != null) {
      buffer.write('[$tag] ');
    }

    // Add message
    buffer.write(message);

    // Add error if provided
    if (error != null) {
      buffer.write('\nError: $error');
    }

    // Add stack trace if provided
    if (stackTrace != null) {
      buffer.write('\nStack trace:\n$stackTrace');
    }

    // Print the log message
    // ignore: avoid_print
    print(buffer.toString());
  }
}
