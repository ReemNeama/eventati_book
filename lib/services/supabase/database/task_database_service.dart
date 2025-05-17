import 'package:eventati_book/models/planning_models/task.dart';
import 'package:eventati_book/models/planning_models/task_category.dart';
import 'package:eventati_book/models/planning_models/task_dependency.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling task-related database operations with Supabase
class TaskDatabaseService {
  /// Supabase client
  final SupabaseClient _supabase;

  /// Table name for tasks
  static const String _tasksTable = 'tasks';

  /// Table name for task categories
  static const String _categoriesTable = 'task_categories';

  /// Table name for task dependencies
  static const String _dependenciesTable = 'task_dependencies';

  /// Constructor
  TaskDatabaseService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  /// Get all tasks for an event
  Future<List<Task>> getTasks(String eventId) async {
    try {
      final response = await _supabase
          .from(_tasksTable)
          .select()
          .eq('event_id', eventId);

      return response.map<Task>((data) => Task.fromJson(data)).toList();
    } catch (e) {
      Logger.e('Error getting tasks: $e', tag: 'TaskDatabaseService');
      return [];
    }
  }

  /// Get a stream of tasks for an event
  Stream<List<Task>> getTasksStream(String eventId) {
    return _supabase
        .from(_tasksTable)
        .stream(primaryKey: ['id'])
        .eq('event_id', eventId)
        .map((data) => data.map<Task>((item) => Task.fromJson(item)).toList());
  }

  /// Get all task categories for an event
  Future<List<TaskCategory>> getTaskCategories(String eventId) async {
    try {
      final response = await _supabase
          .from(_categoriesTable)
          .select()
          .eq('event_id', eventId);

      return response
          .map<TaskCategory>(
            (data) => TaskCategory(
              id: data['id'] as String,
              name: data['name'] as String,
              description: data['description'] as String? ?? '',
              icon: data['icon'] as String? ?? 'task_alt',
              color: data['color'] as String? ?? '#2196F3',
              order: data['order'] as int? ?? 0,
              isDefault: data['is_default'] as bool? ?? false,
              isActive: data['is_active'] as bool? ?? true,
              createdAt: DateTime.parse(
                data['created_at'] as String? ??
                    DateTime.now().toIso8601String(),
              ),
              updatedAt: DateTime.parse(
                data['updated_at'] as String? ??
                    DateTime.now().toIso8601String(),
              ),
            ),
          )
          .toList();
    } catch (e) {
      Logger.e('Error getting task categories: $e', tag: 'TaskDatabaseService');
      return [];
    }
  }

  /// Get a stream of task categories for an event
  Stream<List<TaskCategory>> getTaskCategoriesStream(String eventId) {
    return _supabase
        .from(_categoriesTable)
        .stream(primaryKey: ['id'])
        .eq('event_id', eventId)
        .map(
          (data) =>
              data
                  .map<TaskCategory>(
                    (item) => TaskCategory(
                      id: item['id'] as String,
                      name: item['name'] as String,
                      description: item['description'] as String? ?? '',
                      icon: item['icon'] as String? ?? 'task_alt',
                      color: item['color'] as String? ?? '#2196F3',
                      order: item['order'] as int? ?? 0,
                      isDefault: item['is_default'] as bool? ?? false,
                      isActive: item['is_active'] as bool? ?? true,
                      createdAt: DateTime.parse(
                        item['created_at'] as String? ??
                            DateTime.now().toIso8601String(),
                      ),
                      updatedAt: DateTime.parse(
                        item['updated_at'] as String? ??
                            DateTime.now().toIso8601String(),
                      ),
                    ),
                  )
                  .toList(),
        );
  }

  /// Get all task dependencies for an event
  Future<List<TaskDependency>> getTaskDependencies(String eventId) async {
    try {
      final response = await _supabase
          .from(_dependenciesTable)
          .select()
          .eq('event_id', eventId);

      return response
          .map<TaskDependency>(
            (data) => TaskDependency(
              prerequisiteTaskId: data['prerequisite_task_id'],
              dependentTaskId: data['dependent_task_id'],
            ),
          )
          .toList();
    } catch (e) {
      Logger.e(
        'Error getting task dependencies: $e',
        tag: 'TaskDatabaseService',
      );
      return [];
    }
  }

  /// Get a stream of task dependencies for an event
  Stream<List<TaskDependency>> getTaskDependenciesStream(String eventId) {
    return _supabase
        .from(_dependenciesTable)
        .stream(primaryKey: ['prerequisite_task_id', 'dependent_task_id'])
        .eq('event_id', eventId)
        .map(
          (data) =>
              data
                  .map<TaskDependency>(
                    (item) => TaskDependency(
                      prerequisiteTaskId: item['prerequisite_task_id'],
                      dependentTaskId: item['dependent_task_id'],
                    ),
                  )
                  .toList(),
        );
  }

  /// Add a new task
  Future<String> addTask(String eventId, Task task) async {
    try {
      final taskData = task.toJson();
      taskData['event_id'] = eventId;

      final response =
          await _supabase.from(_tasksTable).insert(taskData).select().single();

      return response['id'];
    } catch (e) {
      Logger.e('Error adding task: $e', tag: 'TaskDatabaseService');
      rethrow;
    }
  }

  /// Add a new task with eventId from the task object
  Future<String> addTaskWithEventId(Task task) async {
    try {
      if (task.eventId == null) {
        throw Exception('Task must have an eventId');
      }

      final taskData = task.toJson();

      final response =
          await _supabase.from(_tasksTable).insert(taskData).select().single();

      return response['id'];
    } catch (e) {
      Logger.e('Error adding task: $e', tag: 'TaskDatabaseService');
      rethrow;
    }
  }

