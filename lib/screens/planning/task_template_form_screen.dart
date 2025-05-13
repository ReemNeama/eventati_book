import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/planning_models/task_template.dart';
import 'package:eventati_book/models/planning_models/task_dependency.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';

/// Screen for creating or editing a task template
class TaskTemplateFormScreen extends StatefulWidget {
  /// The template to edit (null for creating a new template)
  final TaskTemplate? template;

  /// Constructor
  const TaskTemplateFormScreen({super.key, this.template});

  @override
  State<TaskTemplateFormScreen> createState() => _TaskTemplateFormScreenState();
}

class _TaskTemplateFormScreenState extends State<TaskTemplateFormScreen> {
  /// Form key
  final _formKey = GlobalKey<FormState>();

  /// Name controller
  final _nameController = TextEditingController();

  /// Description controller
  final _descriptionController = TextEditingController();

  /// Selected event type
  String _selectedEventType = 'Wedding';

  /// List of event types
  final List<String> _eventTypes = [
    'Wedding',
    'Business',
    'Birthday',
    'Anniversary',
    'Conference',
    'Other',
  ];

  /// List of task definitions
  List<TaskDefinition> _taskDefinitions = [];

  /// List of dependencies
  List<TaskDependencyDefinition> _dependencies = [];

  /// List of tags
  List<String> _tags = [];

  /// Whether the screen is loading
  bool _isLoading = false;

  /// Error message
  String? _errorMessage;

