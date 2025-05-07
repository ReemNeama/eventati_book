import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';

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

class _TaskDependencyScreenState extends State<TaskDependencyScreen> {
  /// The selected prerequisite task
  Task? _prerequisiteTask;

  /// The selected dependent task
  Task? _dependentTask;

  /// Whether the screen is in loading state
  bool _isLoading = false;

  /// Error message if an operation fails
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTasks();
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
  void _addDependency() {
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

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final success = taskProvider.addDependency(
      _prerequisiteTask!.id,
      _dependentTask!.id,
    );

    if (success) {
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
    } else {
      setState(() {
        _errorMessage =
            'Failed to add dependency. It may create a circular reference.';
      });
    }
  }

  /// Remove a dependency between tasks
  void _removeDependency(String prerequisiteId, String dependentId) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final success = taskProvider.removeDependency(prerequisiteId, dependentId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dependency removed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Failed to remove dependency';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Dependencies')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.tasks;
        final dependencies = taskProvider.dependencies;

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

                      // Prerequisite task dropdown
                      DropdownButtonFormField<Task>(
                        decoration: const InputDecoration(
                          labelText:
                              'Prerequisite Task (Must be completed first)',
                          border: OutlineInputBorder(),
                        ),
                        value: _prerequisiteTask,
                        items:
                            tasks.map((task) {
                              return DropdownMenuItem<Task>(
                                value: task,
                                child: Text(
                                  task.title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                        onChanged: (Task? newValue) {
                          setState(() {
                            _prerequisiteTask = newValue;
                            _errorMessage = null;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Dependent task dropdown
                      DropdownButtonFormField<Task>(
                        decoration: const InputDecoration(
                          labelText:
                              'Dependent Task (Can only start after prerequisite)',
                          border: OutlineInputBorder(),
                        ),
                        value: _dependentTask,
                        items:
                            tasks.map((task) {
                              return DropdownMenuItem<Task>(
                                value: task,
                                child: Text(
                                  task.title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                        onChanged: (Task? newValue) {
                          setState(() {
                            _dependentTask = newValue;
                            _errorMessage = null;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Add button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addDependency,
                          child: const Text('Add Dependency'),
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

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              child: ListTile(
                                title: Text(prerequisiteTask.title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    const Text('Must be completed before:'),
                                    Text(
                                      dependentTask.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed:
                                      () => _removeDependency(
                                        dependency.prerequisiteTaskId,
                                        dependency.dependentTaskId,
                                      ),
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
}
