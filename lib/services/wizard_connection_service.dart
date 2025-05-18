import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/services/planning/budget_items_builder.dart';
import 'package:eventati_book/services/planning/guest_groups_builder.dart';
import 'package:eventati_book/services/planning/specialized_task_templates.dart';
import 'package:eventati_book/services/planning/task_template_service.dart';
import 'package:eventati_book/services/wizard_connection_service_internal.dart';
import 'package:eventati_book/services/supabase/database/wizard_connection_database_service.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/logger.dart';

/// Service to connect the wizard with other planning tools
class WizardConnectionService {
  /// Connect wizard to all planning tools at once
  static Future<void> connectToAllPlanningTools(
    BuildContext context,
    Map<String, dynamic> wizardData,
  ) async {
    // Store the context for later use
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Store the theme brightness before any async operations
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Get all providers before async operations
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final guestListProvider = Provider.of<GuestListProvider>(
      context,
      listen: false,
    );
    final wizardProvider = Provider.of<WizardProvider>(context, listen: false);

    // Try to get task provider (might not be available yet)
    TaskProvider? taskProvider;
    try {
      taskProvider = Provider.of<TaskProvider>(context, listen: false);
    } catch (e) {
      // Provider not found, will be created by the TimelineScreen
      Logger.w(
        'Task provider not found, will be created by the TimelineScreen',
        tag: 'WizardConnectionService',
      );
    }

    // Try to get service recommendation provider
    ServiceRecommendationProvider? serviceRecommendationProvider;
    try {
      serviceRecommendationProvider =
          Provider.of<ServiceRecommendationProvider>(context, listen: false);
    } catch (e) {
      // Provider not found
      Logger.w(
        'ServiceRecommendationProvider not found',
        tag: 'WizardConnectionService',
      );
    }

    try {
      // Connect to budget calculator with enhanced historical data analysis
      await WizardConnectionServiceInternal.connectToBudget(
        budgetProvider,
        wizardData,
      );

      // Connect to guest list
      WizardConnectionServiceInternal.connectToGuestList(
        guestListProvider,
        wizardData,
      );

      // Connect to timeline/checklist if task provider is available
      if (taskProvider != null) {
        WizardConnectionServiceInternal.connectToTimeline(
          taskProvider,
          wizardData,
        );
      }

      // Connect to service screens for recommendations if provider is available
      if (serviceRecommendationProvider != null) {
        WizardConnectionServiceInternal.connectToServiceScreens(
          serviceRecommendationProvider,
          wizardProvider,
          wizardData,
        );
      }

      // Persist connections to Supabase if user and event IDs are available
      await WizardConnectionServiceInternal.persistConnectionsToSupabase(
        wizardProvider,
        budgetProvider,
        wizardData,
      );

      // Show success message after async operations complete
      // We'll use the stored scaffoldMessenger which doesn't depend on context
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text(
            'Wizard data connected to all planning tools successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor:
              isDarkMode ? AppColorsDark.success : AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );

      Logger.i(
        'Connected wizard to all planning tools',
        tag: 'WizardConnectionService',
      );
    } catch (e) {
      // Show error message if any connection fails
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'Error connecting wizard data: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: isDarkMode ? AppColorsDark.error : AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );

      Logger.e(
        'Error connecting wizard to planning tools: $e',
        tag: 'WizardConnectionService',
      );
    }
  }