  /// Update an existing task
  Future<void> updateTask(String eventId, Task task) async {
    try {
      final taskData = task.toJson();
      taskData['event_id'] = eventId;

      await _supabase
          .from(_tasksTable)
          .update(taskData)
          .eq('id', task.id)
          .eq('event_id', eventId);
    } catch (e) {
      Logger.e('Error updating task: $e', tag: 'TaskDatabaseService');
      rethrow;
    }
  }

  /// Delete a task
  Future<void> deleteTask(String eventId, String taskId) async {
    try {
      await _supabase
          .from(_tasksTable)
          .delete()
          .eq('id', taskId)
          .eq('event_id', eventId);
    } catch (e) {
      Logger.e('Error deleting task: $e', tag: 'TaskDatabaseService');
      rethrow;
    }
  }

  /// Add a dependency between two tasks
  Future<void> addTaskDependency(
    String eventId,
    TaskDependency dependency,
  ) async {
    try {
      final data = {
        'prerequisite_task_id': dependency.prerequisiteTaskId,
        'dependent_task_id': dependency.dependentTaskId,
        'event_id': eventId,
        'type': dependency.type.index,
        'offset_days': dependency.offsetDays,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from(_dependenciesTable)
          .upsert(data, onConflict: 'prerequisite_task_id, dependent_task_id');

      Logger.i(
        'Added task dependency: ${dependency.prerequisiteTaskId} -> ${dependency.dependentTaskId}',
        tag: 'TaskDatabaseService',
      );
    } catch (e) {
      Logger.e('Error adding task dependency: $e', tag: 'TaskDatabaseService');
      rethrow;
    }
  }

  /// Add a dependency between two tasks with explicit event ID
  Future<void> addTaskDependencyWithEventId(
    TaskDependency dependency,
    String eventId,
  ) async {
    try {
      final data = {
        'prerequisite_task_id': dependency.prerequisiteTaskId,
        'dependent_task_id': dependency.dependentTaskId,
        'event_id': eventId,
        'type': dependency.type.index,
        'offset_days': dependency.offsetDays,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from(_dependenciesTable)
          .upsert(data, onConflict: 'prerequisite_task_id, dependent_task_id');

      Logger.i(
        'Added task dependency: ${dependency.prerequisiteTaskId} -> ${dependency.dependentTaskId}',
        tag: 'TaskDatabaseService',
      );
    } catch (e) {
      Logger.e('Error adding task dependency: $e', tag: 'TaskDatabaseService');
      rethrow;
    }
  }

  /// Remove a dependency between two tasks
  Future<void> removeTaskDependency(
    String eventId,
    String prerequisiteTaskId,
    String dependentTaskId,
  ) async {
    try {
      await _supabase
          .from(_dependenciesTable)
          .delete()
          .eq('prerequisite_task_id', prerequisiteTaskId)
          .eq('dependent_task_id', dependentTaskId)
          .eq('event_id', eventId);

      Logger.i(
        'Removed task dependency: $prerequisiteTaskId -> $dependentTaskId',
        tag: 'TaskDatabaseService',
      );
    } catch (e) {
      Logger.e(
        'Error removing task dependency: $e',
        tag: 'TaskDatabaseService',
      );
      rethrow;
    }
  }

  /// Add a task category
  Future<String> addTaskCategory(String eventId, TaskCategory category) async {
    try {
      final categoryData = {
        'id': category.id,
        'name': category.name,
        'description': category.description,
        'icon': category.icon,
        'color': category.color,
        'order': category.order,
        'is_default': category.isDefault,
        'is_active': category.isActive,
        'event_id': eventId,
        'created_at': category.createdAt.toIso8601String(),
        'updated_at': category.updatedAt.toIso8601String(),
      };

      final response =
          await _supabase
              .from(_categoriesTable)
              .upsert(categoryData)
              .select()
              .single();

      Logger.i(
        'Added task category: ${category.name}',
        tag: 'TaskDatabaseService',
      );

      return response['id'];
    } catch (e) {
      Logger.e('Error adding task category: $e', tag: 'TaskDatabaseService');
      rethrow;
    }
  }

  /// Update a task category
  Future<void> updateTaskCategory(String eventId, TaskCategory category) async {
    try {
      final categoryData = {
        'name': category.name,
        'description': category.description,
        'icon': category.icon,
        'color': category.color,
        'order': category.order,
        'is_default': category.isDefault,
        'is_active': category.isActive,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from(_categoriesTable)
          .update(categoryData)
          .eq('id', category.id)
          .eq('event_id', eventId);

      Logger.i(
        'Updated task category: ${category.name}',
        tag: 'TaskDatabaseService',
      );
    } catch (e) {
      Logger.e('Error updating task category: $e', tag: 'TaskDatabaseService');
      rethrow;
    }
  }

  /// Delete a task category
  Future<void> deleteTaskCategory(String eventId, String categoryId) async {
    try {
      await _supabase
          .from(_categoriesTable)
          .delete()
          .eq('id', categoryId)
          .eq('event_id', eventId);

      Logger.i(
        'Deleted task category: $categoryId',
        tag: 'TaskDatabaseService',
      );
    } catch (e) {
      Logger.e('Error deleting task category: $e', tag: 'TaskDatabaseService');
      rethrow;
    }
  }
}

// Implementation of DatabaseServiceInterface is in utils/database_service.dart
