import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/planning_providers/task_provider.dart';
import 'package:eventati_book/services/firebase/firestore/task_firestore_service.dart';
import 'package:eventati_book/utils/logger.dart';

/// Service for migrating task data to Firestore
class TaskMigrationService {
  /// Task Firestore service
  final TaskFirestoreService _taskFirestoreService;

  /// Constructor
  TaskMigrationService({TaskFirestoreService? taskFirestoreService})
    : _taskFirestoreService = taskFirestoreService ?? TaskFirestoreService();

  /// Migrate task data for an event to Firestore
  ///
  /// [eventId] The ID of the event
  /// [tasks] The list of tasks to migrate
  /// [categories] The list of task categories to migrate
  /// [dependencies] The list of task dependencies to migrate
  ///
  /// Returns true if the migration was successful
  Future<bool> migrateTaskData(
    String eventId,
    List<Task> tasks,
    List<TaskCategory> categories,
    List<TaskDependency> dependencies,
  ) async {
    try {
      // Migrate categories
      final categoryMap = <String, String>{}; // Old ID to new ID mapping
      for (final category in categories) {
        final newCategoryId = await _taskFirestoreService.addTaskCategory(
          eventId,
          category,
        );
        categoryMap[category.id] = newCategoryId;
      }

      // Migrate tasks
      final taskMap = <String, String>{}; // Old ID to new ID mapping
      for (final task in tasks) {
        // Update category ID if it was remapped
        final updatedTask =
            categoryMap.containsKey(task.categoryId)
                ? task.copyWith(categoryId: categoryMap[task.categoryId])
                : task;

        final newTaskId = await _taskFirestoreService.addTask(
          eventId,
          updatedTask,
        );
        taskMap[task.id] = newTaskId;
      }

      // Migrate dependencies
      for (final dependency in dependencies) {
        // Update task IDs if they were remapped
        final prerequisiteId =
            taskMap.containsKey(dependency.prerequisiteTaskId)
                ? taskMap[dependency.prerequisiteTaskId]!
                : dependency.prerequisiteTaskId;

        final dependentId =
            taskMap.containsKey(dependency.dependentTaskId)
                ? taskMap[dependency.dependentTaskId]!
                : dependency.dependentTaskId;

        final updatedDependency = TaskDependency(
          prerequisiteTaskId: prerequisiteId,
          dependentTaskId: dependentId,
        );

        await _taskFirestoreService.addTaskDependency(
          eventId,
          updatedDependency,
        );
      }

      return true;
    } catch (e) {
      Logger.e('Error migrating task data: $e', tag: 'TaskMigrationService');
      return false;
    }
  }
}
