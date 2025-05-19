import 'package:flutter/material.dart';
import 'package:eventati_book/utils/ui/ui_utils.dart';
import 'package:eventati_book/utils/ui/feedback_utils.dart';

/// A button that shows a loading indicator during async operations
class AsyncButton extends StatefulWidget {
  /// The text to display on the button
  final String text;

  /// The callback when the button is pressed
  final Future<void> Function() onPressed;

  /// The callback when the operation is completed successfully
  final VoidCallback? onSuccess;

  /// The callback when the operation fails
  final Function(dynamic error)? onError;

  /// The style of the button
  final ButtonStyle? style;

  /// The text style of the button
  final TextStyle? textStyle;

  /// The loading indicator color
  final Color? loadingColor;

  /// The loading indicator size
  final double loadingSize;

  /// Whether to show a success message when the operation completes
  final bool showSuccessMessage;

  /// The success message to show
  final String? successMessage;

  /// Whether to add haptic feedback when pressed
  final bool addHapticFeedback;

  /// The type of haptic feedback to add
  final HapticFeedbackType hapticFeedbackType;

  /// Whether the button is enabled
  final bool isEnabled;

  /// The icon to display before the text
  final IconData? icon;

  /// The size of the icon
  final double iconSize;

  /// The spacing between the icon and text
  final double iconSpacing;

  /// Creates an AsyncButton
  const AsyncButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.onSuccess,
    this.onError,
    this.style,
    this.textStyle,
    this.loadingColor,
    this.loadingSize = 20.0,
    this.showSuccessMessage = false,
    this.successMessage,
    this.addHapticFeedback = true,
    this.hapticFeedbackType = HapticFeedbackType.light,
    this.isEnabled = true,
    this.icon,
    this.iconSize = 20.0,
    this.iconSpacing = 8.0,
  });

  @override
  State<AsyncButton> createState() => _AsyncButtonState();
}

class _AsyncButtonState extends State<AsyncButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final loadingColor =
        widget.loadingColor ?? (isDarkMode ? Colors.white : Colors.white);

    return ElevatedButton(
      onPressed: _isLoading || !widget.isEnabled ? null : _handlePress,
      style: widget.style,
      child:
          _isLoading
              ? SizedBox(
                width: widget.loadingSize,
                height: widget.loadingSize,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
                  strokeWidth: 2.0,
                ),
              )
              : _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: widget.iconSize),
          SizedBox(width: widget.iconSpacing),
          Text(widget.text, style: widget.textStyle),
        ],
      );
    }

    return Text(widget.text, style: widget.textStyle);
  }

  Future<void> _handlePress() async {
    // Add haptic feedback
    if (widget.addHapticFeedback) {
      FeedbackUtils.addHapticFeedback(widget.hapticFeedbackType);
    }

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Execute the callback
      await widget.onPressed();

      // Only proceed if the widget is still mounted
      if (!mounted) return;

      // Show success message if enabled
      if (widget.showSuccessMessage && mounted) {
        FeedbackUtils.showSuccessToast(
          context,
          widget.successMessage ?? 'Operation completed successfully',
        );
      }

      // Call success callback if provided
      widget.onSuccess?.call();
    } catch (error) {
      // Only proceed if the widget is still mounted
      if (!mounted) return;

      // Call error callback if provided
      widget.onError?.call(error);
    } finally {
      // Reset loading state if the widget is still mounted
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

/// A text button that shows a loading indicator during async operations
class AsyncTextButton extends StatelessWidget {
  /// The text to display on the button
  final String text;

  /// The callback when the button is pressed
  final Future<void> Function() onPressed;

  /// The callback when the operation is completed successfully
  final VoidCallback? onSuccess;

  /// The callback when the operation fails
  final Function(dynamic error)? onError;

  /// The style of the button
  final ButtonStyle? style;

  /// The text style of the button
  final TextStyle? textStyle;

  /// The loading indicator color
  final Color? loadingColor;

  /// The loading indicator size
  final double loadingSize;

  /// Whether to show a success message when the operation completes
  final bool showSuccessMessage;

  /// The success message to show
  final String? successMessage;

  /// Whether to add haptic feedback when pressed
  final bool addHapticFeedback;

  /// The type of haptic feedback to add
  final HapticFeedbackType hapticFeedbackType;

  /// Whether the button is enabled
  final bool isEnabled;

  /// The icon to display before the text
  final IconData? icon;

  /// Creates an AsyncTextButton
  const AsyncTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.onSuccess,
    this.onError,
    this.style,
    this.textStyle,
    this.loadingColor,
    this.loadingSize = 16.0,
    this.showSuccessMessage = false,
    this.successMessage,
    this.addHapticFeedback = true,
    this.hapticFeedbackType = HapticFeedbackType.light,
    this.isEnabled = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AsyncButton(
      text: text,
      onPressed: onPressed,
      onSuccess: onSuccess,
      onError: onError,
      style: style ?? TextButton.styleFrom(),
      textStyle: textStyle,
      loadingColor: loadingColor,
      loadingSize: loadingSize,
      showSuccessMessage: showSuccessMessage,
      successMessage: successMessage,
      addHapticFeedback: addHapticFeedback,
      hapticFeedbackType: hapticFeedbackType,
      isEnabled: isEnabled,
      icon: icon,
    );
  }
}
