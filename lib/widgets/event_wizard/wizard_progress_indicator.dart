import 'package:flutter/material.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/styles/wizard_styles.dart';
import 'package:eventati_book/styles/app_colors.dart';

/// A progress indicator for the event wizard
class WizardProgressIndicator extends StatelessWidget {
  /// Current step in the wizard
  final int currentStep;

  /// Total number of steps in the wizard
  final int totalSteps;

  /// Whether to show the percentage
  final bool showPercentage;

  /// Whether to show step labels
  final bool showStepLabels;

  /// Labels for each step
  final List<String>? stepLabels;

  const WizardProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.showPercentage = true,
    this.showStepLabels = false,
    this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress percentage
    final progress = totalSteps > 0 ? (currentStep + 1) / totalSteps : 0.0;
    final percentage = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        Container(
          height: 10,
          width: double.infinity,
          decoration: WizardStyles.getProgressIndicatorDecoration(),
          child: Stack(
            children: [
              // Progress fill
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  decoration: WizardStyles.getProgressBarDecoration(context),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Progress text and step indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Progress percentage
            if (showPercentage)
              Text(
                '$percentage% Complete',
                style: TextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),

            // Step indicator
            Text(
              'Step ${currentStep + 1} of $totalSteps',
              style: TextStyles.bodySmall.copyWith(
                color: Color.fromRGBO(
                  AppColors.disabled.r.toInt(),
                  AppColors.disabled.g.toInt(),
                  AppColors.disabled.b.toInt(),
                  0.6,
                ),
              ),
            ),
          ],
        ),

        // Step labels
        if (showStepLabels && stepLabels != null && stepLabels!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(totalSteps, (index) {
                final isActive = index <= currentStep;
                // Store stepLabels in a local variable to avoid null checks
                final labels = stepLabels!;

                return Expanded(
                  child: Column(
                    children: [
                      // Step circle
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isActive
                                  ? Theme.of(context).primaryColor
                                  : Color.fromRGBO(
                                    AppColors.disabled.r.toInt(),
                                    AppColors.disabled.g.toInt(),
                                    AppColors.disabled.b.toInt(),
                                    0.3,
                                  ),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyles.bodySmall.copyWith(
                              color:
                                  isActive
                                      ? Colors.white
                                      : Color.fromRGBO(
                                        AppColors.disabled.r.toInt(),
                                        AppColors.disabled.g.toInt(),
                                        AppColors.disabled.b.toInt(),
                                        0.6,
                                      ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Step label
                      Text(
                        // Use the local variable to avoid null checks
                        index < labels.length ? labels[index] : '',
                        style: TextStyle(
                          color:
                              isActive
                                  ? Theme.of(context).primaryColor
                                  : Color.fromRGBO(
                                    AppColors.disabled.r.toInt(),
                                    AppColors.disabled.g.toInt(),
                                    AppColors.disabled.b.toInt(),
                                    0.6,
                                  ),
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
