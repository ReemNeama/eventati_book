import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';

/// A full-screen error widget for critical errors
class ErrorScreen extends StatelessWidget {
  /// The error message to display
  final String message;

  /// Optional error details
  final String? details;

  /// Optional retry callback
  final VoidCallback? onRetry;

  /// Optional home navigation callback
  final VoidCallback? onGoHome;

  const ErrorScreen({
    super.key,
    required this.message,
    this.details,
    this.onRetry,
    this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final errorColor = isDarkMode ? AppColorsDark.error : AppColors.error;
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.grey[100];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: errorColor,
                size: 64,
                semanticLabel: 'Error icon',
              ),
              const SizedBox(height: 24),
              Text(
                'Something went wrong',
                style: TextStyle(
                  color: errorColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              if (details != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    // Use null-safe approach with null coalescing operator
                    details ?? '',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white60 : Colors.black54,
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              if (onRetry != null)
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              if (onRetry != null && onGoHome != null)
                const SizedBox(height: 16),
              if (onGoHome != null)
                TextButton.icon(
                  onPressed: onGoHome,
                  icon: const Icon(Icons.home),
                  label: const Text('Go to Home'),
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
