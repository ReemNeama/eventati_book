import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/planning_models/task_dependency.dart';
import 'package:eventati_book/models/planning_models/task_template.dart';
import 'package:eventati_book/providers/planning_providers/task_template_provider.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:eventati_book/widgets/common/error_message.dart';
import 'package:eventati_book/styles/app_colors.dart';

/// Screen to display task template details
class TaskTemplateDetailsScreen extends StatefulWidget {
  /// Constructor
  const TaskTemplateDetailsScreen({super.key});

  @override
  State<TaskTemplateDetailsScreen> createState() =>
      _TaskTemplateDetailsScreenState();
}

class _TaskTemplateDetailsScreenState extends State<TaskTemplateDetailsScreen> {
  // Using final ValueNotifiers to satisfy the linter
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessage = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _isLoading.dispose();
    _errorMessage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskTemplateProvider>(
      builder: (context, provider, child) {
        final template = provider.selectedTemplate;

        if (template == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Template Details')),
            body: const Center(child: Text('No template selected')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Template Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Template',
                onPressed: () => _navigateToTemplateForm(template),
              ),
              IconButton(
                icon: const Icon(Icons.play_arrow),
                tooltip: 'Apply Template',
                onPressed: () => _showApplyTemplateDialog(template),
              ),
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'Export Template',
                onPressed: () => _exportTemplate(template),
              ),
            ],
          ),
          body: ValueListenableBuilder<bool>(
            valueListenable: _isLoading,
            builder: (context, isLoading, _) {
              if (isLoading) {
                return const LoadingIndicator();
              }

              return ValueListenableBuilder<String?>(
                valueListenable: _errorMessage,
                builder: (context, errorMessage, _) {
                  if (errorMessage != null) {
                    return ErrorMessage(message: errorMessage);
                  }

                  return _buildTemplateDetails(template);
                },
              );
            },
          ),
        );
      },
    );
  }

  /// Build the template details
  Widget _buildTemplateDetails(TaskTemplate template) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTemplateHeader(template),
          const Divider(height: 32),
          _buildTasksList(template),
          const Divider(height: 32),
          _buildDependenciesList(template),
          const Divider(height: 32),
          _buildTagsList(template),
        ],
      ),
    );
  }

  /// Build the template header
  Widget _buildTemplateHeader(TaskTemplate template) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(template.name, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Event Type: ${template.eventType}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          template.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(
              template.isSystemTemplate ? Icons.public : Icons.person,
              size: 16,
              color: AppColors.disabled,
            ),
            const SizedBox(width: 8),
            Text(
              template.isSystemTemplate ? 'System Template' : 'User Template',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.disabled),
            ),
          ],
        ),
      ],
    );
  }

  /// Build the tasks list
  Widget _buildTasksList(TaskTemplate template) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tasks (${template.taskDefinitions.length})',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (template.taskDefinitions.isEmpty)
          const Text('No tasks defined for this template')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: template.taskDefinitions.length,
            itemBuilder: (context, index) {
              final task = template.taskDefinitions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.description ?? ''),
                  trailing: Text('${task.daysBeforeEvent} days before'),
                  leading:
                      task.isImportant
                          ? const Icon(Icons.star, color: AppColors.ratingStarColor)
                          : const Icon(Icons.check_circle_outline),
                ),
              );
            },
          ),
      ],
    );
  }

  /// Build the dependencies list
  Widget _buildDependenciesList(TaskTemplate template) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dependencies (${template.dependencies.length})',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (template.dependencies.isEmpty)
          const Text('No dependencies defined for this template')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: template.dependencies.length,
            itemBuilder: (context, index) {
              final dependency = template.dependencies[index];

              // Find the task names
              final prerequisiteTask = template.taskDefinitions.firstWhere(
                (task) => task.id == dependency.prerequisiteTaskId,
                orElse:
                    () => TaskDefinition(
                      id: dependency.prerequisiteTaskId,
                      title: 'Unknown Task',
                      categoryId: '1',
                      daysBeforeEvent: 0,
                      service: 'Unknown',
                    ),
              );

              final dependentTask = template.taskDefinitions.firstWhere(
                (task) => task.id == dependency.dependentTaskId,
                orElse:
                    () => TaskDefinition(
                      id: dependency.dependentTaskId,
                      title: 'Unknown Task',
                      categoryId: '1',
                      daysBeforeEvent: 0,
                      service: 'Unknown',
                    ),
              );

              // Get dependency type text
              String dependencyTypeText;
              switch (dependency.type) {
                case DependencyType.finishToStart:
                  dependencyTypeText = 'must finish before';
                  break;
                case DependencyType.startToStart:
                  dependencyTypeText = 'must start before';
                  break;
                case DependencyType.finishToFinish:
                  dependencyTypeText = 'must finish before finishing';
                  break;
                case DependencyType.startToFinish:
                  dependencyTypeText = 'must start before finishing';
                  break;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${prerequisiteTask.title} $dependencyTypeText ${dependentTask.title}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (dependency.offsetDays > 0)
                        Text(
                          'Offset: ${dependency.offsetDays} days',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  /// Build the tags list
  Widget _buildTagsList(TaskTemplate template) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags (${template.tags.length})',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (template.tags.isEmpty)
          const Text('No tags for this template')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                template.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                      ),
                    )
                    .toList(),
          ),
      ],
    );
  }

  /// Navigate to the template form
  void _navigateToTemplateForm(TaskTemplate template) {
    // Implementation will be added in the task_template_screen.dart file
    Navigator.pop(context); // Return to the templates screen
  }

  /// Show apply template dialog
  void _showApplyTemplateDialog(TaskTemplate template) {
    // Implementation will be added in the task_template_screen.dart file
    Navigator.pop(context); // Return to the templates screen
  }

  /// Export template
  void _exportTemplate(TaskTemplate template) {
    // Implementation will be added in the task_template_screen.dart file
    Navigator.pop(context); // Return to the templates screen
  }
}
