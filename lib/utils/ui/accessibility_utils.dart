import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/text_styles.dart';

import 'dart:math' as math;

/// Utility functions for accessibility
class AccessibilityUtils {
  /// Check if the device has a screen reader enabled
  static bool isScreenReaderEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  /// Get semantic label for an icon button
  ///
  /// Uses the [icon] parameter to generate a more descriptive label.
  static String getIconButtonLabel(IconData icon, String action) {
    // Map common icons to descriptive names
    String iconDescription = '';

    if (icon == Icons.add) {
      iconDescription = 'Add';
    } else if (icon == Icons.delete || icon == Icons.delete_outline) {
      iconDescription = 'Delete';
    } else if (icon == Icons.edit || icon == Icons.edit_outlined) {
      iconDescription = 'Edit';
    } else if (icon == Icons.save || icon == Icons.save_outlined) {
      iconDescription = 'Save';
    } else if (icon == Icons.close) {
      iconDescription = 'Close';
    } else if (icon == Icons.menu) {
      iconDescription = 'Menu';
    } else if (icon == Icons.search) {
      iconDescription = 'Search';
    } else if (icon == Icons.settings || icon == Icons.settings_outlined) {
      iconDescription = 'Settings';
    } else if (icon == Icons.favorite || icon == Icons.favorite_border) {
      iconDescription = 'Favorite';
    } else if (icon == Icons.share) {
      iconDescription = 'Share';
    } else if (icon == Icons.arrow_back) {
      iconDescription = 'Back';
    } else if (icon == Icons.arrow_forward) {
      iconDescription = 'Forward';
    } else if (icon == Icons.check) {
      iconDescription = 'Check';
    } else if (icon == Icons.info || icon == Icons.info_outline) {
      iconDescription = 'Information';
    } else if (icon == Icons.help || icon == Icons.help_outline) {
      iconDescription = 'Help';
    }

    // If we have an icon description, include it in the label
    if (iconDescription.isNotEmpty) {
      return '$iconDescription $action button';
    }

    // Default to just the action if we don't recognize the icon
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
  ///
  /// [subject] is the main subject of the image.
  /// [description] is an optional detailed description of the image.
  /// If [description] is provided, it will be included in the label.
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

  /// Get high contrast text color based on background color
  static Color getHighContrastTextColor(Color backgroundColor) {
    // Calculate the relative luminance of the background color
    // Using the formula: 0.299 * R + 0.587 * G + 0.114 * B
    final luminance =
        (0.299 * backgroundColor.r +
            0.587 * backgroundColor.g +
            0.114 * backgroundColor.b) /
        255;

    // If the background is dark, use white text; otherwise, use black text
    return luminance > 0.5 ? AppColors.black : AppColors.white;
  }

  /// Get a high contrast color pair (background and text)
  static Map<String, Color> getHighContrastColorPair(bool isDarkMode) {
    if (isDarkMode) {
      // High contrast dark mode: very dark background, very light text
      return {'background': AppColors.black, 'text': AppColors.white};
    } else {
      // High contrast light mode: very light background, very dark text
      return {'background': AppColors.white, 'text': AppColors.black};
    }
  }

  /// Get a high contrast border color
  static Color getHighContrastBorderColor(bool isDarkMode) {
    return isDarkMode ? AppColors.white : AppColors.black;
  }

  /// Get a high contrast primary color
  static Color getHighContrastPrimaryColor(bool isDarkMode) {
    return isDarkMode
        ? AppColors.warning
        : Color.fromRGBO(
          AppColors.primary.r.toInt(),
          AppColors.primary.g.toInt(),
          AppColors.primary.b.toInt(),
          0.9,
        );
  }

  /// Get a high contrast secondary color
  static Color getHighContrastSecondaryColor(bool isDarkMode) {
    return isDarkMode
        ? AppColors.info
        : Color.fromRGBO(
          AppColors.primary.r.toInt(),
          AppColors.primary.g.toInt(),
          AppColors.primary.b.toInt(),
          0.9,
        );
  }

  /// Get a high contrast error color
  static Color getHighContrastErrorColor(bool isDarkMode) {
    return isDarkMode
        ? Color.fromRGBO(
          AppColors.error.r.toInt(),
          AppColors.error.g.toInt(),
          AppColors.error.b.toInt(),
          0.3,
        )
        : Color.fromRGBO(
          AppColors.error.r.toInt(),
          AppColors.error.g.toInt(),
          AppColors.error.b.toInt(),
          0.9,
        );
  }

  /// Get a high contrast success color
  static Color getHighContrastSuccessColor(bool isDarkMode) {
    return isDarkMode
        ? Color.fromRGBO(
          AppColors.success.r.toInt(),
          AppColors.success.g.toInt(),
          AppColors.success.b.toInt(),
          0.3,
        )
        : Color.fromRGBO(
          AppColors.success.r.toInt(),
          AppColors.success.g.toInt(),
          AppColors.success.b.toInt(),
          0.9,
        );
  }

  /// Get a high contrast warning color
  static Color getHighContrastWarningColor(bool isDarkMode) {
    return isDarkMode
        ? Color.fromRGBO(
          AppColors.warning.r.toInt(),
          AppColors.warning.g.toInt(),
          AppColors.warning.b.toInt(),
          0.3,
        )
        : Color.fromRGBO(
          AppColors.warning.r.toInt(),
          AppColors.warning.g.toInt(),
          AppColors.warning.b.toInt(),
          0.9,
        );
  }

  /// Get a high contrast info color
  static Color getHighContrastInfoColor(bool isDarkMode) {
    return isDarkMode
        ? Color.fromRGBO(
          AppColors.primary.r.toInt(),
          AppColors.primary.g.toInt(),
          AppColors.primary.b.toInt(),
          0.3,
        )
        : Color.fromRGBO(
          AppColors.primary.r.toInt(),
          AppColors.primary.g.toInt(),
          AppColors.primary.b.toInt(),
          0.9,
        );
  }

  /// Get a high contrast theme data
  static ThemeData getHighContrastTheme(bool isDarkMode) {
    final colorPair = getHighContrastColorPair(isDarkMode);
    final backgroundColor = colorPair['background']!;
    final textColor = colorPair['text']!;
    final primaryColor = getHighContrastPrimaryColor(isDarkMode);
    final errorColor = getHighContrastErrorColor(isDarkMode);

    return ThemeData(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: backgroundColor,
      colorScheme: ColorScheme(
        primary: primaryColor,
        secondary: getHighContrastSecondaryColor(isDarkMode),
        surface: backgroundColor,
        error: errorColor,
        onPrimary: getHighContrastTextColor(primaryColor),
        onSecondary: textColor,
        onSurface: textColor,
        onError: getHighContrastTextColor(errorColor),
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyles.bodyLarge.copyWith(color: textColor),
        bodyMedium: TextStyles.bodyMedium.copyWith(color: textColor),
        bodySmall: TextStyles.bodySmall.copyWith(color: textColor),
        titleLarge: TextStyles.title.copyWith(color: textColor),
        titleMedium: TextStyles.subtitle.copyWith(color: textColor),
        titleSmall: TextStyles.sectionTitle.copyWith(color: textColor),
        labelLarge: TextStyles.buttonText.copyWith(color: textColor),
        labelMedium: TextStyles.bodyMedium.copyWith(color: textColor),
        labelSmall: TextStyles.caption.copyWith(color: textColor),
      ),
      dividerColor:
          isDarkMode
              ? Color.fromRGBO(
                AppColors.white.r.toInt(),
                AppColors.white.g.toInt(),
                AppColors.white.b.toInt(),
                0.54,
              )
              : Color.fromRGBO(
                AppColors.black.r.toInt(),
                AppColors.black.g.toInt(),
                AppColors.black.b.toInt(),
                0.38,
              ),
      iconTheme: IconThemeData(color: textColor),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: getHighContrastTextColor(primaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: getHighContrastTextColor(primaryColor),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryColor),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderSide: BorderSide(color: textColor)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: textColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: errorColor),
        ),
        labelStyle: TextStyles.bodyMedium.copyWith(color: textColor),
        hintStyle: TextStyles.bodyMedium.copyWith(
          color:
              isDarkMode
                  ? Color.fromRGBO(
                    AppColors.white.r.toInt(),
                    AppColors.white.g.toInt(),
                    AppColors.white.b.toInt(),
                    0.7,
                  )
                  : AppColors.textSecondary,
        ),
      ),
    );
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

    // Adjust color based on background luminance
    adjustedColor = HSLColor.fromAHSL(
      hslForeground.alpha,
      hslForeground.hue,
      hslForeground.saturation,
      background.computeLuminance() < 0.5
          ? 0.9
          : 0.1, // 0.9 for dark backgrounds (lighter text), 0.1 for light backgrounds (darker text)
    );

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