  /// Whether the form is in edit mode
  bool get _isEditMode => widget.template != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  /// Initialize the form with template data if in edit mode
  void _initializeForm() {
    if (_isEditMode) {
      final template = widget.template!;
      _nameController.text = template.name;
      _descriptionController.text = template.description;
      _selectedEventType = template.eventType;
      _taskDefinitions = List.from(template.taskDefinitions);
      _dependencies = List.from(template.dependencies);
      _tags = List.from(template.tags);
    } else {
      // Initialize with default values for new template
      _taskDefinitions = [];
      _dependencies = [];
      _tags = [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Template' : 'Create Template'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTemplate,
            tooltip: 'Save template',
          ),
        ],
      ),
      body:
          _isLoading
              ? const LoadingIndicator()
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error, color: Colors.red[700]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Template Name',
                          hintText: 'Enter a name for this template',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter a description for this template',
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedEventType,
                        decoration: const InputDecoration(
                          labelText: 'Event Type',
                        ),
                        items:
                            _eventTypes.map((type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedEventType = value;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select an event type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildTaskDefinitionsSection(),
                      const SizedBox(height: 24),
                      _buildDependenciesSection(),
                      const SizedBox(height: 24),
                      _buildTagsSection(),
                    ],
                  ),
                ),
              ),
    );
  }

  /// Build the task definitions section
  Widget _buildTaskDefinitionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tasks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _addTaskDefinition,
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_taskDefinitions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No tasks added yet. Add tasks to create a template.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _taskDefinitions.length,
            itemBuilder: (context, index) {
              final task = _taskDefinitions[index];
              return _buildTaskDefinitionItem(task, index);
            },
          ),
      ],
    );
  }

  /// Build a task definition item
  Widget _buildTaskDefinitionItem(TaskDefinition task, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editTaskDefinition(index),
                  tooltip: 'Edit task',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeTaskDefinition(index),
                  tooltip: 'Remove task',
                ),
              ],
            ),
            if (task.description != null && task.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(task.description!),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(label: Text('${task.daysBeforeEvent} days before')),
                const SizedBox(width: 8),
                Chip(label: Text(task.service)),
                if (task.isImportant)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Chip(
                      label: Text('Important'),
                      backgroundColor: Colors.amber,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build the dependencies section
  Widget _buildDependenciesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dependencies',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _taskDefinitions.length >= 2 ? _addDependency : null,
              icon: const Icon(Icons.add),
              label: const Text('Add Dependency'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_dependencies.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No dependencies added yet.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _dependencies.length,
            itemBuilder: (context, index) {
              final dependency = _dependencies[index];
              return _buildDependencyItem(dependency, index);
            },
          ),
      ],
    );
  }

  /// Build a dependency item
  Widget _buildDependencyItem(TaskDependencyDefinition dependency, int index) {
    // Find the prerequisite and dependent tasks
    final prerequisiteTask = _taskDefinitions.firstWhere(
      (task) => task.id == dependency.prerequisiteTaskId,
      orElse:
          () => TaskDefinition(
            id: dependency.prerequisiteTaskId,
            title: 'Unknown Task',
            categoryId: '0',
            daysBeforeEvent: 0,
            service: 'Unknown',
          ),
    );

    final dependentTask = _taskDefinitions.firstWhere(
      (task) => task.id == dependency.dependentTaskId,
      orElse:
          () => TaskDefinition(
            id: dependency.dependentTaskId,
            title: 'Unknown Task',
            categoryId: '0',
            daysBeforeEvent: 0,
            service: 'Unknown',
          ),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${prerequisiteTask.title} → ${dependentTask.title}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeDependency(index),
                  tooltip: 'Remove dependency',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getDependencyTypeDescription(dependency.type),
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            if (dependency.offsetDays > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Offset: ${dependency.offsetDays} days'),
              ),
          ],
        ),
      ),
    );
  }

  /// Build the tags section
  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tags',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _addTag,
              icon: const Icon(Icons.add),
              label: const Text('Add Tag'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_tags.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No tags added yet.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                  );
                }).toList(),
          ),
      ],
    );
  }

  /// Add a task definition
  void _addTaskDefinition() {
    // TODO: Implement task definition form dialog
  }

  /// Edit a task definition
  void _editTaskDefinition(int index) {
    // TODO: Implement task definition form dialog
  }

  /// Remove a task definition
  void _removeTaskDefinition(int index) {
    setState(() {
      final removedTask = _taskDefinitions.removeAt(index);

      // Remove any dependencies that involve this task
      _dependencies.removeWhere(
        (dep) =>
            dep.prerequisiteTaskId == removedTask.id ||
            dep.dependentTaskId == removedTask.id,
      );
    });
  }

  /// Add a dependency
  void _addDependency() {
    // TODO: Implement dependency form dialog
  }

  /// Remove a dependency
  void _removeDependency(int index) {
    setState(() {
      _dependencies.removeAt(index);
    });
  }

  /// Add a tag
  void _addTag() {
    // TODO: Implement tag input dialog
  }

  /// Remove a tag
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  /// Get a description of a dependency type
  String _getDependencyTypeDescription(DependencyType type) {
    switch (type) {
      case DependencyType.finishToStart:
        return 'Finish-to-Start: The dependent task can start only after the prerequisite task finishes';
      case DependencyType.startToStart:
        return 'Start-to-Start: The dependent task can start only after the prerequisite task starts';
      case DependencyType.finishToFinish:
        return 'Finish-to-Finish: The dependent task can finish only after the prerequisite task finishes';
      case DependencyType.startToFinish:
        return 'Start-to-Finish: The dependent task can finish only after the prerequisite task starts';
    }
  }

  /// Save the template
  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_taskDefinitions.isEmpty) {
      setState(() {
        _errorMessage = 'Please add at least one task to the template';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = Provider.of<TaskTemplateProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId == null) {
        throw Exception('User not logged in');
      }

      if (_isEditMode) {
        // Update existing template
        final updatedTemplate = widget.template!.copyWith(
          name: _nameController.text,
          description: _descriptionController.text,
          eventType: _selectedEventType,
          taskDefinitions: _taskDefinitions,
          dependencies: _dependencies,
          tags: _tags,
        );

        final success = await provider.updateTemplate(updatedTemplate);

        if (mounted) {
          if (success) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Template updated successfully')),
            );
          } else {
            setState(() {
              _errorMessage = 'Failed to update template';
            });
          }
        }
      } else {
        // Create new template
        final templateId = await provider.createTemplate(
          name: _nameController.text,
          description: _descriptionController.text,
          eventType: _selectedEventType,
          userId: userId,
          taskDefinitions: _taskDefinitions,
          dependencies: _dependencies,
          tags: _tags,
        );

        if (mounted) {
          if (templateId != null) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Template created successfully')),
            );
          } else {
            setState(() {
              _errorMessage = 'Failed to create template';
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error saving template: $e';
        });
        Logger.e(_errorMessage!, tag: 'TaskTemplateFormScreen');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
