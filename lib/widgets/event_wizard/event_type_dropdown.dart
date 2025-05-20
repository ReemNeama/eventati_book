import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/widgets/event_wizard/field_completion_indicator.dart';

class EventTypeDropdown extends StatelessWidget {
  final String? selectedValue;
  final List<String> eventTypes;
  final Color primaryColor;
  final ValueChanged<String?> onChanged;
  final bool showCompletionStatus;

  const EventTypeDropdown({
    super.key,
    required this.selectedValue,
    required this.eventTypes,
    required this.primaryColor,
    required this.onChanged,
    this.showCompletionStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    // Get the wizard provider to check field completion status
    final wizardProvider = Provider.of<WizardProvider>(context);
    final isCompleted = wizardProvider.isFieldCompleted('eventType');

    // Update field completion status based on current selection
    if ((selectedValue != null && selectedValue!.isNotEmpty) != isCompleted) {
      // Only update if there's a change to avoid unnecessary rebuilds
      WidgetsBinding.instance.addPostFrameCallback((_) {
        wizardProvider.updateFieldCompletionStatus(
          'eventType',
          selectedValue != null && selectedValue!.isNotEmpty,
        );
      });
    }

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Event Type',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        ),
        // Add completion indicator
        suffixIcon:
            showCompletionStatus
                ? Padding(
                  padding: const EdgeInsets.only(
                    right: 32.0,
                  ), // Make room for dropdown arrow
                  child: FieldCompletionIndicator(
                    isCompleted:
                        selectedValue != null && selectedValue!.isNotEmpty,
                    tooltip:
                        selectedValue != null && selectedValue!.isNotEmpty
                            ? 'Event type is selected'
                            : 'Event type is required',
                  ),
                )
                : null,
      ),
      value: selectedValue,
      items:
          eventTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
      onChanged: (value) {
        onChanged(value);
        // Update field completion status when selection changes
        wizardProvider.updateFieldCompletionStatus(
          'eventType',
          value != null && value.isNotEmpty,
        );
      },
    );
  }
}
