import 'package:flutter/material.dart';

enum TaskStatus { notStarted, inProgress, completed, overdue }

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
    );
  }
}
