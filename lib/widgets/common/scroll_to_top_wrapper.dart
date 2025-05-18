import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/common/back_to_top_button.dart';

/// A wrapper widget that adds a "Back to Top" button to scrollable content
class ScrollToTopWrapper extends StatefulWidget {
  /// The child widget
  final Widget child;

  /// Optional scroll controller
  /// If not provided, a new one will be created
  final ScrollController? scrollController;

  /// The threshold in pixels after which the button appears
  final double scrollThreshold;

  /// The duration of the scroll animation
  final Duration scrollDuration;

  /// The curve of the scroll animation
  final Curve scrollCurve;

  /// The icon to display in the button
  final IconData icon;

  /// The color of the button
  final Color? backgroundColor;

  /// The color of the icon
  final Color? iconColor;

  /// The size of the button
  final double size;

  /// The tooltip text for accessibility
  final String tooltip;

  /// The position of the button
  final BackToTopButtonPosition position;

  /// The padding around the button
  final EdgeInsets padding;

  /// Constructor
  const ScrollToTopWrapper({
    super.key,
    required this.child,
    this.scrollController,
    this.scrollThreshold = 300.0,
    this.scrollDuration = const Duration(milliseconds: 500),
    this.scrollCurve = Curves.easeInOut,
    this.icon = Icons.arrow_upward,
    this.backgroundColor,
    this.iconColor,
    this.size = 56.0,
    this.tooltip = 'Back to top',
    this.position = BackToTopButtonPosition.bottomRight,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  State<ScrollToTopWrapper> createState() => _ScrollToTopWrapperState();
}

class _ScrollToTopWrapperState extends State<ScrollToTopWrapper> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    // Use the provided scroll controller or create a new one
    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  void dispose() {
    // Dispose the scroll controller if we created it
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The scrollable content
        widget.child is Scrollable
            ? widget.child
            : SingleChildScrollView(
              controller: _scrollController,
              child: widget.child,
            ),

        // The back to top button
        BackToTopButton(
          scrollController: _scrollController,
          scrollThreshold: widget.scrollThreshold,
          scrollDuration: widget.scrollDuration,
          scrollCurve: widget.scrollCurve,
          icon: widget.icon,
          backgroundColor: widget.backgroundColor,
          iconColor: widget.iconColor,
          size: widget.size,
          tooltip: widget.tooltip,
          position: widget.position,
          padding: widget.padding,
        ),
      ],
    );
  }
}
