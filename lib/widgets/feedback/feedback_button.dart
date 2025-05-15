import 'package:flutter/material.dart';
import 'package:eventati_book/models/feedback_models/user_feedback.dart';
import 'package:eventati_book/widgets/feedback/feedback_form.dart';
import 'package:eventati_book/utils/ui/accessibility_utils.dart';

/// A button that opens a feedback form when pressed
class FeedbackButton extends StatelessWidget {
  /// The context of the feedback (e.g., screen name)
  final String? context;

  /// The initial feedback type
  final FeedbackType initialType;

  /// The callback when feedback is submitted
  final Function(UserFeedback feedback)? onFeedbackSubmitted;

  /// The icon to display on the button
  final IconData icon;

  /// The label to display on the button
  final String? label;

  /// The tooltip to display when hovering over the button
  final String? tooltip;

  /// The color of the button
  final Color? color;

  /// The size of the button
  final double size;

  /// Whether to show the button as a floating action button
  final bool isFloating;

  /// The position of the floating action button
  final FloatingActionButtonLocation? floatingLocation;

  /// Creates a FeedbackButton
  const FeedbackButton({
    super.key,
    this.context,
    this.initialType = FeedbackType.general,
    this.onFeedbackSubmitted,
    this.icon = Icons.feedback,
    this.label,
    this.tooltip = 'Provide Feedback',
    this.color,
    this.size = 24.0,
    this.isFloating = false,
    this.floatingLocation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.primaryColor;

    if (isFloating) {
      return FloatingActionButton(
        onPressed: () => _showFeedbackDialog(context),
        tooltip: tooltip,
        backgroundColor: buttonColor,
        child: Icon(icon),
      );
    }

    if (label != null) {
      return ElevatedButton.icon(
        onPressed: () => _showFeedbackDialog(context),
        icon: Icon(icon, size: size),
        label: Text(label!),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
      );
    }

    return IconButton(
      onPressed: () => _showFeedbackDialog(context),
      icon: Icon(icon, size: size),
      tooltip: tooltip,
      color: buttonColor,
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    AccessibilityUtils.buttonPressHapticFeedback();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('We Value Your Feedback'),
            content: SizedBox(
              width: 400,
              child: FeedbackForm(
                context: this.context,
                initialType: initialType,
                onFeedbackSubmitted: (feedback) {
                  Navigator.of(context).pop();
                  if (onFeedbackSubmitted != null) {
                    onFeedbackSubmitted!(feedback);
                  }
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }
}

/// A floating feedback button
class FloatingFeedbackButton extends StatelessWidget {
  /// The context of the feedback (e.g., screen name)
  final String? context;

  /// The initial feedback type
  final FeedbackType initialType;

  /// The callback when feedback is submitted
  final Function(UserFeedback feedback)? onFeedbackSubmitted;

  /// The icon to display on the button
  final IconData icon;

  /// The tooltip to display when hovering over the button
  final String? tooltip;

  /// The color of the button
  final Color? color;

  /// The position of the floating action button
  final FloatingActionButtonLocation location;

  /// Creates a FloatingFeedbackButton
  const FloatingFeedbackButton({
    super.key,
    this.context,
    this.initialType = FeedbackType.general,
    this.onFeedbackSubmitted,
    this.icon = Icons.feedback,
    this.tooltip = 'Provide Feedback',
    this.color,
    this.location = FloatingActionButtonLocation.endFloat,
  });

  @override
  Widget build(BuildContext context) {
    return FeedbackButton(
      context: null, // Pass null instead of context
      initialType: initialType,
      onFeedbackSubmitted: onFeedbackSubmitted,
      icon: icon,
      tooltip: tooltip,
      color: color,
      isFloating: true,
      floatingLocation: location,
    );
  }
}
