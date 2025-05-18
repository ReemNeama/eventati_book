import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// Error display type
enum ErrorDisplayType {
  /// Standard error with icon and message
  standard,

  /// Compact error with smaller icon and message
  compact,

  /// Inline error with just text
  inline,

  /// Toast-style error that appears briefly
  toast,

  /// Banner-style error that spans the width of the screen
  banner,

  /// Form field error for use with input fields
  formField,
}

/// Error severity level for visual styling
enum ErrorSeverity {
  /// Low severity - informational
  low,

  /// Medium severity - warning
  medium,

  /// High severity - critical error
  high,
}

/// A reusable error message widget
class ErrorMessage extends StatelessWidget {
  /// The error message to display
  final String message;

  /// Optional error details
  final String? details;

  /// Optional retry callback
  final VoidCallback? onRetry;

  /// Optional dismiss callback
  final VoidCallback? onDismiss;

  /// Display type for the error
  final ErrorDisplayType displayType;

  /// Whether to show the error icon
  final bool showIcon;

  /// Error severity level for visual styling
  final ErrorSeverity severity;

  /// Optional custom icon
  final IconData? customIcon;

  /// Optional custom action text
  final String? actionText;

  /// Optional custom action callback
  final VoidCallback? onAction;

  /// Whether to automatically dismiss the error after a duration (for toast type)
  final bool autoDismiss;

  /// Duration before auto-dismissing (for toast type)
  final Duration autoDismissDuration;

  /// Whether to show a close button
  final bool showCloseButton;

  /// Creates a reusable error message widget
  const ErrorMessage({
    super.key,
    required this.message,
    this.details,
    this.onRetry,
    this.onDismiss,
    this.displayType = ErrorDisplayType.standard,
    this.showIcon = true,
    this.severity = ErrorSeverity.medium,
    this.customIcon,
    this.actionText,
    this.onAction,
    this.autoDismiss = false,
    this.autoDismissDuration = const Duration(seconds: 4),
    this.showCloseButton = false,
  });

  /// Factory constructor for form field errors
  factory ErrorMessage.formField({
    required String message,
    bool showIcon = true,
  }) {
    return ErrorMessage(
      message: message,
      displayType: ErrorDisplayType.formField,
      showIcon: showIcon,
      severity: ErrorSeverity.medium,
    );
  }

  /// Factory constructor for toast errors
  factory ErrorMessage.toast({
    required String message,
    ErrorSeverity severity = ErrorSeverity.medium,
    VoidCallback? onDismiss,
    bool autoDismiss = true,
    Duration autoDismissDuration = const Duration(seconds: 4),
  }) {
    return ErrorMessage(
      message: message,
      displayType: ErrorDisplayType.toast,
      severity: severity,
      onDismiss: onDismiss,
      autoDismiss: autoDismiss,
      autoDismissDuration: autoDismissDuration,
      showCloseButton: true,
    );
  }