  /// Persist wizard connections to Supabase
  static Future<void> persistConnectionsToSupabase(
    BuildContext context,
    Map<String, dynamic> wizardData,
  ) async {
    try {
      // Get the wizard provider
      final wizardProvider = Provider.of<WizardProvider>(
        context,
        listen: false,
      );

      // Check if Supabase persistence is enabled
      if (wizardProvider.useSupabase) {
        Logger.i(
          'Persisting wizard connections to Supabase',
          tag: 'WizardConnectionService',
        );

        // Check if the wizard provider has Supabase persistence enabled
        // This means it has user and event IDs
        if (!wizardProvider.useSupabase) {
          Logger.w(
            'Supabase persistence is not enabled in WizardProvider',
            tag: 'WizardConnectionService',
          );
          return;
        }

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
              tag: 'WizardConnectionService',
            );
            return;
          }
        } catch (e) {
          Logger.e(
            'Error extracting user/event IDs: $e',
            tag: 'WizardConnectionService',
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

        // Get the budget provider to collect budget item IDs
        try {
          final budgetProvider = Provider.of<BudgetProvider>(
            context,
            listen: false,
          );
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
            tag: 'WizardConnectionService',
          );
        } catch (e) {
          Logger.e(
            'Error getting budget items: $e',
            tag: 'WizardConnectionService',
          );

          // Save the connection without budget items
          final databaseService = WizardConnectionDatabaseService();
          await databaseService.saveWizardConnection(
            userId,
            eventId,
            connection.toJson(),
          );
        }

        // The WizardProvider will handle saving the wizard state to Supabase
        await wizardProvider.saveStateToSupabase();
      }
    } catch (e) {
      Logger.e(
        'Error persisting wizard connections to Supabase: $e',
        tag: 'WizardConnectionService',
      );
    }
  }

  /// Connect wizard data to budget calculator
  static Future<void> connectToBudget(
    BuildContext context,
    Map<String, dynamic> wizardData,
  ) async {
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

    // Get location and venue information from wizard data
    final location = wizardData['location'] as String? ?? 'Unknown';
    final isPremiumVenue = wizardData['isPremiumVenue'] as bool? ?? false;

    // Create budget items based on selected services with enhanced calculations
    await _createBudgetItemsFromServices(
      budgetProvider,
      selectedServices,
      guestCount,
      eventType,
      eventDuration,
      needsSetup,
      setupHours,
      needsTeardown,
      teardownHours,
      location: location,
      eventDate: eventDate,
      isPremiumVenue: isPremiumVenue,
    );

    // Add budget allocation recommendations
    _addBudgetRecommendations(budgetProvider, eventType, guestCount, eventDate);

    Logger.i(
      'Connected wizard data to budget calculator',
      tag: 'WizardConnectionService',
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
      final taskTemplateService = TaskTemplateService();
      final tasks = taskTemplateService.getTasksForEvent(
        eventType,
        eventDate,
        selectedServices: selectedServices,
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
    // Use specialized task templates based on event type
    final specializedTasks = SpecializedTaskTemplates.getSpecializedTasks(
      eventType,
      eventDate,
      selectedServices,
      guestCount,
    );

    // Log the specialized tasks that were created
    Logger.i(
      'Created ${specializedTasks.length} specialized tasks for $eventType event',
      tag: 'WizardConnectionService',
    );

    if (eventType.toLowerCase().contains('wedding')) {
      // Get comprehensive business event task list from specialized templates
      debugPrint('Would add specialized business event tasks');
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

      specializedTasks.add(
        Task(
          id: 'celebration_task_${DateTime.now().millisecondsSinceEpoch}_3',
          title: 'Arrange decorations',
          description: 'Plan and purchase decorations for the event',
          categoryId: '5', // Decor category
          dueDate: eventDate.subtract(const Duration(days: 30)),
          status: TaskStatus.notStarted,
          isImportant: true,
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

      // For very large events, add crowd management tasks
      if (guestCount > 250) {
        specializedTasks.add(
          Task(
            id: 'task_${DateTime.now().millisecondsSinceEpoch}_large_1',
            title: 'Hire event staff',
            description: 'Arrange for additional staff for large event',
            categoryId: '6', // Staff category
            dueDate: eventDate.subtract(const Duration(days: 60)),
            status: TaskStatus.notStarted,
            isImportant: true,
          ),
        );

        specializedTasks.add(
          Task(
            id: 'task_${DateTime.now().millisecondsSinceEpoch}_large_2',
            title: 'Create crowd flow plan',
            description: 'Plan traffic flow and crowd management',
            categoryId: '5', // Logistics category
            dueDate: eventDate.subtract(const Duration(days: 45)),
            status: TaskStatus.notStarted,
            isImportant: true,
          ),
        );
      }
    }

    // Add tasks based on selected services
    if (selectedServices['Catering'] == true) {
      specializedTasks.add(
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_catering_1',
          title: 'Finalize menu selections',
          description: 'Confirm final menu choices with caterer',
          categoryId: '6', // Vendors category
          dueDate: eventDate.subtract(const Duration(days: 45)),
          status: TaskStatus.notStarted,
          isImportant: true,
        ),
      );

      if (guestCount > 100) {
        specializedTasks.add(
          Task(
            id: 'task_${DateTime.now().millisecondsSinceEpoch}_catering_2',
            title: 'Confirm catering staff count',
            description: 'Ensure adequate staff for large guest count',
            categoryId: '6', // Vendors category
            dueDate: eventDate.subtract(const Duration(days: 21)),
            status: TaskStatus.notStarted,
            isImportant: false,
          ),
        );
      }

      // Add dietary restrictions task
      specializedTasks.add(
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_catering_3',
          title: 'Collect dietary restrictions',
          description: 'Gather special dietary needs from guests',
          categoryId: '6', // Vendors category
          dueDate: eventDate.subtract(const Duration(days: 30)),
          status: TaskStatus.notStarted,
          isImportant: true,
        ),
      );
    }

    // Add photography/videography specific tasks
    if (selectedServices['Photography'] == true ||
        selectedServices['Videography'] == true ||
        selectedServices['Photography/Videography'] == true) {
      specializedTasks.add(
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_photo_1',
          title: 'Create shot list',
          description: 'Prepare list of must-have photos/videos',
          categoryId: '7', // Photography category
          dueDate: eventDate.subtract(const Duration(days: 30)),
          status: TaskStatus.notStarted,
          isImportant: true,
        ),
      );

      specializedTasks.add(
        Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}_photo_2',
          title: 'Scout photo locations',
          description: 'Identify key spots for photos/videos',
          categoryId: '7', // Photography category
          dueDate: eventDate.subtract(const Duration(days: 14)),
          status: TaskStatus.notStarted,
          isImportant: false,
        ),
      );
    }

    return specializedTasks;
  }

  /// Create task dependencies and sequences
  ///
  /// Creates logical dependencies between tasks based on their categories and due dates.
  /// For example, venue booking must be completed before sending invitations.
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

    // Venue tasks must be completed before most other tasks
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

      // Venue booking must be completed before sending invitations
      final invitationTasks =
          allTasks
              .where(
                (task) =>
                    task.title.toLowerCase().contains('invitation') ||
                    task.title.toLowerCase().contains('invite'),
              )
              .toList();

      for (final invitationTask in invitationTasks) {
        taskProvider.addDependency(venueBookingTask.id, invitationTask.id);
      }
    }

    // Guest list must be created before sending invitations
    final guestListTasks =
        allTasks
            .where((task) => task.title.toLowerCase().contains('guest list'))
            .toList();

    final invitationTasks =
        allTasks
            .where(
              (task) =>
                  task.title.toLowerCase().contains('invitation') ||
                  task.title.toLowerCase().contains('invite'),
            )
            .toList();

    if (guestListTasks.isNotEmpty && invitationTasks.isNotEmpty) {
      for (final invitationTask in invitationTasks) {
        taskProvider.addDependency(guestListTasks.first.id, invitationTask.id);
      }
    }

    debugPrint(
      'Created task dependencies for ${adjustedTasks.length + specializedTasks.length} tasks',
    );
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
  static Future<void> _createBudgetItemsFromServices(
    BudgetProvider budgetProvider,
    Map<String, bool> selectedServices,
    int guestCount,
    String eventType,
    int eventDuration,
    bool needsSetup,
    int setupHours,
    bool needsTeardown,
    int teardownHours, {
    String location = 'Unknown',
    DateTime? eventDate,
    bool isPremiumVenue = false,
  }) async {
    // Use BudgetItemsBuilder to create budget items
    final budgetItems = BudgetItemsBuilder.createBudgetItems(
      selectedServices,
      guestCount,
      eventType,
      eventDuration,
      location: location,
      eventDate: eventDate,
      isPremiumVenue: isPremiumVenue,
    );

    try {
      // Add all budget items to the provider
      for (final budgetItem in budgetItems) {
        await budgetProvider.addBudgetItem(budgetItem);
      }

      Logger.i(
        'Added ${budgetItems.length} budget items for $eventType event',
        tag: 'WizardConnectionService',
      );
    } catch (e) {
      Logger.e(
        'Error creating budget items: $e',
        tag: 'WizardConnectionService',
      );
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
    // Create guest groups using the GuestGroupsBuilder
    final guestGroups = GuestGroupsBuilder.createDefaultGuestGroups(eventType);

    // Add common groups for all event types
    guestGroups.add(
      GuestGroup(
        id: 'family_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Family',
        description: 'Close family members',
        color: '#4CAF50', // Green
      ),
    );

    guestGroups.add(
      GuestGroup(
        id: 'friends_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Friends',
        description: 'Friends and colleagues',
        color: '#2196F3', // Blue
      ),
    );

    // Add event-specific groups
    if (eventType.toLowerCase().contains('wedding')) {
      guestGroups.add(
        GuestGroup(
          id: 'wedding_party_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Wedding Party',
          description: 'Bridesmaids, groomsmen, etc.',
          color: '#9C27B0', // Purple
        ),
      );
    } else if (eventType.toLowerCase().contains('business')) {
      guestGroups.add(
        GuestGroup(
          id: 'clients_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Clients',
          description: 'Business clients and partners',
          color: '#FF9800', // Orange
        ),
      );
    }

    // Add all guest groups to the provider
    for (final group in guestGroups) {
      guestListProvider.addGroup(group);
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

      // Get the wizard state from the wizard provider
      final wizardProvider = Provider.of<WizardProvider>(
        context,
        listen: false,
      );
      final wizardState = wizardProvider.state;

      // Set the wizard state in the provider for personalized recommendations
      if (wizardState != null) {
        serviceRecommendationProvider.setWizardState(wizardState);
      }

      debugPrint(
        'Connected wizard data to service screens for recommendations',
      );
    } catch (e) {
      debugPrint('Error connecting wizard data to service screens: $e');
    }
  }
}
