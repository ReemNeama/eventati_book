import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/utils/core/constants.dart';

/// A widget that visualizes a dependency relationship between two tasks
class DependencyIndicator extends StatelessWidget {
  /// Whether the dependency is being created (animated)
  final bool isCreating;

  /// Creates a new dependency indicator
  const DependencyIndicator({
    super.key,
    this.isCreating = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vertical line
          Container(
            width: 2,
            height: 40,
            color: isCreating
                ? AppColors.primary
                : AppColors.textSecondary.withOpacity(0.5),
          ),
          
          // Arrow
          Positioned(
            bottom: 0,
            child: CustomPaint(
              size: const Size(16, 8),
              painter: ArrowPainter(
                color: isCreating
                    ? AppColors.primary
                    : AppColors.textSecondary.withOpacity(0.5),
              ),
            ),
          ),
          
          // Optional animation for creating state
          if (isCreating)
            Positioned(
              top: 0,
              child: _buildAnimatedDot(),
            ),
        ],
      ),
    );
  }

  /// Builds an animated dot that moves down the line
  Widget _buildAnimatedDot() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: AppConstants.mediumAnimationDuration,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * value),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for drawing the arrow
class ArrowPainter extends CustomPainter {
  /// The color of the arrow
  final Color color;

  /// Creates a new arrow painter
  ArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is ArrowPainter && oldDelegate.color != color;
  }
}
