import 'dart:async';
import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/firebase/firestore/task_firestore_service.dart';

/// Represents a dependency between two tasks
class TaskDependency {
  /// The ID of the prerequisite task that must be completed first
  final String prerequisiteTaskId;

  /// The ID of the dependent task that can only be started after the prerequisite
  final String dependentTaskId;

  /// Creates a new task dependency
  TaskDependency({
    required this.prerequisiteTaskId,
    required this.dependentTaskId,
  });
}

/// Provider for managing tasks and checklists for an event.
///
/// The TaskProvider is responsible for:
/// * Managing tasks and task categories
/// * Tracking task status and completion
/// * Organizing tasks by category and due date
/// * Calculating task statistics and progress
/// * Identifying overdue and upcoming tasks
///
/// Each event has its own task list, identified by the eventId.
/// This provider currently uses mock data, but would connect to a
/// database or API in a production environment.
///
/// Usage example:
/// ```dart
/// // Create a provider for a specific event
/// final taskProvider = TaskProvider(eventId: 'event123');
///
/// // Access the provider from the widget tree
/// final taskProvider = Provider.of<TaskProvider>(context);
///
/// // Get task statistics
/// final totalTasks = taskProvider.totalTasks;
/// final completedTasks = taskProvider.completedTasks;
/// final completionPercentage = taskProvider.completionPercentage;
///
/// // Get tasks by category
/// final venueRelatedTasks = taskProvider.getTasksByCategory('venue');
///
/// // Get upcoming tasks
/// final nextWeekTasks = taskProvider.getUpcomingTasks(7);
///
/// // Add a new task
/// final newTask = Task(
///   id: 'task1',
///   title: 'Book photographer',
///   description: 'Find and book a photographer for the event',
///   dueDate: DateTime.now().add(const Duration(days: 30)),
///   categoryId: 'photography',
///   isImportant: true,
/// );
/// await taskProvider.addTask(newTask);
///
/// // Update task status
/// await taskProvider.updateTaskStatus('task1', TaskStatus.completed);
/// ```
class TaskProvider extends ChangeNotifier {
  /// The unique identifier of the event this task list belongs to
  final String eventId;

  /// List of all tasks for the event
  List<Task> _tasks = [];

  /// List of task categories (e.g., Venue, Catering, Invitations)
  List<TaskCategory> _categories = [];

  /// List of task dependencies (which tasks depend on other tasks)
  List<TaskDependency> _dependencies = [];

  /// Flag indicating if the provider is currently loading data
  bool _isLoading = false;

  /// Error message if an operation fails
  String? _error;

  /// Firestore service for tasks
  final TaskFirestoreService _taskFirestoreService;

  /// Stream subscriptions
  StreamSubscription<List<Task>>? _tasksSubscription;
  StreamSubscription<List<TaskCategory>>? _categoriesSubscription;
  StreamSubscription<List<TaskDependency>>? _dependenciesSubscription;

  /// Creates a new TaskProvider for the specified event
  ///
  /// Automatically loads task data when instantiated
  TaskProvider({
    required this.eventId,
    TaskFirestoreService? taskFirestoreService,
  }) : _taskFirestoreService = taskFirestoreService ?? TaskFirestoreService() {
    _loadTasks();
  }

  /// Returns the list of all tasks
  List<Task> get tasks => _tasks;

  /// Returns the list of all task categories
  List<TaskCategory> get categories => _categories;

  /// Returns the list of all task dependencies
  List<TaskDependency> get dependencies => _dependencies;

  /// Indicates if the provider is currently loading data
  bool get isLoading => _isLoading;

  /// Returns the error message if an operation has failed, null otherwise
  String? get error => _error;

  /// The total number of tasks in the task list
  int get totalTasks => _tasks.length;

  /// The number of tasks that have been completed
  int get completedTasks =>
      _tasks.where((t) => t.status == TaskStatus.completed).length;

  /// The number of tasks that are not yet completed
  int get pendingTasks =>
      _tasks.where((t) => t.status != TaskStatus.completed).length;

  /// The percentage of tasks that have been completed (0-100)
  ///
  /// Returns 0 if there are no tasks.
  double get completionPercentage =>
      totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

  /// Returns all tasks belonging to the specified category
  ///
  /// [categoryId] The ID of the category to filter by
  List<Task> getTasksByCategory(String categoryId) {
    return _tasks.where((task) => task.categoryId == categoryId).toList();
  }

