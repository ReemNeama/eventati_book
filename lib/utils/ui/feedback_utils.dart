import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/ui/accessibility_utils.dart';
import 'package:eventati_book/utils/ui/ui_utils.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';

/// Utility class for providing feedback mechanisms to users
class FeedbackUtils {
  /// Show a toast message for successful operations
  static void showSuccessToast(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onDismiss,
    bool addHapticFeedback = true,
  }) {
    // Dismiss any existing snackbars
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Add haptic feedback for success
    if (addHapticFeedback) {
      AccessibilityUtils.successHapticFeedback();
    }

    // Show the snackbar
    final snackBar = SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: AppColors.success,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(8),
      dismissDirection: DismissDirection.horizontal,
      action:
          onDismiss != null
              ? SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: onDismiss,
              )
              : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Show a toast message for informational updates
  static void showInfoToast(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onDismiss,
    bool addHapticFeedback = true,
  }) {
    // Dismiss any existing snackbars
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Add haptic feedback for info
    if (addHapticFeedback) {
      AccessibilityUtils.buttonPressHapticFeedback();
    }

    // Show the snackbar
    final isDarkMode = UIUtils.isDarkMode(context);
    final backgroundColor = isDarkMode ? AppColorsDark.info : AppColors.info;

    final snackBar = SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(8),
      dismissDirection: DismissDirection.horizontal,
      action:
          onDismiss != null
              ? SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: onDismiss,
              )
              : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Add haptic feedback for important actions
  static void addHapticFeedback(HapticFeedbackType type) {
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.vibrate:
        HapticFeedback.vibrate();
        break;
    }
  }

  /// Show a loading overlay for long operations
  static OverlayEntry showLoadingOverlay(
    BuildContext context, {
    String? message,
    bool dismissible = false,
    VoidCallback? onDismiss,
  }) {
    final overlayState = Overlay.of(context);
    final entry = OverlayEntry(
      builder:
          (context) => Material(
            color: Colors.black54,
            child: InkWell(
              onTap: dismissible && onDismiss != null ? onDismiss : null,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        UIUtils.isDarkMode(context)
                            ? AppColorsDark.cardBackground
                            : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      const BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.2),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LoadingIndicator(size: 50),
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          message,
                          style: TextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (dismissible) ...[
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: onDismiss,
                          child: const Text('Cancel'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
    );

    overlayState.insert(entry);
    return entry;
  }

  /// Create a progress indicator for long operations
  static Widget createProgressIndicator({
    required double progress,
    String? message,
    Color? backgroundColor,
    Color? progressColor,
    double height = 10.0,
    bool showPercentage = true,
    bool isAnimated = true,
  }) {
    return Builder(
      builder: (context) {
        final isDarkMode = UIUtils.isDarkMode(context);
        final bgColor =
            backgroundColor ??
            (isDarkMode
                ? AppColorsDark.cardBackground
                : AppColors.cardBackground);
        final pgColor =
            progressColor ??
            (isDarkMode ? AppColorsDark.primary : AppColors.primary);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message != null) ...[
              Text(
                message,
                style: TextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Stack(
              children: [
                // Background
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
                // Progress
                isAnimated
                    ? AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: height,
                      width: progress * 100,
                      decoration: BoxDecoration(
                        color: pgColor,
                        borderRadius: BorderRadius.circular(height / 2),
                      ),
                    )
                    : Container(
                      height: height,
                      width: progress * 100,
                      decoration: BoxDecoration(
                        color: pgColor,
                        borderRadius: BorderRadius.circular(height / 2),
                      ),
                    ),
              ],
            ),
            if (showPercentage) ...[
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Types of haptic feedback
enum HapticFeedbackType {
  /// Light impact feedback
  light,

  /// Medium impact feedback
  medium,

  /// Heavy impact feedback
  heavy,

  /// Selection click feedback
  selection,

  /// Vibration feedback
  vibrate,
}
