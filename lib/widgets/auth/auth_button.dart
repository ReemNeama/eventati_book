import 'package:flutter/material.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';

class AuthButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isWhiteBackground;

  const AuthButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isWhiteBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final backgroundColor = isWhiteBackground ? Colors.white : primaryColor;
    final textColor = isWhiteBackground ? primaryColor : Colors.white;

    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding * 2,
            vertical: AppConstants.mediumPadding,
          ),
        ),
        minimumSize: WidgetStateProperty.all(const Size(200, 40)),
        backgroundColor: WidgetStateProperty.all(backgroundColor),
        elevation: WidgetStateProperty.all(0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
