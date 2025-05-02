import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';

/// Error display type
enum ErrorDisplayType {
  /// Standard error with icon and message
  standard,

  /// Compact error with smaller icon and message
  compact,

  /// Inline error with just text
  inline,
}

/// A reusable error message widget
class ErrorMessage extends StatelessWidget {
  /// The error message to display
  final String message;

  /// Optional error details
  final String? details;

  /// Optional retry callback
  final VoidCallback? onRetry;

  /// Display type for the error
  final ErrorDisplayType displayType;

  /// Whether to show the error icon
  final bool showIcon;

  const ErrorMessage({
    super.key,
    required this.message,
    this.details,
    this.onRetry,
    this.displayType = ErrorDisplayType.standard,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final errorColor = isDarkMode ? AppColorsDark.error : AppColors.error;
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    switch (displayType) {
      case ErrorDisplayType.standard:
        return _buildStandardError(context, errorColor, primaryColor);
      case ErrorDisplayType.compact:
        return _buildCompactError(context, errorColor, primaryColor);
      case ErrorDisplayType.inline:
        return _buildInlineError(context, errorColor);
    }
  }

  Widget _buildStandardError(
    BuildContext context,
    Color errorColor,
    Color primaryColor,
  ) {
    final isDarkMode = UIUtils.isDarkMode(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon) ...[
              Icon(
                Icons.error_outline,
                color: errorColor,
                size: 48,
                semanticLabel: 'Error icon',
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Error',
              style: TextStyle(
                color: errorColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color:
                    isDarkMode
                        ? AppColorsDark.textSecondary
                        : AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (details != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  details!,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white60 : Colors.black54,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
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
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactError(
    BuildContext context,
    Color errorColor,
    Color primaryColor,
  ) {
    final isDarkMode = UIUtils.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          if (showIcon) ...[
            Icon(
              Icons.error_outline,
              color: errorColor,
              size: 24,
              semanticLabel: 'Error icon',
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color:
                        isDarkMode
                            ? AppColorsDark.textPrimary
                            : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (details != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    details!,
                    style: TextStyle(
                      color:
                          isDarkMode
                              ? AppColorsDark.textSecondary
                              : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              color: primaryColor,
              tooltip: 'Retry',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInlineError(BuildContext context, Color errorColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.error_outline,
              color: errorColor,
              size: 16,
              semanticLabel: 'Error icon',
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: errorColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
