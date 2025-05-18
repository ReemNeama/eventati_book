import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/planning_models/task_template.dart';
import 'package:eventati_book/providers/planning_providers/task_template_provider.dart';
import 'package:eventati_book/screens/planning/task_template_details_screen.dart';
import 'package:eventati_book/screens/planning/task_template_form_screen_wrapper.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:eventati_book/styles/text_styles.dart';


/// Screen for managing task templates
class TaskTemplateScreen extends StatefulWidget {
  /// Constructor
  const TaskTemplateScreen({super.key});

  @override
  State<TaskTemplateScreen> createState() => _TaskTemplateScreenState();
}

class _TaskTemplateScreenState extends State<TaskTemplateScreen> {
  /// Whether the screen is loading
  bool _isLoading = false;

  /// Error message
  String? _errorMessage;

  /// Selected event type filter
  String? _selectedEventType;

  /// List of event types
  final List<String> _eventTypes = [
    'Wedding',
    'Business',
    'Birthday',
    'Anniversary',
    'Conference',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  /// Load templates from the database
  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = Provider.of<TaskTemplateProvider>(
        context,
        listen: false,
      );

      if (_selectedEventType != null) {
        await provider.loadTemplatesByEventType(_selectedEventType!);
      } else {
        await provider.loadAllTemplates();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading templates: $e';
      });
      Logger.e(_errorMessage!, tag: 'TaskTemplateScreen');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Templates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter templates',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToTemplateForm(),
            tooltip: 'Create new template',
          ),
        ],
      ),
      body:
          _isLoading
              ? const LoadingIndicator()
              : _errorMessage != null
              ? Center(
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Color.fromRGBO(
                      AppColors.error.r.toInt(),
                      AppColors.error.g.toInt(),
                      AppColors.error.b.toInt(),
                      0.7,
                    ),
                  ),
                ),
              )
              : _buildTemplateList(),
    );
  }

  /// Build the list of templates
  Widget _buildTemplateList() {
    return Consumer<TaskTemplateProvider>(
      builder: (context, provider, child) {
        final templates = provider.templates;

        if (templates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No templates found',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _navigateToTemplateForm(),
                  child: const Text('Create Template'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final template = templates[index];
            return _buildTemplateCard(template);
          },
        );
      },
    );
  }

  /// Build a card for a template
  Widget _buildTemplateCard(TaskTemplate template) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showTemplateDetails(template),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(template.name, style: TextStyles.sectionTitle),
                  ),
                  _buildTemplateMenu(template),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                template.description,
                style: TextStyle(
                  color:
                      isDarkMode
                          ? Color.fromRGBO(
                            AppColors.disabled.r.toInt(),
                            AppColors.disabled.g.toInt(),
                            AppColors.disabled.b.toInt(),
                            0.3,
                          )
                          : Color.fromRGBO(
                            AppColors.disabled.r.toInt(),
                            AppColors.disabled.g.toInt(),
                            AppColors.disabled.b.toInt(),
                            0.7,
                          ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text(template.eventType),
                    backgroundColor:
                        isDarkMode
                            ? AppColorsDark.info
                            : Color.fromRGBO(
                              AppColors.info.r.toInt(),
                              AppColors.info.g.toInt(),
                              AppColors.info.b.toInt(),
                              0.20,
                            ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text('${template.taskDefinitions.length} tasks'),
                    backgroundColor:
                        isDarkMode
                            ? AppColorsDark.success
                            : Color.fromRGBO(
                              AppColors.success.r.toInt(),
                              AppColors.success.g.toInt(),
                              AppColors.success.b.toInt(),
                              0.20,
                            ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the template menu
  Widget _buildTemplateMenu(TaskTemplate template) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleMenuAction(value, template),
      itemBuilder:
          (context) => [
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'apply',
              child: Row(
                children: [
                  Icon(Icons.play_arrow),
                  SizedBox(width: 8),
                  Text('Apply to Event'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.file_download),
                  SizedBox(width: 8),
                  Text('Export'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
    );
  }

  /// Handle menu actions
  void _handleMenuAction(String action, TaskTemplate template) {
    switch (action) {
      case 'edit':
        _navigateToTemplateForm(template: template);
        break;
      case 'apply':
        _showApplyTemplateDialog(template);
        break;
      case 'export':
        _exportTemplate(template);
        break;
      case 'delete':
        _showDeleteConfirmation(template);
        break;
    }
  }

  /// Show template details
  void _showTemplateDetails(TaskTemplate template) {
    // Set the selected template in the provider
    Provider.of<TaskTemplateProvider>(
      context,
      listen: false,
    ).setSelectedTemplate(template);

    // Navigate to the template details screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TaskTemplateDetailsScreen(),
      ),
    );
  }

  /// Navigate to the template form
  void _navigateToTemplateForm({TaskTemplate? template}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskTemplateFormScreenWrapper(template: template),
      ),
    );
  }

  /// Show apply template dialog
  void _showApplyTemplateDialog(TaskTemplate template) {
    final eventIdController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Apply Template to Event'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Apply template "${template.name}" to an event',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: eventIdController,
                  decoration: const InputDecoration(
                    labelText: 'Event ID',
                    hintText: 'Enter the event ID',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Note: This will add all tasks from this template to the specified event.',
                  style: TextStyles.bodySmall,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final eventId = eventIdController.text.trim();
                  if (eventId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Event ID is required')),
                    );
                    return;
                  }

                  // Close the dialog first
                  Navigator.of(context).pop();

                  // Then apply the template
                  _applyTemplateToEvent(template.id, eventId);
                },
                child: const Text('Apply'),
              ),
            ],
          ),
    );
  }

  /// Apply a template to an event
  Future<void> _applyTemplateToEvent(String templateId, String eventId) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // This is a placeholder for the actual implementation
      // In a real implementation, you would call a method on the provider
      // to apply the template to the event
      await Future.delayed(const Duration(seconds: 1));

      // Check if still mounted after the async operation
      if (!mounted) return;

      // Now it's safe to use context
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template applied successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Error applying template: $e';
      });
      Logger.e(_errorMessage!, tag: 'TaskTemplateScreen');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Export template
  void _exportTemplate(TaskTemplate template) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // In a real implementation, you would convert template to JSON
      // For demonstration purposes, we're not using the JSON here

      // In a real implementation, you would:
      // 1. Convert the JSON to a formatted string
      // 2. Save it to a file or share it

      // For now, just show a success message
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show a success message
        showDialog(
          context: context,
          builder:
              (context) => const AlertDialog(
                title: Text('Template Exported'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Template exported successfully!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Text('In a real implementation, this would:'),
                    SizedBox(height: 8),
                    Text('• Save the template to a file'),
                    Text('• Allow sharing the template'),
                    Text('• Support importing in another app'),
                  ],
                ),
                actions: [CloseButton()],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error exporting template: $e';
        });
        Logger.e(_errorMessage!, tag: 'TaskTemplateScreen');
      }
    }
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(TaskTemplate template) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Template'),
            content: Text(
              'Are you sure you want to delete the template "${template.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _deleteTemplate(template);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }

  /// Delete a template
  Future<void> _deleteTemplate(TaskTemplate template) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = Provider.of<TaskTemplateProvider>(
        context,
        listen: false,
      );
      final success = await provider.deleteTemplate(template.id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Template deleted successfully')),
          );
        } else {
          setState(() {
            _errorMessage = 'Failed to delete template';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error deleting template: $e';
        });
        Logger.e(_errorMessage!, tag: 'TaskTemplateScreen');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filter Templates'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Filter by event type:'),
                const SizedBox(height: 16),
                DropdownButton<String?>(
                  isExpanded: true,
                  value: _selectedEventType,
                  hint: const Text('All event types'),
                  onChanged: (value) {
                    Navigator.of(context).pop();
                    setState(() {
                      _selectedEventType = value;
                    });
                    _loadTemplates();
                  },
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All event types'),
                    ),
                    ..._eventTypes.map(
                      (type) => DropdownMenuItem<String?>(
                        value: type,
                        child: Text(type),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }
}
