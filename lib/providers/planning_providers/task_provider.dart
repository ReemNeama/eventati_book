import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';

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

  /// Creates a new TaskProvider for the specified event
  ///
  /// Automatically loads task data when instantiated
  TaskProvider({required this.eventId}) {
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
  /// In a real application, this would fetch data from a database or API.
  /// Currently uses mock data for demonstration purposes.
  Future<void> _loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // In a real app, this would load from a database or API
      await Future.delayed(const Duration(milliseconds: 500));
      _loadMockData();
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
  /// In a real application, this would persist the task to a database or API.
  /// Notifies listeners when the operation completes.
  Future<void> addTask(Task task) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would save to a database or API
      await Future.delayed(const Duration(milliseconds: 300));

      // Check if task with this ID already exists
      final existingTaskIndex = _tasks.indexWhere((t) => t.id == task.id);
      if (existingTaskIndex >= 0) {
        // Update existing task
        _tasks[existingTaskIndex] = task;
      } else {
        // Add new task
        _tasks.add(task);
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
  /// In a real application, this would persist the tasks to a database or API.
  /// Notifies listeners when the operation completes.
  Future<void> addTasks(List<Task> tasks) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would save to a database or API
      await Future.delayed(const Duration(milliseconds: 300));

      for (final task in tasks) {
        // Check if task with this ID already exists
        final existingTaskIndex = _tasks.indexWhere((t) => t.id == task.id);
        if (existingTaskIndex >= 0) {
          // Update existing task
          _tasks[existingTaskIndex] = task;
        } else {
          // Add new task
          _tasks.add(task);
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
  /// In a real application, this would update the task in a database or API.
  /// Notifies listeners when the operation completes.
  Future<void> updateTask(Task task) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would update in a database or API
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index >= 0) {
        _tasks[index] = task;
      }
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
  /// In a real application, this would delete the task from a database or API.
  /// Notifies listeners when the operation completes.
  Future<void> deleteTask(String taskId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would delete from a database or API
      await Future.delayed(const Duration(milliseconds: 300));
      _tasks.removeWhere((task) => task.id == taskId);
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
  /// In a real application, this would update the task in a database or API.
  /// Notifies listeners when the operation completes.
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would update in a database or API
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index >= 0) {
        _tasks[index] = _tasks[index].copyWith(status: status);
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
  bool addDependency(String prerequisiteTaskId, String dependentTaskId) {
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

    // Add the dependency
    _dependencies.add(
      TaskDependency(
        prerequisiteTaskId: prerequisiteTaskId,
        dependentTaskId: dependentTaskId,
      ),
    );

    notifyListeners();
    return true;
  }

  /// Removes a dependency between two tasks
  ///
  /// [prerequisiteTaskId] The ID of the prerequisite task
  /// [dependentTaskId] The ID of the dependent task
  ///
  /// Returns true if the dependency was removed, false if it didn't exist
  bool removeDependency(String prerequisiteTaskId, String dependentTaskId) {
    final initialLength = _dependencies.length;

    _dependencies.removeWhere(
      (d) =>
          d.prerequisiteTaskId == prerequisiteTaskId &&
          d.dependentTaskId == dependentTaskId,
    );

    final removed = initialLength > _dependencies.length;

    if (removed) {
      notifyListeners();
    }

    return removed;
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

  /// Loads mock data for testing and demonstration purposes
  ///
  /// This method creates sample task categories and tasks.
  /// In a real application, this would be replaced with data from a database or API.
  void _loadMockData() {
    _categories = [
      TaskCategory(
        id: '1',
        name: 'Venue',
        icon: Icons.location_on,
        color: Colors.blue,
      ),
      TaskCategory(
        id: '2',
        name: 'Catering',
        icon: Icons.restaurant,
        color: Colors.orange,
      ),
      TaskCategory(
        id: '3',
        name: 'Invitations',
        icon: Icons.mail,
        color: Colors.purple,
      ),
      TaskCategory(
        id: '4',
        name: 'Decoration',
        icon: Icons.celebration,
        color: Colors.pink,
      ),
      TaskCategory(
        id: '5',
        name: 'Attire',
        icon: Icons.checkroom,
        color: Colors.teal,
      ),
      TaskCategory(
        id: '6',
        name: 'Transportation',
        icon: Icons.directions_car,
        color: Colors.green,
      ),
      TaskCategory(
        id: '7',
        name: 'Miscellaneous',
        icon: Icons.more_horiz,
        color: Colors.grey,
      ),
    ];

    final now = DateTime.now();

    _tasks = [
      Task(
        id: '1',
        title: 'Book venue',
        description: 'Find and book the perfect venue for the event',
        dueDate: now.add(const Duration(days: 90)),
        status: TaskStatus.completed,
        categoryId: '1',
        isImportant: true,
      ),
      Task(
        id: '2',
        title: 'Select catering menu',
        description: 'Choose menu items and confirm with caterer',
        dueDate: now.add(const Duration(days: 60)),
        status: TaskStatus.inProgress,
        categoryId: '2',
      ),
      Task(
        id: '3',
        title: 'Send invitations',
        description: 'Finalize guest list and send out invitations',
        dueDate: now.add(const Duration(days: 45)),
        status: TaskStatus.notStarted,
        categoryId: '3',
        isImportant: true,
      ),
      Task(
        id: '4',
        title: 'Order flowers',
        description: 'Select and order flowers for the event',
        dueDate: now.add(const Duration(days: 30)),
        status: TaskStatus.notStarted,
        categoryId: '4',
      ),
    ];

    // Initialize dependencies
    _dependencies = [
      // Venue booking must be completed before catering selection
      TaskDependency(
        prerequisiteTaskId: '1', // Book venue
        dependentTaskId: '2', // Select catering menu
      ),
      // Venue booking must be completed before sending invitations
      TaskDependency(
        prerequisiteTaskId: '1', // Book venue
        dependentTaskId: '3', // Send invitations
      ),
    ];
  }
}
