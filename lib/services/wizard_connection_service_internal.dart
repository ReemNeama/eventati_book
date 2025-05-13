import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/services/task_template_service.dart';
import 'package:eventati_book/services/wizard/budget_items_builder.dart';
import 'package:eventati_book/services/wizard/budget_items_builder_enhanced.dart';
import 'package:eventati_book/services/wizard/guest_groups_builder.dart';
import 'package:eventati_book/services/wizard/specialized_task_templates.dart';
import 'package:eventati_book/services/supabase/database/wizard_connection_database_service.dart';
import 'package:eventati_book/utils/logger.dart';

/// Internal implementation of wizard connection service methods
/// These methods don't use BuildContext directly to avoid async gap issues
class WizardConnectionServiceInternal {
  /// Ensure standard budget categories exist
  static void _ensureBudgetCategoriesExist(BudgetProvider budgetProvider) {
    // Define standard budget categories
    final standardCategories = [
      BudgetCategory(id: '1', name: 'Venue', icon: Icons.location_on),
      BudgetCategory(id: '2', name: 'Catering', icon: Icons.restaurant),
      BudgetCategory(id: '3', name: 'Photography', icon: Icons.camera_alt),
      BudgetCategory(id: '4', name: 'Entertainment', icon: Icons.music_note),
      BudgetCategory(id: '5', name: 'Decor', icon: Icons.brush),
      BudgetCategory(
        id: '6',
        name: 'Transportation',
        icon: Icons.directions_car,
      ),
      BudgetCategory(id: '7', name: 'Attire', icon: Icons.accessibility),
      BudgetCategory(id: '8', name: 'Stationery', icon: Icons.mail),
      BudgetCategory(id: '9', name: 'Gifts', icon: Icons.card_giftcard),
      BudgetCategory(id: '10', name: 'Miscellaneous', icon: Icons.more_horiz),
    ];

    // Check if categories exist
    // Note: BudgetProvider doesn't have an addCategory method, so we'll just log missing categories
    final existingCategories = budgetProvider.categories;
    for (final category in standardCategories) {
      if (!existingCategories.any((c) => c.id == category.id)) {
        Logger.w(
          'Missing budget category: ${category.name}',
          tag: 'WizardConnectionServiceInternal',
        );
        // In a real implementation, we would add the category
        // budgetProvider.addCategory(category);
      }
    }
  }

