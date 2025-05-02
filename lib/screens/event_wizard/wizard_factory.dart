import 'package:flutter/material.dart';
import 'package:eventati_book/models/event_template.dart';
import 'package:eventati_book/screens/event_wizard/event_wizard_screen.dart';
import 'package:eventati_book/screens/event_planning/timeline/timeline_screen.dart';
import 'package:eventati_book/services/wizard_connection_service.dart';

/// Factory class to create appropriate wizard and checklist screens
class WizardFactory {
  /// Create a wizard screen for the given template
  static Widget createWizardScreen(BuildContext context, String templateId) {
    final template = EventTemplates.findById(templateId);

    if (template == null) {
      return Center(child: Text('Template not found: $templateId'));
    }

    return EventWizardScreen(
      template: template,
      onComplete: (data) {
        // Connect wizard data to planning tools
        try {
          WizardConnectionService.connectToBudget(context, data);
          WizardConnectionService.connectToGuestList(context, data);
          WizardConnectionService.connectToTimeline(context, data);
          WizardConnectionService.connectToServiceScreens(context, data);
        } catch (e) {
          // Log the error but continue with navigation
          debugPrint('Error connecting wizard data to planning tools: $e');
        }

        // Navigate to the appropriate checklist screen
        final checklistScreen = createChecklistScreen(templateId, data);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => checklistScreen),
        );
      },
    );
  }

  /// Create a checklist screen for the given template and data
  static Widget createChecklistScreen(
    String templateId,
    Map<String, dynamic> data,
  ) {
    // Generate a unique event ID based on the event name and date
    final String eventId =
        '${data['eventName']}_${DateTime.now().millisecondsSinceEpoch}';
    final String eventName = data['eventName'];

    // Initialize the task provider with template tasks based on event type
    // This will be done in the WizardConnectionService

    // Return the unified timeline screen which includes the checklist functionality
    return TimelineScreen(eventId: eventId, eventName: eventName);
  }
}
