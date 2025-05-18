import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/text_styles.dart';

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
      padding: const EdgeInsets.all(24.0), // Large padding
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.error),
          const SizedBox(height: 16.0), // Medium padding
          Text(
            message,
            style: TextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24.0), // Large padding
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, // Medium padding
                  vertical: 8.0, // Small padding
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
