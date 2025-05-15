import 'package:flutter/material.dart';

/// Model for user feedback
class UserFeedback {
  /// The ID of the feedback
  final String? id;

  /// The ID of the user who submitted the feedback
  final String userId;

  /// The type of feedback
  final FeedbackType type;

  /// The rating (1-5)
  final int? rating;

  /// The feedback message
  final String message;

  /// The screen or feature the feedback is about
  final String? context;

  /// Whether the feedback has been read
  final bool isRead;

  /// Whether the feedback has been resolved
  final bool isResolved;

  /// The timestamp when the feedback was created
  final DateTime createdAt;

  /// The timestamp when the feedback was last updated
  final DateTime updatedAt;

  /// Creates a UserFeedback
  UserFeedback({
    this.id,
    required this.userId,
    required this.type,
    this.rating,
    required this.message,
    this.context,
    this.isRead = false,
    this.isResolved = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Creates a UserFeedback from a map
  factory UserFeedback.fromMap(Map<String, dynamic> map, String id) {
    return UserFeedback(
      id: id,
      userId: map['user_id'] as String,
      type: FeedbackType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => FeedbackType.general,
      ),
      rating: map['rating'] as int?,
      message: map['message'] as String,
      context: map['context'] as String?,
      isRead: map['is_read'] as bool? ?? false,
      isResolved: map['is_resolved'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Converts the UserFeedback to a map
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'type': type.name,
      'rating': rating,
      'message': message,
      'context': context,
      'is_read': isRead,
      'is_resolved': isResolved,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy of the UserFeedback with the given fields replaced
  UserFeedback copyWith({
    String? id,
    String? userId,
    FeedbackType? type,
    int? rating,
    String? message,
    String? context,
    bool? isRead,
    bool? isResolved,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserFeedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      rating: rating ?? this.rating,
      message: message ?? this.message,
      context: context ?? this.context,
      isRead: isRead ?? this.isRead,
      isResolved: isResolved ?? this.isResolved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Types of feedback
enum FeedbackType {
  /// General feedback
  general,

  /// Bug report
  bug,

  /// Feature request
  feature,

  /// UI/UX feedback
  ui,

  /// Performance feedback
  performance,

  /// Content feedback
  content,

  /// Other feedback
  other,
}

/// Extension methods for FeedbackType
extension FeedbackTypeExtension on FeedbackType {
  /// Get the display name of the feedback type
  String get displayName {
    switch (this) {
      case FeedbackType.general:
        return 'General Feedback';
      case FeedbackType.bug:
        return 'Bug Report';
      case FeedbackType.feature:
        return 'Feature Request';
      case FeedbackType.ui:
        return 'UI/UX Feedback';
      case FeedbackType.performance:
        return 'Performance Feedback';
      case FeedbackType.content:
        return 'Content Feedback';
      case FeedbackType.other:
        return 'Other';
    }
  }

  /// Get the icon for the feedback type
  IconData get icon {
    switch (this) {
      case FeedbackType.general:
        return Icons.feedback;
      case FeedbackType.bug:
        return Icons.bug_report;
      case FeedbackType.feature:
        return Icons.lightbulb;
      case FeedbackType.ui:
        return Icons.palette;
      case FeedbackType.performance:
        return Icons.speed;
      case FeedbackType.content:
        return Icons.article;
      case FeedbackType.other:
        return Icons.help;
    }
  }
}