  /// Factory constructor for banner errors
  factory ErrorMessage.banner({
    required String message,
    String? details,
    ErrorSeverity severity = ErrorSeverity.medium,
    VoidCallback? onDismiss,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return ErrorMessage(
      message: message,
      details: details,
      displayType: ErrorDisplayType.banner,
      severity: severity,
      onDismiss: onDismiss,
      actionText: actionText,
      onAction: onAction,
      showCloseButton: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final errorColor = _getSeverityColor(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    // If auto-dismiss is enabled and this is a toast, wrap in a dismissible widget
    if (autoDismiss && displayType == ErrorDisplayType.toast) {
      // Use a stateful builder to handle auto-dismiss
      return StatefulBuilder(
        builder: (context, setState) {
          // Schedule auto-dismiss
          Future.delayed(autoDismissDuration, () {
            onDismiss?.call();
          });

          return _buildErrorByType(context, errorColor, primaryColor);
        },
      );
    }

    return _buildErrorByType(context, errorColor, primaryColor);
  }

  /// Build the appropriate error widget based on display type
  Widget _buildErrorByType(
    BuildContext context,
    Color errorColor,
    Color primaryColor,
  ) {
    switch (displayType) {
      case ErrorDisplayType.standard:
        return _buildStandardError(context, errorColor, primaryColor);
      case ErrorDisplayType.compact:
        return _buildCompactError(context, errorColor, primaryColor);
      case ErrorDisplayType.inline:
        return _buildInlineError(context, errorColor);
      case ErrorDisplayType.toast:
        return _buildToastError(context, errorColor, primaryColor);
      case ErrorDisplayType.banner:
        return _buildBannerError(context, errorColor, primaryColor);
      case ErrorDisplayType.formField:
        return _buildFormFieldError(context, errorColor);
    }
  }

  /// Get the appropriate color based on severity
  Color _getSeverityColor(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);

    switch (severity) {
      case ErrorSeverity.low:
        return isDarkMode ? AppColorsDark.info : AppColors.info;
      case ErrorSeverity.medium:
        return isDarkMode ? AppColorsDark.warning : AppColors.warning;
      case ErrorSeverity.high:
        return isDarkMode ? AppColorsDark.error : AppColors.error;
    }
  }

  /// Get the appropriate icon based on severity and custom icon
  IconData _getIcon() {
    if (customIcon != null) {
      return customIcon!;
    }

    switch (severity) {
      case ErrorSeverity.low:
        return Icons.info_outline;
      case ErrorSeverity.medium:
        return Icons.warning_amber_outlined;
      case ErrorSeverity.high:
        return Icons.error_outline;
    }
  }

  Widget _buildStandardError(
    BuildContext context,
    Color errorColor,
    Color primaryColor,
  ) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final textColor = isDarkMode ? AppColorsDark.textPrimary : AppColors.textPrimary;
    final secondaryTextColor = isDarkMode ? AppColorsDark.textSecondary : AppColors.textSecondary;

    // Get responsive values
    final isTablet =
        ResponsiveUtils.getDeviceType(context) != DeviceType.mobile;
    final iconSize = isTablet ? 56.0 : 48.0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon) ...[
              Icon(
                _getIcon(),
                color: errorColor,
                size: iconSize,
                semanticLabel: 'Error icon',
              ),
              const SizedBox(height: 16),
            ],
            Text(
              _getSeverityTitle(),
              style: isTablet 
                ? TextStyles.title.copyWith(color: errorColor)
                : TextStyles.subtitle.copyWith(color: errorColor),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: isTablet 
                ? TextStyles.bodyLarge.copyWith(color: textColor)
                : TextStyles.bodyMedium.copyWith(color: textColor),
              textAlign: TextAlign.center,
            ),
            if (details != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? Color.fromRGBO(
                            AppColors.disabled.r.toInt(),
                            AppColors.disabled.g.toInt(),
                            AppColors.disabled.b.toInt(),
                            0.8,
                          )
                          : Color.fromRGBO(
                            AppColors.disabled.r.toInt(),
                            AppColors.disabled.g.toInt(),
                            AppColors.disabled.b.toInt(),
                            0.2,
                          ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  details ?? '',
                  style: TextStyles.bodySmall.copyWith(
                    color: secondaryTextColor,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onRetry != null)
                  ElevatedButton.icon(
                    onPressed: () {
                      AccessibilityUtils.buttonPressHapticFeedback();
                      onRetry?.call();
                    },
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
                if (onRetry != null && onAction != null)
                  const SizedBox(width: 16),
                if (onAction != null)
                  TextButton(
                    onPressed: () {
                      AccessibilityUtils.buttonPressHapticFeedback();
                      onAction?.call();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: Text(actionText ?? 'Action'),
                  ),
              ],
            ),
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
    final textColor =
        isDarkMode ? AppColorsDark.textPrimary : AppColors.textPrimary;
    final secondaryTextColor =
        isDarkMode ? AppColorsDark.textSecondary : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showIcon) ...[
            Icon(
              _getIcon(),
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
                  style: TextStyles.bodyMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (details != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    details ?? '',
                    style: TextStyles.bodySmall.copyWith(color: secondaryTextColor),
                  ),
                ],
              ],
            ),
          ),
          if (onAction != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                AccessibilityUtils.buttonPressHapticFeedback();
                onAction?.call();
              },
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(actionText ?? 'Action'),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                AccessibilityUtils.buttonPressHapticFeedback();
                onRetry?.call();
              },
              icon: const Icon(Icons.refresh),
              color: primaryColor,
              tooltip: 'Retry',
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
          if (showCloseButton && onDismiss != null) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: () {
                AccessibilityUtils.buttonPressHapticFeedback();
                onDismiss?.call();
              },
              icon: const Icon(Icons.close),
              color: secondaryTextColor,
              tooltip: 'Dismiss',
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ],
      ),
    );
  }

  /// Build an inline error message
  Widget _buildInlineError(BuildContext context, Color errorColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon) ...[
            Icon(
              _getIcon(),
              color: errorColor,
              size: 16,
              semanticLabel: 'Error icon',
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyles.bodySmall.copyWith(color: errorColor),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a toast-style error message
  Widget _buildToastError(
    BuildContext context,
    Color errorColor,
    Color primaryColor,
  ) {
    final isDarkMode = UIUtils.isDarkMode(context);
    // Create colors with opacity
    final backgroundColor = Color.fromRGBO(
      errorColor.r.toInt(),
      errorColor.g.toInt(),
      errorColor.b.toInt(),
      isDarkMode ? 0.2 : 0.1,
    );
    final borderColor = Color.fromRGBO(
      errorColor.r.toInt(),
      errorColor.g.toInt(),
      errorColor.b.toInt(),
      0.5,
    );
    final textColor = isDarkMode ? AppColorsDark.textPrimary : AppColors.textPrimary;
    final iconColor = isDarkMode ? AppColorsDark.textSecondary : AppColors.textSecondary;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                _getIcon(),
                color: errorColor,
                size: 20,
                semanticLabel: 'Error icon',
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyles.bodyMedium.copyWith(color: textColor),
              ),
            ),
            if (showCloseButton && onDismiss != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  AccessibilityUtils.buttonPressHapticFeedback();
                  onDismiss?.call();
                },
                icon: const Icon(Icons.close),
                iconSize: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                color: iconColor,
                tooltip: 'Dismiss',
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build a banner-style error message
  Widget _buildBannerError(
    BuildContext context,
    Color errorColor,
    Color primaryColor,
  ) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final backgroundColor = Color.fromRGBO(
      errorColor.r.toInt(),
      errorColor.g.toInt(),
      errorColor.b.toInt(),
      isDarkMode ? 0.2 : 0.1,
    );
    final textColor = isDarkMode ? AppColorsDark.textPrimary : AppColors.textPrimary;
    final secondaryTextColor = isDarkMode ? AppColorsDark.textSecondary : AppColors.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(color: errorColor, width: 1),
          bottom: BorderSide(color: errorColor, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon) ...[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                _getIcon(),
                color: errorColor,
                size: 20,
                semanticLabel: 'Error icon',
              ),
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
                  style: TextStyles.bodyMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (details != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    details ?? '',
                    style: TextStyles.bodySmall.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                ],
                if (onAction != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      AccessibilityUtils.buttonPressHapticFeedback();
                      onAction?.call();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: errorColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(actionText ?? 'Action'),
                  ),
                ],
              ],
            ),
          ),
          if (showCloseButton && onDismiss != null)
            IconButton(
              onPressed: () {
                AccessibilityUtils.buttonPressHapticFeedback();
                onDismiss?.call();
              },
              icon: const Icon(Icons.close),
              iconSize: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              color: isDarkMode ? Colors.white70 : Colors.black54,
              tooltip: 'Dismiss',
            ),
        ],
      ),
    );
  }

  /// Build a form field error message
  Widget _buildFormFieldError(BuildContext context, Color errorColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, left: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.error_outline,
              color: errorColor,
              size: 14,
              semanticLabel: 'Error icon',
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              message,
              style: TextStyles.bodySmall.copyWith(color: errorColor),
            ),
          ),
        ],
      ),
    );
  }

  /// Get title based on severity
  String _getSeverityTitle() {
    switch (severity) {
      case ErrorSeverity.low:
        return 'Information';
      case ErrorSeverity.medium:
        return 'Warning';
      case ErrorSeverity.high:
        return 'Error';
    }
  }
}
