import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/ui/ui_utils.dart';

/// Enum defining different styles for the progress indicator
enum ProgressIndicatorStyle {
  /// Linear progress bar style
  linear,

  /// Dots representing each step
  dots,

  /// Numbered circles for each step
  numbered,
}

/// A customizable progress indicator for multi-step flows
class StepProgressIndicator extends StatelessWidget {
  /// Current step (0-based index)
  final int currentStep;

  /// Total number of steps
  final int totalSteps;

  /// Optional labels for each step
  final List<String>? stepLabels;

  /// Whether to show step numbers
  final bool showStepNumbers;

  /// Whether to show completion percentage
  final bool showPercentage;

  /// Style of the progress indicator
  final ProgressIndicatorStyle style;

  /// Color for active steps (defaults to theme primary color)
  final Color? activeColor;

  /// Color for inactive steps (defaults to theme disabled color)
  final Color? inactiveColor;

  /// Height of the progress indicator
  final double height;

  /// Constructor
  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels,
    this.showStepNumbers = true,
    this.showPercentage = false,
    this.style = ProgressIndicatorStyle.linear,
    this.activeColor,
    this.inactiveColor,
    this.height = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = activeColor ?? theme.primaryColor;
    final disabledColor =
        inactiveColor ??
        Color.fromRGBO(
          AppColors.disabled.r.toInt(),
          AppColors.disabled.g.toInt(),
          AppColors.disabled.b.toInt(),
          0.3,
        );

    // Calculate progress percentage
    final progress = totalSteps > 0 ? (currentStep + 1) / totalSteps : 0.0;
    final percentage = (progress * 100).toInt();

    // Main column to hold the progress indicator and labels
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress indicator
        _buildProgressIndicator(primaryColor, disabledColor, progress, context),

        // Percentage display (optional)
        if (showPercentage) ...[
          const SizedBox(height: 4),
          Text(
            '$percentage% Complete',
            style: TextStyles.bodySmall.copyWith(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ],

        // Step labels (optional)
        if (stepLabels != null && stepLabels!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildStepLabels(primaryColor, disabledColor, context),
        ],
      ],
    );
  }

  /// Builds the appropriate progress indicator based on the selected style
  Widget _buildProgressIndicator(
    Color activeColor,
    Color inactiveColor,
    double progress,
    BuildContext context,
  ) {
    switch (style) {
      case ProgressIndicatorStyle.linear:
        return _buildLinearIndicator(activeColor, inactiveColor, progress);
      case ProgressIndicatorStyle.dots:
        return _buildDotsIndicator(activeColor, inactiveColor);
      case ProgressIndicatorStyle.numbered:
        return _buildNumberedIndicator(activeColor, inactiveColor, context);
    }
  }

  /// Builds a linear progress bar
  Widget _buildLinearIndicator(
    Color activeColor,
    Color inactiveColor,
    double progress,
  ) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: inactiveColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Stack(
        children: [
          // Progress fill
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a series of dots representing steps
  Widget _buildDotsIndicator(Color activeColor, Color inactiveColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? activeColor : inactiveColor,
          ),
        );
      }),
    );
  }

  /// Builds numbered circles with connecting lines
  Widget _buildNumberedIndicator(
    Color activeColor,
    Color inactiveColor,
    BuildContext context,
  ) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        final isCurrentStep = index == currentStep;

        return Expanded(
          child: Row(
            children: [
              // Step circle
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? activeColor : inactiveColor,
                  border:
                      isCurrentStep
                          ? Border.all(color: activeColor, width: 2)
                          : null,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyles.bodySmall.copyWith(
                      color: isActive ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Connector line (except for last item)
              if (index < totalSteps - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color:
                        isActive && index < currentStep
                            ? activeColor
                            : inactiveColor,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  /// Builds labels for each step
  Widget _buildStepLabels(
    Color activeColor,
    Color inactiveColor,
    BuildContext context,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        stepLabels!.length > totalSteps ? totalSteps : stepLabels!.length,
        (index) {
          final isActive = index <= currentStep;
          return Text(
            stepLabels![index],
            style: TextStyles.bodySmall.copyWith(
              color: isActive ? activeColor : inactiveColor,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          );
        },
      ),
    );
  }
}
