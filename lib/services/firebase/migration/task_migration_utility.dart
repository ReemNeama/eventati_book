import 'package:eventati_book/models/planning_models/task.dart';
import 'package:eventati_book/providers/planning_providers/task_provider.dart';
import 'package:eventati_book/services/firebase/firestore/task_firestore_service.dart';
import 'package:eventati_book/services/firebase/migration/base_migration_utility.dart';
import 'package:eventati_book/services/firebase/migration/migration_result.dart';
import 'package:eventati_book/tempDB/tasks.dart' as temp_db;
import 'package:eventati_book/utils/logger.dart';

/// Utility for migrating task data from tempDB to Firestore
class TaskMigrationUtility extends BaseMigrationUtility<Task> {
  /// Event ID for which tasks are being migrated
  final String eventId;

  /// Task Firestore service for additional operations
  final TaskFirestoreService _taskFirestoreService;

  /// Constructor
  TaskMigrationUtility({
    required this.eventId,
    super.firestore,
    super.auth,
    TaskFirestoreService? taskFirestoreService,
  }) : _taskFirestoreService = taskFirestoreService ?? TaskFirestoreService(),
       super(collectionName: 'events/$eventId/tasks', entityTypeName: 'Task');

  @override
  List<String> validateEntity(Task entity) {
    final errors = <String>[];

    // Validate required fields
    if (entity.id.isEmpty) {
      errors.add('Task ID is required');
    }
    if (entity.title.isEmpty) {
      errors.add('Title is required');
    }
    if (entity.categoryId.isEmpty) {
      errors.add('Category ID is required');
    }

    return errors;
  }

  @override
  Map<String, dynamic> entityToFirestore(Task entity) {
    return entity.toFirestore();
  }

  @override
  String getEntityId(Task entity) {
    return entity.id;
  }

  /// Migrate all tasks for an event from tempDB to Firestore
  Future<MigrationResult> migrateEventTasks() async {
    try {
      // Get tasks from tempDB
      final tasks = temp_db.TaskDB.getTasks(eventId);

      Logger.i(
        'Migrating ${tasks.length} tasks for event $eventId from tempDB to Firestore',
        tag: 'TaskMigrationUtility',
      );

      // Migrate tasks
      final result = await migrateEntities(tasks);

      // Log result
      if (result.success) {
        Logger.i(
          'Successfully migrated ${result.entitiesMigrated} tasks for event $eventId to Firestore',
          tag: 'TaskMigrationUtility',
        );
      } else {
        Logger.e(
          'Failed to migrate tasks for event $eventId to Firestore: ${result.errorMessage}',
          tag: 'TaskMigrationUtility',
        );
      }

      return result;
    } catch (e) {
      Logger.e(
        'Error migrating tasks for event $eventId: $e',
        tag: 'TaskMigrationUtility',
      );
      return MigrationResult.failure(
        errorMessage: 'Error migrating tasks for event $eventId: $e',
        exception: e,
        entitiesMigrated: 0,
        entitiesFailed: 0,
        migratedIds: const [],
        failedIds: const [],
        idMap: const {},
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      );
    }
  }

  /// Migrate task categories for an event from tempDB to Firestore
  Future<MigrationResult> migrateTaskCategories() async {
    final startTime = DateTime.now();
    try {
      // Get task categories from tempDB
      final tempCategories = temp_db.TaskDB.getTaskCategories();

      // Convert tempDB categories to model categories
      final categories =
          tempCategories
              .map(
                (tempCategory) => TaskCategory(
                  id: tempCategory.id,
                  name: tempCategory.name,
                  color: tempCategory.color,
                  icon: tempCategory.icon,
                ),
              )
              .toList();

      Logger.i(
        'Migrating ${categories.length} task categories for event $eventId from tempDB to Firestore',
        tag: 'TaskMigrationUtility',
      );

      final migratedIds = <String>[];
      final failedIds = <String>[];
      final idMap = <String, String>{};

      for (final category in categories) {
        try {
          // Create the category in Firestore
          final newCategoryId = await _taskFirestoreService.addTaskCategory(
            eventId,
            category,
          );

          // Store ID mapping
          idMap[category.id] = newCategoryId;
          migratedIds.add(newCategoryId);
        } catch (e) {
          Logger.e(
            'Error migrating task category ${category.id}: $e',
            tag: 'TaskMigrationUtility',
          );
          failedIds.add(category.id);
        }
      }

      // Create success result
      final result = MigrationResult(
        success: failedIds.isEmpty,
        errorMessage:
            failedIds.isEmpty ? null : 'Some categories failed to migrate',
        exception: null,
        entitiesMigrated: migratedIds.length,
        entitiesFailed: failedIds.length,
        migratedIds: migratedIds,
        failedIds: failedIds,
        idMap: idMap,
        startTime: startTime,
        endTime: DateTime.now(),
      );

      // Log result
      if (result.success) {
        Logger.i(
          'Successfully migrated ${result.entitiesMigrated} task categories for event $eventId to Firestore',
          tag: 'TaskMigrationUtility',
        );
      } else {
        Logger.e(
          'Failed to migrate some task categories for event $eventId to Firestore',
          tag: 'TaskMigrationUtility',
        );
      }

      return result;
    } catch (e) {
      Logger.e(
        'Error migrating task categories for event $eventId: $e',
        tag: 'TaskMigrationUtility',
      );
      return MigrationResult.failure(
        errorMessage: 'Error migrating task categories for event $eventId: $e',
        exception: e,
        entitiesMigrated: 0,
        entitiesFailed: 0,
        migratedIds: const [],
        failedIds: const [],
        idMap: const {},
        startTime: startTime,
        endTime: DateTime.now(),
      );
    }
  }

