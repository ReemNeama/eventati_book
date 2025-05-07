import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/screens/planning/widgets/dependency_graph.dart';
import 'package:eventati_book/screens/planning/widgets/dependency_indicator.dart';
import 'package:eventati_book/screens/planning/widgets/task_card.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/utils/core/constants.dart';

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

  /// The current view mode (list or graph)
  ViewMode _viewMode = ViewMode.list;

  /// Tab controller for switching between views
  late TabController _tabController;

  /// Whether a dependency is being created
  bool _isCreatingDependency = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _viewMode =
              _tabController.index == 0 ? ViewMode.list : ViewMode.graph;
        });
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
      final success = await taskProvider.addDependency(
        _prerequisiteTask!.id,
        _dependentTask!.id,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dependency added successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Reset selections
          setState(() {
            _prerequisiteTask = null;
            _dependentTask = null;
            _errorMessage = null;
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
              backgroundColor: Colors.green,
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
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),

              // Add new dependency section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add New Dependency',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Prerequisite task selection
                      const Text(
                        'Prerequisite Task (Must be completed first):',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                                    icon: Icons.help_outline,
                                    color: Colors.grey,
                                  ),
                            );

                            return SizedBox(
                              width: 250,
                              child: TaskCard(
                                task: task,
                                category: category,
                                isSelected: _prerequisiteTask?.id == task.id,
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
                      const Text(
                        'Dependent Task (Can only start after prerequisite):',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                                    icon: Icons.help_outline,
                                    color: Colors.grey,
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

                      const SizedBox(height: 24),

                      // Add button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isCreatingDependency = true;
                            });
                            _addDependency().then((_) {
                              setState(() {
                                _isCreatingDependency = false;
                              });
                            });
                          },
                          icon: const Icon(Icons.link),
                          label: const Text('Create Dependency'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Existing dependencies section
              const Text(
                'Existing Dependencies',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Expanded(
                child:
                    dependencies.isEmpty
                        ? const Center(
                          child: Text(
                            'No dependencies yet',
                            style: TextStyle(
                              fontSize: 16,
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
                                    icon: Icons.help_outline,
                                    color: Colors.grey,
                                  ),
                            );

                            final dependentCategory = categories.firstWhere(
                              (cat) => cat.id == dependentTask.categoryId,
                              orElse:
                                  () => TaskCategory(
                                    id: '0',
                                    name: 'Unknown',
                                    icon: Icons.help_outline,
                                    color: Colors.grey,
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
                                          prerequisiteCategory.icon,
                                          color: prerequisiteCategory.color,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            prerequisiteTask.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        _buildStatusChip(
                                          prerequisiteTask.status,
                                        ),
                                      ],
                                    ),

                                    // Dependency indicator
                                    const Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: DependencyIndicator(),
                                      ),
                                    ),

                                    // Dependent task
                                    Row(
                                      children: [
                                        Icon(
                                          dependentCategory.icon,
                                          color: dependentCategory.color,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            dependentTask.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
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
                                            () => _removeDependency(
                                              dependency.prerequisiteTaskId,
                                              dependency.dependentTaskId,
                                            ),
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        label: const Text(
                                          'Remove Dependency',
                                          style: TextStyle(color: Colors.red),
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
          return const Center(
            child: Text('No tasks available', style: TextStyle(fontSize: 16)),
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

  /// Builds a status chip for a task
  Widget _buildStatusChip(TaskStatus status) {
    Color color;
    String label;

    switch (status) {
      case TaskStatus.completed:
        color = Colors.green;
        label = 'Completed';
        break;
      case TaskStatus.inProgress:
        color = Colors.blue;
        label = 'In Progress';
        break;
      case TaskStatus.overdue:
        color = Colors.red;
        label = 'Overdue';
        break;
      case TaskStatus.notStarted:
        color = Colors.grey;
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
      child: Text(label, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}
