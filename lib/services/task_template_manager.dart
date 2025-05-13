import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/models/planning_models/task_template.dart';
import 'package:eventati_book/models/planning_models/task_dependency.dart';
import 'package:eventati_book/services/supabase/database/task_database_service.dart';
import 'package:eventati_book/services/supabase/database/task_template_database_service.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:uuid/uuid.dart';

/// Manager for task templates with enhanced functionality
class TaskTemplateManager {
  /// Database service for task templates
  final TaskTemplateDatabaseService _templateDatabaseService;

  /// Database service for tasks
  final TaskDatabaseService _taskDatabaseService;

  /// Constructor
  TaskTemplateManager({
    TaskTemplateDatabaseService? templateDatabaseService,
    TaskDatabaseService? taskDatabaseService,
  }) : _templateDatabaseService =
           templateDatabaseService ?? TaskTemplateDatabaseService(),
       _taskDatabaseService = taskDatabaseService ?? TaskDatabaseService();

  /// Get all templates
  Future<List<TaskTemplate>> getAllTemplates() async {
    try {
      return await _templateDatabaseService.getAllTemplates();
    } catch (e) {
      Logger.e('Error getting all templates: $e', tag: 'TaskTemplateManager');
      return [];
    }
  }

  /// Get templates by event type
  Future<List<TaskTemplate>> getTemplatesByEventType(String eventType) async {
    try {
      return await _templateDatabaseService.getTemplatesByEventType(eventType);
    } catch (e) {
      Logger.e(
        'Error getting templates by event type: $e',
        tag: 'TaskTemplateManager',
      );
      return [];
    }
  }

  /// Get templates by user ID
  Future<List<TaskTemplate>> getTemplatesByUserId(String userId) async {
    try {
      return await _templateDatabaseService.getTemplatesByUserId(userId);
    } catch (e) {
      Logger.e(
        'Error getting templates by user ID: $e',
        tag: 'TaskTemplateManager',
      );
      return [];
    }
  }

  /// Get a template by ID
  Future<TaskTemplate?> getTemplateById(String templateId) async {
    try {
      return await _templateDatabaseService.getTemplateById(templateId);
    } catch (e) {
      Logger.e('Error getting template by ID: $e', tag: 'TaskTemplateManager');
      return null;
    }
  }

