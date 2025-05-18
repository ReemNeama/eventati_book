import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/core/constants.dart';

import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// A class that defines the application's theme using the colors from AppColors.
/// This provides a consistent look and feel across the entire application.
class AppTheme {
  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      // Color scheme
      primaryColor: AppColors.primary,
      hintColor: AppColors.hintColor,
      canvasColor: AppColors.canvasColor,
      fontFamily: 'Montserrat',
      brightness: Brightness.light,

      // Scaffold and background colors
      scaffoldBackgroundColor: AppColors.background,

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      // Card theme
      cardTheme: const CardTheme(
        color: AppColors.card,
        elevation: 2,
        margin: EdgeInsets.symmetric(
          vertical: AppConstants.smallPadding,
          horizontal: AppConstants.mediumPadding,
        ),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.smallBorderRadius * 2,
            ),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.smallBorderRadius * 2,
          ),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.smallBorderRadius * 2,
          ),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.smallBorderRadius * 2,
          ),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.smallBorderRadius * 2,
          ),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.mediumPadding,
          vertical: AppConstants.smallPadding + 4,
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.chipBackground,
        selectedColor: AppColors.primary,
        secondarySelectedColor: Color.fromRGBO(
          AppColors.primary.r.toInt(),
          AppColors.primary.g.toInt(),
          AppColors.primary.b.toInt(),
          0.7,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.smallPadding,
          vertical: AppConstants.smallPadding / 2,
        ),
        labelStyle: TextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        secondaryLabelStyle: TextStyles.bodyMedium.copyWith(
          color: Colors.white,
        ),
        brightness: Brightness.light,
      ),

      // Text themes
      textTheme: TextTheme(
        displayLarge: TextStyles.title.copyWith(
          color: AppColors.textPrimary,
          fontSize: 32,
        ),
        displayMedium: TextStyles.title.copyWith(
          color: AppColors.textPrimary,
          fontSize: 28,
        ),
        displaySmall: TextStyles.title.copyWith(color: AppColors.textPrimary),
        headlineLarge: TextStyles.title.copyWith(color: AppColors.textPrimary),
        headlineMedium: TextStyles.subtitle.copyWith(
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyles.sectionTitle.copyWith(
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyles.sectionTitle.copyWith(
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyles.bodyLarge.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
        bodyMedium: TextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        bodySmall: TextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
        labelLarge: TextStyles.buttonText.copyWith(
          color: AppColors.textPrimary,
        ),
        labelMedium: TextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        labelSmall: TextStyles.caption.copyWith(color: AppColors.textSecondary),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
      ),
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      // Color scheme
      primaryColor: AppColorsDark.primary,
      hintColor: AppColorsDark.hintColor,
      canvasColor: AppColorsDark.canvasColor,
      fontFamily: 'Montserrat',
      brightness: Brightness.dark,

      // Scaffold and background colors
      scaffoldBackgroundColor: AppColorsDark.background,

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColorsDark.appBarBackground,
        foregroundColor: Colors.white,
      ),

      // Card theme
      cardTheme: const CardTheme(
        color: AppColorsDark.card,
        elevation: 2,
        margin: EdgeInsets.symmetric(
          vertical: AppConstants.smallPadding,
          horizontal: AppConstants.mediumPadding,
        ),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsDark.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.smallBorderRadius * 2,
            ),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColorsDark.primary),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsDark.inputFieldBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.smallBorderRadius * 2,
          ),
          borderSide: const BorderSide(color: AppColorsDark.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.smallBorderRadius * 2,
          ),
          borderSide: const BorderSide(color: AppColorsDark.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.smallBorderRadius * 2,
          ),
          borderSide: const BorderSide(color: AppColorsDark.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.smallBorderRadius * 2,
          ),
          borderSide: const BorderSide(color: AppColorsDark.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.mediumPadding,
          vertical: AppConstants.smallPadding + 4,
        ),
        hintStyle: TextStyles.bodyMedium.copyWith(
          color: AppColorsDark.textHint,
        ),
        labelStyle: TextStyles.bodyMedium.copyWith(
          color: AppColorsDark.textSecondary,
        ),
        prefixIconColor: AppColorsDark.textSecondary,
        suffixIconColor: AppColorsDark.textSecondary,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColorsDark.chipBackground,
        selectedColor: AppColorsDark.primary,
        secondarySelectedColor: AppColorsDark.primaryWithAlpha(0.7),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.smallPadding,
          vertical: AppConstants.smallPadding / 2,
        ),
        labelStyle: TextStyles.bodyMedium.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        secondaryLabelStyle: TextStyles.bodyMedium.copyWith(
          color: Colors.white,
        ),
        brightness: Brightness.dark,
      ),

      // Text themes
      textTheme: TextTheme(
        displayLarge: TextStyles.title.copyWith(
          color: AppColorsDark.textPrimary,
          fontSize: 32,
        ),
        displayMedium: TextStyles.title.copyWith(
          color: AppColorsDark.textPrimary,
          fontSize: 28,
        ),
        displaySmall: TextStyles.title.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        headlineLarge: TextStyles.title.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        headlineMedium: TextStyles.subtitle.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        headlineSmall: TextStyles.sectionTitle.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        titleLarge: TextStyles.sectionTitle.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        titleMedium: TextStyles.bodyLarge.copyWith(
          color: AppColorsDark.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyles.bodyMedium.copyWith(
          color: AppColorsDark.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyles.bodyLarge.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        bodyMedium: TextStyles.bodyMedium.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        bodySmall: TextStyles.bodySmall.copyWith(
          color: AppColorsDark.textSecondary,
        ),
        labelLarge: TextStyles.buttonText.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        labelMedium: TextStyles.bodyMedium.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        labelSmall: TextStyles.caption.copyWith(
          color: AppColorsDark.textSecondary,
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColorsDark.bottomNavBackground,
        selectedItemColor: AppColorsDark.selectedItemColor,
        unselectedItemColor: AppColorsDark.unselectedItemColor,
      ),
    );
  }
}
