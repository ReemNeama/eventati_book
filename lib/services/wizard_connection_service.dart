import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/budget_item.dart';
import 'package:eventati_book/models/guest.dart';
import 'package:eventati_book/providers/budget_provider.dart';
import 'package:eventati_book/providers/guest_list_provider.dart';
import 'package:eventati_book/providers/task_provider.dart';
import 'package:eventati_book/providers/service_recommendation_provider.dart';
import 'package:eventati_book/services/task_template_service.dart';

/// Service to connect the wizard with other planning tools
class WizardConnectionService {
  /// Connect wizard data to budget calculator
  static void connectToBudget(
    BuildContext context,
    Map<String, dynamic> wizardData,
  ) {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);

    // Generate budget items based on selected services
    final selectedServices = Map<String, bool>.from(
      wizardData['selectedServices'],
    );
    final guestCount = wizardData['guestCount'] as int;

    // Create budget items based on selected services
    _createBudgetItemsFromServices(
      budgetProvider,
      selectedServices,
      guestCount,
    );
  }

  /// Connect wizard data to guest list
  static void connectToGuestList(
    BuildContext context,
    Map<String, dynamic> wizardData,
  ) {
    final guestListProvider = Provider.of<GuestListProvider>(
      context,
      listen: false,
    );

    // Set RSVP deadline based on event date
    final eventDate = wizardData['eventDate'] as DateTime;
    final rsvpDeadline = eventDate.subtract(
      const Duration(days: 30),
    ); // 30 days before event

    guestListProvider.setRsvpDeadline(rsvpDeadline);

    // Create guest groups based on event type
    final eventType = wizardData['eventType'] as String;
    _createGuestGroupsFromEventType(guestListProvider, eventType);
  }

  /// Connect wizard data to timeline/checklist
  static void connectToTimeline(
    BuildContext context,
    Map<String, dynamic> wizardData,
  ) {
    try {
      // Generate a unique event ID based on the event name and date
      final String eventId =
          '${wizardData['eventName']}_${DateTime.now().millisecondsSinceEpoch}';

      // Get event details
      final String eventType = wizardData['eventType'] as String;
      final DateTime eventDate = wizardData['eventDate'] as DateTime;
      final Map<String, bool> selectedServices = Map<String, bool>.from(
        wizardData['selectedServices'],
      );

      // Create task provider if it doesn't exist yet
      TaskProvider? taskProvider;
      try {
        taskProvider = Provider.of<TaskProvider>(context, listen: false);
      } catch (e) {
        // Provider not found, will be created by the TimelineScreen
        debugPrint(
          'Task provider not found, will be created by the TimelineScreen',
        );
        return;
      }

      // Generate tasks from templates based on event type
      final tasks = TaskTemplateService.createTasksFromTemplates(
        eventId,
        eventType,
        eventDate,
        selectedServices,
      );

      // Add tasks to the provider
      taskProvider.addTasks(tasks);

      debugPrint('Added ${tasks.length} template tasks for $eventType event');
    } catch (e) {
      debugPrint('Error connecting wizard data to timeline: $e');
    }
  }

  // Private helper methods
  static void _createBudgetItemsFromServices(
    BudgetProvider budgetProvider,
    Map<String, bool> selectedServices,
    int guestCount,
  ) {
    // Create budget items based on selected services
    if (selectedServices['venue'] == true) {
      budgetProvider.addBudgetItem(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '1', // Venue category
          description: 'Venue rental',
          estimatedCost: 5000 + (guestCount * 10), // Base cost + per guest
          isPaid: false,
        ),
      );
    }

    if (selectedServices['catering'] == true) {
      budgetProvider.addBudgetItem(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '2', // Catering category
          description: 'Catering service',
          estimatedCost: 1500 + (guestCount * 50), // Base cost + per guest
          isPaid: false,
        ),
      );
    }

    if (selectedServices['photography'] == true) {
      budgetProvider.addBudgetItem(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '3', // Photography category
          description: 'Photographer',
          estimatedCost: 2000, // Fixed cost
          isPaid: false,
        ),
      );
    }

    // Add more items based on other selected services
  }

  static void _createGuestGroupsFromEventType(
    GuestListProvider guestListProvider,
    String eventType,
  ) {
    // Create guest groups based on event type
    if (eventType.toLowerCase().contains('wedding')) {
      guestListProvider.addGroup(
        GuestGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Family',
          description: 'Close family members',
        ),
      );

      guestListProvider.addGroup(
        GuestGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Friends',
          description: 'Close friends',
        ),
      );

      guestListProvider.addGroup(
        GuestGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Colleagues',
          description: 'Work colleagues',
        ),
      );
    } else if (eventType.toLowerCase().contains('business')) {
      guestListProvider.addGroup(
        GuestGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Clients',
          description: 'Business clients',
        ),
      );

      guestListProvider.addGroup(
        GuestGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Partners',
          description: 'Business partners',
        ),
      );

      guestListProvider.addGroup(
        GuestGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Team',
          description: 'Team members',
        ),
      );
    } else {
      // Default groups for other event types
      guestListProvider.addGroup(
        GuestGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Family',
          description: 'Family members',
        ),
      );

      guestListProvider.addGroup(
        GuestGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Friends',
          description: 'Friends',
        ),
      );
    }
  }

  /// Connect wizard data to service screens for recommended vendors
  static void connectToServiceScreens(
    BuildContext context,
    Map<String, dynamic> wizardData,
  ) {
    try {
      // Get the service recommendation provider
      final serviceRecommendationProvider =
          Provider.of<ServiceRecommendationProvider>(context, listen: false);

      // Set the wizard data in the provider
      serviceRecommendationProvider.setWizardData(wizardData);

      debugPrint(
        'Connected wizard data to service screens for recommendations',
      );
    } catch (e) {
      debugPrint('Error connecting wizard data to service screens: $e');
    }
  }
}
