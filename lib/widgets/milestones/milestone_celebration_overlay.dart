import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// An overlay to celebrate milestone completion
class MilestoneCelebrationOverlay extends StatefulWidget {
  /// The milestone that was completed
  final Milestone milestone;

  /// Callback when the celebration is dismissed
  final VoidCallback onDismiss;

  const MilestoneCelebrationOverlay({
    super.key,
    required this.milestone,
    required this.onDismiss,
  });

  @override
  State<MilestoneCelebrationOverlay> createState() =>
      _MilestoneCelebrationOverlayState();
}

class _MilestoneCelebrationOverlayState
    extends State<MilestoneCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _scaleAnimation;
  Animation<double>? _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller!, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Start animation
    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        color: Color.fromRGBO(
          Colors.black.r.toInt(),
          Colors.black.g.toInt(),
          Colors.black.b.toInt(),
          0.59,
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller!,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation!.value,
                child: Transform.scale(
                  scale: _scaleAnimation!.value,
                  child: child,
                ),
              );
            },
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(
                      Colors.black.r.toInt(),
                      Colors.black.g.toInt(),
                      Colors.black.b.toInt(),
                      0.20,
                    ),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Confetti icon
                  const Icon(
                    Icons.celebration,
                    size: 48,
                    color: AppColors.ratingStarColor,
                  ),
                  const SizedBox(height: 16),

                  // Milestone achieved text
                  Text(
                    'Milestone Achieved!',
                    style: TextStyles.title,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Milestone icon and title
                  Icon(
                    widget.milestone.icon,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.milestone.title,
                    style: TextStyles.subtitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Reward text
                  Text(
                    widget.milestone.rewardText,
                    style: TextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Points
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '+${widget.milestone.points} points',
                          style: TextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dismiss button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: widget.onDismiss,
                    child: Text(
                      'Awesome!',
                      style: TextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
