import 'package:flutter/material.dart';
import 'package:eventati_book/utils/styles.dart';

/// A widget to display error messages with a retry button
class ErrorDisplay extends StatelessWidget {
  /// The error message to display
  final String message;

  /// Callback function when retry button is pressed
  final VoidCallback? onRetry;

  /// Icon to display
  final IconData icon;

  /// Constructor
  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppPadding.large),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.errorColor),
          const SizedBox(height: AppPadding.medium),
          Text(
            message,
            style: AppTextStyles.bodyText,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppPadding.large),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.medium,
                  vertical: AppPadding.small,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
