import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/styles/wizard_styles.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/widgets/event_wizard/field_completion_indicator.dart';

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

  /// List of step completion percentages (0-100)
  final List<double>? stepCompletionPercentages;

  /// Whether to show field completion indicators
  final bool showFieldCompletionStatus;

  const WizardProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.showPercentage = true,
    this.showStepLabels = false,
    this.stepLabels,
    this.stepCompletionPercentages,
    this.showFieldCompletionStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    // Get the wizard provider to access field completion status
    final wizardProvider = Provider.of<WizardProvider>(context);

    // Calculate progress percentage
    final progress = totalSteps > 0 ? (currentStep + 1) / totalSteps : 0.0;
    final percentage = (progress * 100).toInt();

    // Get step completion percentages
    final List<double> completionPercentages =
        stepCompletionPercentages ??
        List.generate(totalSteps, (index) {
          if (index < currentStep) {
            // Previous steps are 100% complete
            return 100.0;
          } else if (index > currentStep) {
            // Future steps are 0% complete
            return 0.0;
          } else {
            // Current step - get completion from provider if available
            return wizardProvider.getStepCompletionPercentage(index);
          }
        });

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
            Row(
              children: [
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
                if (showFieldCompletionStatus && currentStep < totalSteps) ...[
                  const SizedBox(width: 8),
                  FieldCompletionIndicator(
                    isCompleted: completionPercentages[currentStep] >= 100,
                    size: 16,
                    tooltip:
                        completionPercentages[currentStep] >= 100
                            ? 'Step completed'
                            : 'Step in progress (${completionPercentages[currentStep].toInt()}% complete)',
                  ),
                ],
              ],
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
                final isCompleted =
                    index < currentStep ||
                    (index == currentStep &&
                        completionPercentages[index] >= 100);
                // Store stepLabels in a local variable to avoid null checks
                final labels = stepLabels!;

                return Expanded(
                  child: Column(
                    children: [
                      // Step circle with completion status
                      Stack(
                        alignment: Alignment.center,
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
                              child:
                                  isCompleted
                                      ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                      : Text(
                                        '${index + 1}',
                                        style: TextStyles.bodySmall.copyWith(
                                          color:
                                              isActive
                                                  ? Colors.white
                                                  : Color.fromRGBO(
                                                    AppColors.disabled.r
                                                        .toInt(),
                                                    AppColors.disabled.g
                                                        .toInt(),
                                                    AppColors.disabled.b
                                                        .toInt(),
                                                    0.6,
                                                  ),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),

                          // Show completion percentage for current step
                          if (showFieldCompletionStatus &&
                              index == currentStep &&
                              !isCompleted &&
                              completionPercentages[index] > 0)
                            Positioned(
                              right: -4,
                              bottom: -4,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${completionPercentages[index].toInt()}%',
                                    style: TextStyle(
                                      fontSize: 6,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Step label
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                                  isActive
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (isCompleted && showFieldCompletionStatus) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.check_circle,
                              size: 12,
                              color: AppColors.success,
                            ),
                          ],
                        ],
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
