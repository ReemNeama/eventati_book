import 'package:flutter/material.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';

/// A reusable confirmation dialog widget
class ConfirmationDialog extends StatelessWidget {
  /// The title of the dialog
  final String title;

  /// The content of the dialog
  final String content;

  /// The text for the confirm button
  final String confirmText;

  /// The text for the cancel button
  final String cancelText;

  /// The color for the confirm button
  final Color? confirmColor;

  /// Constructor
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final buttonColor = confirmColor ?? primaryColor;

    return AlertDialog(
      title: Text(title, style: TextStyles.subtitle),
      content: Text(content, style: TextStyles.bodyMedium),
      actions: [
        TextButton(
          onPressed: () => NavigationUtils.pop(context, false),
          child: Text(
            cancelText,
            style: TextStyles.bodyMedium.copyWith(
              color: Color.fromRGBO(
                AppColors.disabled.r.toInt(),
                AppColors.disabled.g.toInt(),
                AppColors.disabled.b.toInt(),
                0.6,
              ),
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
          onPressed: () => NavigationUtils.pop(context, true),
          child: Text(
            confirmText,
            style: TextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
