import 'package:eventati_book/utils/database_utils.dart';

/// Status of a task
enum TaskStatus { notStarted, inProgress, completed, overdue }

/// Priority level of a task
enum TaskPriority { low, medium, high }

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
  final String? eventId;
  final String? service;

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
    this.eventId,
    this.service,
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
    String? eventId,
    String? service,
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
      eventId: eventId ?? this.eventId,
      service: service ?? this.service,
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
      'eventId': eventId,
      'service': service,
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
      eventId: json['eventId'],
      service: json['service'],
    );
  }

  /// Convert to database data
  Map<String, dynamic> toDatabaseDoc() {
    return {
      'title': title,
      'description': description,
      'due_date': DbTimestamp.fromDate(dueDate).toIso8601String(),
      'status': status.toString().split('.').last,
      'category_id': categoryId,
      'assigned_to': assignedTo,
      'is_important': isImportant,
      'notes': notes,
      'completed_date':
          completedDate != null
              ? DbTimestamp.fromDate(completedDate!).toIso8601String()
              : null,
      'priority': priority.toString().split('.').last,
      'is_service_related': isServiceRelated,
      'service_id': serviceId,
      'dependencies': dependencies,
      'event_id': eventId,
      'service': service,
      'created_at': DbFieldValue.serverTimestamp(),
      'updated_at': DbFieldValue.serverTimestamp(),
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
          data['due_date'] != null
              ? DateTime.parse(data['due_date'])
              : DateTime.now(),
      status: _parseTaskStatus(data['status']),
      categoryId: data['category_id'] ?? '',
      assignedTo: data['assigned_to'],
      isImportant: data['is_important'] ?? false,
      notes: data['notes'],
      completedDate:
          data['completed_date'] != null
              ? DateTime.parse(data['completed_date'])
              : null,
      priority: _parseTaskPriority(data['priority']),
      isServiceRelated: data['is_service_related'] ?? false,
      serviceId: data['service_id'],
      dependencies:
          data['dependencies'] != null
              ? List<String>.from(data['dependencies'])
              : [],
      eventId: data['event_id'],
      service: data['service'],
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
