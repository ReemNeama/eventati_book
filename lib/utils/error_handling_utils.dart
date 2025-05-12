import 'package:eventati_book/utils/error_utils.dart';

/// Utility class for handling errors in the UI
class ErrorHandlingUtils {
  /// Log an error to the console and crashlytics
  static void logError(dynamic error, {StackTrace? stackTrace}) {
    final message = error.toString();
    ErrorUtils.logError(message, error: error, stackTrace: stackTrace);
  }

  /// Get a user-friendly error message based on the error type
  static String getErrorMessage(dynamic error) {
    if (error == null) {
      return 'An unknown error occurred';
    }

    // Handle common error types
    if (error is FormatException) {
      return 'Invalid format: ${error.message}';
    } else if (error is ArgumentError) {
      return 'Invalid argument: ${error.message}';
    } else if (error is StateError) {
      return 'State error: ${error.message}';
    } else if (error is TypeError) {
      return 'Type error: ${error.toString()}';
    } else if (error is UnsupportedError) {
      return 'Unsupported operation: ${error.message}';
    } else if (error is RangeError) {
      return 'Range error: ${error.message}';
    } else if (error is AssertionError) {
      return 'Assertion error: ${error.message}';
    } else if (error is Exception) {
      return 'Exception: ${error.toString()}';
    }

    // If it's a string, return it directly
    if (error is String) {
      return error;
    }

    // Default error message
    return error.toString();
  }

  /// Handle an exception and show a user-friendly message
  static String handleException(dynamic exception, {String? context}) {
    // Log the error
    ErrorUtils.handleException(exception, context: context);

    // Return a user-friendly message
    return getErrorMessage(exception);
  }
}
