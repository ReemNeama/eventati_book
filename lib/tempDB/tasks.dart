import 'package:eventati_book/models/planning_models/task.dart';
import 'package:flutter/material.dart';

/// Task category model for tempDB
class TaskCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  TaskCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// Task dependency model for tempDB
class TaskDependency {
  final String prerequisiteTaskId;
  final String dependentTaskId;

  TaskDependency({
    required this.prerequisiteTaskId,
    required this.dependentTaskId,
  });
}

/// Temporary database for task data
class TaskDB {
  /// Get mock tasks for an event
  static List<Task> getTasks(String eventId) {
    // Different tasks based on event ID
    if (eventId == 'event_1') {
      return _getWeddingTasks();
    } else if (eventId == 'event_2' || eventId == 'event_5') {
      return _getBusinessTasks();
    } else {
      return _getCelebrationTasks();
    }
  }

  /// Get mock task categories
  static List<TaskCategory> getTaskCategories() {
    return [
      TaskCategory(
        id: 'category_1',
        name: 'Venue',
        icon: Icons.location_on,
        color: Colors.blue,
      ),
      TaskCategory(
        id: 'category_2',
        name: 'Catering',
        icon: Icons.restaurant,
        color: Colors.orange,
      ),
      TaskCategory(
        id: 'category_3',
        name: 'Invitations',
        icon: Icons.mail,
        color: Colors.green,
      ),
      TaskCategory(
        id: 'category_4',
        name: 'Entertainment',
        icon: Icons.music_note,
        color: Colors.purple,
      ),
      TaskCategory(
        id: 'category_5',
        name: 'Logistics',
        icon: Icons.directions_car,
        color: Colors.red,
      ),
      TaskCategory(
        id: 'category_6',
        name: 'Miscellaneous',
        icon: Icons.more_horiz,
        color: Colors.grey,
      ),
    ];
  }

  /// Get mock task dependencies for an event
  static List<TaskDependency> getTaskDependencies(String eventId) {
    // Different dependencies based on event ID
    if (eventId == 'event_1') {
      return _getWeddingTaskDependencies();
    } else if (eventId == 'event_2' || eventId == 'event_5') {
      return _getBusinessTaskDependencies();
    } else {
      return _getCelebrationTaskDependencies();
    }
  }

  /// Get wedding tasks
  static List<Task> _getWeddingTasks() {
    return [
      Task(
        id: 'task_1',
        title: 'Book venue',
        description: 'Find and book the perfect wedding venue',
        dueDate: DateTime(2023, 2, 15),
        status: TaskStatus.completed,
        categoryId: 'category_1',
        priority: TaskPriority.high,
      ),
      Task(
        id: 'task_2',
        title: 'Hire caterer',
        description: 'Find and hire a caterer for the wedding',
        dueDate: DateTime(2023, 3, 1),
        status: TaskStatus.completed,
        categoryId: 'category_2',
        priority: TaskPriority.high,
      ),
      Task(
        id: 'task_3',
        title: 'Send invitations',
        description: 'Design, print, and send wedding invitations',
        dueDate: DateTime(2023, 4, 15),
        status: TaskStatus.inProgress,
        categoryId: 'category_3',
        priority: TaskPriority.medium,
      ),
      Task(
        id: 'task_4',
        title: 'Book DJ',
        description: 'Find and book a DJ for the wedding',
        dueDate: DateTime(2023, 5, 1),
        status: TaskStatus.notStarted,
        categoryId: 'category_4',
        priority: TaskPriority.medium,
      ),
      Task(
        id: 'task_5',
        title: 'Arrange transportation',
        description: 'Arrange transportation for the wedding party',
        dueDate: DateTime(2023, 5, 15),
        status: TaskStatus.notStarted,
        categoryId: 'category_5',
        priority: TaskPriority.low,
      ),
    ];
  }

  /// Get business tasks
  static List<Task> _getBusinessTasks() {
    return [
      Task(
        id: 'task_6',
        title: 'Book conference room',
        description: 'Book a conference room for the event',
        dueDate: DateTime(2023, 6, 15),
        status: TaskStatus.completed,
        categoryId: 'category_1',
        priority: TaskPriority.high,
      ),
      Task(
        id: 'task_7',
        title: 'Arrange catering',
        description: 'Arrange catering for the event',
        dueDate: DateTime(2023, 7, 1),
        status: TaskStatus.inProgress,
        categoryId: 'category_2',
        priority: TaskPriority.high,
      ),
      Task(
        id: 'task_8',
        title: 'Send invitations',
        description: 'Send invitations to attendees',
        dueDate: DateTime(2023, 7, 15),
        status: TaskStatus.notStarted,
        categoryId: 'category_3',
        priority: TaskPriority.medium,
      ),
      Task(
        id: 'task_9',
        title: 'Prepare presentation',
        description: 'Prepare presentation materials',
        dueDate: DateTime(2023, 8, 1),
        status: TaskStatus.notStarted,
        categoryId: 'category_6',
        priority: TaskPriority.high,
      ),
    ];
  }

  /// Get celebration tasks
  static List<Task> _getCelebrationTasks() {
    return [
      Task(
        id: 'task_10',
        title: 'Book party venue',
        description: 'Book a venue for the celebration',
        dueDate: DateTime(2023, 4, 1),
        status: TaskStatus.completed,
        categoryId: 'category_1',
        priority: TaskPriority.high,
      ),
      Task(
        id: 'task_11',
        title: 'Order food and drinks',
        description: 'Order food and drinks for the party',
        dueDate: DateTime(2023, 4, 15),
        status: TaskStatus.completed,
        categoryId: 'category_2',
        priority: TaskPriority.high,
      ),
      Task(
        id: 'task_12',
        title: 'Send invitations',
        description: 'Send invitations to guests',
        dueDate: DateTime(2023, 4, 20),
        status: TaskStatus.completed,
        categoryId: 'category_3',
        priority: TaskPriority.medium,
      ),
      Task(
        id: 'task_13',
        title: 'Book DJ',
        description: 'Book a DJ for the party',
        dueDate: DateTime(2023, 4, 25),
        status: TaskStatus.inProgress,
        categoryId: 'category_4',
        priority: TaskPriority.medium,
      ),
    ];
  }

  /// Get wedding task dependencies
  static List<TaskDependency> _getWeddingTaskDependencies() {
    return [
      TaskDependency(prerequisiteTaskId: 'task_1', dependentTaskId: 'task_2'),
      TaskDependency(prerequisiteTaskId: 'task_2', dependentTaskId: 'task_3'),
    ];
  }

  /// Get business task dependencies
  static List<TaskDependency> _getBusinessTaskDependencies() {
    return [
      TaskDependency(prerequisiteTaskId: 'task_6', dependentTaskId: 'task_7'),
      TaskDependency(prerequisiteTaskId: 'task_7', dependentTaskId: 'task_8'),
    ];
  }

  /// Get celebration task dependencies
  static List<TaskDependency> _getCelebrationTaskDependencies() {
    return [
      TaskDependency(prerequisiteTaskId: 'task_10', dependentTaskId: 'task_11'),
      TaskDependency(prerequisiteTaskId: 'task_11', dependentTaskId: 'task_12'),
    ];
  }
}
