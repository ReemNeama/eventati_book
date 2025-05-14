/// Log levels
enum LogLevel { debug, info, warning, error }

/// Simple logger for scripts
class Logger {
  /// Current log level
  static LogLevel level = LogLevel.info;

  /// Log a debug message
  static void d(String message, {String? tag}) {
    if (level.index <= LogLevel.debug.index) {
      _log('DEBUG', message, tag);
    }
  }

  /// Log an info message
  static void i(String message, {String? tag}) {
    if (level.index <= LogLevel.info.index) {
      _log('INFO', message, tag);
    }
  }

  /// Log a warning message
  static void w(String message, {String? tag}) {
    if (level.index <= LogLevel.warning.index) {
      _log('WARNING', message, tag);
    }
  }

  /// Log an error message
  static void e(String message, {String? tag}) {
    if (level.index <= LogLevel.error.index) {
      _log('ERROR', message, tag);
    }
  }

  /// Internal log method
  static void _log(String level, String message, String? tag) {
    final timestamp = DateTime.now().toString();
    final tagStr = tag != null ? '[$tag]' : '';
    // Using print is acceptable in script files
    // ignore: avoid_print
    print('$timestamp [$level]$tagStr $message');
  }
}
