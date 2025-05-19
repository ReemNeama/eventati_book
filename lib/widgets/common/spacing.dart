import 'package:flutter/material.dart';
import 'package:eventati_book/utils/core/constants.dart';

/// Spacing sizes
enum SpacingSize {
  /// Extra small spacing (4)
  extraSmall,

  /// Small spacing (8)
  small,

  /// Medium spacing (16)
  medium,

  /// Large spacing (24)
  large,

  /// Extra large spacing (32)
  extraLarge,
}

/// A widget that adds consistent spacing between other widgets
class Spacing extends StatelessWidget {
  /// The size of the spacing
  final SpacingSize size;

  /// Whether the spacing is horizontal
  final bool isHorizontal;

  /// Constructor for vertical spacing
  const Spacing({
    super.key,
    this.size = SpacingSize.medium,
    this.isHorizontal = false,
  });

  /// Constructor for horizontal spacing
  const Spacing.horizontal({Key? key, SpacingSize size = SpacingSize.medium})
    : this(key: key, size: size, isHorizontal: true);

  /// Constructor for vertical spacing
  const Spacing.vertical({Key? key, SpacingSize size = SpacingSize.medium})
    : this(key: key, size: size, isHorizontal: false);

  /// Get the spacing value based on size
  static double getValue(SpacingSize size) {
    switch (size) {
      case SpacingSize.extraSmall:
        return 4.0;
      case SpacingSize.small:
        return AppConstants.smallPadding;
      case SpacingSize.medium:
        return AppConstants.mediumPadding;
      case SpacingSize.large:
        return AppConstants.largePadding;
      case SpacingSize.extraLarge:
        return 32.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = getValue(size);

    return isHorizontal ? SizedBox(width: spacing) : SizedBox(height: spacing);
  }
}

/// A widget that adds consistent padding around other widgets
class StandardPadding extends StatelessWidget {
  /// The child widget
  final Widget child;

  /// The padding size
  final SpacingSize size;

  /// Whether to add padding horizontally
  final bool horizontal;

  /// Whether to add padding vertically
  final bool vertical;

  /// Whether to add padding on the left
  final bool left;

  /// Whether to add padding on the right
  final bool right;

  /// Whether to add padding on the top
  final bool top;

  /// Whether to add padding on the bottom
  final bool bottom;

  /// Constructor
  const StandardPadding({
    super.key,
    required this.child,
    this.size = SpacingSize.medium,
    this.horizontal = true,
    this.vertical = true,
    this.left = true,
    this.right = true,
    this.top = true,
    this.bottom = true,
  });

  /// Constructor for horizontal padding
  const StandardPadding.horizontal({
    Key? key,
    required Widget child,
    SpacingSize size = SpacingSize.medium,
    bool left = true,
    bool right = true,
  }) : this(
         key: key,
         child: child,
         size: size,
         horizontal: true,
         vertical: false,
         left: left,
         right: right,
         top: false,
         bottom: false,
       );

  /// Constructor for vertical padding
  const StandardPadding.vertical({
    Key? key,
    required Widget child,
    SpacingSize size = SpacingSize.medium,
    bool top = true,
    bool bottom = true,
  }) : this(
         key: key,
         child: child,
         size: size,
         horizontal: false,
         vertical: true,
         left: false,
         right: false,
         top: top,
         bottom: bottom,
       );

  /// Constructor for all padding
  const StandardPadding.all({
    Key? key,
    required Widget child,
    SpacingSize size = SpacingSize.medium,
  }) : this(
         key: key,
         child: child,
         size: size,
         horizontal: true,
         vertical: true,
         left: true,
         right: true,
         top: true,
         bottom: true,
       );

  @override
  Widget build(BuildContext context) {
    final spacing = Spacing.getValue(size);

    return Padding(
      padding: EdgeInsets.only(
        left: horizontal && left ? spacing : 0,
        right: horizontal && right ? spacing : 0,
        top: vertical && top ? spacing : 0,
        bottom: vertical && bottom ? spacing : 0,
      ),
      child: child,
    );
  }
}
