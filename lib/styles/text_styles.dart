import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eventati_book/styles/app_colors.dart';

/// Text styles for the application
class TextStyles {
  /// Title style for large headers
  static final TextStyle title = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  /// Subtitle style for section headers
  static final TextStyle subtitle = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  /// Section title style for smaller headers
  static final TextStyle sectionTitle = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  /// Body text style for regular content
  static final TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  /// Medium body text style
  static final TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  /// Small body text style
  static final TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  /// Button text style
  static final TextStyle buttonText = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  /// Caption text style for small labels
  static final TextStyle caption = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color.fromRGBO(AppColors.disabled.r.toInt(), AppColors.disabled.g.toInt(), AppColors.disabled.b.toInt(), 0.6),
  );

  /// Chip text style for tags and chips
  static final TextStyle chip = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  /// Price text style for displaying prices
  static final TextStyle price = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  /// Error text style for error messages
  static final TextStyle error = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.error,
  );

  /// Success text style for success messages
  static final TextStyle success = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.success,
  );
}
