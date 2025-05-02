import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';

/// Styles for the event wizard
class WizardStyles {
  /// Get the container decoration for the wizard body
  static BoxDecoration getWizardBodyDecoration() {
    return const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
    );
  }

  /// Get the theme data for the stepper
  static ThemeData getStepperTheme(BuildContext context, Color primaryColor) {
    return Theme.of(context).copyWith(
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black87,
      ),
    );
  }

  /// Get the style for the wizard title
  static TextStyle getTitleStyle() {
    return const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }

  /// Get the style for the step title
  static TextStyle getStepTitleStyle() {
    return const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
  }

  /// Get the style for the previous button
  static ButtonStyle getPreviousButtonStyle(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final backgroundColor = isDarkMode ? Colors.grey[700] : Colors.grey;

    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 15),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  /// Get the style for the next/finish button
  static ButtonStyle getNextButtonStyle(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final backgroundColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 15),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  /// Get the style for the button text
  static TextStyle getButtonTextStyle() {
    return const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }

  /// Get the decoration for the review container
  static BoxDecoration getReviewContainerDecoration() {
    return BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(4),
    );
  }

  /// Get the style for the review section title
  static TextStyle getReviewSectionTitleStyle(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final color = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  /// Get the style for the progress indicator
  static BoxDecoration getProgressIndicatorDecoration() {
    return BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(10),
    );
  }

  /// Get the decoration for the progress bar
  static BoxDecoration getProgressBarDecoration(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final color = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    );
  }

  /// Get the style for the progress text
  static TextStyle getProgressTextStyle() {
    return const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }

  /// Get the decoration for the wizard card
  static BoxDecoration getWizardCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
