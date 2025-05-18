import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';


class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final IconData prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    // Always use contrasting colors for text fields in authentication screens
    // since they often have colored backgrounds
    const textColor = Colors.black87;
    const hintColor = Colors.black54;
    const borderColor = Colors.white70;
    const fillColor = Colors.white;

    return TextFormField(
      controller: controller,
      style: const TextStyle(color: textColor),
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: hintColor),
        filled: true,
        fillColor: fillColor,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: borderColor),
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        ),
        prefixIcon: Icon(prefixIcon, color: primaryColor),
        contentPadding: const EdgeInsets.all(AppConstants.mediumPadding),
      ),
      validator: validator,
    );
  }
}
