import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/common/firebase_error_handler.dart';

/// Widget that handles Firebase streams with loading, error, and data states
class FirebaseStreamBuilder<T> extends StatelessWidget {
  /// Stream that represents the Firebase data
  final Stream<T> stream;

  /// Builder for the loading state
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Builder for the error state
  final Widget Function(BuildContext context, dynamic error)? errorBuilder;

  /// Builder for the data state
  final Widget Function(BuildContext context, T data) builder;

  /// Builder for the empty state
  final Widget Function(BuildContext context)? emptyBuilder;

  /// Callback when retry is pressed
  final VoidCallback? onRetry;

  /// Whether to show a retry button
  final bool showRetry;

  /// Whether to show error details
  final bool showErrorDetails;

  /// Constructor
  const FirebaseStreamBuilder({
    super.key,
    required this.stream,
    this.loadingBuilder,
    this.errorBuilder,
    required this.builder,
    this.emptyBuilder,
    this.onRetry,
    this.showRetry = true,
    this.showErrorDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingBuilder?.call(context) ??
              const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          if (errorBuilder != null) {
            return errorBuilder!(context, snapshot.error);
          }
          return FirebaseErrorHandler(
            error: snapshot.error,
            onRetry: onRetry,
            showRetry: showRetry,
            showDetails: showErrorDetails,
            child: const SizedBox.shrink(),
          );
        }

        if (!snapshot.hasData) {
          return emptyBuilder?.call(context) ??
              const Center(child: Text('No data available'));
        }

        // For lists, check if the list is empty
        if (snapshot.data is List && (snapshot.data as List).isEmpty) {
          return emptyBuilder?.call(context) ??
              const Center(child: Text('No items available'));
        }

        return builder(context, snapshot.data as T);
      },
    );
  }
}
