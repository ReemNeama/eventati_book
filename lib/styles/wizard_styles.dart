import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/text_styles.dart';

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
        onSurface: AppColors.textPrimary,
      ),
    );
  }

  /// Get the style for the wizard title
  static TextStyle getTitleStyle() {
    return TextStyles.title;
  }

  /// Get the style for the step title
  static TextStyle getStepTitleStyle() {
    return TextStyles.sectionTitle;
  }

  /// Get the style for the previous button
  static ButtonStyle getPreviousButtonStyle(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final backgroundColor =
        isDarkMode
            ? Color.fromRGBO(
              AppColors.disabled.r.toInt(),
              AppColors.disabled.g.toInt(),
              AppColors.disabled.b.toInt(),
              0.7,
            )
            : AppColors.disabled;

    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 15),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
  }

  /// Get the style for the next/finish button
  static ButtonStyle getNextButtonStyle(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final backgroundColor =
        isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 15),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
  }

  /// Get the style for the button text
  static TextStyle getButtonTextStyle() {
    return TextStyles.bodyMedium;
  }

  /// Get the decoration for the review container
  static BoxDecoration getReviewContainerDecoration() {
    return BoxDecoration(
      border: Border.all(
        color: Color.fromRGBO(
          AppColors.disabled.r.toInt(),
          AppColors.disabled.g.toInt(),
          AppColors.disabled.b.toInt(),
          0.3,
        ),
      ),
      borderRadius: BorderRadius.circular(4),
    );
  }

  /// Get the style for the review section title
  static TextStyle getReviewSectionTitleStyle(BuildContext context) {
    return TextStyles.sectionTitle;
  }

  /// Get the style for the progress indicator
  static BoxDecoration getProgressIndicatorDecoration() {
    return BoxDecoration(
      color: Color.fromRGBO(
        AppColors.disabled.r.toInt(),
        AppColors.disabled.g.toInt(),
        AppColors.disabled.b.toInt(),
        0.2,
      ),
      borderRadius: BorderRadius.circular(10),
    );
  }

  /// Get the decoration for the progress bar
  static BoxDecoration getProgressBarDecoration(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final color = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return BoxDecoration(color: color, borderRadius: BorderRadius.circular(10));
  }

  /// Get the style for the progress text
  static TextStyle getProgressTextStyle() {
    return TextStyles.bodyMedium;
  }

  /// Get the card decoration for wizard components
  static BoxDecoration getCardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Color.fromRGBO(
            AppColors.black.r.toInt(),
            AppColors.black.g.toInt(),
            AppColors.black.b.toInt(),
            0.10,
          ),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
