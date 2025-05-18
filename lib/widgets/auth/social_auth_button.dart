import 'package:flutter/material.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// A button for social authentication methods
class SocialAuthButton extends StatelessWidget {
  /// The callback when the button is pressed
  final VoidCallback? onPressed;

  /// The text to display on the button
  final String text;

  /// The icon to display on the button
  final IconData? icon;

  /// The image asset path to display on the button
  final String? imagePath;

  /// The background color of the button
  final Color? backgroundColor;

  /// The text color of the button
  final Color? textColor;

  /// The width of the button
  final double? width;

  /// The height of the button
  final double height;

  /// Constructor
  const SocialAuthButton({
    super.key,
    this.onPressed,
    required this.text,
    this.icon,
    this.imagePath,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 50,
  }) : assert(
         icon != null || imagePath != null,
         'Either icon or imagePath must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.white;
    final txtColor = textColor ?? AppColors.textPrimary;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(bgColor),
          foregroundColor: WidgetStateProperty.all(txtColor),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.smallBorderRadius,
              ),
              side: BorderSide(color: Color.fromRGBO(AppColors.disabled.r.toInt(), AppColors.disabled.g.toInt(), AppColors.disabled.b.toInt(), 0.3)),
            ),
          ),
          elevation: WidgetStateProperty.all(1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(icon, color: txtColor)
            else if (imagePath != null)
              Image.asset(imagePath!, height: 24, width: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyles.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
