import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/services/task_template_service.dart';

/// Service to connect the wizard with other planning tools
class WizardConnectionService {
  /// Connect wizard to all planning tools at once
  static void connectToAllPlanningTools(
    BuildContext context,
    Map<String, dynamic> wizardData,
  ) {
    // Connect to budget calculator
    connectToBudget(context, wizardData);

    // Connect to guest list
    connectToGuestList(context, wizardData);

    // Connect to timeline/checklist
    connectToTimeline(context, wizardData);

    debugPrint('Connected wizard to all planning tools');
  }

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

    // Create budget items based on selected services
    _createBudgetItemsFromServices(
      budgetProvider,
      selectedServices,
      guestCount,
      eventType,
      eventDuration,
      needsSetup,
      setupHours,
      needsTeardown,
      teardownHours,
    );

    // Add budget allocation recommendations
    _addBudgetRecommendations(budgetProvider, eventType, guestCount, eventDate);

    debugPrint('Connected wizard data to budget calculator');
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

    debugPrint('Connected wizard data to guest list management');
    debugPrint(
      'RSVP deadline set to $rsvpDeadline ($rsvpDaysBeforeEvent days before event)',
    );
    debugPrint('Expected guest count set to $guestCount');
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

  /// Connect wizard data to timeline/checklist
  static void connectToTimeline(
    BuildContext context,
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

      debugPrint('Connected wizard data to timeline/checklist');
      debugPrint(
        'Created ${adjustedTasks.length + specializedTasks.length} tasks for $eventType event',
      );
      debugPrint('Event complexity: $eventComplexity');
    } catch (e) {
      debugPrint('Error connecting wizard data to timeline: $e');
    }
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

    // Add tasks specific to event type
    if (eventType.toLowerCase().contains('wedding')) {
      // Wedding-specific tasks
      specializedTasks.add(
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_1',
          title: 'Create wedding website',
          description: 'Set up a wedding website to share details with guests',
          categoryId: '1', // Planning category
          dueDate: eventDate.subtract(const Duration(days: 180)),
          status: TaskStatus.notStarted,
          isImportant: true,
        ),
      );

