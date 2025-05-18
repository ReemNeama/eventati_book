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

  // Basic colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  // Background colors
  static const Color background = canvasColor;
  static const Color surface = white;
  static const Color card = white;
  static const Color cardBackground = white;

  // Text colors
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color textHint = hintColor;

  // Status colors
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;
  static const Color info = primary;

  // Other common colors
  static const Color divider = Colors.grey;
  static const Color disabled = Colors.grey;

  // Alpha values for semi-transparent colors
  static Color primaryWithAlpha(double opacity) {
    return Color.fromRGBO(
      primary.r.toInt(),
      primary.g.toInt(),
      primary.b.toInt(),
      opacity,
    );
  }

  // Specific UI element colors
  static Color filterBarBackground = Color.fromRGBO(
    primary.r.toInt(),
    primary.g.toInt(),
    primary.b.toInt(),
    0.1,
  ); // Very light primary color
  static const Color chipBackground = Colors.white;
  static const Color ratingStarColor = Colors.amber;
}
