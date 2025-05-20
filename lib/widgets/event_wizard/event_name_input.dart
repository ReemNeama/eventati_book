import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/widgets/event_wizard/field_completion_indicator.dart';

class EventNameInput extends StatelessWidget {
  final TextEditingController controller;
  final Color primaryColor;
  final bool showCompletionStatus;

  const EventNameInput({
    super.key,
    required this.controller,
    required this.primaryColor,
    this.showCompletionStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    // Get the wizard provider to check field completion status
    final wizardProvider = Provider.of<WizardProvider>(context);
    final isCompleted = wizardProvider.isFieldCompleted('eventName');

    // Update field completion status based on current text
    if (controller.text.isNotEmpty != isCompleted) {
      // Only update if there's a change to avoid unnecessary rebuilds
      WidgetsBinding.instance.addPostFrameCallback((_) {
        wizardProvider.updateFieldCompletionStatus(
          'eventName',
          controller.text.isNotEmpty,
        );
      });
    }

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Event Name',
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
                ? FieldCompletionIndicator(
                  isCompleted: controller.text.isNotEmpty,
                  tooltip:
                      controller.text.isNotEmpty
                          ? 'Event name is complete'
                          : 'Event name is required',
                )
                : null,
      ),
      onChanged: (value) {
        // Update field completion status when text changes
        wizardProvider.updateFieldCompletionStatus(
          'eventName',
          value.isNotEmpty,
        );
      },
    );
  }
}
