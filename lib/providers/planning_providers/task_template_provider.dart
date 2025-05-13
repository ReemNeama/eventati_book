import 'package:eventati_book/models/planning_models/task.dart';
import 'package:eventati_book/models/planning_models/task_template.dart';
import 'package:eventati_book/services/task_template_manager.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:flutter/foundation.dart';

/// Provider for managing task templates
class TaskTemplateProvider extends ChangeNotifier {
  /// Task template manager
  final TaskTemplateManager _manager;

  /// List of all templates
  List<TaskTemplate> _templates = [];

  /// Currently selected template
  TaskTemplate? _selectedTemplate;

  /// Loading state
  bool _isLoading = false;

  /// Error message
  String? _errorMessage;

  /// Constructor
  TaskTemplateProvider({TaskTemplateManager? manager})
    : _manager = manager ?? TaskTemplateManager();

  /// Get all templates
  List<TaskTemplate> get templates => _templates;

  /// Get selected template
  TaskTemplate? get selectedTemplate => _selectedTemplate;

  /// Get loading state
  bool get isLoading => _isLoading;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Set selected template
  void setSelectedTemplate(TaskTemplate template) {
    _selectedTemplate = template;
    notifyListeners();
  }

  /// Clear selected template
  void clearSelectedTemplate() {
    _selectedTemplate = null;
    notifyListeners();
  }

  /// Load all templates
  Future<void> loadAllTemplates() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _templates = await _manager.getAllTemplates();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error loading templates: $e';
      Logger.e(_errorMessage!, tag: 'TaskTemplateProvider');
      notifyListeners();
    }
  }

  /// Load templates by event type
  Future<void> loadTemplatesByEventType(String eventType) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _templates = await _manager.getTemplatesByEventType(eventType);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error loading templates by event type: $e';
      Logger.e(_errorMessage!, tag: 'TaskTemplateProvider');
      notifyListeners();
    }
  }

  /// Load templates by user ID
  Future<void> loadTemplatesByUserId(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _templates = await _manager.getTemplatesByUserId(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error loading templates by user ID: $e';
      Logger.e(_errorMessage!, tag: 'TaskTemplateProvider');
      notifyListeners();
    }
  }

  /// Create a new template
  Future<String?> createTemplate({
    required String name,
    required String description,
    required String eventType,
    required String userId,
    required List<TaskDefinition> taskDefinitions,
    List<TaskDependencyDefinition> dependencies = const [],
    List<String> tags = const [],
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final templateId = await _manager.createTemplate(
        name: name,
        description: description,
        eventType: eventType,
        userId: userId,
        taskDefinitions: taskDefinitions,
        dependencies: dependencies,
        tags: tags,
      );

      // Reload templates
      await loadAllTemplates();

      return templateId;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error creating template: $e';
      Logger.e(_errorMessage!, tag: 'TaskTemplateProvider');
      notifyListeners();
      return null;
    }
  }

  /// Update an existing template
  Future<bool> updateTemplate(TaskTemplate template) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _manager.updateTemplate(template);

      // Update the template in the list
      final index = _templates.indexWhere((t) => t.id == template.id);
      if (index >= 0) {
        _templates[index] = template;
      }

      // Update selected template if it's the same
      if (_selectedTemplate?.id == template.id) {
        _selectedTemplate = template;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error updating template: $e';
      Logger.e(_errorMessage!, tag: 'TaskTemplateProvider');
      notifyListeners();
      return false;
    }
  }

  /// Delete a template
  Future<bool> deleteTemplate(String templateId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _manager.deleteTemplate(templateId);

      // Remove the template from the list
      _templates.removeWhere((t) => t.id == templateId);

      // Clear selected template if it's the same
      if (_selectedTemplate?.id == templateId) {
        _selectedTemplate = null;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error deleting template: $e';
      Logger.e(_errorMessage!, tag: 'TaskTemplateProvider');
      notifyListeners();
      return false;
    }
  }

  /// Apply a template to create tasks
  Future<List<Task>?> applyTemplate({
    required String templateId,
    required String eventId,
    required DateTime eventDate,
    String? assignedTo,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final tasks = await _manager.applyTemplate(
        templateId: templateId,
        eventId: eventId,
        eventDate: eventDate,
        assignedTo: assignedTo,
      );

      _isLoading = false;
      notifyListeners();
      return tasks;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error applying template: $e';
      Logger.e(_errorMessage!, tag: 'TaskTemplateProvider');
      notifyListeners();
      return null;
    }
  }

  /// Import a template from JSON
  Future<String?> importTemplate(Map<String, dynamic> templateJson) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final templateId = await _manager.importTemplate(templateJson);

      // Reload templates
      await loadAllTemplates();

      return templateId;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error importing template: $e';
      Logger.e(_errorMessage!, tag: 'TaskTemplateProvider');
      notifyListeners();
      return null;
    }
  }

  /// Export a template to JSON
  Future<Map<String, dynamic>?> exportTemplate(String templateId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final templateJson = await _manager.exportTemplate(templateId);

      _isLoading = false;
      notifyListeners();
      return templateJson;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error exporting template: $e';
      Logger.e(_errorMessage!, tag: 'TaskTemplateProvider');
      notifyListeners();
      return null;
    }
  }
}
