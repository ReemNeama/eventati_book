import 'package:eventati_book/models/planning_models/task.dart'
    hide TaskCategory;
import 'package:eventati_book/models/planning_models/task_category.dart';
import 'package:eventati_book/models/planning_models/task_dependency.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for migrating task data to Supabase
class TaskMigrationService {
  /// Supabase client
  final SupabaseClient _supabase;

  /// Constructor
  TaskMigrationService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  /// Migrate task data to Supabase
  ///
  /// This will migrate tasks, categories, and dependencies to Supabase.
  /// Returns true if the migration was successful, false otherwise.
  Future<bool> migrateTaskData(
    String eventId,
    List<Task> tasks,
    List<TaskCategory> categories,
    List<TaskDependency> dependencies,
  ) async {
    try {
      // Start a transaction
      await _supabase.rpc('begin_transaction');

      // Migrate task categories
      for (final category in categories) {
        await _migrateTaskCategory(eventId, category);
      }

      // Migrate tasks
      for (final task in tasks) {
        await _migrateTask(eventId, task);
      }

      // Migrate task dependencies
      for (final dependency in dependencies) {
        await _migrateTaskDependency(eventId, dependency);
      }

      // Commit the transaction
      await _supabase.rpc('commit_transaction');

      Logger.i(
        'Successfully migrated ${tasks.length} tasks, ${categories.length} categories, and ${dependencies.length} dependencies',
        tag: 'TaskMigrationService',
      );

      return true;
    } catch (e) {
      // Rollback the transaction
      await _supabase.rpc('rollback_transaction');

      Logger.e('Error migrating task data: $e', tag: 'TaskMigrationService');

      return false;
    }
  }

  /// Migrate a task category to Supabase
  Future<void> _migrateTaskCategory(
    String eventId,
    TaskCategory category,
  ) async {
    try {
      final data = {
        'id': category.id,
        'name': category.name,
        'description': category.description,
        'color': category.color,
        'icon': category.icon,
        'order': category.order,
        'is_default': category.isDefault,
        'is_active': category.isActive,
        'event_id': eventId,
        'created_at': category.createdAt.toIso8601String(),
        'updated_at': category.updatedAt.toIso8601String(),
      };

      await _supabase.from('task_categories').upsert(data, onConflict: 'id');

      Logger.i(
        'Migrated task category: ${category.name}',
        tag: 'TaskMigrationService',
      );
    } catch (e) {
      Logger.e(
        'Error migrating task category: $e',
        tag: 'TaskMigrationService',
      );
      rethrow;
    }
  }

  /// Migrate a task to Supabase
  Future<void> _migrateTask(String eventId, Task task) async {
    try {
      final data = task.toJson();
      data['event_id'] = eventId;

      await _supabase.from('tasks').upsert(data, onConflict: 'id');

      Logger.i('Migrated task: ${task.title}', tag: 'TaskMigrationService');
    } catch (e) {
      Logger.e('Error migrating task: $e', tag: 'TaskMigrationService');
      rethrow;
    }
  }

  /// Migrate a task dependency to Supabase
  Future<void> _migrateTaskDependency(
    String eventId,
    TaskDependency dependency,
  ) async {
    try {
      final data = {
        'prerequisite_task_id': dependency.prerequisiteTaskId,
        'dependent_task_id': dependency.dependentTaskId,
        'type': dependency.type.index,
        'offset_days': dependency.offsetDays,
        'event_id': eventId,
        'created_at': dependency.createdAt.toIso8601String(),
        'updated_at': dependency.updatedAt.toIso8601String(),
      };

      await _supabase
          .from('task_dependencies')
          .upsert(data, onConflict: 'prerequisite_task_id, dependent_task_id');

      Logger.i(
        'Migrated task dependency: ${dependency.prerequisiteTaskId} -> ${dependency.dependentTaskId}',
        tag: 'TaskMigrationService',
      );
    } catch (e) {
      Logger.e(
        'Error migrating task dependency: $e',
        tag: 'TaskMigrationService',
      );
      rethrow;
    }
  }
}
