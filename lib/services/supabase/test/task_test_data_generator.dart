import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/models/planning_models/task_dependency.dart';
import 'package:eventati_book/services/supabase/database/task_database_service.dart';
import 'package:eventati_book/utils/logger.dart';

/// Utility for creating test data in Supabase
class TaskTestDataGenerator {
  /// Task database service
  final TaskDatabaseService _taskDatabaseService;

  /// Constructor
  TaskTestDataGenerator({TaskDatabaseService? taskDatabaseService})
    : _taskDatabaseService = taskDatabaseService ?? TaskDatabaseService();

  /// Create test data for an event
  ///
  /// This will create a set of test tasks, categories, and dependencies
  /// for the specified event.
  Future<void> createTestData(String eventId) async {
    try {
      // Create task categories
      final categories = _createTestCategories();

      // Create tasks
      final tasks = _createTestTasks(categories);

      // Create dependencies
      final dependencies = _createTestDependencies(tasks);

      // Save to Supabase
      // TODO: Implement category saving in TaskDatabaseService
      Logger.i(
        'Would save ${categories.length} categories',
        tag: 'TaskTestDataGenerator',
      );

      for (final task in tasks) {
        await _taskDatabaseService.addTask(eventId, task);
      }

      // TODO: Implement dependency saving in TaskDatabaseService
      Logger.i(
        'Would save ${dependencies.length} dependencies',
        tag: 'TaskTestDataGenerator',
      );

      Logger.i(
        'Created ${categories.length} categories, ${tasks.length} tasks, and ${dependencies.length} dependencies',
        tag: 'TaskTestDataGenerator',
      );
    } catch (e) {
      Logger.e('Error creating test data: $e', tag: 'TaskTestDataGenerator');
      rethrow;
    }
  }

  /// Create test task categories
  List<TaskCategory> _createTestCategories() {
    final now = DateTime.now();
    return [
      TaskCategory(
        id: 'category_planning',
        name: 'Planning',
        description: 'Tasks related to overall event planning',
        color: '#2196F3', // Blue
        icon: 'calendar_today',
        createdAt: now,
        updatedAt: now,
      ),
      TaskCategory(
        id: 'category_venue',
        name: 'Venue',
        description: 'Tasks related to venue selection and booking',
        color: '#4CAF50', // Green
        icon: 'location_on',
        createdAt: now,
        updatedAt: now,
      ),
      TaskCategory(
        id: 'category_catering',
        name: 'Catering',
        description: 'Tasks related to food and beverage planning',
        color: '#FF9800', // Orange
        icon: 'restaurant',
        createdAt: now,
        updatedAt: now,
      ),
      TaskCategory(
        id: 'category_decoration',
        name: 'Decoration',
        description: 'Tasks related to event decorations and setup',
        color: '#9C27B0', // Purple
        icon: 'brush',
        createdAt: now,
        updatedAt: now,
      ),
      TaskCategory(
        id: 'category_entertainment',
        name: 'Entertainment',
        description: 'Tasks related to entertainment and activities',
        color: '#F44336', // Red
        icon: 'music_note',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// Create test tasks
  List<Task> _createTestTasks(List<TaskCategory> categories) {
    final now = DateTime.now();

    return [
      Task(
        id: 'task_1',
        title: 'Create event budget',
        description:
            'Determine overall budget and allocate funds to different categories',
        categoryId: categories[0].id,
        dueDate: now.add(const Duration(days: 7)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
      Task(
        id: 'task_2',
        title: 'Book venue',
        description: 'Research and book the perfect venue for the event',
        categoryId: categories[1].id,
        dueDate: now.add(const Duration(days: 14)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
      Task(
        id: 'task_3',
        title: 'Select catering service',
        description: 'Choose a catering service and plan the menu',
        categoryId: categories[2].id,
        dueDate: now.add(const Duration(days: 30)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
      Task(
        id: 'task_4',
        title: 'Plan decorations',
        description: 'Design and plan decorations for the event',
        categoryId: categories[3].id,
        dueDate: now.add(const Duration(days: 45)),
        status: TaskStatus.notStarted,
        isImportant: false,
      ),
      Task(
        id: 'task_5',
        title: 'Book entertainment',
        description: 'Find and book entertainment for the event',
        categoryId: categories[4].id,
        dueDate: now.add(const Duration(days: 60)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    ];
  }

  /// Create test dependencies
  List<TaskDependency> _createTestDependencies(List<Task> tasks) {
    return [
      TaskDependency(
        prerequisiteTaskId: tasks[0].id,
        dependentTaskId: tasks[1].id,
      ),
      TaskDependency(
        prerequisiteTaskId: tasks[1].id,
        dependentTaskId: tasks[2].id,
      ),
      TaskDependency(
        prerequisiteTaskId: tasks[1].id,
        dependentTaskId: tasks[3].id,
      ),
      TaskDependency(
        prerequisiteTaskId: tasks[2].id,
        dependentTaskId: tasks[4].id,
      ),
    ];
  }
}
