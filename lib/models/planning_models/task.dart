import 'package:flutter/material.dart';
import 'package:eventati_book/utils/database_utils.dart';

enum TaskStatus { notStarted, inProgress, completed, overdue }

enum TaskPriority { low, medium, high }

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

  /// Convert to database data
  Map<String, dynamic> toDatabaseDoc() {
    return {
      'name': name,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
      'colorARGB': [color.a, color.r, color.g, color.b],
      'createdAt': DbFieldValue.serverTimestamp(),
    };
  }

  /// Create from database document
  factory TaskCategory.fromDatabaseDoc(DbDocumentSnapshot doc) {
    final data = doc.getData();
    if (data.isEmpty) {
      throw Exception('Document data was null');
    }

    final colorData = data['colorARGB'] as List<dynamic>?;
    final color =
        colorData != null
            ? Color.fromARGB(
              colorData[0] as int,
              colorData[1] as int,
              colorData[2] as int,
              colorData[3] as int,
            )
            : Colors.blue;

    return TaskCategory(
      id: doc.id,
      name: data['name'] ?? '',
      icon: IconData(
        data['iconCodePoint'] ?? Icons.task_alt.codePoint,
        fontFamily: data['iconFontFamily'],
        fontPackage: data['iconFontPackage'],
      ),
      color: color,
    );
  }
}

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final TaskStatus status;
  final String categoryId;
  final String? assignedTo;
  final bool isImportant;
  final String? notes;
  final DateTime? completedDate;
  final TaskPriority priority;
  final bool isServiceRelated;
  final String? serviceId;
  final List<String> dependencies;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.status = TaskStatus.notStarted,
    required this.categoryId,
    this.assignedTo,
    this.isImportant = false,
    this.notes,
    this.completedDate,
    this.priority = TaskPriority.medium,
    this.isServiceRelated = false,
    this.serviceId,
    this.dependencies = const [],
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    String? categoryId,
    String? assignedTo,
    bool? isImportant,
    String? notes,
    DateTime? completedDate,
    TaskPriority? priority,
    bool? isServiceRelated,
    String? serviceId,
    List<String>? dependencies,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      assignedTo: assignedTo ?? this.assignedTo,
      isImportant: isImportant ?? this.isImportant,
      notes: notes ?? this.notes,
      completedDate: completedDate ?? this.completedDate,
      priority: priority ?? this.priority,
      isServiceRelated: isServiceRelated ?? this.isServiceRelated,
      serviceId: serviceId ?? this.serviceId,
      dependencies: dependencies ?? this.dependencies,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'categoryId': categoryId,
      'assignedTo': assignedTo,
      'isImportant': isImportant,
      'notes': notes,
      'completedDate': completedDate?.toIso8601String(),
      'priority': priority.toString().split('.').last,
      'isServiceRelated': isServiceRelated,
      'serviceId': serviceId,
      'dependencies': dependencies,
    };
  }

  /// Create from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      status: _parseTaskStatus(json['status']),
      categoryId: json['categoryId'] ?? '',
      assignedTo: json['assignedTo'],
      isImportant: json['isImportant'] ?? false,
      notes: json['notes'],
      completedDate:
          json['completedDate'] != null
              ? DateTime.parse(json['completedDate'])
              : null,
      priority: _parseTaskPriority(json['priority']),
      isServiceRelated: json['isServiceRelated'] ?? false,
      serviceId: json['serviceId'],
      dependencies:
          json['dependencies'] != null
              ? List<String>.from(json['dependencies'])
              : [],
    );
  }

  /// Convert to database data
  Map<String, dynamic> toDatabaseDoc() {
    return {
      'title': title,
      'description': description,
      'dueDate': DbTimestamp.fromDate(dueDate).toIso8601String(),
      'status': status.toString().split('.').last,
      'categoryId': categoryId,
      'assignedTo': assignedTo,
      'isImportant': isImportant,
      'notes': notes,
      'completedDate':
          completedDate != null
              ? DbTimestamp.fromDate(completedDate!).toIso8601String()
              : null,
      'priority': priority.toString().split('.').last,
      'isServiceRelated': isServiceRelated,
      'serviceId': serviceId,
      'dependencies': dependencies,
      'createdAt': DbFieldValue.serverTimestamp(),
      'updatedAt': DbFieldValue.serverTimestamp(),
    };
  }

  /// Create from database document
  factory Task.fromDatabaseDoc(DbDocumentSnapshot doc) {
    final data = doc.getData();
    if (data.isEmpty) {
      throw Exception('Document data was null');
    }

    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      dueDate:
          data['dueDate'] != null
              ? DateTime.parse(data['dueDate'])
              : DateTime.now(),
      status: _parseTaskStatus(data['status']),
      categoryId: data['categoryId'] ?? '',
      assignedTo: data['assignedTo'],
      isImportant: data['isImportant'] ?? false,
      notes: data['notes'],
      completedDate:
          data['completedDate'] != null
              ? DateTime.parse(data['completedDate'])
              : null,
      priority: _parseTaskPriority(data['priority']),
      isServiceRelated: data['isServiceRelated'] ?? false,
      serviceId: data['serviceId'],
      dependencies:
          data['dependencies'] != null
              ? List<String>.from(data['dependencies'])
              : [],
    );
  }

  /// Parse task status from string
  static TaskStatus _parseTaskStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'inprogress':
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      case 'overdue':
        return TaskStatus.overdue;
      case 'notstarted':
      case 'not_started':
      default:
        return TaskStatus.notStarted;
    }
  }

  /// Parse task priority from string
  static TaskPriority _parseTaskPriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      case 'medium':
      default:
        return TaskPriority.medium;
    }
  }
}
