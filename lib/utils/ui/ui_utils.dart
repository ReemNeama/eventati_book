import 'package:flutter/material.dart';

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
      backgroundColor: Colors.green,
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
      backgroundColor: Colors.red,
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
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelText),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
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
  /// Note: The [context] parameter is not currently used but is kept for future
  /// implementation where the theme might affect the alpha calculation.
  static Color getColorWithAlpha(
    // TODO: Use context parameter for theme-aware alpha calculation
    BuildContext context,
    Color color,
    double opacity,
  ) {
    return color.withAlpha((opacity * 255).round());
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
