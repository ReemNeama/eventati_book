import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';

/// A widget that displays a visual indicator of password strength
class PasswordStrengthIndicator extends StatelessWidget {
  /// The password to evaluate
  final String password;

  /// Creates a new password strength indicator
  const PasswordStrengthIndicator({super.key, required this.password});

  /// Get strength level based on score
  _StrengthLevel _getStrengthLevel() {
    final score = ValidationUtils.calculatePasswordStrength(password);

    if (score < 25) return _StrengthLevel.weak;
    if (score < 50) return _StrengthLevel.fair;
    if (score < 75) return _StrengthLevel.good;
    return _StrengthLevel.strong;
  }

  /// Get color based on strength level
  Color _getColor(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final level = _getStrengthLevel();

    switch (level) {
      case _StrengthLevel.weak:
        return AppColors.error;
      case _StrengthLevel.fair:
        return AppColors.warning;
      case _StrengthLevel.good:
        return isDarkMode ? AppColorsDark.info : AppColors.info;
      case _StrengthLevel.strong:
        return isDarkMode ? AppColorsDark.success : AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final strengthScore = ValidationUtils.calculatePasswordStrength(password);
    final strengthColor = _getColor(context);
    final feedbackText = ValidationUtils.getPasswordStrengthDescription(
      strengthScore,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: strengthScore / 100,
            backgroundColor: Color.fromRGBO(
              AppColors.disabled.r.toInt(),
              AppColors.disabled.g.toInt(),
              AppColors.disabled.b.toInt(),
              0.2,
            ),
            valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 4),
        // Feedback text
        Text(
          feedbackText,
          style: TextStyles.bodySmall.copyWith(color: strengthColor),
        ),
      ],
    );
  }
}

/// Enum for password strength levels
enum _StrengthLevel { weak, fair, good, strong }
