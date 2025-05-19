import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eventati_book/styles/app_colors.dart';

/// Text styles for the application
class TextStyles {
  // Base font sizes
  static const double _titleFontSize = 24;
  static const double _subtitleFontSize = 18;
  static const double _sectionTitleFontSize = 16;
  static const double _bodyLargeFontSize = 16;
  static const double _bodyMediumFontSize = 14;
  static const double _bodySmallFontSize = 12;
  static const double _buttonTextFontSize = 16;
  static const double _captionFontSize = 12;
  static const double _chipFontSize = 12;
  static const double _priceFontSize = 18;
  static const double _errorFontSize = 12;
  static const double _successFontSize = 12;

  /// Title style for large headers
  static final TextStyle title = GoogleFonts.poppins(
    fontSize: _titleFontSize,
    fontWeight: FontWeight.bold,
  );

  /// Subtitle style for section headers
  static final TextStyle subtitle = GoogleFonts.poppins(
    fontSize: _subtitleFontSize,
    fontWeight: FontWeight.w600,
  );

  /// Section title style for smaller headers
  static final TextStyle sectionTitle = GoogleFonts.poppins(
    fontSize: _sectionTitleFontSize,
    fontWeight: FontWeight.w600,
  );

  /// Body text style for regular content
  static final TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: _bodyLargeFontSize,
    fontWeight: FontWeight.normal,
  );

  /// Medium body text style
  static final TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: _bodyMediumFontSize,
    fontWeight: FontWeight.normal,
  );

  /// Small body text style
  static final TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: _bodySmallFontSize,
    fontWeight: FontWeight.normal,
  );

  /// Button text style
  static final TextStyle buttonText = GoogleFonts.poppins(
    fontSize: _buttonTextFontSize,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  /// Caption text style for small labels
  static final TextStyle caption = GoogleFonts.poppins(
    fontSize: _captionFontSize,
    fontWeight: FontWeight.w400,
    color: Color.fromRGBO(
      AppColors.disabled.r.toInt(),
      AppColors.disabled.g.toInt(),
      AppColors.disabled.b.toInt(),
      0.6,
    ),
  );

  /// Chip text style for tags and chips
  static final TextStyle chip = GoogleFonts.poppins(
    fontSize: _chipFontSize,
    fontWeight: FontWeight.w500,
  );

  /// Price text style for displaying prices
  static final TextStyle price = GoogleFonts.poppins(
    fontSize: _priceFontSize,
    fontWeight: FontWeight.bold,
  );

  /// Error text style for error messages
  static final TextStyle error = GoogleFonts.poppins(
    fontSize: _errorFontSize,
    fontWeight: FontWeight.normal,
    color: AppColors.error,
  );

  /// Success text style for success messages
  static final TextStyle success = GoogleFonts.poppins(
    fontSize: _successFontSize,
    fontWeight: FontWeight.normal,
    color: AppColors.success,
  );

  /// Get a scaled version of the title style
  static TextStyle getTitleStyle(BuildContext context) {
    return _getScaledTextStyle(context, title);
  }

  /// Get a scaled version of the subtitle style
  static TextStyle getSubtitleStyle(BuildContext context) {
    return _getScaledTextStyle(context, subtitle);
  }

  /// Get a scaled version of the section title style
  static TextStyle getSectionTitleStyle(BuildContext context) {
    return _getScaledTextStyle(context, sectionTitle);
  }

  /// Get a scaled version of the body large style
  static TextStyle getBodyLargeStyle(BuildContext context) {
    return _getScaledTextStyle(context, bodyLarge);
  }

  /// Get a scaled version of the body medium style
  static TextStyle getBodyMediumStyle(BuildContext context) {
    return _getScaledTextStyle(context, bodyMedium);
  }

  /// Get a scaled version of the body small style
  static TextStyle getBodySmallStyle(BuildContext context) {
    return _getScaledTextStyle(context, bodySmall);
  }

  /// Get a scaled version of the button text style
  static TextStyle getButtonTextStyle(BuildContext context) {
    return _getScaledTextStyle(context, buttonText);
  }

  /// Get a scaled version of the caption style
  static TextStyle getCaptionStyle(BuildContext context) {
    return _getScaledTextStyle(context, caption);
  }

  /// Get a scaled version of the chip style
  static TextStyle getChipStyle(BuildContext context) {
    return _getScaledTextStyle(context, chip);
  }

  /// Get a scaled version of the price style
  static TextStyle getPriceStyle(BuildContext context) {
    return _getScaledTextStyle(context, price);
  }

  /// Get a scaled version of the error style
  static TextStyle getErrorStyle(BuildContext context) {
    return _getScaledTextStyle(context, error);
  }

  /// Get a scaled version of the success style
  static TextStyle getSuccessStyle(BuildContext context) {
    return _getScaledTextStyle(context, success);
  }

  /// Helper method to get a scaled version of a text style
  static TextStyle _getScaledTextStyle(BuildContext context, TextStyle style) {
    final textScaler = MediaQuery.of(context).textScaler;
    return style.copyWith(fontSize: textScaler.scale(style.fontSize ?? 14));
  }
}