  /// Migrate task dependencies for an event from tempDB to Firestore
  Future<MigrationResult> migrateTaskDependencies(
    Map<String, String> taskIdMap,
  ) async {
    final startTime = DateTime.now();
    try {
      // Get task dependencies from tempDB
      final dependencies = temp_db.TaskDB.getTaskDependencies(eventId);

      Logger.i(
        'Migrating ${dependencies.length} task dependencies for event $eventId from tempDB to Firestore',
        tag: 'TaskMigrationUtility',
      );

      final migratedIds = <String>[];
      final failedIds = <String>[];
      final idMap = <String, String>{};

      for (final dependency in dependencies) {
        try {
          // Update task IDs if they were remapped
          final prerequisiteId =
              taskIdMap.containsKey(dependency.prerequisiteTaskId)
                  ? taskIdMap[dependency.prerequisiteTaskId]!
                  : dependency.prerequisiteTaskId;

          final dependentId =
              taskIdMap.containsKey(dependency.dependentTaskId)
                  ? taskIdMap[dependency.dependentTaskId]!
                  : dependency.dependentTaskId;

          final updatedDependency = TaskDependency(
            prerequisiteTaskId: prerequisiteId,
            dependentTaskId: dependentId,
          );

          // Create the dependency in Firestore
          await _taskFirestoreService.addTaskDependency(
            eventId,
            updatedDependency,
          );

          // Generate a synthetic ID for tracking
          final syntheticId = '$prerequisiteId-$dependentId';
          migratedIds.add(syntheticId);
          idMap[syntheticId] = syntheticId;
        } catch (e) {
          Logger.e(
            'Error migrating task dependency: $e',
            tag: 'TaskMigrationUtility',
          );
          // Generate a synthetic ID for tracking
          final syntheticId =
              '${dependency.prerequisiteTaskId}_${dependency.dependentTaskId}';
          failedIds.add(syntheticId);
        }
      }

      // Create success result
      final result = MigrationResult(
        success: failedIds.isEmpty,
        errorMessage:
            failedIds.isEmpty ? null : 'Some dependencies failed to migrate',
        exception: null,
        entitiesMigrated: migratedIds.length,
        entitiesFailed: failedIds.length,
        migratedIds: migratedIds,
        failedIds: failedIds,
        idMap: idMap,
        startTime: startTime,
        endTime: DateTime.now(),
      );

      // Log result
      if (result.success) {
        Logger.i(
          'Successfully migrated ${result.entitiesMigrated} task dependencies for event $eventId to Firestore',
          tag: 'TaskMigrationUtility',
        );
      } else {
        Logger.e(
          'Failed to migrate some task dependencies for event $eventId to Firestore',
          tag: 'TaskMigrationUtility',
        );
      }

      return result;
    } catch (e) {
      Logger.e(
        'Error migrating task dependencies for event $eventId: $e',
        tag: 'TaskMigrationUtility',
      );
      return MigrationResult.failure(
        errorMessage:
            'Error migrating task dependencies for event $eventId: $e',
        exception: e,
        entitiesMigrated: 0,
        entitiesFailed: 0,
        migratedIds: const [],
        failedIds: const [],
        idMap: const {},
        startTime: startTime,
        endTime: DateTime.now(),
      );
    }
  }

  /// Migrate all task data for an event (tasks, categories, dependencies)
  Future<MigrationResult> migrateFullTaskData() async {
    final startTime = DateTime.now();
    try {
      // First migrate categories
      final categoriesResult = await migrateTaskCategories();

      // Then migrate tasks, updating category IDs
      final tasks = temp_db.TaskDB.getTasks(eventId);

      // Update category IDs based on the mapping from the categories migration
      final updatedTasks =
          tasks.map((task) {
            if (categoriesResult.idMap.containsKey(task.categoryId)) {
              return task.copyWith(
                categoryId: categoriesResult.idMap[task.categoryId]!,
              );
            }
            return task;
          }).toList();

      // Migrate the updated tasks
      final tasksResult = await migrateEntities(updatedTasks);

      // Finally migrate dependencies, updating task IDs
      final dependenciesResult = await migrateTaskDependencies(
        tasksResult.idMap,
      );

      // Combine the results
      final combinedResult = MigrationResult.combine([
        categoriesResult,
        tasksResult,
        dependenciesResult,
      ]);

      return combinedResult;
    } catch (e) {
      Logger.e(
        'Error migrating full task data for event $eventId: $e',
        tag: 'TaskMigrationUtility',
      );
      return MigrationResult.failure(
        errorMessage: 'Error migrating full task data for event $eventId: $e',
        exception: e,
        entitiesMigrated: 0,
        entitiesFailed: 0,
        migratedIds: const [],
        failedIds: const [],
        idMap: const {},
        startTime: startTime,
        endTime: DateTime.now(),
      );
    }
  }
}