      specializedTasks.add(
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_2',
          title: 'Schedule dress fittings',
          description: 'Book appointments for wedding dress fittings',
          categoryId: '2', // Attire category
          dueDate: eventDate.subtract(const Duration(days: 90)),
          status: TaskStatus.notStarted,
          isImportant: true,
        ),
      );

      specializedTasks.add(
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_3',
          title: 'Plan rehearsal dinner',
          description: 'Organize the rehearsal dinner before the wedding',
          categoryId: '1', // Planning category
          dueDate: eventDate.subtract(const Duration(days: 60)),
          status: TaskStatus.notStarted,
          isImportant: false,
        ),
      );
    } else if (eventType.toLowerCase().contains('business')) {
      // Business event-specific tasks
      specializedTasks.add(
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_1',
          title: 'Prepare event agenda',
          description: 'Create a detailed agenda for the business event',
          categoryId: '1', // Planning category
          dueDate: eventDate.subtract(const Duration(days: 45)),
          status: TaskStatus.notStarted,
          isImportant: true,
        ),
      );

      specializedTasks.add(
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_2',
          title: 'Arrange speaker presentations',
          description: 'Collect and review presentations from all speakers',
          categoryId: '3', // Content category
          dueDate: eventDate.subtract(const Duration(days: 14)),
          status: TaskStatus.notStarted,
          isImportant: true,
        ),
      );

      specializedTasks.add(
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_3',
          title: 'Prepare name badges',
          description: 'Create name badges for all attendees',
          categoryId: '4', // Materials category
          dueDate: eventDate.subtract(const Duration(days: 7)),
          status: TaskStatus.notStarted,
          isImportant: false,
        ),
      );
    }

    // Add tasks based on guest count
    if (guestCount > 150) {
      specializedTasks.add(
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_4',
          title: 'Arrange additional seating',
          description: 'Ensure adequate seating for large guest count',
          categoryId: '5', // Logistics category
          dueDate: eventDate.subtract(const Duration(days: 30)),
          status: TaskStatus.notStarted,
          isImportant: true,
        ),
      );
    }

    // Add tasks based on selected services
    if (selectedServices['Catering'] == true && guestCount > 100) {
      specializedTasks.add(
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_5',
          title: 'Confirm catering staff count',
          description: 'Ensure adequate staff for large guest count',
          categoryId: '6', // Vendors category
          dueDate: eventDate.subtract(const Duration(days: 21)),
          status: TaskStatus.notStarted,
          isImportant: false,
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
    // In a real implementation, we would create dependencies between tasks
    // For now, we'll just log that dependencies would be created
    debugPrint(
      'Created task dependencies for ${adjustedTasks.length + specializedTasks.length} tasks',
    );

    // Example of how dependencies might be implemented:
    // taskProvider.addDependency(taskId1, taskId2);
  }

  // Private helper methods

  /// Ensure that all necessary budget categories exist
  static void _ensureBudgetCategoriesExist(BudgetProvider budgetProvider) {
    // Define standard budget categories with icons
    final standardCategories = [
      BudgetCategory(id: '1', name: 'Venue', icon: Icons.location_on),
      BudgetCategory(id: '2', name: 'Catering', icon: Icons.restaurant),
      BudgetCategory(id: '3', name: 'Photography', icon: Icons.camera_alt),
      BudgetCategory(id: '4', name: 'Entertainment', icon: Icons.music_note),
      BudgetCategory(id: '5', name: 'Decor', icon: Icons.celebration),
      BudgetCategory(id: '6', name: 'Attire', icon: Icons.checkroom),
      BudgetCategory(
        id: '7',
        name: 'Transportation',
        icon: Icons.directions_car,
      ),
      BudgetCategory(id: '8', name: 'Stationery', icon: Icons.mail),
      BudgetCategory(id: '9', name: 'Gifts', icon: Icons.card_giftcard),
      BudgetCategory(id: '10', name: 'Miscellaneous', icon: Icons.more_horiz),
    ];

    // Check if categories exist
    // Note: BudgetProvider doesn't have an addCategory method, so we'll just log missing categories
    final existingCategories = budgetProvider.categories;
    for (final category in standardCategories) {
      if (!existingCategories.any((c) => c.id == category.id)) {
        debugPrint('Missing budget category: ${category.name}');
        // In a real implementation, we would add the category
        // budgetProvider.addCategory(category);
      }
    }
  }

  /// Create budget items based on selected services
  static void _createBudgetItemsFromServices(
    BudgetProvider budgetProvider,
    Map<String, bool> selectedServices,
    int guestCount,
    String eventType,
    int eventDuration,
    bool needsSetup,
    int setupHours,
    bool needsTeardown,
    int teardownHours,
  ) {
    // Create budget items based on selected services
    if (selectedServices['Venue'] == true) {
      final cost = _calculateEstimatedCost(
        'Venue',
        guestCount,
        eventType,
        eventDuration,
      );

      budgetProvider.addBudgetItem(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '1', // Venue category
          description: 'Venue rental',
          estimatedCost: cost,
          isPaid: false,
          notes: 'Based on $guestCount guests and $eventDuration day(s)',
        ),
      );

      // Add setup and teardown costs for business events
      if (eventType.toLowerCase().contains('business')) {
        if (needsSetup) {
          budgetProvider.addBudgetItem(
            BudgetItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              categoryId: '1', // Venue category
              description: 'Venue setup',
              estimatedCost: setupHours * 100, // $100 per hour
              isPaid: false,
              notes: 'Setup costs for $setupHours hour(s)',
            ),
          );
        }

        if (needsTeardown) {
          budgetProvider.addBudgetItem(
            BudgetItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              categoryId: '1', // Venue category
              description: 'Venue teardown',
              estimatedCost: teardownHours * 100, // $100 per hour
              isPaid: false,
              notes: 'Teardown costs for $teardownHours hour(s)',
            ),
          );
        }
      }
    }

    if (selectedServices['Catering'] == true) {
      final cost = _calculateEstimatedCost(
        'Catering',
        guestCount,
        eventType,
        eventDuration,
      );

      budgetProvider.addBudgetItem(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '2', // Catering category
          description: 'Catering service',
          estimatedCost: cost,
          isPaid: false,
          notes: 'Based on $guestCount guests',
        ),
      );

      // Add beverage costs
      budgetProvider.addBudgetItem(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '2', // Catering category
          description: 'Beverages',
          estimatedCost: guestCount * 15, // $15 per guest
          isPaid: false,
          notes: 'Estimated beverage costs',
        ),
      );
    }

    if (selectedServices['Photography'] == true ||
        selectedServices['Photography/Videography'] == true) {
      final cost = _calculateEstimatedCost(
        'Photography',
        guestCount,
        eventType,
        eventDuration,
      );

      budgetProvider.addBudgetItem(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '3', // Photography category
          description: 'Photographer',
          estimatedCost: cost,
          isPaid: false,
          notes: 'Photography services for $eventDuration day(s)',
        ),
      );
    }

    if (selectedServices['Videography'] == true ||
        selectedServices['Photography/Videography'] == true) {
      budgetProvider.addBudgetItem(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '3', // Photography category
          description: 'Videographer',
          estimatedCost: 2500.0 * eventDuration, // $2500 per day
          isPaid: false,
          notes: 'Videography services for $eventDuration day(s)',
        ),
      );
    }

    if (selectedServices['Entertainment'] == true) {
      budgetProvider.addBudgetItem(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '4', // Entertainment category
          description: 'Entertainment',
          estimatedCost: 1500, // Base cost
          isPaid: false,
          notes: 'Entertainment services',
        ),
      );
    }

    if (selectedServices['Decor'] == true) {
      budgetProvider.addBudgetItem(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '5', // Decor category
          description: 'Decorations',
          estimatedCost: 500 + (guestCount * 5), // Base cost + per guest
          isPaid: false,
          notes: 'Decorations for venue and tables',
        ),
      );
    }

    if (selectedServices['Transportation'] == true) {
      budgetProvider.addBudgetItem(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '7', // Transportation category
          description: 'Guest transportation',
          estimatedCost: guestCount * 20, // $20 per guest
          isPaid: false,
          notes: 'Transportation for guests',
        ),
      );
    }

    // Add more items based on other selected services
    if (selectedServices['Flowers'] == true) {
      budgetProvider.addBudgetItem(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '5', // Decor category
          description: 'Flowers',
          estimatedCost: 800, // Base cost
          isPaid: false,
          notes: 'Floral arrangements',
        ),
      );
    }

    if (selectedServices['Wedding Planner'] == true ||
        selectedServices['Event Staff'] == true) {
      budgetProvider.addBudgetItem(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '10', // Miscellaneous category
          description: 'Event planner',
          estimatedCost: 2000, // Base cost
          isPaid: false,
          notes: 'Event planning services',
        ),
      );
    }
  }

  /// Calculate estimated cost based on service type, guest count, and event type
  static double _calculateEstimatedCost(
    String serviceType,
    int guestCount,
    String eventType,
    int eventDuration,
  ) {
    switch (serviceType) {
      case 'Venue':
        // Different base costs and per-guest costs based on event type
        if (eventType.toLowerCase().contains('wedding')) {
          return 5000.0 + (guestCount * 15.0) * eventDuration;
        } else if (eventType.toLowerCase().contains('business')) {
          return 3000.0 + (guestCount * 10.0) * eventDuration;
        } else {
          return 2000.0 + (guestCount * 8.0) * eventDuration;
        }

      case 'Catering':
        // Different per-guest costs based on event type
        if (eventType.toLowerCase().contains('wedding')) {
          return guestCount * 75.0 * eventDuration; // $75 per guest
        } else if (eventType.toLowerCase().contains('business')) {
          return guestCount * 50.0 * eventDuration; // $50 per guest
        } else {
          return guestCount * 40.0 * eventDuration; // $40 per guest
        }

      case 'Photography':
        // Different base costs based on event type and duration
        if (eventType.toLowerCase().contains('wedding')) {
          return 3000.0 * eventDuration; // $3000 per day
        } else if (eventType.toLowerCase().contains('business')) {
          return 2000.0 * eventDuration; // $2000 per day
        } else {
          return 1500.0 * eventDuration; // $1500 per day
        }

      default:
        return 1000.0; // Default cost
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

  static void _createGuestGroupsFromEventType(
    GuestListProvider guestListProvider,
    String eventType,
  ) {
    // Create guest groups based on event type
    if (eventType.toLowerCase().contains('wedding')) {
      // Wedding-specific groups
      guestListProvider.addGroup(
        GuestGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Bride\'s Family',
          description: 'Family members of the bride',
        ),
      );

      guestListProvider.addGroup(
        GuestGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Groom\'s Family',
          description: 'Family members of the groom',
        ),
      );

      guestListProvider.addGroup(
        GuestGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Bride\'s Friends',
          description: 'Friends of the bride',
        ),
      );

      guestListProvider.addGroup(
        GuestGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Groom\'s Friends',
          description: 'Friends of the groom',
        ),
      );

      guestListProvider.addGroup(
        GuestGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Colleagues',
          description: 'Work colleagues',
        ),
      );

      guestListProvider.addGroup(
        GuestGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Wedding Party',
          description: 'Bridesmaids, groomsmen, etc.',
        ),
      );
    } else if (eventType.toLowerCase().contains('business')) {
      // Business event-specific groups
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
          name: 'Team Members',
          description: 'Internal team members',
        ),
      );

      guestListProvider.addGroup(
        GuestGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Executives',
          description: 'Executive leadership',
        ),
      );

      guestListProvider.addGroup(
        GuestGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Speakers',
          description: 'Event speakers and presenters',
        ),
      );

      guestListProvider.addGroup(
        GuestGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Media',
          description: 'Press and media representatives',
        ),
      );
    } else if (eventType.toLowerCase().contains('celebration') ||
        eventType.toLowerCase().contains('party')) {
      // Celebration/party-specific groups
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
          name: 'Close Friends',
          description: 'Close friends',
        ),
      );

      guestListProvider.addGroup(
        GuestGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Friends',
          description: 'Other friends',
        ),
      );

      guestListProvider.addGroup(
        GuestGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Colleagues',
          description: 'Work colleagues',
        ),
      );

      guestListProvider.addGroup(
        GuestGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Neighbors',
          description: 'Neighbors and community members',
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

      guestListProvider.addGroup(
        GuestGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Other Guests',
          description: 'Other invited guests',
        ),
      );
    }

    // Add VIP group for all event types
    guestListProvider.addGroup(
      GuestGroup(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'VIP',
        description: 'Very important guests',
      ),
    );
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
