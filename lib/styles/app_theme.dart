import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/core/constants.dart';

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
        secondarySelectedColor: AppColors.primaryWithAlpha(0.7),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.smallPadding,
          vertical: AppConstants.smallPadding / 2,
        ),
        labelStyle: const TextStyle(color: AppColors.textPrimary),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        brightness: Brightness.light,
      ),

      // Text themes
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.textPrimary),
        displayMedium: TextStyle(color: AppColors.textPrimary),
        displaySmall: TextStyle(color: AppColors.textPrimary),
        headlineLarge: TextStyle(color: AppColors.textPrimary),
        headlineMedium: TextStyle(color: AppColors.textPrimary),
        headlineSmall: TextStyle(color: AppColors.textPrimary),
        titleLarge: TextStyle(color: AppColors.textPrimary),
        titleMedium: TextStyle(color: AppColors.textPrimary),
        titleSmall: TextStyle(color: AppColors.textPrimary),
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textPrimary),
        bodySmall: TextStyle(color: AppColors.textSecondary),
        labelLarge: TextStyle(color: AppColors.textPrimary),
        labelMedium: TextStyle(color: AppColors.textPrimary),
        labelSmall: TextStyle(color: AppColors.textSecondary),
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
        hintStyle: const TextStyle(color: AppColorsDark.textHint),
        labelStyle: const TextStyle(color: AppColorsDark.textSecondary),
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
        labelStyle: const TextStyle(color: AppColorsDark.textPrimary),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        brightness: Brightness.dark,
      ),

      // Text themes
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColorsDark.textPrimary),
        displayMedium: TextStyle(color: AppColorsDark.textPrimary),
        displaySmall: TextStyle(color: AppColorsDark.textPrimary),
        headlineLarge: TextStyle(color: AppColorsDark.textPrimary),
        headlineMedium: TextStyle(color: AppColorsDark.textPrimary),
        headlineSmall: TextStyle(color: AppColorsDark.textPrimary),
        titleLarge: TextStyle(color: AppColorsDark.textPrimary),
        titleMedium: TextStyle(color: AppColorsDark.textPrimary),
        titleSmall: TextStyle(color: AppColorsDark.textPrimary),
        bodyLarge: TextStyle(color: AppColorsDark.textPrimary),
        bodyMedium: TextStyle(color: AppColorsDark.textPrimary),
        bodySmall: TextStyle(color: AppColorsDark.textSecondary),
        labelLarge: TextStyle(color: AppColorsDark.textPrimary),
        labelMedium: TextStyle(color: AppColorsDark.textPrimary),
        labelSmall: TextStyle(color: AppColorsDark.textSecondary),
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
