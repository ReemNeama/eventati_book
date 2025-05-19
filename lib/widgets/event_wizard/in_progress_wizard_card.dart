import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// A card displaying an in-progress wizard that can be continued
class InProgressWizardCard extends StatelessWidget {
  /// The wizard state to display
  final WizardState wizard;

  /// Callback when the continue button is pressed
  final VoidCallback onContinue;

  /// Callback when the delete button is pressed
  final VoidCallback? onDelete;

  /// Constructor
  const InProgressWizardCard({
    super.key,
    required this.wizard,
    required this.onContinue,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final cardColor = isDarkMode ? AppColorsDark.cardBackground : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Color.fromRGBO(
            primaryColor.r.toInt(),
            primaryColor.g.toInt(),
            primaryColor.b.toInt(),
            0.3,
          ),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onContinue,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event name and type
              Row(
                children: [
                  Icon(wizard.template.icon, color: primaryColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wizard.eventName.isEmpty
                              ? 'Unnamed ${wizard.template.name}'
                              : wizard.eventName,
                          style: TextStyles.subtitle.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (wizard.selectedEventType != null)
                          Text(
                            wizard.selectedEventType!,
                            style: TextStyles.bodyMedium.copyWith(
                              color: Color.fromRGBO(
                                textColor.r.toInt(),
                                textColor.g.toInt(),
                                textColor.b.toInt(),
                                0.7,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Progress indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyles.bodyMedium.copyWith(
                          color: Color.fromRGBO(
                            textColor.r.toInt(),
                            textColor.g.toInt(),
                            textColor.b.toInt(),
                            0.7,
                          ),
                        ),
                      ),
                      Text(
                        '${wizard.completionPercentage.toStringAsFixed(0)}%',
                        style: TextStyles.bodyMedium.copyWith(
                          color: Color.fromRGBO(
                            textColor.r.toInt(),
                            textColor.g.toInt(),
                            textColor.b.toInt(),
                            0.7,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: wizard.completionPercentage / 100,
                    backgroundColor: Color.fromRGBO(
                      Colors.grey.r.toInt(),
                      Colors.grey.g.toInt(),
                      Colors.grey.b.toInt(),
                      0.2,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Last updated
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Last updated: ${DateTimeUtils.formatDateTime(wizard.lastUpdated)}',
                    style: TextStyles.caption.copyWith(
                      color: Color.fromRGBO(
                        textColor.r.toInt(),
                        textColor.g.toInt(),
                        textColor.b.toInt(),
                        0.6,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      if (onDelete != null)
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Color.fromRGBO(
                              Colors.red.r.toInt(),
                              Colors.red.g.toInt(),
                              Colors.red.b.toInt(),
                              0.7,
                            ),
                            size: 20,
                          ),
                          onPressed: () {
                            // Show confirmation dialog
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Delete Draft'),
                                    content: const Text(
                                      'Are you sure you want to delete this draft? '
                                      'This action cannot be undone.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          onDelete!();
                                        },
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          tooltip: 'Delete draft',
                        ),
                      ElevatedButton(
                        onPressed: onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('Continue'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
