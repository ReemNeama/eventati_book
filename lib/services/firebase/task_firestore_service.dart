import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/firebase/firestore_service.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:flutter/material.dart';

/// Service for handling task-related Firestore operations
class TaskFirestoreService {
  /// Firestore service
  final FirestoreService _firestoreService;

  /// Collection name
  final String _collection = 'events';

  /// Constructor
  TaskFirestoreService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  /// Get task categories for an event
  Future<List<TaskCategory>> getTaskCategories(String eventId) async {
    try {
      final categories = await _firestoreService.getSubcollectionAs(
        _collection,
        eventId,
        'task_categories',
        (data, id) => TaskCategory(
          id: id,
          name: data['name'] ?? '',
          icon: _iconDataFromMap(data),
          color: Color(data['color'] ?? 0xFF000000),
        ),
      );
      return categories;
    } catch (e) {
      Logger.e('Error getting task categories: $e', tag: 'TaskFirestoreService');
      rethrow;
    }
  }

  /// Get tasks for an event
  Future<List<Task>> getTasks(String eventId) async {
    try {
      final tasks = await _firestoreService.getSubcollectionAs(
        _collection,
        eventId,
        'tasks',
        (data, id) => Task(
          id: id,
          title: data['title'] ?? '',
          description: data['description'],
          dueDate: data['dueDate'] != null
              ? (data['dueDate'] as Timestamp).toDate()
              : DateTime.now(),
          status: _mapTaskStatus(data['status']),
          categoryId: data['categoryId'] ?? '',
          assignedTo: data['assignedTo'],
          isImportant: data['isImportant'] ?? false,
          notes: data['notes'],
        ),
      );
      return tasks;
    } catch (e) {
      Logger.e('Error getting tasks: $e', tag: 'TaskFirestoreService');
      rethrow;
    }
  }

  /// Add a task category to an event
  Future<String> addTaskCategory(String eventId, TaskCategory category) async {
    try {
      final categoryId = await _firestoreService.addSubcollectionDocument(
        _collection,
        eventId,
        'task_categories',
        {
          'name': category.name,
          'iconCodePoint': category.icon.codePoint,
          'iconFontFamily': category.icon.fontFamily,
          'iconFontPackage': category.icon.fontPackage,
          'color': category.color.value,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );
      return categoryId;
    } catch (e) {
      Logger.e('Error adding task category: $e', tag: 'TaskFirestoreService');
      rethrow;
    }
  }

  /// Update a task category
  Future<void> updateTaskCategory(
    String eventId,
    TaskCategory category,
  ) async {
    try {
      await _firestoreService.updateSubcollectionDocument(
        _collection,
        eventId,
        'task_categories',
        category.id,
        {
          'name': category.name,
          'iconCodePoint': category.icon.codePoint,
          'iconFontFamily': category.icon.fontFamily,
          'iconFontPackage': category.icon.fontPackage,
          'color': category.color.value,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      Logger.e('Error updating task category: $e', tag: 'TaskFirestoreService');
      rethrow;
    }
  }

  /// Delete a task category
  Future<void> deleteTaskCategory(String eventId, String categoryId) async {
    try {
      await _firestoreService.deleteSubcollectionDocument(
        _collection,
        eventId,
        'task_categories',
        categoryId,
      );
    } catch (e) {
      Logger.e('Error deleting task category: $e', tag: 'TaskFirestoreService');
      rethrow;
    }
  }

  /// Add a task to an event
  Future<String> addTask(String eventId, Task task) async {
    try {
      final taskId = await _firestoreService.addSubcollectionDocument(
        _collection,
        eventId,
        'tasks',
        {
          'title': task.title,
          'description': task.description,
          'dueDate': Timestamp.fromDate(task.dueDate),
          'status': task.status.toString().split('.').last,
          'categoryId': task.categoryId,
          'assignedTo': task.assignedTo,
          'isImportant': task.isImportant,
          'notes': task.notes,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );
      return taskId;
    } catch (e) {
      Logger.e('Error adding task: $e', tag: 'TaskFirestoreService');
      rethrow;
    }
  }

  /// Update a task
  Future<void> updateTask(String eventId, Task task) async {
    try {
      await _firestoreService.updateSubcollectionDocument(
        _collection,
        eventId,
        'tasks',
        task.id,
        {
          'title': task.title,
          'description': task.description,
          'dueDate': Timestamp.fromDate(task.dueDate),
          'status': task.status.toString().split('.').last,
          'categoryId': task.categoryId,
          'assignedTo': task.assignedTo,
          'isImportant': task.isImportant,
          'notes': task.notes,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      Logger.e('Error updating task: $e', tag: 'TaskFirestoreService');
      rethrow;
    }
  }

  /// Delete a task
  Future<void> deleteTask(String eventId, String taskId) async {
    try {
      await _firestoreService.deleteSubcollectionDocument(
        _collection,
        eventId,
        'tasks',
        taskId,
      );
    } catch (e) {
      Logger.e('Error deleting task: $e', tag: 'TaskFirestoreService');
      rethrow;
    }
  }

  /// Add multiple tasks to an event
  Future<List<String>> addTasks(String eventId, List<Task> tasks) async {
    try {
      final List<String> taskIds = [];
      for (final task in tasks) {
        final taskId = await addTask(eventId, task);
        taskIds.add(taskId);
      }
      return taskIds;
    } catch (e) {
      Logger.e('Error adding tasks: $e', tag: 'TaskFirestoreService');
      rethrow;
    }
  }

  /// Helper method to map string to TaskStatus enum
  TaskStatus _mapTaskStatus(String? status) {
    switch (status) {
      case 'inProgress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      case 'overdue':
        return TaskStatus.overdue;
      case 'notStarted':
      default:
        return TaskStatus.notStarted;
    }
  }

  /// Helper method to create IconData from Firestore data
  IconData _iconDataFromMap(Map<String, dynamic> data) {
    return IconData(
      data['iconCodePoint'] ?? Icons.task_alt.codePoint,
      fontFamily: data['iconFontFamily'],
      fontPackage: data['iconFontPackage'],
    );
  }
}
