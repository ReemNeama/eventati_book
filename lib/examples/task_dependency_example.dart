import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/planning_models/task.dart';
import 'package:eventati_book/models/planning_models/task_category.dart';
import 'package:eventati_book/providers/planning_providers/task_provider.dart';

/// Example app demonstrating task dependency functionality
class TaskDependencyExample extends StatefulWidget {
  /// Creates a new task dependency example
  const TaskDependencyExample({super.key});

  @override
  State<TaskDependencyExample> createState() => _TaskDependencyExampleState();
}

class _TaskDependencyExampleState extends State<TaskDependencyExample> {
  /// The event ID for this example
  final String eventId = 'example_event';

  /// The selected prerequisite task
  Task? _prerequisiteTask;

  /// The selected dependent task
  Task? _dependentTask;

  /// Error message to display
  String? _errorMessage;

  /// Whether the app is loading
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Dependency Example')),
      body: ChangeNotifierProvider(
        create:
            (_) => TaskProvider(
              eventId: eventId,
              loadFromDatabase: false, // Use mock data for example
            ),
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instructions
                  const Text(
                    'This example demonstrates how to use the task dependency system. '
                    'Select a prerequisite task and a dependent task, then click "Add Dependency" '
                    'to create a dependency between them.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),

                  // Prerequisite task selection
                  const Text(
                    'Prerequisite Task (Must be completed first):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildTaskList(taskProvider, (task) {
                    setState(() {
                      _prerequisiteTask =
                          _prerequisiteTask?.id == task.id ? null : task;
                      _errorMessage = null;
                    });
                  }, _prerequisiteTask),

                  const SizedBox(height: 24),

                  // Dependent task selection
                  const Text(
                    'Dependent Task (Can only start after prerequisite):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildTaskList(taskProvider, (task) {
                    setState(() {
                      _dependentTask =
                          _dependentTask?.id == task.id ? null : task;
                      _errorMessage = null;
                    });
                  }, _dependentTask),

                  const SizedBox(height: 24),

                  // Add dependency button
                  Center(
                    child: ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () => _addDependency(taskProvider),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Add Dependency'),
                    ),
                  ),

                  // Error message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Dependencies list
                  const Text(
                    'Current Dependencies:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: _buildDependenciesList(taskProvider)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds a list of tasks
  Widget _buildTaskList(
    TaskProvider taskProvider,
    Function(Task) onTaskSelected,
    Task? selectedTask,
  ) {
    final tasks = taskProvider.tasks;
    final categories = taskProvider.categories;

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final category = categories.firstWhere(
            (c) => c.id == task.categoryId,
            orElse:
                () => TaskCategory(
                  id: '',
                  name: 'Unknown',
                  description: 'Unknown category',
                  color: '#CCCCCC',
                  icon: 'help',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
          );

          return Card(
            color:
                selectedTask?.id == task.id
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
            margin: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => onTaskSelected(task),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          IconData(
                            int.parse(
                              '0xe${category.icon.substring(1)}',
                              radix: 16,
                            ),
                            fontFamily: 'MaterialIcons',
                          ),
                          color: Color(
                            int.parse(category.color.substring(1), radix: 16) +
                                0xFF000000,
                          ),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          category.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Due: ${task.dueDate.toString().substring(0, 10)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds a list of dependencies
  Widget _buildDependenciesList(TaskProvider taskProvider) {
    final tasks = taskProvider.tasks;
    final dependencies = taskProvider.dependencies;

    if (dependencies.isEmpty) {
      return const Center(child: Text('No dependencies yet'));
    }

    return ListView.builder(
      itemCount: dependencies.length,
      itemBuilder: (context, index) {
        final dependency = dependencies[index];
        final prerequisiteTask = tasks.firstWhere(
          (t) => t.id == dependency.prerequisiteTaskId,
          orElse:
              () => Task(
                id: dependency.prerequisiteTaskId,
                title: 'Unknown Task',
                dueDate: DateTime.now(),
                categoryId: '',
              ),
        );
        final dependentTask = tasks.firstWhere(
          (t) => t.id == dependency.dependentTaskId,
          orElse:
              () => Task(
                id: dependency.dependentTaskId,
                title: 'Unknown Task',
                dueDate: DateTime.now(),
                categoryId: '',
              ),
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prerequisiteTask.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text('must be completed before'),
                      Text(
                        dependentTask.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed:
                      () => _removeDependency(
                        taskProvider,
                        dependency.prerequisiteTaskId,
                        dependency.dependentTaskId,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Add a dependency between the selected tasks
  Future<void> _addDependency(TaskProvider taskProvider) async {
    if (_prerequisiteTask == null || _dependentTask == null) {
      setState(() {
        _errorMessage = 'Please select both tasks';
      });
      return;
    }

    if (_prerequisiteTask!.id == _dependentTask!.id) {
      setState(() {
        _errorMessage = 'A task cannot depend on itself';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await taskProvider.addDependency(
        _prerequisiteTask!.id,
        _dependentTask!.id,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Reset selections
        setState(() {
          _prerequisiteTask = null;
          _dependentTask = null;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to add dependency. It may create a circular reference.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error adding dependency: $e';
      });
    }
  }

  /// Remove a dependency between tasks
  Future<void> _removeDependency(
    TaskProvider taskProvider,
    String prerequisiteId,
    String dependentId,
  ) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await taskProvider.removeDependency(
        prerequisiteId,
        dependentId,
      );

      setState(() {
        _isLoading = false;
      });

      if (!success) {
        setState(() {
          _errorMessage = 'Failed to remove dependency';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error removing dependency: $e';
      });
    }
  }
}
