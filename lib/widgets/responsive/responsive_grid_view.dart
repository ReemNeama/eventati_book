import 'package:flutter/material.dart';

/// A grid view that adapts the number of columns based on available width.
///
/// This widget helps create responsive grid layouts by automatically
/// adjusting the number of columns based on the available width.
class ResponsiveGridView extends StatelessWidget {
  /// The items to display in the grid.
  final List<Widget> children;

  /// The minimum width for each item in the grid.
  final double minItemWidth;

  /// The aspect ratio of each item (width / height).
  final double childAspectRatio;

  /// The spacing between items horizontally.
  final double crossAxisSpacing;

  /// The spacing between items vertically.
  final double mainAxisSpacing;

  /// Whether the grid should be scrollable.
  final bool shrinkWrap;

  /// The physics for the grid's scrolling behavior.
  final ScrollPhysics? physics;

  /// The padding around the grid.
  final EdgeInsetsGeometry? padding;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.minItemWidth = 150,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the number of columns based on available width
        final width = constraints.maxWidth;
        final crossAxisCount = (width / minItemWidth).floor();

        // Ensure at least 1 column
        final columns = crossAxisCount > 0 ? crossAxisCount : 1;

        return GridView.builder(
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: physics,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}
