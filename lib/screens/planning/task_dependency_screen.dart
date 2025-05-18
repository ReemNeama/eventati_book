import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/models/planning_models/task_dependency.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/screens/planning/widgets/dependency_graph.dart';
import 'package:eventati_book/screens/planning/widgets/dependency_indicator.dart';
import 'package:eventati_book/screens/planning/widgets/task_card.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// Enum for the different view modes
enum ViewMode {
  /// List view mode
  list,

  /// Graph view mode
  graph,
}

/// Screen for managing task dependencies
class TaskDependencyScreen extends StatefulWidget {
  /// The ID of the event
  final String eventId;

  /// Optional ID of a specific task to focus on
  final String? focusedTaskId;

  /// Creates a new task dependency screen
  const TaskDependencyScreen({
    super.key,
    required this.eventId,
    this.focusedTaskId,
  });

  @override
  State<TaskDependencyScreen> createState() => _TaskDependencyScreenState();
}

class _TaskDependencyScreenState extends State<TaskDependencyScreen>
    with SingleTickerProviderStateMixin {
  /// The selected prerequisite task
  Task? _prerequisiteTask;

  /// The selected dependent task
  Task? _dependentTask;

  /// Whether the screen is in loading state
  bool _isLoading = false;

  /// Error message if an operation fails
  String? _errorMessage;

  // We'll use TabController instead of a separate view mode field

  /// Tab controller for switching between views
  late TabController _tabController;

  /// Whether a dependency is being created
  bool _isCreatingDependency = false;

  /// ID of the dependency being removed (format: "prerequisiteId_dependentId")
  String? _isRemovingDependencyId;

  /// Selected dependency type
  DependencyType _dependencyType = DependencyType.finishToStart;

  /// Offset days for the dependency
  int _offsetDays = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // Update UI when tab changes
        setState(() {});
      }
    });
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // If we have a focused task ID, set it as the prerequisite task
    if (widget.focusedTaskId != null && _prerequisiteTask == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);

        // Find the task with the focused ID
        final matchingTasks =
            taskProvider.tasks
                .where((task) => task.id == widget.focusedTaskId)
                .toList();

        if (matchingTasks.isNotEmpty) {
          setState(() {
            _prerequisiteTask = matchingTasks.first;
          });
        }
      });
    }
  }

  /// Load tasks from the provider
  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // No need to load tasks explicitly as they're already in the provider
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading tasks: $e';
      });
    }
  }

  /// Add a dependency between the selected tasks
  Future<bool> _addDependency() async {
    if (_prerequisiteTask == null || _dependentTask == null) {
      setState(() {
        _errorMessage = 'Please select both tasks';
      });
      return false;
    }

    if (_prerequisiteTask!.id == _dependentTask!.id) {
      setState(() {
        _errorMessage = 'A task cannot depend on itself';
      });
      return false;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      // Create a TaskDependency object with the selected type and offset days
      final dependency = TaskDependency(
        prerequisiteTaskId: _prerequisiteTask!.id,
        dependentTaskId: _dependentTask!.id,
        type: _dependencyType,
        offsetDays: _offsetDays,
      );

      // Add the dependency using the provider
      final success = await taskProvider.addDependencyWithDetails(dependency);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dependency added successfully'),
              backgroundColor: AppColors.success,
            ),
          );

          // Reset selections
          setState(() {
            _prerequisiteTask = null;
            _dependentTask = null;
            _errorMessage = null;
            // Reset dependency type and offset days to defaults
            _dependencyType = DependencyType.finishToStart;
            _offsetDays = 0;
          });
        }
        return true;
      } else {
        if (mounted) {
          setState(() {
            _errorMessage =
                'Failed to add dependency. It may create a circular reference.';
          });
        }
        return false;
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error adding dependency: $e';
      });
      return false;
    }
  }

  /// Remove a dependency between tasks
  Future<void> _removeDependency(
    String prerequisiteId,
    String dependentId,
  ) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final success = await taskProvider.removeDependency(
        prerequisiteId,
        dependentId,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dependency removed successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to remove dependency';
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error removing dependency: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Dependencies'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'List View'),
            Tab(icon: Icon(Icons.account_tree), text: 'Graph View'),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [_buildListView(), _buildGraphView()],
              ),
    );
  }

  /// Builds the list view of task dependencies
  Widget _buildListView() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.tasks;
        final dependencies = taskProvider.dependencies;
        final categories = taskProvider.categories;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(
                      AppColors.error.r.toInt(),
                      AppColors.error.g.toInt(),
                      AppColors.error.b.toInt(),
                      0.1,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyles.bodyMedium.copyWith(
                      color: Color.fromRGBO(
                        AppColors.error.r.toInt(),
                        AppColors.error.g.toInt(),
                        AppColors.error.b.toInt(),
                        0.9,
                      ),
                    ),
                  ),
                ),

              // Add new dependency section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New Dependency',
                        style: TextStyles.sectionTitle,
                      ),
                      const SizedBox(height: 16),

                      // Prerequisite task selection
                      Text(
                        'Prerequisite Task (Must be completed first):',
                        style: TextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Task cards for prerequisite selection
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            final category = categories.firstWhere(
                              (cat) => cat.id == task.categoryId,
                              orElse:
                                  () => TaskCategory(
                                    id: '0',
                                    name: 'Unknown',
                                    description: '',
                                    icon: 'help_outline',
                                    color: '#9E9E9E',
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                  ),
                            );

                            return SizedBox(
                              width: 250,
                              child: TaskCard(
                                task: task,
                                category: category,
                                isSelected: _prerequisiteTask?.id == task.id,
                                prerequisiteCount:
                                    taskProvider
                                        .getPrerequisiteTasks(task.id)
                                        .length,
                                dependentCount:
                                    taskProvider
                                        .getDependentTasks(task.id)
                                        .length,
                                onTap: () {
                                  setState(() {
                                    _prerequisiteTask =
                                        _prerequisiteTask?.id == task.id
                                            ? null
                                            : task;
                                    _errorMessage = null;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Dependency indicator
                      if (_prerequisiteTask != null && _dependentTask != null)
                        Center(
                          child: DependencyIndicator(
                            isCreating: _isCreatingDependency,
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Dependent task selection
                      Text(
                        'Dependent Task (Can only start after prerequisite):',
                        style: TextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Task cards for dependent selection
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            final category = categories.firstWhere(
                              (cat) => cat.id == task.categoryId,
                              orElse:
                                  () => TaskCategory(
                                    id: '0',
                                    name: 'Unknown',
                                    description: '',
                                    icon: 'help_outline',
                                    color: '#9E9E9E',
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                  ),
                            );

                            // Don't allow selecting the same task as both prerequisite and dependent
                            if (_prerequisiteTask?.id == task.id) {
                              return const SizedBox.shrink();
                            }

                            return SizedBox(
                              width: 250,
                              child: TaskCard(
                                task: task,
                                category: category,
                                isSelected: _dependentTask?.id == task.id,
                                prerequisiteCount:
                                    taskProvider
                                        .getPrerequisiteTasks(task.id)
                                        .length,
                                dependentCount:
                                    taskProvider
                                        .getDependentTasks(task.id)
                                        .length,
                                onTap: () {
                                  setState(() {
                                    _dependentTask =
                                        _dependentTask?.id == task.id
                                            ? null
                                            : task;
                                    _errorMessage = null;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Dependency type selection
                      Text(
                        'Dependency Type:',
                        style: TextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      DropdownButtonFormField<DependencyType>(
                        value: _dependencyType,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items:
                            DependencyType.values.map((type) {
                              String label;
                              switch (type) {
                                case DependencyType.finishToStart:
                                  label = 'Finish-to-Start (most common)';
                                  break;
                                case DependencyType.startToStart:
                                  label = 'Start-to-Start';
                                  break;
                                case DependencyType.finishToFinish:
                                  label = 'Finish-to-Finish';
                                  break;
                                case DependencyType.startToFinish:
                                  label = 'Start-to-Finish';
                                  break;
                              }
                              return DropdownMenuItem<DependencyType>(
                                value: type,
                                child: Text(label),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _dependencyType = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Offset days selection
                      Text(
                        'Offset Days:',
                        style: TextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _offsetDays.toDouble(),
                              min: 0,
                              max: 30,
                              divisions: 30,
                              label: _offsetDays.toString(),
                              onChanged: (value) {
                                setState(() {
                                  _offsetDays = value.round();
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              controller: TextEditingController(
                                text: _offsetDays.toString(),
                              ),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                suffixText: 'days',
                              ),
                              onChanged: (value) {
                                final days = int.tryParse(value);
                                if (days != null && days >= 0 && days <= 30) {
                                  setState(() {
                                    _offsetDays = days;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      // Dependency explanation
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(
                            AppColors.primary.r.toInt(),
                            AppColors.primary.g.toInt(),
                            AppColors.primary.b.toInt(),
                            0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Color.fromRGBO(
                              AppColors.primary.r.toInt(),
                              AppColors.primary.g.toInt(),
                              AppColors.primary.b.toInt(),
                              0.3,
                            ),
                          ),
                        ),
                        child: Text(
                          _getDependencyExplanation(),
                          style: TextStyles.bodySmall.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Add button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              _isCreatingDependency
                                  ? null
                                  : () {
                                    setState(() {
                                      _isCreatingDependency = true;
                                    });
                                    _addDependency().then((_) {
                                      setState(() {
                                        _isCreatingDependency = false;
                                      });
                                    });
                                  },
                          icon:
                              _isCreatingDependency
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Icon(Icons.link),
                          label: Text(
                            _isCreatingDependency
                                ? 'Creating...'
                                : 'Create Dependency',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Existing dependencies section
              Text('Existing Dependencies', style: TextStyles.sectionTitle),
              const SizedBox(height: 8),

              Expanded(
                child:
                    dependencies.isEmpty
                        ? Center(
                          child: Text(
                            'No dependencies yet',
                            style: TextStyles.bodyLarge.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                        : ListView.builder(
                          itemCount: dependencies.length,
                          itemBuilder: (context, index) {
                            final dependency = dependencies[index];

                            // Find the task objects
                            final prerequisiteTask = tasks.firstWhere(
                              (task) =>
                                  task.id == dependency.prerequisiteTaskId,
                              orElse:
                                  () => Task(
                                    id: dependency.prerequisiteTaskId,
                                    title: 'Unknown Task',
                                    categoryId: '0',
                                    dueDate: DateTime.now(),
                                    status: TaskStatus.notStarted,
                                  ),
                            );

                            final dependentTask = tasks.firstWhere(
                              (task) => task.id == dependency.dependentTaskId,
                              orElse:
                                  () => Task(
                                    id: dependency.dependentTaskId,
                                    title: 'Unknown Task',
                                    categoryId: '0',
                                    dueDate: DateTime.now(),
                                    status: TaskStatus.notStarted,
                                  ),
                            );

                            // Find categories
                            final prerequisiteCategory = categories.firstWhere(
                              (cat) => cat.id == prerequisiteTask.categoryId,
                              orElse:
                                  () => TaskCategory(
                                    id: '0',
                                    name: 'Unknown',
                                    description: '',
                                    icon: 'help_outline',
                                    color: '#9E9E9E',
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                  ),
                            );

                            final dependentCategory = categories.firstWhere(
                              (cat) => cat.id == dependentTask.categoryId,
                              orElse:
                                  () => TaskCategory(
                                    id: '0',
                                    name: 'Unknown',
                                    description: '',
                                    icon: 'help_outline',
                                    color: '#9E9E9E',
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                  ),
                            );

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Prerequisite task
                                    Row(
                                      children: [
                                        Icon(
                                          prerequisiteCategory.getIconData(),
                                          color:
                                              prerequisiteCategory
                                                  .getColorObject(),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            prerequisiteTask.title,
                                            style: TextStyles.bodyLarge
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                        _buildStatusChip(
                                          prerequisiteTask.status,
                                        ),
                                      ],
                                    ),

                                    // Dependency indicator and type
                                    Center(
                                      child: Column(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: DependencyIndicator(),
                                          ),
                                          // We can't directly access dependency type from TaskDependencySimple
                                          // So we'll just show a generic message
                                          Text(
                                            'Dependency',
                                            style: TextStyles.bodySmall
                                                .copyWith(
                                                  fontStyle: FontStyle.italic,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Dependent task
                                    Row(
                                      children: [
                                        Icon(
                                          dependentCategory.getIconData(),
                                          color:
                                              dependentCategory
                                                  .getColorObject(),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            dependentTask.title,
                                            style: TextStyles.bodyLarge
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                        _buildStatusChip(dependentTask.status),
                                      ],
                                    ),

                                    // Remove button
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        onPressed:
                                            _isLoading
                                                ? null
                                                : () {
                                                  setState(() {
                                                    _isRemovingDependencyId =
                                                        '${dependency.prerequisiteTaskId}_${dependency.dependentTaskId}';
                                                  });
                                                  _removeDependency(
                                                    dependency
                                                        .prerequisiteTaskId,
                                                    dependency.dependentTaskId,
                                                  ).then((_) {
                                                    setState(() {
                                                      _isRemovingDependencyId =
                                                          null;
                                                    });
                                                  });
                                                },
                                        icon:
                                            _isRemovingDependencyId ==
                                                    '${dependency.prerequisiteTaskId}_${dependency.dependentTaskId}'
                                                ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(AppColors.error),
                                                  ),
                                                )
                                                : const Icon(
                                                  Icons.delete,
                                                  color: AppColors.error,
                                                ),
                                        label: Text(
                                          _isRemovingDependencyId ==
                                                  '${dependency.prerequisiteTaskId}_${dependency.dependentTaskId}'
                                              ? 'Removing...'
                                              : 'Remove Dependency',
                                          style: TextStyles.bodyMedium.copyWith(
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the graph view of task dependencies
  Widget _buildGraphView() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.tasks;
        final dependencies = taskProvider.dependencies;
        final categories = taskProvider.categories;

        if (tasks.isEmpty) {
          return Center(
            child: Text('No tasks available', style: TextStyles.bodyLarge),
          );
        }

        return DependencyGraph(
          tasks: tasks,
          categories: categories,
          dependencies: dependencies,
          onTaskSelected: (task) {
            setState(() {
              if (_prerequisiteTask == null) {
                _prerequisiteTask = task;
              } else if (_dependentTask == null &&
                  _prerequisiteTask?.id != task.id) {
                _dependentTask = task;
              } else {
                _prerequisiteTask = task;
                _dependentTask = null;
              }
            });
          },
        );
      },
    );
  }

  /// Gets an explanation of the current dependency type and offset
  String _getDependencyExplanation() {
    String explanation;

    switch (_dependencyType) {
      case DependencyType.finishToStart:
        if (_offsetDays == 0) {
          explanation =
              'The dependent task can start only after the prerequisite task finishes.';
        } else {
          explanation =
              'The dependent task can start only $_offsetDays days after the prerequisite task finishes.';
        }
        break;
      case DependencyType.startToStart:
        if (_offsetDays == 0) {
          explanation =
              'The dependent task can start only after the prerequisite task starts.';
        } else {
          explanation =
              'The dependent task can start only $_offsetDays days after the prerequisite task starts.';
        }
        break;
      case DependencyType.finishToFinish:
        if (_offsetDays == 0) {
          explanation =
              'The dependent task can finish only after the prerequisite task finishes.';
        } else {
          explanation =
              'The dependent task can finish only $_offsetDays days after the prerequisite task finishes.';
        }
        break;
      case DependencyType.startToFinish:
        if (_offsetDays == 0) {
          explanation =
              'The dependent task can finish only after the prerequisite task starts.';
        } else {
          explanation =
              'The dependent task can finish only $_offsetDays days after the prerequisite task starts.';
        }
        break;
    }

    return explanation;
  }

  /// Builds a status chip for a task
  Widget _buildStatusChip(TaskStatus status) {
    Color color;
    String label;

    switch (status) {
      case TaskStatus.completed:
        color = AppColors.success;
        label = 'Completed';
        break;
      case TaskStatus.inProgress:
        color = AppColors.primary;
        label = 'In Progress';
        break;
      case TaskStatus.overdue:
        color = AppColors.error;
        label = 'Overdue';
        break;
      case TaskStatus.notStarted:
        color = AppColors.disabled;
        label = 'Not Started';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color.fromRGBO(
          color.r.toInt(),
          color.g.toInt(),
          color.b.toInt(),
          0.2,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(label, style: TextStyles.bodySmall.copyWith(color: color)),
    );
  }
}
