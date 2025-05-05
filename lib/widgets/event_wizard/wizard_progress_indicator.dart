import 'package:flutter/material.dart';
import 'package:eventati_book/styles/wizard_styles.dart';

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
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),

            // Step indicator
            Text(
              'Step ${currentStep + 1} of $totalSteps',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                                  : Colors.grey[300],
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Step label
                      Text(
                        index < stepLabels!.length ? stepLabels![index] : '',
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              isActive
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[600],
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
