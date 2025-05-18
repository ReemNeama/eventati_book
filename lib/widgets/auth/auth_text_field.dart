import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/auth/password_strength_indicator.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final IconData prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool showPasswordStrength;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.showPasswordStrength = false,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    // Always use contrasting colors for text fields in authentication screens
    // since they often have colored backgrounds
    const textColor = AppColors.textPrimary;
    const hintColor = AppColors.textSecondary;

    const fillColor = Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          style: const TextStyle(color: textColor),
          obscureText: widget.obscureText && !_showPassword,
          keyboardType: widget.keyboardType,
          onChanged:
              widget.showPasswordStrength ? (_) => setState(() {}) : null,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: hintColor),
            filled: true,
            fillColor: fillColor,
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color.fromRGBO(255, 255, 255, 0.7),
              ),
              borderRadius: BorderRadius.circular(
                AppConstants.smallBorderRadius,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor, width: 2),
              borderRadius: BorderRadius.circular(
                AppConstants.smallBorderRadius,
              ),
            ),
            prefixIcon: Icon(widget.prefixIcon, color: primaryColor),
            suffixIcon:
                widget.obscureText
                    ? IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                        color: primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    )
                    : null,
            contentPadding: const EdgeInsets.all(AppConstants.mediumPadding),
          ),
          validator: widget.validator,
        ),
        if (widget.showPasswordStrength) ...[
          const SizedBox(height: 8),
          PasswordStrengthIndicator(password: widget.controller.text),
        ],
      ],
    );
  }
}
