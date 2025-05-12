import 'package:flutter/material.dart';
import 'package:eventati_book/services/supabase/utils/supabase_exceptions.dart';
import 'package:eventati_book/utils/error_handling_utils.dart';
import 'package:eventati_book/widgets/common/error_retry_button.dart';

/// Widget for handling Supabase errors with a retry option
class SupabaseErrorHandler extends StatelessWidget {
  /// The error that occurred
  final dynamic error;

  /// The stack trace of the error
  final StackTrace? stackTrace;

  /// The callback to retry the operation
  final VoidCallback onRetry;

  /// Whether to show a retry button
  final bool showRetryButton;

  /// Custom error message to display
  final String? customErrorMessage;

  /// Custom retry button text
  final String? retryButtonText;

  /// Constructor
  const SupabaseErrorHandler({
    super.key,
    required this.error,
    this.stackTrace,
    required this.onRetry,
    this.showRetryButton = true,
    this.customErrorMessage,
    this.retryButtonText,
  });

  @override
  Widget build(BuildContext context) {
    final errorMessage = customErrorMessage ?? _getErrorMessage();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (showRetryButton) ...[
              const SizedBox(height: 24),
              ErrorRetryButton(
                onPressed: onRetry,
                text: retryButtonText ?? 'Try Again',
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Get a user-friendly error message based on the error type
  String _getErrorMessage() {
    // Log the error for debugging
    ErrorHandlingUtils.logError(error, stackTrace: stackTrace);

    // Handle specific Supabase errors
    if (error is SupabaseAuthException) {
      return SupabaseExceptions.getAuthErrorMessage(error);
    } else if (error is SupabaseDatabaseException) {
      return SupabaseExceptions.getDatabaseErrorMessage(error);
    } else if (error is SupabaseStorageException) {
      return SupabaseExceptions.getStorageErrorMessage(error);
    } else if (error is SupabaseNetworkException) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (error is SupabaseTimeoutException) {
      return 'The operation timed out. Please try again.';
    } else if (error is SupabasePermissionException) {
      return 'You don\'t have permission to perform this action.';
    }

    // Handle general errors
    return ErrorHandlingUtils.getErrorMessage(error);
  }
}
