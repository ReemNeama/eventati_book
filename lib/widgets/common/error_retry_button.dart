import 'package:flutter/material.dart';

/// Button that allows retrying an operation after an error
class ErrorRetryButton extends StatelessWidget {
  /// Text to display on the button
  final String text;

  /// Icon to display on the button
  final IconData icon;

  /// Callback when the button is pressed
  final VoidCallback onPressed;

  /// Whether the button is loading
  final bool isLoading;

  /// Button color
  final Color? color;

  /// Text color
  final Color? textColor;

  /// Button size
  final Size? minimumSize;

  /// Constructor
  const ErrorRetryButton({
    super.key,
    this.text = 'Retry',
    this.icon = Icons.refresh,
    required this.onPressed,
    this.isLoading = false,
    this.color,
    this.textColor,
    this.minimumSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.primary;
    final buttonTextColor = textColor ?? theme.colorScheme.onPrimary;

    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: buttonTextColor,
        minimumSize: minimumSize ?? const Size(120, 40),
      ),
      icon:
          isLoading
              ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(buttonTextColor),
                ),
              )
              : Icon(icon, size: 16),
      label: Text(text),
    );
  }
}
