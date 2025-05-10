import 'package:flutter/material.dart';
import 'package:eventati_book/services/firebase/utils/firebase_exceptions.dart';
import 'package:eventati_book/utils/ui/error_handling_utils.dart';
import 'package:eventati_book/widgets/common/error_retry_button.dart';

/// Widget that handles Firebase errors
class FirebaseErrorHandler extends StatelessWidget {
  /// Child widget to display when there's no error
  final Widget child;

  /// Error to handle
  final dynamic error;

  /// Callback when retry is pressed
  final VoidCallback? onRetry;

  /// Whether to show a retry button
  final bool showRetry;

  /// Whether to show error details
  final bool showDetails;

  /// Constructor
  const FirebaseErrorHandler({
    super.key,
    required this.child,
    required this.error,
    this.onRetry,
    this.showRetry = true,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    if (error == null) {
      return child;
    }

    String errorMessage = 'An error occurred';
    String? errorDetails;

    if (error is FirebaseAuthException) {
      final authError = error as FirebaseAuthException;
      errorMessage = 'Authentication Error: ${authError.message}';
      errorDetails =
          showDetails
              ? 'Method: ${authError.method}\n'
                  'User ID: ${authError.userId ?? 'N/A'}'
              : null;
    } else if (error is FirestoreException) {
      final firestoreError = error as FirestoreException;
      errorMessage = 'Database Error: ${firestoreError.message}';
      errorDetails =
          showDetails
              ? 'Operation: ${firestoreError.operation}\n'
                  'Collection: ${firestoreError.collection}\n'
                  'Document ID: ${firestoreError.documentId ?? 'N/A'}'
              : null;
    } else if (error is FirebaseStorageException) {
      final storageError = error as FirebaseStorageException;
      errorMessage = 'Storage Error: ${storageError.message}';
      errorDetails =
          showDetails
              ? 'Operation: ${storageError.operation}\n'
                  'Path: ${storageError.path}'
              : null;
    } else if (error is NetworkConnectivityException) {
      errorMessage =
          'Network Error: You are offline. Please check your connection.';
    } else if (error is OfflineOperationException) {
      final offlineError = error as OfflineOperationException;
      errorMessage =
          'Offline Error: This operation requires an internet connection.';
      errorDetails =
          showDetails ? 'Operation: ${offlineError.operation}' : null;
    } else {
      errorMessage = ErrorHandlingUtils.formatExceptionMessage(error);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (errorDetails != null) ...[
              const SizedBox(height: 8),
              Text(
                errorDetails,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            if (showRetry && onRetry != null) ...[
              const SizedBox(height: 16),
              ErrorRetryButton(onPressed: onRetry!, text: 'Try Again'),
            ],
          ],
        ),
      ),
    );
  }
}
