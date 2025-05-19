import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/core_providers/accessibility_provider.dart';
import 'package:eventati_book/utils/ui/accessibility_utils.dart';
import 'package:eventati_book/utils/ui/touch_target_utils.dart';

/// An accessible button that combines semantic labels and minimum touch target size
///
/// This button ensures:
/// 1. It has a semantic label for screen readers
/// 2. It has a minimum touch target size of 48x48dp
/// 3. It provides haptic feedback when pressed (if enabled)
/// 4. It has a focus node for keyboard navigation
/// 5. It has a visual focus indicator
class AccessibleButton extends StatefulWidget {
  /// The child widget
  final Widget child;

  /// The callback to call when the button is pressed
  final VoidCallback onPressed;

  /// The semantic label for the button
  final String semanticLabel;

  /// The semantic hint for the button (additional description)
  final String? semanticHint;

  /// The style of the button
  final ButtonStyle? style;

  /// The focus node for the button
  final FocusNode? focusNode;

  /// Whether to add haptic feedback when the button is pressed
  final bool addHapticFeedback;

  /// Constructor
  const AccessibleButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.semanticLabel,
    this.semanticHint,
    this.style,
    this.focusNode,
    this.addHapticFeedback = true,
  });

  @override
  State<AccessibleButton> createState() => _AccessibleButtonState();
}

class _AccessibleButtonState extends State<AccessibleButton> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _handleTap() {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(
      context,
      listen: false,
    );

    if (widget.addHapticFeedback &&
        accessibilityProvider.enableHapticFeedback) {
      AccessibilityUtils.buttonPressHapticFeedback();
    }

    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      hint: widget.semanticHint,
      button: true,
      focusable: true,
      focused: _isFocused,
      child: Focus(
        focusNode: _focusNode,
        child: Container(
          decoration:
              _isFocused
                  ? BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  )
                  : null,
          constraints: const BoxConstraints(
            minWidth: TouchTargetUtils.minTouchTargetSize,
            minHeight: TouchTargetUtils.minTouchTargetSize,
          ),
          child: ElevatedButton(
            onPressed: _handleTap,
            style: widget.style,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// An accessible icon button that combines semantic labels and minimum touch target size
class AccessibleIconButton extends StatefulWidget {
  /// The icon to display
  final IconData icon;

  /// The callback to call when the button is pressed
  final VoidCallback onPressed;

  /// The semantic label for the button
  final String semanticLabel;

  /// The semantic hint for the button (additional description)
  final String? semanticHint;

  /// The color of the icon
  final Color? color;

  /// The size of the icon
  final double size;

  /// The focus node for the button
  final FocusNode? focusNode;

  /// Whether to add haptic feedback when the button is pressed
  final bool addHapticFeedback;

  /// Constructor
  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.semanticHint,
    this.color,
    this.size = 24.0,
    this.focusNode,
    this.addHapticFeedback = true,
  });

  @override
  State<AccessibleIconButton> createState() => _AccessibleIconButtonState();
}

class _AccessibleIconButtonState extends State<AccessibleIconButton> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _handleTap() {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(
      context,
      listen: false,
    );

    if (widget.addHapticFeedback &&
        accessibilityProvider.enableHapticFeedback) {
      AccessibilityUtils.buttonPressHapticFeedback();
    }

    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      hint: widget.semanticHint,
      button: true,
      focusable: true,
      focused: _isFocused,
      child: Focus(
        focusNode: _focusNode,
        child: Container(
          decoration:
              _isFocused
                  ? BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  )
                  : null,
          constraints: const BoxConstraints(
            minWidth: TouchTargetUtils.minTouchTargetSize,
            minHeight: TouchTargetUtils.minTouchTargetSize,
          ),
          child: IconButton(
            icon: Icon(widget.icon, size: widget.size, color: widget.color),
            onPressed: _handleTap,
            tooltip: widget.semanticLabel,
          ),
        ),
      ),
    );
  }
}