  /// Create a new template from existing tasks
  Future<String> createTemplateFromTasks({
    required String name,
    required String description,
    required String eventType,
    required String userId,
    required List<Task> tasks,
    required List<TaskDependency> dependencies,
    List<String> tags = const [],
  }) async {
    try {
      // Create task definitions from tasks
      final taskDefinitions =
          tasks.map((task) {
            // Calculate days before event based on due date
            final daysBeforeEvent =
                DateTime.now().difference(task.dueDate).inDays;

            return TaskDefinition(
              id: task.id,
              title: task.title,
              description: task.description,
              categoryId: task.categoryId,
              daysBeforeEvent: daysBeforeEvent,
              isImportant: task.isImportant,
              service: task.service ?? 'General',
            );
          }).toList();

      // Create dependency definitions from dependencies
      final dependencyDefinitions =
          dependencies.map((dependency) {
            return TaskDependencyDefinition(
              prerequisiteTaskId: dependency.prerequisiteTaskId,
              dependentTaskId: dependency.dependentTaskId,
              type: dependency.type,
              offsetDays: dependency.offsetDays,
            );
          }).toList();

      // Create the template
      final template = TaskTemplate(
        id: const Uuid().v4(),
        name: name,
        description: description,
        eventType: eventType,
        userId: userId,
        isSystemTemplate: false,
        taskDefinitions: taskDefinitions,
        dependencies: dependencyDefinitions,
        tags: tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save the template to the database
      return await _templateDatabaseService.addTemplate(template);
    } catch (e) {
      Logger.e(
        'Error creating template from tasks: $e',
        tag: 'TaskTemplateManager',
      );
      rethrow;
    }
  }

  /// Create a new template from scratch
  Future<String> createTemplate({
    required String name,
    required String description,
    required String eventType,
    required String userId,
    required List<TaskDefinition> taskDefinitions,
    List<TaskDependencyDefinition> dependencies = const [],
    List<String> tags = const [],
  }) async {
    try {
      // Create the template
      final template = TaskTemplate(
        id: const Uuid().v4(),
        name: name,
        description: description,
        eventType: eventType,
        userId: userId,
        isSystemTemplate: false,
        taskDefinitions: taskDefinitions,
        dependencies: dependencies,
        tags: tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save the template to the database
      return await _templateDatabaseService.addTemplate(template);
    } catch (e) {
      Logger.e('Error creating template: $e', tag: 'TaskTemplateManager');
      rethrow;
    }
  }

  /// Update an existing template
  Future<void> updateTemplate(TaskTemplate template) async {
    try {
      // Update the template in the database
      await _templateDatabaseService.updateTemplate(
        template.copyWith(updatedAt: DateTime.now()),
      );
    } catch (e) {
      Logger.e('Error updating template: $e', tag: 'TaskTemplateManager');
      rethrow;
    }
  }

  /// Delete a template
  Future<void> deleteTemplate(String templateId) async {
    try {
      await _templateDatabaseService.deleteTemplate(templateId);
    } catch (e) {
      Logger.e('Error deleting template: $e', tag: 'TaskTemplateManager');
      rethrow;
    }
  }

  /// Apply a template to create tasks for an event
  Future<List<Task>> applyTemplate({
    required String templateId,
    required String eventId,
    required DateTime eventDate,
    String? assignedTo,
  }) async {
    try {
      // Get the template
      final template = await _templateDatabaseService.getTemplateById(
        templateId,
      );
      if (template == null) {
        throw Exception('Template not found');
      }

      // Create tasks from the template
      final tasks = <Task>[];
      final taskIdMap = <String, String>{}; // Map old task IDs to new task IDs

      // Create tasks from task definitions
      for (final taskDef in template.taskDefinitions) {
        // Calculate due date based on days before event
        final dueDate = eventDate.subtract(
          Duration(days: taskDef.daysBeforeEvent),
        );

        // Create a new task
        final task = Task(
          id: const Uuid().v4(),
          title: taskDef.title,
          description: taskDef.description,
          categoryId: taskDef.categoryId,
          dueDate: dueDate,
          status: TaskStatus.notStarted,
          assignedTo: assignedTo,
          isImportant: taskDef.isImportant,
          service: taskDef.service,
          eventId: eventId,
        );

        // Add to tasks list
        tasks.add(task);

        // Map old task ID to new task ID
        taskIdMap[taskDef.id] = task.id;
      }

      // Save tasks to the database
      for (final task in tasks) {
        // Make sure the task has the event ID
        final taskWithEventId = task.copyWith(eventId: eventId);
        await _taskDatabaseService.addTaskWithEventId(taskWithEventId);
      }

      // Create dependencies
      for (final depDef in template.dependencies) {
        // Get the new task IDs
        final prerequisiteTaskId = taskIdMap[depDef.prerequisiteTaskId];
        final dependentTaskId = taskIdMap[depDef.dependentTaskId];

        if (prerequisiteTaskId != null && dependentTaskId != null) {
          // Create the dependency
          final dependency = TaskDependency(
            prerequisiteTaskId: prerequisiteTaskId,
            dependentTaskId: dependentTaskId,
            type: depDef.type,
            offsetDays: depDef.offsetDays,
          );

          // Save the dependency to the database
          await _taskDatabaseService.addTaskDependencyWithEventId(
            dependency,
            eventId,
          );
        }
      }

      return tasks;
    } catch (e) {
      Logger.e('Error applying template: $e', tag: 'TaskTemplateManager');
      rethrow;
    }
  }

  /// Import a template from JSON
  Future<String> importTemplate(Map<String, dynamic> templateJson) async {
    try {
      // Create a template from the JSON
      final template = TaskTemplate.fromJson(templateJson);

      // Generate a new ID for the imported template
      final importedTemplate = template.copyWith(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save the template to the database
      return await _templateDatabaseService.addTemplate(importedTemplate);
    } catch (e) {
      Logger.e('Error importing template: $e', tag: 'TaskTemplateManager');
      rethrow;
    }
  }

  /// Export a template to JSON
  Future<Map<String, dynamic>> exportTemplate(String templateId) async {
    try {
      // Get the template
      final template = await _templateDatabaseService.getTemplateById(
        templateId,
      );
      if (template == null) {
        throw Exception('Template not found');
      }

      // Return the template as JSON
      return template.toJson();
    } catch (e) {
      Logger.e('Error exporting template: $e', tag: 'TaskTemplateManager');
      rethrow;
    }
  }
}
