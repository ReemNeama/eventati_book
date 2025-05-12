import 'package:eventati_book/utils/database_utils.dart';

/// Represents a dependency between two tasks
class TaskDependency {
  /// ID of the prerequisite task
  final String prerequisiteTaskId;

  /// ID of the dependent task
  final String dependentTaskId;

  /// Type of dependency
  final DependencyType type;

  /// Offset in days (for start-to-start or finish-to-finish dependencies)
  final int offsetDays;

  /// When the dependency was created
  final DateTime createdAt;

  /// When the dependency was last updated
  final DateTime updatedAt;

  /// Constructor
  TaskDependency({
    required this.prerequisiteTaskId,
    required this.dependentTaskId,
    this.type = DependencyType.finishToStart,
    this.offsetDays = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Create a copy of this dependency with modified fields
  TaskDependency copyWith({
    String? prerequisiteTaskId,
    String? dependentTaskId,
    DependencyType? type,
    int? offsetDays,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskDependency(
      prerequisiteTaskId: prerequisiteTaskId ?? this.prerequisiteTaskId,
      dependentTaskId: dependentTaskId ?? this.dependentTaskId,
      type: type ?? this.type,
      offsetDays: offsetDays ?? this.offsetDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'prerequisite_task_id': prerequisiteTaskId,
      'dependent_task_id': dependentTaskId,
      'type': type.index,
      'offset_days': offsetDays,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory TaskDependency.fromJson(Map<String, dynamic> json) {
    return TaskDependency(
      prerequisiteTaskId: json['prerequisite_task_id'] as String,
      dependentTaskId: json['dependent_task_id'] as String,
      type: DependencyType.values[json['type'] as int? ?? 0],
      offsetDays: json['offset_days'] as int? ?? 0,
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
      'prerequisite_task_id': prerequisiteTaskId,
      'dependent_task_id': dependentTaskId,
      'type': type.index,
      'offset_days': offsetDays,
      'created_at': DbTimestamp.fromDate(createdAt).toIso8601String(),
      'updated_at': DbTimestamp.fromDate(updatedAt).toIso8601String(),
    };
  }

  /// Create from database document
  factory TaskDependency.fromDatabaseDoc(DbDocumentSnapshot doc) {
    final data = doc.getData();
    if (data.isEmpty) {
      throw Exception('Document data was empty');
    }

    return TaskDependency(
      prerequisiteTaskId: data['prerequisite_task_id'] as String,
      dependentTaskId: data['dependent_task_id'] as String,
      type: DependencyType.values[data['type'] as int? ?? 0],
      offsetDays: data['offset_days'] as int? ?? 0,
      createdAt:
          data['created_at'] != null
              ? DateTime.parse(data['created_at'] as String)
              : null,
      updatedAt:
          data['updated_at'] != null
              ? DateTime.parse(data['updated_at'] as String)
              : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskDependency &&
          runtimeType == other.runtimeType &&
          prerequisiteTaskId == other.prerequisiteTaskId &&
          dependentTaskId == other.dependentTaskId;

  @override
  int get hashCode => prerequisiteTaskId.hashCode ^ dependentTaskId.hashCode;
}

/// Types of task dependencies
enum DependencyType {
  /// The dependent task can start only after the prerequisite task finishes
  finishToStart,

  /// The dependent task can start only after the prerequisite task starts
  startToStart,

  /// The dependent task can finish only after the prerequisite task finishes
  finishToFinish,

  /// The dependent task can finish only after the prerequisite task starts
  startToFinish,
}
