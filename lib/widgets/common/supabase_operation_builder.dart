import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/common/supabase_error_handler.dart';

/// Widget that handles Supabase operations with loading, error, and success states
class SupabaseOperationBuilder<T> extends StatelessWidget {
  /// Future that represents the Supabase operation
  final Future<T> future;

  /// Builder for the loading state
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Builder for the error state
  final Widget Function(BuildContext context, dynamic error)? errorBuilder;

  /// Builder for the success state
  final Widget Function(BuildContext context, T data) builder;

  /// Callback when retry is pressed
  final VoidCallback? onRetry;

  /// Whether to show a retry button
  final bool showRetry;

  /// Whether to show error details
  final bool showErrorDetails;

  /// Constructor
  const SupabaseOperationBuilder({
    super.key,
    required this.future,
    this.loadingBuilder,
    this.errorBuilder,
    required this.builder,
    this.onRetry,
    this.showRetry = true,
    this.showErrorDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingBuilder?.call(context) ??
              const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          if (errorBuilder != null) {
            return errorBuilder!(context, snapshot.error);
          }
          return SupabaseErrorHandler(
            error: snapshot.error,
            onRetry: onRetry ?? () {},
            showRetryButton: showRetry,
            customErrorMessage: showErrorDetails ? null : 'An error occurred',
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        }

        return builder(context, snapshot.data as T);
      },
    );
  }
}
