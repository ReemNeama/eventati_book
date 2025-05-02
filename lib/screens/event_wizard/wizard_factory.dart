import 'package:flutter/material.dart';
import 'package:eventati_book/models/event_template.dart';
import 'package:eventati_book/screens/event_wizard/event_wizard_screen.dart';
import 'package:eventati_book/screens/weddings/wedding_checklist_screen.dart';
import 'package:eventati_book/screens/businesses/business_event_checklist_screen.dart';
import 'package:eventati_book/screens/celebrations/celebration_checklist_screen.dart';

/// Factory class to create appropriate wizard and checklist screens
class WizardFactory {
  /// Create a wizard screen for the given template
  static Widget createWizardScreen(BuildContext context, String templateId) {
    final template = EventTemplates.findById(templateId);
    
    if (template == null) {
      return Center(
        child: Text('Template not found: $templateId'),
      );
    }
    
    return EventWizardScreen(
      template: template,
      onComplete: (data) {
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
  static Widget createChecklistScreen(String templateId, Map<String, dynamic> data) {
    switch (templateId) {
      case 'wedding':
        return WeddingChecklistScreen(
          eventName: data['eventName'],
          eventType: data['eventType'],
          eventDate: data['eventDate'],
          guestCount: data['guestCount'],
          selectedServices: Map<String, bool>.from(data['selectedServices']),
        );
        
      case 'business':
        return BusinessEventChecklistScreen(
          eventName: data['eventName'],
          eventType: data['eventType'],
          eventDate: data['eventDate'],
          guestCount: data['guestCount'],
          selectedServices: Map<String, bool>.from(data['selectedServices']),
        );
        
      case 'celebration':
        return CelebrationChecklistScreen(
          eventName: data['eventName'],
          eventType: data['eventType'],
          eventDate: data['eventDate'],
          guestCount: data['guestCount'],
          selectedServices: Map<String, bool>.from(data['selectedServices']),
        );
        
      default:
        throw Exception('Unknown template ID: $templateId');
    }
  }
}
