import 'package:flutter/material.dart';

/// A class that defines all the colors used in the application's dark mode.
/// This centralized approach makes it easier to maintain consistent colors
/// and update them across the entire app.
class AppColorsDark {
  // Primary colors for dark theme - darker brown tones
  static const Color primary = Color(0xFF5D4B38); // Darker brown
  static const Color hintColor = Color(0xFF8A7A68); // Medium brown for hints
  static const Color canvasColor = Color(0xFF121212); // Very dark background

  // Background colors
  static const Color background = canvasColor;
  static const Color surface = Color(
    0xFF1E1E1E,
  ); // Slightly lighter than background
  static const Color card = Color(0xFF252525); // Card background
  static const Color cardBackground = Color(0xFF252525); // Card background

  // Text colors
  static const Color textPrimary = Color(
    0xFFE0E0E0,
  ); // Slightly off-white for better eye comfort
  static const Color textSecondary = Color(0xFFB0B0B0); // Light gray
  static const Color textHint = Color(0xFF8A7A68); // Same as hintColor

  // Status colors
  static const Color success = Color(0xFF4F8A65); // Darker green for dark mode
  static const Color error = Color(0xFFB54A4A); // Darker red for dark mode
  static const Color warning = Color(0xFFD4B256); // Darker amber for dark mode
  static const Color info = Color(0xFF4A77B5); // Darker blue for dark mode

  // Other common colors
  static const Color divider = Color(0xFF353535); // Dark divider
  static const Color disabled = Color(0xFF5A5A5A); // Disabled color

  // Alpha values for semi-transparent colors
  static Color primaryWithAlpha(double opacity) {
    return primary.withAlpha((opacity * 255).round());
  }

  // Specific UI element colors
  static const Color filterBarBackground = Color(
    0xFF1A1A1A,
  ); // Very dark filter bar
  static const Color chipBackground = Color(0xFF333333); // Dark chip background
  static const Color ratingStarColor = Color(
    0xFFD4AF37,
  ); // Darker gold color for stars

  // Search, sort and filter specific colors
  static const Color searchBarBackground = Color(0xFF252525); // Dark search bar
  static const Color sortFilterBackground = Color(
    0xFF2A2A2A,
  ); // Dark sort/filter background
  static const Color inputFieldBackground = Color(
    0xFF2D2D2D,
  ); // Dark input field

  // Additional dark mode specific colors
  static const Color appBarBackground = Color(
    0xFF1F1F1F,
  ); // Slightly darker than surface
  static const Color bottomNavBackground = Color(
    0xFF1F1F1F,
  ); // Same as appBarBackground
  static const Color selectedItemColor =
      primary; // Primary color for selected items
  static const Color unselectedItemColor = Color(
    0xFF7A7A7A,
  ); // Darker grey for unselected items
}
