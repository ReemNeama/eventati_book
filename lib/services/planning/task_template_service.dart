import 'package:eventati_book/models/planning_models/task.dart';
import 'package:eventati_book/utils/logger.dart';

/// Service for managing task templates
class TaskTemplateService {
  /// Get tasks for an event based on event type
  List<Task> getTasksForEvent(
    String eventType,
    DateTime eventDate, {
    Map<String, bool>? selectedServices,
  }) {
    Logger.i(
      'Getting tasks for event type: $eventType',
      tag: 'TaskTemplateService',
    );

    // Get base tasks for all event types
    final baseTasks = _getBaseTasks(eventDate);

    // Get event-specific tasks
    final eventSpecificTasks = _getEventSpecificTasks(eventType, eventDate);

    // Get service-specific tasks
    final serviceSpecificTasks =
        selectedServices != null
            ? _getServiceSpecificTasks(selectedServices, eventDate)
            : <Task>[];

    // Combine all tasks
    return [...baseTasks, ...eventSpecificTasks, ...serviceSpecificTasks];
  }

  /// Get base tasks that apply to all event types
  List<Task> _getBaseTasks(DateTime eventDate) {
    return [
      Task(
        id: 'base_task_1',
        title: 'Create event budget',
        description: 'Set up initial budget for the event',
        categoryId: '1', // Planning category
        dueDate: eventDate.subtract(const Duration(days: 120)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
      Task(
        id: 'base_task_2',
        title: 'Create guest list',
        description: 'Compile initial guest list',
        categoryId: '2', // Guest Management category
        dueDate: eventDate.subtract(const Duration(days: 90)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
      Task(
        id: 'base_task_3',
        title: 'Book venue',
        description: 'Research and book event venue',
        categoryId: '3', // Venue category
        dueDate: eventDate.subtract(const Duration(days: 180)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    ];
  }

  /// Get tasks specific to the event type
  List<Task> _getEventSpecificTasks(String eventType, DateTime eventDate) {
    if (eventType.toLowerCase().contains('wedding')) {
      return _getWeddingTasks(eventDate);
    } else if (eventType.toLowerCase().contains('business')) {
      return _getBusinessEventTasks(eventDate);
    } else if (eventType.toLowerCase().contains('celebration')) {
      return _getCelebrationTasks(eventDate);
    } else {
      return [];
    }
  }

  /// Get wedding-specific tasks
  List<Task> _getWeddingTasks(DateTime eventDate) {
    return [
      Task(
        id: 'wedding_task_1',
        title: 'Choose wedding party',
        description: 'Select bridesmaids, groomsmen, etc.',
        categoryId: '4', // Wedding Party category
        dueDate: eventDate.subtract(const Duration(days: 270)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
      Task(
        id: 'wedding_task_2',
        title: 'Shop for wedding attire',
        description: 'Find wedding dress, suits, etc.',
        categoryId: '5', // Attire category
        dueDate: eventDate.subtract(const Duration(days: 180)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
      Task(
        id: 'wedding_task_3',
        title: 'Order wedding cake',
        description: 'Select bakery and cake design',
        categoryId: '6', // Food & Beverage category
        dueDate: eventDate.subtract(const Duration(days: 90)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
      Task(
        id: 'wedding_task_4',
        title: 'Plan honeymoon',
        description: 'Research and book honeymoon destination',
        categoryId: '7', // Travel category
        dueDate: eventDate.subtract(const Duration(days: 120)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    ];
  }

  /// Get business event-specific tasks
  List<Task> _getBusinessEventTasks(DateTime eventDate) {
    return [
      Task(
        id: 'business_task_1',
        title: 'Define event objectives',
        description: 'Establish clear goals for the business event',
        categoryId: '8', // Planning category
        dueDate: eventDate.subtract(const Duration(days: 120)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
      Task(
        id: 'business_task_2',
        title: 'Create event agenda',
        description: 'Develop detailed schedule of activities',
        categoryId: '8', // Planning category
        dueDate: eventDate.subtract(const Duration(days: 60)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
      Task(
        id: 'business_task_3',
        title: 'Book speakers/presenters',
        description: 'Secure speakers or presenters for the event',
        categoryId: '9', // Talent category
        dueDate: eventDate.subtract(const Duration(days: 90)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
      Task(
        id: 'business_task_4',
        title: 'Arrange A/V equipment',
        description: 'Secure necessary audio/visual equipment',
        categoryId: '10', // Equipment category
        dueDate: eventDate.subtract(const Duration(days: 45)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    ];
  }

  /// Get celebration-specific tasks
  List<Task> _getCelebrationTasks(DateTime eventDate) {
    return [
      Task(
        id: 'celebration_task_1',
        title: 'Plan entertainment',
        description: 'Book DJ, band, or other entertainment',
        categoryId: '11', // Entertainment category
        dueDate: eventDate.subtract(const Duration(days: 60)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
      Task(
        id: 'celebration_task_2',
        title: 'Order decorations',
        description: 'Purchase or rent event decorations',
        categoryId: '12', // Decor category
        dueDate: eventDate.subtract(const Duration(days: 45)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
      Task(
        id: 'celebration_task_3',
        title: 'Plan activities',
        description: 'Organize games or activities for guests',
        categoryId: '11', // Entertainment category
        dueDate: eventDate.subtract(const Duration(days: 30)),
        status: TaskStatus.notStarted,
        isImportant: false,
      ),
    ];
  }

  /// Get tasks based on selected services
  List<Task> _getServiceSpecificTasks(
    Map<String, bool> selectedServices,
    DateTime eventDate,
  ) {
    final tasks = <Task>[];

    if (selectedServices['Catering'] == true) {
      tasks.add(
        Task(
          id: 'service_task_catering_1',
          title: 'Plan menu with caterer',
          description: 'Meet with caterer to plan event menu',
          categoryId: '6', // Food & Beverage category
          dueDate: eventDate.subtract(const Duration(days: 60)),
          status: TaskStatus.notStarted,
          isImportant: true,
        ),
      );
      tasks.add(
        Task(
          id: 'service_task_catering_2',
          title: 'Finalize menu and headcount',
          description: 'Confirm final menu and guest count with caterer',
          categoryId: '6', // Food & Beverage category
          dueDate: eventDate.subtract(const Duration(days: 14)),
          status: TaskStatus.notStarted,
          isImportant: true,
        ),
      );
    }

    if (selectedServices['Photography'] == true) {
      tasks.add(
        Task(
          id: 'service_task_photo_1',
          title: 'Create shot list',
          description: 'Prepare list of must-have photos',
          categoryId: '13', // Photography category
          dueDate: eventDate.subtract(const Duration(days: 30)),
          status: TaskStatus.notStarted,
          isImportant: true,
        ),
      );
    }

    return tasks;
  }
}
