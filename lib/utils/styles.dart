import 'package:flutter/material.dart';

/// App color palette
class AppColors {
  /// Primary color
  static const Color primaryColor = Color(0xFF4A2511);

  /// Secondary color
  static const Color secondaryColor = Color(0xFF8B5A2B);

  /// Accent color
  static const Color accentColor = Color(0xFFD2B48C);

  /// Background color
  static const Color backgroundColor = Color(0xFFF5F5F5);

  /// Text color
  static const Color textColor = Color(0xFF333333);

  /// Light text color
  static const Color lightTextColor = Color(0xFF777777);

  /// Error color
  static const Color errorColor = Color(0xFFB00020);

  /// Success color
  static const Color successColor = Color(0xFF4CAF50);

  /// Warning color
  static const Color warningColor = Color(0xFFFFC107);

  /// Info color
  static const Color infoColor = Color(0xFF2196F3);

  /// Disabled color
  static const Color disabledColor = Color(0xFFBDBDBD);

  /// Divider color
  static const Color dividerColor = Color(0xFFE0E0E0);

  /// Card color
  static const Color cardColor = Colors.white;

  /// Shadow color
  static const Color shadowColor = Color(0x1A000000);
}

/// Text styles for the app
class AppTextStyles {
  /// Heading 1
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  /// Heading 2
  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  /// Heading 3
  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  /// Body text
  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: AppColors.textColor,
  );

  /// Small text
  static const TextStyle smallText = TextStyle(
    fontSize: 14,
    color: AppColors.lightTextColor,
  );

  /// Caption text
  static const TextStyle captionText = TextStyle(
    fontSize: 12,
    color: AppColors.lightTextColor,
  );

  /// Button text
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}

/// Padding values for the app
class AppPadding {
  /// Small padding (8.0)
  static const double small = 8.0;

  /// Medium padding (16.0)
  static const double medium = 16.0;

  /// Large padding (24.0)
  static const double large = 24.0;

  /// Extra large padding (32.0)
  static const double extraLarge = 32.0;
}

/// Border radius values for the app
class AppBorderRadius {
  /// Small border radius (4.0)
  static const double small = 4.0;

  /// Medium border radius (8.0)
  static const double medium = 8.0;

  /// Large border radius (12.0)
  static const double large = 12.0;

  /// Extra large border radius (16.0)
  static const double extraLarge = 16.0;

  /// Circular border radius (50.0)
  static const double circular = 50.0;
}

/// Elevation values for the app
class AppElevation {
  /// No elevation (0.0)
  static const double none = 0.0;

  /// Small elevation (2.0)
  static const double small = 2.0;

  /// Medium elevation (4.0)
  static const double medium = 4.0;

  /// Large elevation (8.0)
  static const double large = 8.0;

  /// Extra large elevation (16.0)
  static const double extraLarge = 16.0;
}

/// Animation durations for the app
class AppDurations {
  /// Short duration (150ms)
  static const Duration short = Duration(milliseconds: 150);

  /// Medium duration (300ms)
  static const Duration medium = Duration(milliseconds: 300);

  /// Long duration (500ms)
  static const Duration long = Duration(milliseconds: 500);
}
