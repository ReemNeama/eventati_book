import 'package:flutter/material.dart';

/// A class that defines all the colors used in the application.
/// This centralized approach makes it easier to maintain consistent colors
/// and update them across the entire app.
class AppColors {
  // Primary colors from original theme
  static const Color primary = Color.fromARGB(
    255,
    150,
    136,
    119,
  ); // Original primaryColor
  static const Color hintColor = Color.fromARGB(
    255,
    125,
    112,
    96,
  ); // Original hintColor
  static const Color canvasColor = Color.fromARGB(
    255,
    215,
    213,
    211,
  ); // Original canvasColor

  // Background colors
  static const Color background = canvasColor;
  static const Color surface = Colors.white;
  static const Color card = Colors.white;

  // Text colors
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color textHint = hintColor;

  // Status colors
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Colors.amber;
  static const Color info = Colors.blue;

  // Other common colors
  static const Color divider = Colors.grey;
  static const Color disabled = Colors.grey;

  // Opacity values for semi-transparent colors
  static Color primaryWithOpacity(double opacity) {
    return primary.withAlpha((opacity * 255).round());
  }

  // Specific UI element colors
  static Color filterBarBackground = primary.withAlpha(
    26,
  ); // Very light primary color
  static const Color chipBackground = Colors.white;
  static const Color ratingStarColor = Colors.amber;
}
