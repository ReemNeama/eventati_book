import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';

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
  }
}
