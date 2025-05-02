import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// Utility functions for accessibility
class AccessibilityUtils {
  /// Check if the device has a screen reader enabled
  static bool isScreenReaderEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  /// Get semantic label for an icon button
  static String getIconButtonLabel(IconData icon, String action) {
    return '$action button';
  }

  /// Get semantic label for a text field
  static String getTextFieldLabel(String fieldName, {String? hint}) {
    return hint != null ? '$fieldName, $hint' : fieldName;
  }

  /// Get semantic label for a checkbox
  static String getCheckboxLabel(String label, bool isChecked) {
    return '$label, ${isChecked ? 'checked' : 'unchecked'}';
  }

  /// Get semantic label for a radio button
  static String getRadioButtonLabel(String label, bool isSelected) {
    return '$label, ${isSelected ? 'selected' : 'unselected'}';
  }

  /// Get semantic label for a dropdown
  static String getDropdownLabel(String label, String selectedValue) {
    return '$label, $selectedValue selected';
  }

  /// Get semantic label for a slider
  static String getSliderLabel(
    String label,
    double value,
    double min,
    double max,
  ) {
    return '$label, $value out of $max';
  }

  /// Get semantic label for a date
  static String getDateLabel(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  /// Get semantic label for a time
  static String getTimeLabel(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Get semantic label for a price
  static String getPriceLabel(double price, {String currencySymbol = '\$'}) {
    return '$currencySymbol${price.toStringAsFixed(2)}';
  }

  /// Get semantic label for a rating
  static String getRatingLabel(double rating, double maxRating) {
    return '$rating out of $maxRating stars';
  }

  /// Get semantic label for an image
  static String getImageLabel(String subject, {String? description}) {
    return description != null
        ? 'Image of $subject, $description'
        : 'Image of $subject';
  }

  /// Get semantic label for a button
  static String getButtonLabel(String action) {
    return '$action button';
  }

  /// Get semantic label for a link
  static String getLinkLabel(String text) {
    return '$text, link';
  }

  /// Get semantic label for a tab
  static String getTabLabel(String tabName, bool isSelected) {
    return '$tabName tab, ${isSelected ? 'selected' : 'unselected'}';
  }

  /// Get semantic label for a menu item
  static String getMenuItemLabel(String itemName) {
    return '$itemName, menu item';
  }

  /// Get semantic label for a dialog
  static String getDialogLabel(String title) {
    return '$title dialog';
  }

  /// Get semantic label for an alert
  static String getAlertLabel(String title) {
    return '$title alert';
  }

  /// Get semantic label for a progress indicator
  static String getProgressLabel(String action, {double? progress}) {
    if (progress != null) {
      final percentage = (progress * 100).toInt();
      return '$action, $percentage percent complete';
    }
    return '$action in progress';
  }

  /// Get semantic label for an error
  static String getErrorLabel(String message) {
    return 'Error: $message';
  }

  /// Get semantic label for a success message
  static String getSuccessLabel(String message) {
    return 'Success: $message';
  }

  /// Get semantic label for a warning message
  static String getWarningLabel(String message) {
    return 'Warning: $message';
  }

  /// Get semantic label for an info message
  static String getInfoLabel(String message) {
    return 'Information: $message';
  }

  /// Helper method to get month name
  static String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  /// Create a semantics wrapper for a widget
  static Widget createSemanticsWrapper({
    required Widget child,
    required String label,
    String? hint,
    bool excludeSemantics = false,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: onTap != null || onLongPress != null,
      excludeSemantics: excludeSemantics,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }

  /// Create a semantics button
  static Widget createSemanticsButton({
    required Widget child,
    required String label,
    required VoidCallback onPressed,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      onTap: onPressed,
      child: GestureDetector(onTap: onPressed, child: child),
    );
  }

  /// Add haptic feedback for button press
  static void buttonPressHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  /// Add haptic feedback for success
  static void successHapticFeedback() {
    HapticFeedback.mediumImpact();
  }

  /// Add haptic feedback for error
  static void errorHapticFeedback() {
    HapticFeedback.heavyImpact();
  }

  /// Add haptic feedback for selection change
  static void selectionChangeHapticFeedback() {
    HapticFeedback.selectionClick();
  }

  /// Check if the contrast ratio is sufficient for accessibility
  static bool hasGoodContrast(Color foreground, Color background) {
    // Calculate relative luminance
    double getLuminance(Color color) {
      final double r = color.r / 255;
      final double g = color.g / 255;
      final double b = color.b / 255;

      final double r1 =
          r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4);
      final double g1 =
          g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4);
      final double b1 =
          b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4);

      return 0.2126 * r1 + 0.7152 * g1 + 0.0722 * b1;
    }

    final double l1 = getLuminance(foreground);
    final double l2 = getLuminance(background);

    // Calculate contrast ratio
    final double contrastRatio =
        (l1 > l2) ? (l1 + 0.05) / (l2 + 0.05) : (l2 + 0.05) / (l1 + 0.05);

    // WCAG 2.0 level AA requires a contrast ratio of at least 4.5:1 for normal text
    // and 3:1 for large text
    return contrastRatio >= 4.5;
  }

  /// Get a color with better contrast if needed
  static Color getAccessibleColor(Color foreground, Color background) {
    if (hasGoodContrast(foreground, background)) {
      return foreground;
    }

    // Adjust the foreground color to improve contrast
    final HSLColor hslForeground = HSLColor.fromColor(foreground);
    HSLColor adjustedColor = hslForeground;

    // If the background is dark, make the foreground lighter
    if (background.computeLuminance() < 0.5) {
      adjustedColor = HSLColor.fromAHSL(
        hslForeground.alpha,
        hslForeground.hue,
        hslForeground.saturation,
        0.9, // Very light
      );
    } else {
      // If the background is light, make the foreground darker
      adjustedColor = HSLColor.fromAHSL(
        hslForeground.alpha,
        hslForeground.hue,
        hslForeground.saturation,
        0.1, // Very dark
      );
    }

    return adjustedColor.toColor();
  }

  /// Helper method for pow function
  static double pow(double x, double exponent) {
    return x > 0 ? x.pow(exponent) : 0;
  }
}

/// Extension for double to add pow method
extension DoublePowExtension on double {
  double pow(double exponent) {
    return math.pow(this, exponent) as double;
  }
}
