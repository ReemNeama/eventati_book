import 'package:flutter/material.dart';
import 'package:eventati_book/utils/ui/ui_utils.dart';

/// Enum for the position of the back to top button
enum BackToTopButtonPosition {
  /// Bottom right corner
  bottomRight,

  /// Bottom left corner
  bottomLeft,

  /// Bottom center
  bottomCenter,
}

/// A button that appears when scrolling down and allows users to quickly scroll back to the top
class BackToTopButton extends StatefulWidget {
  /// The scroll controller to listen to
  final ScrollController scrollController;

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
  const BackToTopButton({
    super.key,
    required this.scrollController,
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
  State<BackToTopButton> createState() => _BackToTopButtonState();
}

class _BackToTopButtonState extends State<BackToTopButton>
    with SingleTickerProviderStateMixin {
  bool _showButton = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Create animation
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Add listener to scroll controller
    widget.scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    // Remove listener from scroll controller
    widget.scrollController.removeListener(_scrollListener);

    // Dispose animation controller
    _animationController.dispose();

    super.dispose();
  }

  /// Listen to scroll events and show/hide the button accordingly
  void _scrollListener() {
    if (widget.scrollController.offset >= widget.scrollThreshold &&
        !_showButton) {
      setState(() {
        _showButton = true;
      });
      _animationController.forward();
    } else if (widget.scrollController.offset < widget.scrollThreshold &&
        _showButton) {
      setState(() {
        _showButton = false;
      });
      _animationController.reverse();
    }
  }

  /// Scroll to the top of the list
  void _scrollToTop() {
    widget.scrollController.animateTo(
      0,
      duration: widget.scrollDuration,
      curve: widget.scrollCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    // If the button should not be shown, return an empty container
    if (!_showButton && _animationController.isDismissed) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDarkMode = UIUtils.isDarkMode(context);

    // Default colors
    final defaultBackgroundColor =
        widget.backgroundColor ??
        (isDarkMode ? theme.colorScheme.surface : theme.primaryColor);
    final defaultIconColor =
        widget.iconColor ?? (isDarkMode ? theme.primaryColor : Colors.white);

    // Build the button
    final button = FadeTransition(
      opacity: _animation,
      child: ScaleTransition(
        scale: _animation,
        child: FloatingActionButton(
          onPressed: _scrollToTop,
          tooltip: widget.tooltip,
          backgroundColor: defaultBackgroundColor,
          foregroundColor: defaultIconColor,
          mini: widget.size < 48.0,
          child: Icon(widget.icon),
        ),
      ),
    );

    // Position the button
    return Positioned(
      bottom: widget.padding.bottom,
      right:
          widget.position == BackToTopButtonPosition.bottomRight
              ? widget.padding.right
              : null,
      left:
          widget.position == BackToTopButtonPosition.bottomLeft
              ? widget.padding.left
              : null,
      child:
          widget.position == BackToTopButtonPosition.bottomCenter
              ? Center(child: button)
              : button,
    );
  }
}
