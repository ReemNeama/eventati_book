import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';

class TaskProvider extends ChangeNotifier {
  final String eventId;
  List<Task> _tasks = [];
  List<TaskCategory> _categories = [];
  bool _isLoading = false;
  String? _error;

  TaskProvider({required this.eventId}) {
    _loadTasks();
  }

  // Getters
  List<Task> get tasks => _tasks;
  List<TaskCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Calculated properties
  int get totalTasks => _tasks.length;
  int get completedTasks =>
      _tasks.where((t) => t.status == TaskStatus.completed).length;
  int get pendingTasks =>
      _tasks.where((t) => t.status != TaskStatus.completed).length;
  double get completionPercentage =>
      totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

  // Get tasks by category
  List<Task> getTasksByCategory(String categoryId) {
    return _tasks.where((task) => task.categoryId == categoryId).toList();
  }

  // Get tasks by status
  List<Task> getTasksByStatus(TaskStatus status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  // Get tasks by due date range
  List<Task> getTasksByDateRange(DateTime start, DateTime end) {
    return _tasks
        .where(
          (task) =>
              task.dueDate.isAfter(start.subtract(const Duration(days: 1))) &&
              task.dueDate.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }

  // Get upcoming tasks
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

  // Get overdue tasks
  List<Task> getOverdueTasks() {
    final now = DateTime.now();
    return _tasks
        .where(
          (task) =>
              task.status != TaskStatus.completed && task.dueDate.isBefore(now),
        )
        .toList();
  }

  // CRUD operations
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

  /// Add multiple tasks at once
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

  // Mock data for testing
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
