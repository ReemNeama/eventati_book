import 'package:eventati_book/models/planning_models/task_template.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling task template database operations with Supabase
class TaskTemplateDatabaseService {
  /// Supabase client
  final SupabaseClient _supabase;

  /// Table name for task templates
  static const String _templatesTable = 'task_templates';

  /// Constructor
  TaskTemplateDatabaseService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  /// Get all task templates
  Future<List<TaskTemplate>> getAllTemplates() async {
    try {
      final response = await _supabase.from(_templatesTable).select();

      return response
          .map<TaskTemplate>((data) => TaskTemplate.fromJson(data))
          .toList();
    } catch (e) {
      Logger.e(
        'Error getting all task templates: $e',
        tag: 'TaskTemplateDatabaseService',
      );
      return [];
    }
  }

  /// Get task templates by event type
  Future<List<TaskTemplate>> getTemplatesByEventType(String eventType) async {
    try {
      final response = await _supabase
          .from(_templatesTable)
          .select()
          .eq('event_type', eventType);

      return response
          .map<TaskTemplate>((data) => TaskTemplate.fromJson(data))
          .toList();
    } catch (e) {
      Logger.e(
        'Error getting templates by event type: $e',
        tag: 'TaskTemplateDatabaseService',
      );
      return [];
    }
  }

  /// Get task templates by user ID
  Future<List<TaskTemplate>> getTemplatesByUserId(String userId) async {
    try {
      final response = await _supabase
          .from(_templatesTable)
          .select()
          .eq('user_id', userId);

      return response
          .map<TaskTemplate>((data) => TaskTemplate.fromJson(data))
          .toList();
    } catch (e) {
      Logger.e(
        'Error getting templates by user ID: $e',
        tag: 'TaskTemplateDatabaseService',
      );
      return [];
    }
  }

  /// Get a task template by ID
  Future<TaskTemplate?> getTemplateById(String templateId) async {
    try {
      final response =
          await _supabase
              .from(_templatesTable)
              .select()
              .eq('id', templateId)
              .single();

      return TaskTemplate.fromJson(response);
    } catch (e) {
      Logger.e(
        'Error getting template by ID: $e',
        tag: 'TaskTemplateDatabaseService',
      );
      return null;
    }
  }

  /// Add a new task template
  Future<String> addTemplate(TaskTemplate template) async {
    try {
      final response =
          await _supabase
              .from(_templatesTable)
              .insert(template.toDatabaseDoc())
              .select()
              .single();

      return response['id'];
    } catch (e) {
      Logger.e(
        'Error adding task template: $e',
        tag: 'TaskTemplateDatabaseService',
      );
      rethrow;
    }
  }

  /// Update an existing task template
  Future<void> updateTemplate(TaskTemplate template) async {
    try {
      await _supabase
          .from(_templatesTable)
          .update(template.toDatabaseDoc())
          .eq('id', template.id);
    } catch (e) {
      Logger.e(
        'Error updating task template: $e',
        tag: 'TaskTemplateDatabaseService',
      );
      rethrow;
    }
  }

  /// Delete a task template
  Future<void> deleteTemplate(String templateId) async {
    try {
      await _supabase.from(_templatesTable).delete().eq('id', templateId);
    } catch (e) {
      Logger.e(
        'Error deleting task template: $e',
        tag: 'TaskTemplateDatabaseService',
      );
      rethrow;
    }
  }

  /// Get system templates
  Future<List<TaskTemplate>> getSystemTemplates() async {
    try {
      final response = await _supabase
          .from(_templatesTable)
          .select()
          .eq('is_system_template', true);

      return response
          .map<TaskTemplate>((data) => TaskTemplate.fromJson(data))
          .toList();
    } catch (e) {
      Logger.e(
        'Error getting system templates: $e',
        tag: 'TaskTemplateDatabaseService',
      );
      return [];
    }
  }

  /// Get templates by tags
  Future<List<TaskTemplate>> getTemplatesByTags(List<String> tags) async {
    try {
      // TODO: Update when Supabase API is updated or find compatible methods
      // For now, fetch all templates and filter in memory
      final response = await _supabase.from(_templatesTable).select();

      // Filter in memory
      final templates =
          response
              .map<TaskTemplate>((data) => TaskTemplate.fromJson(data))
              .toList();

      // Filter by tags
      if (tags.isNotEmpty) {
        return templates.where((template) {
          return template.tags.any((tag) => tags.contains(tag));
        }).toList();
      }

      return templates;
    } catch (e) {
      Logger.e(
        'Error getting templates by tags: $e',
        tag: 'TaskTemplateDatabaseService',
      );
      return [];
    }
  }

  /// Search templates by name or description
  Future<List<TaskTemplate>> searchTemplates(String query) async {
    try {
      // TODO: Update when Supabase API is updated or find compatible methods
      // For now, fetch all templates and filter in memory
      final response = await _supabase.from(_templatesTable).select();

      // Filter in memory
      final templates =
          response
              .map<TaskTemplate>((data) => TaskTemplate.fromJson(data))
              .toList();

      // Filter by name or description
      if (query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        return templates.where((template) {
          return template.name.toLowerCase().contains(lowerQuery) ||
              template.description.toLowerCase().contains(lowerQuery);
        }).toList();
      }

      return templates;
    } catch (e) {
      Logger.e(
        'Error searching templates: $e',
        tag: 'TaskTemplateDatabaseService',
      );
      return [];
    }
  }
}
