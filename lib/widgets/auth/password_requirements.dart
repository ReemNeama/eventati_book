import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';

/// A widget that displays password requirements as a checklist
class PasswordRequirements extends StatelessWidget {
  /// The password to evaluate
  final String password;

  /// Minimum length requirement
  final int minLength;

  /// Whether to require uppercase letters
  final bool requireUppercase;

  /// Whether to require lowercase letters
  final bool requireLowercase;

  /// Whether to require numbers
  final bool requireNumbers;

  /// Whether to require special characters
  final bool requireSpecialChars;

  /// Creates a new password requirements widget
  const PasswordRequirements({
    super.key,
    required this.password,
    this.minLength = 8,
    this.requireUppercase = true,
    this.requireLowercase = true,
    this.requireNumbers = true,
    this.requireSpecialChars = true,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final successColor = isDarkMode ? AppColorsDark.success : AppColors.success;
    const errorColor = AppColors.error;

    const double opacity = 0.1;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, opacity),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: TextStyles.bodyMedium.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirementItem(
            context: context,
            text: 'At least $minLength characters',
            isMet: password.length >= minLength,
            successColor: successColor,
            errorColor: errorColor,
          ),
          if (requireUppercase)
            _buildRequirementItem(
              context: context,
              text: 'At least one uppercase letter (A-Z)',
              isMet: password.contains(RegExp(r'[A-Z]')),
              successColor: successColor,
              errorColor: errorColor,
            ),
          if (requireLowercase)
            _buildRequirementItem(
              context: context,
              text: 'At least one lowercase letter (a-z)',
              isMet: password.contains(RegExp(r'[a-z]')),
              successColor: successColor,
              errorColor: errorColor,
            ),
          if (requireNumbers)
            _buildRequirementItem(
              context: context,
              text: 'At least one number (0-9)',
              isMet: password.contains(RegExp(r'[0-9]')),
              successColor: successColor,
              errorColor: errorColor,
            ),
          if (requireSpecialChars)
            _buildRequirementItem(
              context: context,
              text: 'At least one special character (!@#\$%^&*)',
              isMet: password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
              successColor: successColor,
              errorColor: errorColor,
            ),
        ],
      ),
    );
  }

  /// Build a single requirement item with check/x icon
  Widget _buildRequirementItem({
    required BuildContext context,
    required String text,
    required bool isMet,
    required Color successColor,
    required Color errorColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: isMet ? successColor : errorColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyles.bodySmall.copyWith(
                color: isMet ? successColor : errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
