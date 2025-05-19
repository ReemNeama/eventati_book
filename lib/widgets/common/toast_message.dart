import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/ui/ui_utils.dart';
import 'package:eventati_book/utils/ui/accessibility_utils.dart';

/// Types of toast messages
enum ToastType {
  /// Success toast (green)
  success,

  /// Error toast (red)
  error,

  /// Warning toast (orange)
  warning,

  /// Info toast (blue)
  info,
}

/// A customizable toast message widget
class ToastMessage extends StatelessWidget {
  /// The message to display
  final String message;

  /// The type of toast
  final ToastType type;

  /// The icon to display
  final IconData? icon;

  /// The action text
  final String? actionText;

  /// The action callback
  final VoidCallback? onAction;

  /// The dismiss callback
  final VoidCallback? onDismiss;

  /// Whether to show a close button
  final bool showCloseButton;

  /// Creates a ToastMessage
  const ToastMessage({
    super.key,
    required this.message,
    this.type = ToastType.info,
    this.icon,
    this.actionText,
    this.onAction,
    this.onDismiss,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);

    // Get colors based on toast type
    final Color backgroundColor = _getBackgroundColor(isDarkMode);
    final Color iconColor = _getIconColor(isDarkMode);
    final Color textColor = _getTextColor(isDarkMode);

    // Get icon based on toast type
    final IconData toastIcon = icon ?? _getIconData();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(toastIcon, color: iconColor, size: 24.0),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              message,
              style: TextStyles.bodyMedium.copyWith(color: textColor),
            ),
          ),
          if (actionText != null && onAction != null) ...[
            const SizedBox(width: 8.0),
            TextButton(
              onPressed: () {
                onAction?.call();
                AccessibilityUtils.buttonPressHapticFeedback();
              },
              style: TextButton.styleFrom(
                foregroundColor: textColor,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                minimumSize: const Size(0, 36),
              ),
              child: Text(
                actionText!,
                style: TextStyles.bodySmall.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (showCloseButton) ...[
            const SizedBox(width: 4.0),
            IconButton(
              icon: const Icon(Icons.close, size: 18.0),
              color: Color.fromRGBO(
                textColor.r.toInt(),
                textColor.g.toInt(),
                textColor.b.toInt(),
                0.7,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              onPressed: () {
                onDismiss?.call();
                AccessibilityUtils.buttonPressHapticFeedback();
              },
            ),
          ],
        ],
      ),
    );
  }

  /// Get the background color based on toast type
  Color _getBackgroundColor(bool isDarkMode) {
    switch (type) {
      case ToastType.success:
        return isDarkMode
            ? Color.fromRGBO(
              AppColorsDark.success.r.toInt(),
              AppColorsDark.success.g.toInt(),
              AppColorsDark.success.b.toInt(),
              0.2,
            )
            : Color.fromRGBO(
              AppColors.success.r.toInt(),
              AppColors.success.g.toInt(),
              AppColors.success.b.toInt(),
              0.1,
            );
      case ToastType.error:
        return isDarkMode
            ? Color.fromRGBO(
              AppColorsDark.error.r.toInt(),
              AppColorsDark.error.g.toInt(),
              AppColorsDark.error.b.toInt(),
              0.2,
            )
            : Color.fromRGBO(
              AppColors.error.r.toInt(),
              AppColors.error.g.toInt(),
              AppColors.error.b.toInt(),
              0.1,
            );
      case ToastType.warning:
        return isDarkMode
            ? Color.fromRGBO(
              AppColorsDark.warning.r.toInt(),
              AppColorsDark.warning.g.toInt(),
              AppColorsDark.warning.b.toInt(),
              0.2,
            )
            : Color.fromRGBO(
              AppColors.warning.r.toInt(),
              AppColors.warning.g.toInt(),
              AppColors.warning.b.toInt(),
              0.1,
            );
      case ToastType.info:
        return isDarkMode
            ? Color.fromRGBO(
              AppColorsDark.info.r.toInt(),
              AppColorsDark.info.g.toInt(),
              AppColorsDark.info.b.toInt(),
              0.2,
            )
            : Color.fromRGBO(
              AppColors.info.r.toInt(),
              AppColors.info.g.toInt(),
              AppColors.info.b.toInt(),
              0.1,
            );
    }
  }

  /// Get the icon color based on toast type
  Color _getIconColor(bool isDarkMode) {
    switch (type) {
      case ToastType.success:
        return isDarkMode ? AppColorsDark.success : AppColors.success;
      case ToastType.error:
        return isDarkMode ? AppColorsDark.error : AppColors.error;
      case ToastType.warning:
        return isDarkMode ? AppColorsDark.warning : AppColors.warning;
      case ToastType.info:
        return isDarkMode ? AppColorsDark.info : AppColors.info;
    }
  }

  /// Get the text color based on toast type
  Color _getTextColor(bool isDarkMode) {
    return isDarkMode ? AppColorsDark.textPrimary : AppColors.textPrimary;
  }

  /// Get the icon data based on toast type
  IconData _getIconData() {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.warning:
        return Icons.warning_amber_outlined;
      case ToastType.info:
        return Icons.info_outline;
    }
  }

  /// Show a toast message
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    IconData? icon,
    String? actionText,
    VoidCallback? onAction,
    VoidCallback? onDismiss,
    Duration duration = const Duration(seconds: 3),
    bool showCloseButton = true,
    bool addHapticFeedback = true,
  }) {
    // Add haptic feedback based on toast type
    if (addHapticFeedback) {
      switch (type) {
        case ToastType.success:
          AccessibilityUtils.successHapticFeedback();
          break;
        case ToastType.error:
          AccessibilityUtils.errorHapticFeedback();
          break;
        case ToastType.warning:
        case ToastType.info:
          AccessibilityUtils.buttonPressHapticFeedback();
          break;
      }
    }

    // Dismiss any existing snackbars
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Show the snackbar with the toast message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ToastMessage(
          message: message,
          type: type,
          icon: icon,
          actionText: actionText,
          onAction: onAction,
          onDismiss: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            onDismiss?.call();
          },
          showCloseButton: showCloseButton,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        padding: EdgeInsets.zero,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
}
