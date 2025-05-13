import 'package:eventati_book/models/planning_models/task_dependency.dart';

/// Represents a template for creating tasks
class TaskTemplate {
  /// Unique identifier for the template
  final String id;

  /// Name of the template
  final String name;

  /// Description of the template
  final String description;

  /// Event type this template is for (wedding, business, etc.)
  final String eventType;

  /// User ID of the creator (null for system templates)
  final String? userId;

  /// Whether this is a system template or user-created
  final bool isSystemTemplate;

  /// List of task definitions in this template
  final List<TaskDefinition> taskDefinitions;

  /// List of dependencies between tasks in this template
  final List<TaskDependencyDefinition> dependencies;

  /// Tags for categorizing and filtering templates
  final List<String> tags;

  /// When the template was created
  final DateTime createdAt;

  /// When the template was last updated
  final DateTime updatedAt;

  /// Constructor
  TaskTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.eventType,
    this.userId,
    this.isSystemTemplate = false,
    required this.taskDefinitions,
    this.dependencies = const [],
    this.tags = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Create a copy of this template with modified fields
  TaskTemplate copyWith({
    String? id,
    String? name,
    String? description,
    String? eventType,
    String? userId,
    bool? isSystemTemplate,
    List<TaskDefinition>? taskDefinitions,
    List<TaskDependencyDefinition>? dependencies,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      eventType: eventType ?? this.eventType,
      userId: userId ?? this.userId,
      isSystemTemplate: isSystemTemplate ?? this.isSystemTemplate,
      taskDefinitions: taskDefinitions ?? this.taskDefinitions,
      dependencies: dependencies ?? this.dependencies,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'event_type': eventType,
      'user_id': userId,
      'is_system_template': isSystemTemplate,
      'task_definitions': taskDefinitions.map((t) => t.toJson()).toList(),
      'dependencies': dependencies.map((d) => d.toJson()).toList(),
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory TaskTemplate.fromJson(Map<String, dynamic> json) {
    return TaskTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      eventType: json['event_type'] as String,
      userId: json['user_id'] as String?,
      isSystemTemplate: json['is_system_template'] as bool? ?? false,
      taskDefinitions:
          (json['task_definitions'] as List<dynamic>)
              .map((t) => TaskDefinition.fromJson(t as Map<String, dynamic>))
              .toList(),
      dependencies:
          (json['dependencies'] as List<dynamic>?)
              ?.map(
                (d) => TaskDependencyDefinition.fromJson(
                  d as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((t) => t as String).toList() ??
          [],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  /// Convert to database document
  Map<String, dynamic> toDatabaseDoc() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'event_type': eventType,
      'user_id': userId,
      'is_system_template': isSystemTemplate,
      'task_definitions': taskDefinitions.map((t) => t.toJson()).toList(),
      'dependencies': dependencies.map((d) => d.toJson()).toList(),
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Represents a task definition within a template
class TaskDefinition {
  /// Unique identifier for this task definition within the template
  final String id;

  /// Title of the task
  final String title;

  /// Description of the task
  final String? description;

  /// Category ID for the task
  final String categoryId;

  /// Number of days before the event this task should be due
  final int daysBeforeEvent;

  /// Whether this task is important
  final bool isImportant;

  /// Service this task is associated with (Venue, Catering, etc.)
  final String service;

  /// Constructor
  TaskDefinition({
    required this.id,
    required this.title,
    this.description,
    required this.categoryId,
    required this.daysBeforeEvent,
    this.isImportant = false,
    required this.service,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'days_before_event': daysBeforeEvent,
      'is_important': isImportant,
      'service': service,
    };
  }

  /// Create from JSON
  factory TaskDefinition.fromJson(Map<String, dynamic> json) {
    return TaskDefinition(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String,
      daysBeforeEvent: json['days_before_event'] as int,
      isImportant: json['is_important'] as bool? ?? false,
      service: json['service'] as String,
    );
  }
}

/// Represents a dependency between tasks in a template
class TaskDependencyDefinition {
  /// ID of the prerequisite task definition
  final String prerequisiteTaskId;

  /// ID of the dependent task definition
  final String dependentTaskId;

  /// Type of dependency
  final DependencyType type;

  /// Offset in days (for start-to-start or finish-to-finish dependencies)
  final int offsetDays;

  /// Constructor
  TaskDependencyDefinition({
    required this.prerequisiteTaskId,
    required this.dependentTaskId,
    this.type = DependencyType.finishToStart,
    this.offsetDays = 0,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'prerequisite_task_id': prerequisiteTaskId,
      'dependent_task_id': dependentTaskId,
      'type': type.index,
      'offset_days': offsetDays,
    };
  }

  /// Create from JSON
  factory TaskDependencyDefinition.fromJson(Map<String, dynamic> json) {
    return TaskDependencyDefinition(
      prerequisiteTaskId: json['prerequisite_task_id'] as String,
      dependentTaskId: json['dependent_task_id'] as String,
      type: DependencyType.values[json['type'] as int? ?? 0],
      offsetDays: json['offset_days'] as int? ?? 0,
    );
  }
}
