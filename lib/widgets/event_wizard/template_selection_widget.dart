import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';

/// A widget for selecting a detailed event template
class TemplateSelectionWidget extends StatelessWidget {
  /// The parent template ID (wedding, business, celebration)
  final String parentTemplateId;

  /// Callback when a template is selected
  final Function(EventTemplate) onTemplateSelected;

  /// List of templates to display
  final List<EventTemplate> templates;

  /// Constructor
  const TemplateSelectionWidget({
    super.key,
    required this.parentTemplateId,
    required this.onTemplateSelected,
    required this.templates,
  });

  @override
  Widget build(BuildContext context) {
    final filteredTemplates =
        templates
            .where((template) => template.parentTemplateId == parentTemplateId)
            .toList();

    if (filteredTemplates.isEmpty) {
      return const Center(
        child: Text('No templates available for this event type'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredTemplates.length,
      itemBuilder: (context, index) {
        return TemplateCard(
          template: filteredTemplates[index],
          onSelect: onTemplateSelected,
        );
      },
    );
  }
}

/// A card displaying a detailed event template
class TemplateCard extends StatelessWidget {
  /// The template to display
  final EventTemplate template;

  /// Callback when the template is selected
  final Function(EventTemplate) onSelect;

  /// Constructor
  const TemplateCard({
    super.key,
    required this.template,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final cardColor = isDarkMode ? AppColorsDark.cardBackground : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
        onTap: () => onSelect(template),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Template image (if available)
            if (template.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.asset(
                  template.imageUrl!,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Color.fromRGBO(
                        primaryColor.r.toInt(),
                        primaryColor.g.toInt(),
                        primaryColor.b.toInt(),
                        0.1,
                      ),
                      child: Icon(template.icon, size: 50, color: primaryColor),
                    );
                  },
                ),
              )
            else
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(
                    primaryColor.r.toInt(),
                    primaryColor.g.toInt(),
                    primaryColor.b.toInt(),
                    0.1,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Icon(template.icon, size: 50, color: primaryColor),
                ),
              ),

            // Template details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Template name and icon
                  Row(
                    children: [
                      Icon(template.icon, color: primaryColor, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          template.name,
                          style: TextStyles.subtitle.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Template description
                  Text(
                    template.description,
                    style: TextStyles.bodyMedium.copyWith(
                      color: Color.fromRGBO(
                        textColor.r.toInt(),
                        textColor.g.toInt(),
                        textColor.b.toInt(),
                        0.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Template details
                  if (template.defaultValues != null &&
                      template.defaultValues!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Template Details:',
                          style: TextStyles.bodyMedium.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTemplateDetails(template, textColor),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Select button
                  ElevatedButton(
                    onPressed: () => onSelect(template),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Use This Template'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the template details section
  Widget _buildTemplateDetails(EventTemplate template, Color textColor) {
    final defaultValues = template.defaultValues!;
    final details = <Widget>[];

    if (defaultValues.containsKey('guestCount')) {
      details.add(
        _buildDetailItem(
          'Typical Guest Count',
          '${defaultValues['guestCount']} guests',
          textColor,
        ),
      );
    }

    if (defaultValues.containsKey('budgetEstimate')) {
      details.add(
        _buildDetailItem(
          'Budget Estimate',
          '\$${defaultValues['budgetEstimate']}',
          textColor,
        ),
      );
    }

    if (defaultValues.containsKey('timelineMonths')) {
      details.add(
        _buildDetailItem(
          'Planning Timeline',
          '${defaultValues['timelineMonths']} months',
          textColor,
        ),
      );
    }

    if (defaultValues.containsKey('formality')) {
      details.add(
        _buildDetailItem('Formality', defaultValues['formality'], textColor),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: details,
    );
  }

  /// Build a single detail item
  Widget _buildDetailItem(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyles.bodySmall.copyWith(
              color: Color.fromRGBO(
                textColor.r.toInt(),
                textColor.g.toInt(),
                textColor.b.toInt(),
                0.7,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyles.bodySmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