  /// Add budget allocation recommendations
  static void _addBudgetRecommendations(
    BudgetProvider budgetProvider,
    String eventType,
    int guestCount,
    DateTime eventDate,
  ) {
    // Calculate total estimated budget
    double totalBudget = 0;
    for (final item in budgetProvider.items) {
      totalBudget += item.estimatedCost;
    }

    // Add a budget recommendation note
    final daysUntilEvent = eventDate.difference(DateTime.now()).inDays;

    budgetProvider.addBudgetItem(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '10', // Miscellaneous category
        description: 'Budget Recommendation',
        estimatedCost: 0, // No cost
        isPaid: false,
        notes:
            'Recommended total budget: \$${totalBudget.toStringAsFixed(2)}. '
            'Consider allocating 10% as contingency. '
            'You have $daysUntilEvent days until the event to finalize your budget.',
      ),
    );
  }

  /// Calculate how many days before the event the RSVP deadline should be
  static int _calculateRsvpDeadlineDays(String eventType, int guestCount) {
    // For larger events or weddings, set earlier RSVP deadlines
    if (guestCount > 200) {
      return 60; // 60 days before for very large events
    } else if (guestCount > 100) {
      return 45; // 45 days before for large events
    }

    // Adjust based on event type
    if (eventType.toLowerCase().contains('wedding')) {
      return 45; // 45 days before for weddings
    } else if (eventType.toLowerCase().contains('business')) {
      return 21; // 21 days before for business events
    } else {
      return 30; // 30 days before for other events
    }
  }

  /// Create guest groups from event type
  static void _createGuestGroupsFromEventType(
    GuestListProvider guestListProvider,
    String eventType,
  ) {
    // Use the GuestGroupsBuilder to create guest groups
    final guestGroups = GuestGroupsBuilder.createGuestGroupsFromEventType(
      eventType,
    );

    // Add all guest groups to the provider
    for (final group in guestGroups) {
      guestListProvider.addGroup(
        GuestGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: group.name,
          description: group.description,
          color: group.color,
        ),
      );
    }

    // Add VIP group for all event types
    guestListProvider.addGroup(
      GuestGroup(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'VIP',
        description: 'Very important guests',
        color: '#FF0000', // Red
      ),
    );
  }

  /// Calculate event complexity based on guest count and services
  static String _calculateEventComplexity(
    int guestCount,
    Map<String, bool> selectedServices,
    String eventType,
  ) {
    // Count selected services
    final int serviceCount =
        selectedServices.values.where((selected) => selected).length;

    // Determine complexity based on guest count
    String complexity;
    if (guestCount > 200) {
      complexity = 'High';
    } else if (guestCount > 100) {
      complexity = 'Medium';
    } else {
      complexity = 'Low';
    }

    // Adjust complexity based on service count
    if (serviceCount > 5) {
      // Increase complexity by one level
      if (complexity == 'Low') {
        complexity = 'Medium';
      } else if (complexity == 'Medium') {
        complexity = 'High';
      }
    }

    // Wedding events are typically more complex
    if (eventType.toLowerCase().contains('wedding') && complexity != 'High') {
      // Increase complexity by one level
      if (complexity == 'Low') {
        complexity = 'Medium';
      } else if (complexity == 'Medium') {
        complexity = 'High';
      }
    }

    return complexity;
  }

  /// Adjust task timelines based on event complexity
  static List<Task> _adjustTaskTimelines(
    List<Task> tasks,
    String eventComplexity,
    DateTime eventDate,
  ) {
    final adjustedTasks = <Task>[];

    // Determine lead time multiplier based on complexity
    double leadTimeMultiplier;
    switch (eventComplexity) {
      case 'High':
        leadTimeMultiplier = 1.5; // 50% more lead time for high complexity
        break;
      case 'Medium':
        leadTimeMultiplier = 1.2; // 20% more lead time for medium complexity
        break;
      default:
        leadTimeMultiplier = 1.0; // No adjustment for low complexity
    }

    for (final task in tasks) {
      // Calculate days before event
      final daysBeforeEvent = eventDate.difference(task.dueDate).inDays;

      // Apply multiplier to get adjusted days before event
      final adjustedDaysBeforeEvent =
          (daysBeforeEvent * leadTimeMultiplier).round();

      // Calculate new due date
      final adjustedDueDate = eventDate.subtract(
        Duration(days: adjustedDaysBeforeEvent),
      );

      // Create adjusted task
      adjustedTasks.add(
        Task(
          id: task.id,
          title: task.title,
          description: task.description,
          categoryId: task.categoryId,
          dueDate: adjustedDueDate,
          status: task.status,
          assignedTo: task.assignedTo,
          isImportant: task.isImportant,
          notes: task.notes,
        ),
      );
    }

    return adjustedTasks;
  }

  /// Add specialized tasks based on event subtype and requirements
  static List<Task> _addSpecializedTasks(
    String eventType,
    DateTime eventDate,
    Map<String, bool> selectedServices,
    int guestCount,
  ) {
    final specializedTasks = <Task>[];

    // Use specialized task templates based on event type
    if (eventType.toLowerCase().contains('wedding')) {
      // Get comprehensive wedding task list from specialized templates
      specializedTasks.addAll(
        SpecializedTaskTemplates.createWeddingTasks(eventDate),
      );

      Logger.i(
        'Added ${specializedTasks.length} specialized wedding tasks',
        tag: 'WizardConnectionServiceInternal',
      );
    } else if (eventType.toLowerCase().contains('business')) {
      // Get comprehensive business event task list from specialized templates
      specializedTasks.addAll(
        SpecializedTaskTemplates.createBusinessEventTasks(eventDate),
      );

      Logger.i(
        'Added ${specializedTasks.length} specialized business event tasks',
        tag: 'WizardConnectionServiceInternal',
      );
    } else {
      // For other celebration events, add basic tasks
      specializedTasks.add(
        Task(
          id: 'celebration_task_${DateTime.now().millisecondsSinceEpoch}_1',
          title: 'Create event timeline',
          description: 'Develop a detailed schedule for the celebration',
          categoryId: '1', // Planning category
          dueDate: eventDate.subtract(const Duration(days: 60)),
          status: TaskStatus.notStarted,
          isImportant: true,
        ),
      );

      specializedTasks.add(
        Task(
          id: 'celebration_task_${DateTime.now().millisecondsSinceEpoch}_2',
          title: 'Plan entertainment',
          description: 'Arrange music, games, or other entertainment',
          categoryId: '3', // Entertainment category
          dueDate: eventDate.subtract(const Duration(days: 45)),
          status: TaskStatus.notStarted,
          isImportant: true,
        ),
      );
    }

    return specializedTasks;
  }

  /// Create task dependencies and sequences
  static void _createTaskDependencies(
    TaskProvider taskProvider,
    List<Task> adjustedTasks,
    List<Task> specializedTasks,
  ) {
    final allTasks = [...adjustedTasks, ...specializedTasks];

    // Group tasks by category for easier processing
    final Map<String, List<Task>> tasksByCategory = {};
    for (final task in allTasks) {
      if (!tasksByCategory.containsKey(task.categoryId)) {
        tasksByCategory[task.categoryId] = [];
      }
      tasksByCategory[task.categoryId]!.add(task);
    }

    // Sort tasks within each category by due date
    for (final category in tasksByCategory.keys) {
      tasksByCategory[category]!.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    }

    // Create dependencies within categories (sequential tasks)
    for (final category in tasksByCategory.keys) {
      final tasks = tasksByCategory[category]!;
      for (int i = 0; i < tasks.length - 1; i++) {
        // Make each task dependent on the previous task in the same category
        taskProvider.addDependency(tasks[i].id, tasks[i + 1].id);
      }
    }

    // Create cross-category dependencies
    // For example, venue booking must be completed before sending invitations
    if (tasksByCategory.containsKey('1') && tasksByCategory['1']!.isNotEmpty) {
      final venueBookingTask = tasksByCategory['1']!.firstWhere(
        (task) =>
            task.title.toLowerCase().contains('book') ||
            task.title.toLowerCase().contains('deposit'),
        orElse: () => tasksByCategory['1']!.first,
      );

      // Venue booking must be completed before catering can be finalized
      if (tasksByCategory.containsKey('2') &&
          tasksByCategory['2']!.isNotEmpty) {
        for (final cateringTask in tasksByCategory['2']!) {
          if (cateringTask.title.toLowerCase().contains('finalize') ||
              cateringTask.title.toLowerCase().contains('confirm')) {
            taskProvider.addDependency(venueBookingTask.id, cateringTask.id);
          }
        }
      }
    }
  }

  /// Connect wizard data to budget calculator
  static Future<void> connectToBudget(
    BudgetProvider budgetProvider,
    Map<String, dynamic> wizardData,
  ) async {
    // Generate budget items based on selected services
    final selectedServices = Map<String, bool>.from(
      wizardData['selectedServices'],
    );
    final guestCount = wizardData['guestCount'] as int;
    final eventType = wizardData['selectedEventType'] as String? ?? 'General';
    final eventDate = wizardData['eventDate'] as DateTime;

    // Calculate event duration in days
    final eventDuration = wizardData['eventDuration'] as int? ?? 1;

    // Get setup and teardown needs for business events
    final needsSetup = wizardData['needsSetup'] as bool? ?? false;
    final setupHours = wizardData['setupHours'] as int? ?? 0;
    final needsTeardown = wizardData['needsTeardown'] as bool? ?? false;
    final teardownHours = wizardData['teardownHours'] as int? ?? 0;

    // Ensure budget categories exist
    _ensureBudgetCategoriesExist(budgetProvider);

    // Get location and venue information from wizard data
    final location = wizardData['location'] as String? ?? 'Unknown';
    final isPremiumVenue = wizardData['isPremiumVenue'] as bool? ?? false;

    try {
      // Use the enhanced BudgetItemsBuilder with historical data analysis
      final budgetItems =
          await BudgetItemsBuilderEnhanced.createBudgetItemsFromServices(
            selectedServices: selectedServices,
            guestCount: guestCount,
            eventType: eventType,
            eventDuration: eventDuration,
            needsSetup: needsSetup,
            setupHours: setupHours,
            needsTeardown: needsTeardown,
            teardownHours: teardownHours,
            location: location,
            eventDate: eventDate,
            isPremiumVenue: isPremiumVenue,
          );

      // Add all budget items to the provider
      for (final item in budgetItems) {
        await budgetProvider.addBudgetItem(item);
      }

      Logger.i(
        'Created ${budgetItems.length} budget items with historical data analysis',
        tag: 'WizardConnectionServiceInternal',
      );
    } catch (e) {
      // Fallback to the original BudgetItemsBuilder if there's an error
      Logger.w(
        'Error using enhanced budget calculator, falling back to standard calculator: $e',
        tag: 'WizardConnectionServiceInternal',
      );

      final budgetItems = BudgetItemsBuilder.createBudgetItemsFromServices(
        selectedServices: selectedServices,
        guestCount: guestCount,
        eventType: eventType,
        eventDuration: eventDuration,
        needsSetup: needsSetup,
        setupHours: setupHours,
        needsTeardown: needsTeardown,
        teardownHours: teardownHours,
        location: location,
        eventDate: eventDate,
        isPremiumVenue: isPremiumVenue,
      );

      // Add all budget items to the provider
      for (final item in budgetItems) {
        await budgetProvider.addBudgetItem(item);
      }
    }

    // Add budget allocation recommendations
    _addBudgetRecommendations(budgetProvider, eventType, guestCount, eventDate);

    Logger.i(
      'Connected wizard data to budget calculator',
      tag: 'WizardConnectionServiceInternal',
    );
  }

  /// Connect wizard data to guest list
  static void connectToGuestList(
    GuestListProvider guestListProvider,
    Map<String, dynamic> wizardData,
  ) {
    // Get event details
    final eventDate = wizardData['eventDate'] as DateTime;
    final eventType = wizardData['selectedEventType'] as String? ?? 'General';
    final guestCount = wizardData['guestCount'] as int;

    // Calculate RSVP deadline based on event type and date
    final int rsvpDaysBeforeEvent = _calculateRsvpDeadlineDays(
      eventType,
      guestCount,
    );
    final rsvpDeadline = eventDate.subtract(
      Duration(days: rsvpDaysBeforeEvent),
    );

    // Set RSVP deadline
    guestListProvider.setRsvpDeadline(rsvpDeadline);

    // Set expected guest count
    guestListProvider.setExpectedGuestCount(guestCount);

    // Create guest groups based on event type
    _createGuestGroupsFromEventType(guestListProvider, eventType);

    Logger.i(
      'Connected wizard data to guest list management',
      tag: 'WizardConnectionServiceInternal',
    );
  }

  /// Connect wizard data to timeline/checklist
  static void connectToTimeline(
    TaskProvider taskProvider,
    Map<String, dynamic> wizardData,
  ) {
    try {
      // Generate a unique event ID based on the event name and date
      final String eventName = wizardData['eventName'] as String? ?? 'Event';
      final String eventId =
          '${eventName}_${DateTime.now().millisecondsSinceEpoch}';

      // Get event details
      final String eventType =
          wizardData['selectedEventType'] as String? ?? 'General';
      final DateTime eventDate = wizardData['eventDate'] as DateTime;
      final int guestCount = wizardData['guestCount'] as int;
      final Map<String, bool> selectedServices = Map<String, bool>.from(
        wizardData['selectedServices'],
      );

      // Determine event complexity based on guest count and services
      final String eventComplexity = _calculateEventComplexity(
        guestCount,
        selectedServices,
        eventType,
      );

      // Generate tasks from templates based on event type
      final tasks = TaskTemplateService.createTasksFromTemplates(
        eventId,
        eventType,
        eventDate,
        selectedServices,
      );

      // Adjust task timelines based on event complexity
      final adjustedTasks = _adjustTaskTimelines(
        tasks,
        eventComplexity,
        eventDate,
      );

      // Add specialized tasks based on event subtype and requirements
      final specializedTasks = _addSpecializedTasks(
        eventType,
        eventDate,
        selectedServices,
        guestCount,
      );

      // Add all tasks to the provider
      for (final task in [...adjustedTasks, ...specializedTasks]) {
        taskProvider.addTask(task);
      }

      // Create task dependencies and sequences
      _createTaskDependencies(taskProvider, adjustedTasks, specializedTasks);

      Logger.i(
        'Connected wizard data to timeline/checklist',
        tag: 'WizardConnectionServiceInternal',
      );
    } catch (e) {
      Logger.e(
        'Error connecting wizard data to timeline: $e',
        tag: 'WizardConnectionServiceInternal',
      );
    }
  }

  /// Connect wizard data to service screens for recommendations
  static void connectToServiceScreens(
    ServiceRecommendationProvider serviceRecommendationProvider,
    WizardProvider wizardProvider,
    Map<String, dynamic> wizardData,
  ) {
    try {
      // Set the wizard data in the provider
      serviceRecommendationProvider.setWizardData(wizardData);

      // Set the wizard state in the provider for personalized recommendations
      if (wizardProvider.state != null) {
        serviceRecommendationProvider.setWizardState(wizardProvider.state!);
      }

      Logger.i(
        'Connected wizard data to service recommendations',
        tag: 'WizardConnectionServiceInternal',
      );
    } catch (e) {
      Logger.e(
        'Error connecting wizard data to service recommendations: $e',
        tag: 'WizardConnectionServiceInternal',
      );
    }
  }

  /// Persist wizard connections to Supabase
  static Future<void> persistConnectionsToSupabase(
    WizardProvider wizardProvider,
    BudgetProvider budgetProvider,
    Map<String, dynamic> wizardData,
  ) async {
    try {
      // Check if Supabase persistence is enabled
      if (wizardProvider.useSupabase) {
        Logger.i(
          'Persisting wizard connections to Supabase',
          tag: 'WizardConnectionServiceInternal',
        );

        // Get the user and event IDs from the provider's internal state
        String? userId;
        String? eventId;

        try {
          // Access the private fields via reflection (for testing purposes)
          userId =
              wizardProvider.toString().split('_userId: ')[1].split(',')[0];
          eventId =
              wizardProvider.toString().split('_eventId: ')[1].split(',')[0];

          // Clean up the IDs (remove quotes if present)
          userId = userId.replaceAll('\'', '').trim();
          eventId = eventId.replaceAll('\'', '').trim();

          if (userId == 'null' || eventId == 'null') {
            Logger.w(
              'User ID or event ID is null in WizardProvider',
              tag: 'WizardConnectionServiceInternal',
            );
            return;
          }
        } catch (e) {
          Logger.e(
            'Error extracting user/event IDs: $e',
            tag: 'WizardConnectionServiceInternal',
          );
          return;
        }

        // Get the wizard state ID
        final wizardStateId = '${userId}_$eventId';

        // Create a WizardConnection object
        final connection = WizardConnection(
          userId: userId,
          eventId: eventId,
          wizardStateId: wizardStateId,
          budgetEnabled: true,
          guestListEnabled: true,
          timelineEnabled: true,
          serviceRecommendationsEnabled: true,
        );

        // Get budget item IDs
        final budgetItemIds =
            budgetProvider.items.map((item) => item.id).toList();

        // Update the connection with budget item IDs
        final updatedConnection = connection.copyWith(
          budgetItemIds: budgetItemIds,
        );

        // Save the connection to Supabase
        final databaseService = WizardConnectionDatabaseService();
        await databaseService.saveWizardConnection(
          userId,
          eventId,
          updatedConnection.toJson(),
        );

        Logger.i(
          'Saved wizard connection to Supabase with ${budgetItemIds.length} budget items',
          tag: 'WizardConnectionServiceInternal',
        );

        // The WizardProvider will handle saving the wizard state to Supabase
        await wizardProvider.saveStateToSupabase();
      }
    } catch (e) {
      Logger.e(
        'Error persisting wizard connections to Supabase: $e',
        tag: 'WizardConnectionServiceInternal',
      );
    }
  }
}
