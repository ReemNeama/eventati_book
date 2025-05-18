import 'package:flutter/material.dart';
import 'package:eventati_book/utils/ui/navigation_utils.dart';
import 'package:eventati_book/styles/app_colors.dart';

/// Utility functions for UI-related operations
class UIUtils {
  /// Show a snackbar with a message
  static void showSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color? textColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor)),
        duration: duration,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Show a success snackbar
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
      duration: duration,
    );
  }

  /// Show an error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
      duration: duration,
    );
  }

  /// Show a confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => NavigationUtils.pop(context, false),
                child: Text(cancelText),
              ),
              TextButton(
                onPressed: () => NavigationUtils.pop(context, true),
                child: Text(confirmText),
              ),
            ],
          ),
    );

    return result ?? false;
  }

  /// Check if the device is in dark mode
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Get screen size
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Check if the device is a tablet
  static bool isTablet(BuildContext context) {
    final size = getScreenSize(context);

    return size.shortestSide >= 600;
  }

  /// Get a responsive value based on screen size
  static T getResponsiveValue<T>({
    required BuildContext context,
    required T mobile,
    required T tablet,
    T? desktop,
  }) {
    final size = getScreenSize(context);

    if (size.shortestSide >= 900 && desktop != null) {
      return desktop;
    } else if (size.shortestSide >= 600) {
      return tablet;
    } else {
      return mobile;
    }
  }

  /// Get a color with alpha based on the current theme
  ///
  /// Uses the [context] parameter for theme-aware alpha calculation.
  ///
  /// The opacity is adjusted based on the current theme brightness to ensure
  /// appropriate contrast and visibility in both light and dark themes.
  static Color getColorWithAlpha(
    BuildContext context,
    Color color,
    double opacity,
  ) {
    // Get the current theme brightness
    final brightness = Theme.of(context).brightness;

    // Adjust opacity based on theme brightness
    double adjustedOpacity = opacity;

    // For dark theme, we might want to increase opacity slightly for better visibility
    if (brightness == Brightness.dark) {
      // Increase opacity by 10% for dark theme, but cap at 1.0
      adjustedOpacity = (opacity * 1.1).clamp(0.0, 1.0);

      // For very light colors on dark theme, ensure minimum opacity
      if (color.computeLuminance() > 0.7) {
        adjustedOpacity = adjustedOpacity.clamp(0.15, 1.0);
      }
    } else {
      // For dark colors on light theme, ensure minimum opacity
      if (color.computeLuminance() < 0.3) {
        adjustedOpacity = adjustedOpacity.clamp(0.15, 1.0);
      }
    }

    // Convert opacity to alpha value (0-255)
    final alpha = (adjustedOpacity * 255).round();
    return color.withAlpha(alpha);
  }

  /// Show a loading dialog
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Expanded(child: Text(message)),
              ],
            ),
          ),
    );
  }
}
