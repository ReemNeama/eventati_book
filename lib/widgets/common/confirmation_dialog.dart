import 'package:flutter/material.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/ui_utils.dart';
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
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: TextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirmText,
            style: TextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