  /// Returns all tasks with the specified status
  ///
  /// [status] The task status to filter by (notStarted, inProgress, completed, overdue)
  List<Task> getTasksByStatus(TaskStatus status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  /// Returns all tasks with due dates within the specified date range
  ///
  /// [start] The start date of the range (inclusive)
  /// [end] The end date of the range (inclusive)
  ///
  /// The method includes a 1-day buffer on both ends to ensure tasks due exactly
  /// on the start or end date are included.
  List<Task> getTasksByDateRange(DateTime start, DateTime end) {
    return _tasks
        .where(
          (task) =>
              task.dueDate.isAfter(start.subtract(const Duration(days: 1))) &&
              task.dueDate.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }

  /// Returns all incomplete tasks due within the specified number of days
  ///
  /// [days] The number of days from now to include in the upcoming period
  ///
  /// This method only returns tasks that have not been completed and are due
  /// between now and the specified number of days in the future.
  List<Task> getUpcomingTasks(int days) {
    final now = DateTime.now();
    final end = now.add(Duration(days: days));

    return _tasks
        .where(
          (task) =>
              task.status != TaskStatus.completed &&
              task.dueDate.isAfter(now.subtract(const Duration(days: 1))) &&
              task.dueDate.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }

  /// Returns all incomplete tasks that are past their due date
  ///
  /// This method only returns tasks that have not been completed and
  /// have a due date in the past.
  List<Task> getOverdueTasks() {
    final now = DateTime.now();

    return _tasks
        .where(
          (task) =>
              task.status != TaskStatus.completed && task.dueDate.isBefore(now),
        )
        .toList();
  }

  /// Loads the task data for the event
  ///
  /// This is called automatically when the provider is created.
  /// Fetches data from Firestore and sets up stream subscriptions.
  Future<void> _loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Subscribe to tasks stream
      _tasksSubscription = _taskFirestoreService
          .getTasksStream(eventId)
          .listen(
            (tasks) {
              _tasks = tasks;
              notifyListeners();
            },
            onError: (e) {
              _error = e.toString();
              notifyListeners();
            },
          );

      // Subscribe to categories stream
      _categoriesSubscription = _taskFirestoreService
          .getTaskCategoriesStream(eventId)
          .listen(
            (categories) {
              _categories = categories;
              notifyListeners();
            },
            onError: (e) {
              _error = e.toString();
              notifyListeners();
            },
          );

      // Subscribe to dependencies stream
      _dependenciesSubscription = _taskFirestoreService
          .getTaskDependenciesStream(eventId)
          .listen(
            (dependencies) {
              _dependencies = dependencies;
              notifyListeners();
            },
            onError: (e) {
              _error = e.toString();
              notifyListeners();
            },
          );

      // Initial load
      _tasks = await _taskFirestoreService.getTasks(eventId);
      _categories = await _taskFirestoreService.getTaskCategories(eventId);
      _dependencies = await _taskFirestoreService.getTaskDependencies(eventId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Adds a new task or updates an existing task with the same ID
  ///
  /// [task] The task to add or update
  ///
  /// If a task with the same ID already exists, it will be updated.
  /// Otherwise, a new task will be added to the list.
  /// Persists the task to Firestore.
  /// Notifies listeners when the operation completes.
  Future<void> addTask(Task task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (task.id.isEmpty || task.id == 'temp_id') {
        // Add task to Firestore
        await _taskFirestoreService.addTask(eventId, task);

        // The task will be added to _tasks via the stream subscription
      } else {
        // Update existing task
        await _taskFirestoreService.updateTask(eventId, task);

        // The task will be updated in _tasks via the stream subscription
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Adds multiple tasks at once, updating any existing tasks with the same IDs
  ///
  /// [tasks] The list of tasks to add or update
  ///
  /// For each task, if a task with the same ID already exists, it will be updated.
  /// Otherwise, a new task will be added to the list.
  /// Persists the tasks to Firestore.
  /// Notifies listeners when the operation completes.
  Future<void> addTasks(List<Task> tasks) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      for (final task in tasks) {
        if (task.id.isEmpty || task.id == 'temp_id') {
          // Add task to Firestore
          await _taskFirestoreService.addTask(eventId, task);
        } else {
          // Update existing task
          await _taskFirestoreService.updateTask(eventId, task);
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Updates an existing task
  ///
  /// [task] The updated task (must have the same ID as an existing task)
  ///
  /// Updates the task in Firestore.
  /// Notifies listeners when the operation completes.
  Future<void> updateTask(Task task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _taskFirestoreService.updateTask(eventId, task);

      // The task will be updated in _tasks via the stream subscription

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Removes a task from the task list
  ///
  /// [taskId] The ID of the task to remove
  ///
  /// Deletes the task from Firestore.
  /// Notifies listeners when the operation completes.
  Future<void> deleteTask(String taskId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _taskFirestoreService.deleteTask(eventId, taskId);

      // The task will be removed from _tasks via the stream subscription

      // Also remove any dependencies involving this task
      _dependencies.removeWhere(
        (d) => d.prerequisiteTaskId == taskId || d.dependentTaskId == taskId,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Updates the status of an existing task
  ///
  /// [taskId] The ID of the task to update
  /// [status] The new status to set (notStarted, inProgress, completed, overdue)
  ///
  /// This is a convenience method for updating just the status of a task
  /// without having to update the entire task object.
  /// Updates the task in Firestore.
  /// Notifies listeners when the operation completes.
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index >= 0) {
        final task = _tasks[index].copyWith(
          status: status,
          completedDate: status == TaskStatus.completed ? DateTime.now() : null,
        );
        await _taskFirestoreService.updateTask(eventId, task);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Adds a dependency between two tasks
  ///
  /// [prerequisiteTaskId] The ID of the task that must be completed first
  /// [dependentTaskId] The ID of the task that depends on the prerequisite
  ///
  /// Returns true if the dependency was added successfully, false otherwise.
  /// A dependency will not be added if:
  /// - Either task ID doesn't exist
  /// - The dependency would create a circular reference
  /// - The dependency already exists
  Future<bool> addDependency(
    String prerequisiteTaskId,
    String dependentTaskId,
  ) async {
    // Don't allow dependencies to self
    if (prerequisiteTaskId == dependentTaskId) {
      return false;
    }

    // Check if both tasks exist
    final prerequisiteExists = _tasks.any((t) => t.id == prerequisiteTaskId);
    final dependentExists = _tasks.any((t) => t.id == dependentTaskId);

    if (!prerequisiteExists || !dependentExists) {
      return false;
    }

    // Check if dependency already exists
    final dependencyExists = _dependencies.any(
      (d) =>
          d.prerequisiteTaskId == prerequisiteTaskId &&
          d.dependentTaskId == dependentTaskId,
    );

    if (dependencyExists) {
      return false;
    }

    // Check for circular dependencies
    if (_wouldCreateCircularDependency(prerequisiteTaskId, dependentTaskId)) {
      return false;
    }

    try {
      // Create dependency object
      final dependency = TaskDependency(
        prerequisiteTaskId: prerequisiteTaskId,
        dependentTaskId: dependentTaskId,
      );

      // Add dependency to Firestore
      await _taskFirestoreService.addTaskDependency(eventId, dependency);

      // The dependency will be added to _dependencies via the stream subscription

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Removes a dependency between two tasks
  ///
  /// [prerequisiteTaskId] The ID of the prerequisite task
  /// [dependentTaskId] The ID of the dependent task
  ///
  /// Returns true if the dependency was removed, false if it didn't exist
  Future<bool> removeDependency(
    String prerequisiteTaskId,
    String dependentTaskId,
  ) async {
    try {
      // Remove dependency from Firestore
      await _taskFirestoreService.removeTaskDependency(
        eventId,
        prerequisiteTaskId,
        dependentTaskId,
      );

      // The dependency will be removed from _dependencies via the stream subscription

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Gets all dependencies where the specified task is a prerequisite
  ///
  /// [taskId] The ID of the prerequisite task
  ///
  /// Returns a list of task IDs that depend on the specified task
  List<String> getDependentTasks(String taskId) {
    return _dependencies
        .where((d) => d.prerequisiteTaskId == taskId)
        .map((d) => d.dependentTaskId)
        .toList();
  }

  /// Gets all dependencies where the specified task is dependent
  ///
  /// [taskId] The ID of the dependent task
  ///
  /// Returns a list of task IDs that the specified task depends on
  List<String> getPrerequisiteTasks(String taskId) {
    return _dependencies
        .where((d) => d.dependentTaskId == taskId)
        .map((d) => d.prerequisiteTaskId)
        .toList();
  }

  /// Checks if adding a dependency would create a circular reference
  ///
  /// [prerequisiteTaskId] The ID of the prerequisite task
  /// [dependentTaskId] The ID of the dependent task
  ///
  /// Returns true if adding this dependency would create a circular reference
  bool _wouldCreateCircularDependency(
    String prerequisiteTaskId,
    String dependentTaskId,
  ) {
    // If the dependent task is already a prerequisite for the prerequisite task,
    // this would create a circular dependency
    final visited = <String>{};
    final toVisit = <String>[dependentTaskId];

    while (toVisit.isNotEmpty) {
      final current = toVisit.removeLast();
      visited.add(current);

      final dependents = getDependentTasks(current);

      // If any dependent is the prerequisite, we have a cycle
      if (dependents.contains(prerequisiteTaskId)) {
        return true;
      }

      // Add unvisited dependents to the queue
      for (final dependent in dependents) {
        if (!visited.contains(dependent)) {
          toVisit.add(dependent);
        }
      }
    }

    return false;
  }

  /// Clean up resources when the provider is disposed
  @override
  void dispose() {
    _tasksSubscription?.cancel();
    _categoriesSubscription?.cancel();
    _dependenciesSubscription?.cancel();
    super.dispose();
  }
}
