import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/common/error_message.dart';
import 'package:eventati_book/widgets/common/error_screen.dart';

/// Utility functions for error handling
class ErrorHandlingUtils {
  /// Show a snackbar with an error message
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
          if (onRetry != null) ...[
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                onRetry();
              },
              child: const Text(
                'RETRY',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
      backgroundColor: Colors.red,
      duration: duration,
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Show a dialog with an error message
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    String? details,
    VoidCallback? onRetry,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message),
                if (details != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      details,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('CLOSE'),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text('RETRY'),
              ),
          ],
        );
      },
    );
  }

  /// Format an exception into a user-friendly message
  static String formatExceptionMessage(dynamic exception) {
    if (exception is String) {
      return exception;
    }
    
    // Handle common exceptions
    if (exception is FormatException) {
      return 'Invalid format: ${exception.message}';
    }
    
    if (exception is TimeoutException) {
      return 'The operation timed out. Please try again.';
    }
    
    if (exception is NetworkException) {
      return 'Network error: ${exception.message}';
    }
    
    // Default message
    return exception?.toString() ?? 'An unknown error occurred';
  }

  /// Get error widget based on error type and context
  static Widget getErrorWidget(
    String message, {
    String? details,
    VoidCallback? onRetry,
    ErrorDisplayType displayType = ErrorDisplayType.standard,
  }) {
    return ErrorMessage(
      message: message,
      details: details,
      onRetry: onRetry,
      displayType: displayType,
    );
  }

  /// Get a full-screen error widget
  static Widget getErrorScreen(
    String message, {
    String? details,
    VoidCallback? onRetry,
    VoidCallback? onGoHome,
  }) {
    return ErrorScreen(
      message: message,
      details: details,
      onRetry: onRetry,
      onGoHome: onGoHome,
    );
  }
}

/// Exception for network-related errors
class NetworkException implements Exception {
  final String message;
  
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

/// Exception for timeout errors
class TimeoutException implements Exception {
  final String message;
  
  TimeoutException(this.message);
  
  @override
  String toString() => 'TimeoutException: $message';
}
