import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/ui/ui_utils.dart';
import 'package:eventati_book/utils/ui/accessibility_utils.dart';

/// Types of progress indicators
enum ProgressIndicatorType {
  /// Linear progress indicator
  linear,

  /// Circular progress indicator
  circular,

  /// Stepped progress indicator
  stepped,
}

/// A customizable progress indicator widget for long operations
class ProgressIndicatorWidget extends StatelessWidget {
  /// The progress value (0.0 to 1.0)
  final double? progress;

  /// The message to display
  final String? message;

  /// The type of progress indicator
  final ProgressIndicatorType type;

  /// The color of the progress indicator
  final Color? color;

  /// The background color of the progress indicator
  final Color? backgroundColor;

  /// The height of the progress indicator
  final double height;

  /// The width of the progress indicator (for circular)
  final double width;

  /// Whether to show the percentage
  final bool showPercentage;

  /// Whether to animate the progress changes
  final bool animate;

  /// The animation duration
  final Duration animationDuration;

  /// The number of steps (for stepped type)
  final int steps;

  /// The current step (for stepped type)
  final int currentStep;

  /// Creates a ProgressIndicatorWidget
  const ProgressIndicatorWidget({
    super.key,
    this.progress,
    this.message,
    this.type = ProgressIndicatorType.linear,
    this.color,
    this.backgroundColor,
    this.height = 8.0,
    this.width = 48.0,
    this.showPercentage = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.steps = 5,
    this.currentStep = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final progressColor =
        color ?? (isDarkMode ? AppColorsDark.primary : AppColors.primary);
    final bgColor =
        backgroundColor ??
        (isDarkMode ? AppColorsDark.cardBackground : AppColors.cardBackground);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message != null) ...[
          Text(
            message!,
            style: TextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
        _buildProgressIndicator(context, progressColor, bgColor),
        if (showPercentage && progress != null) ...[
          const SizedBox(height: 4),
          Text(
            '${(progress! * 100).toInt()}%',
            style: TextStyles.bodySmall,
            textAlign: TextAlign.center,
            semanticsLabel: AccessibilityUtils.getProgressLabel(
              message ?? 'Loading',
              progress: progress,
            ),
          ),
        ],
      ],
    );
  }

  /// Build the appropriate progress indicator based on type
  Widget _buildProgressIndicator(
    BuildContext context,
    Color progressColor,
    Color bgColor,
  ) {
    switch (type) {
      case ProgressIndicatorType.linear:
        return _buildLinearProgressIndicator(progressColor, bgColor);
      case ProgressIndicatorType.circular:
        return _buildCircularProgressIndicator(progressColor, bgColor);
      case ProgressIndicatorType.stepped:
        return _buildSteppedProgressIndicator(context, progressColor, bgColor);
    }
  }

  /// Build a linear progress indicator
  Widget _buildLinearProgressIndicator(Color progressColor, Color bgColor) {
    if (animate) {
      return AnimatedContainer(
        duration: animationDuration,
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: Stack(
          children: [
            if (progress != null)
              AnimatedContainer(
                duration: animationDuration,
                height: height,
                width: progress! * double.infinity,
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              )
            else
              LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: height,
              ),
          ],
        ),
      );
    } else {
      return Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: Stack(
          children: [
            if (progress != null)
              Container(
                height: height,
                width: progress! * double.infinity,
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              )
            else
              LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: height,
              ),
          ],
        ),
      );
    }
  }

  /// Build a circular progress indicator
  Widget _buildCircularProgressIndicator(Color progressColor, Color bgColor) {
    return SizedBox(
      height: width,
      width: width,
      child:
          progress != null
              ? CircularProgressIndicator(
                value: progress,
                backgroundColor: bgColor,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                strokeWidth: height,
              )
              : CircularProgressIndicator(
                backgroundColor: bgColor,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                strokeWidth: height,
              ),
    );
  }

  /// Build a stepped progress indicator
  Widget _buildSteppedProgressIndicator(
    BuildContext context,
    Color progressColor,
    Color bgColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps, (index) {
        final isActive = index < currentStep;
        final isCurrent = index == currentStep;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child:
              animate
                  ? AnimatedContainer(
                    duration: animationDuration,
                    width: isCurrent ? height * 2 : height,
                    height: height,
                    decoration: BoxDecoration(
                      color: isActive || isCurrent ? progressColor : bgColor,
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  )
                  : Container(
                    width: isCurrent ? height * 2 : height,
                    height: height,
                    decoration: BoxDecoration(
                      color: isActive || isCurrent ? progressColor : bgColor,
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
        );
      }),
    );
  }
}
