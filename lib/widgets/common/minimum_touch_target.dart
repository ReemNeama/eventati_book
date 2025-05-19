import 'package:flutter/material.dart';
import 'package:eventati_book/utils/ui/touch_target_utils.dart';

/// A widget that ensures its child has a minimum touch target size
///
/// This widget wraps its child in a container with a minimum size of 48x48dp
/// to ensure it meets accessibility guidelines for touch targets.
///
/// If the child is already larger than the minimum size, it will not be affected.
class MinimumTouchTarget extends StatelessWidget {
  /// The child widget
  final Widget child;

  /// Whether to center the child within the touch target
  final bool center;

  /// The alignment of the child within the touch target
  final Alignment alignment;

  /// Constructor
  const MinimumTouchTarget({
    super.key,
    required this.child,
    this.center = true,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: TouchTargetUtils.minTouchTargetSize,
        minHeight: TouchTargetUtils.minTouchTargetSize,
      ),
      child:
          center
              ? Center(child: child)
              : Align(alignment: alignment, child: child),
    );
  }
}

/// A widget that ensures its child has a minimum touch target size and is tappable
///
/// This widget wraps its child in a [GestureDetector] with a minimum size of 48x48dp
/// to ensure it meets accessibility guidelines for touch targets.
///
/// The [onTap] callback is called when the widget is tapped.
class TappableMinimumTouchTarget extends StatelessWidget {
  /// The child widget
  final Widget child;

  /// The callback to call when the widget is tapped
  final VoidCallback onTap;

  /// The callback to call when the widget is long-pressed
  final VoidCallback? onLongPress;

  /// Whether to center the child within the touch target
  final bool center;

  /// The alignment of the child within the touch target
  final Alignment alignment;

  /// The semantic label for the touch target
  final String? semanticLabel;

  /// Constructor
  const TappableMinimumTouchTarget({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.center = true,
    this.alignment = Alignment.center,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final Widget touchTarget = GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: TouchTargetUtils.minTouchTargetSize,
          minHeight: TouchTargetUtils.minTouchTargetSize,
        ),
        child:
            center
                ? Center(child: child)
                : Align(alignment: alignment, child: child),
      ),
    );

    if (semanticLabel != null) {
      return Semantics(label: semanticLabel, button: true, child: touchTarget);
    }

    return touchTarget;
  }
}
