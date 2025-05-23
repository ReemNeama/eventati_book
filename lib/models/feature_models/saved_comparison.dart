import 'package:flutter/foundation.dart';

/// Model representing a saved comparison
class SavedComparison {
  /// Unique identifier for the saved comparison
  final String id;

  /// ID of the user who saved the comparison
  final String userId;

  /// Type of service being compared (Venue, Catering, Photographer, Planner)
  final String serviceType;

  /// IDs of the services being compared
  final List<String> serviceIds;

  /// Names of the services being compared (for display purposes)
  final List<String> serviceNames;

  /// Date and time when the comparison was saved
  final DateTime createdAt;

  /// Title/name for the saved comparison
  final String title;

  /// Optional notes about the comparison
  final String notes;

  /// Optional ID of the event associated with this comparison
  final String? eventId;

  /// Optional name of the event associated with this comparison
  final String? eventName;

  /// Constructor
  SavedComparison({
    required this.id,
    required this.userId,
    required this.serviceType,
    required this.serviceIds,
    required this.serviceNames,
    required this.createdAt,
    required this.title,
    this.notes = '',
    this.eventId,
    this.eventName,
  });

  /// Create a copy of this saved comparison with modified fields
  SavedComparison copyWith({
    String? id,
    String? userId,
    String? serviceType,
    List<String>? serviceIds,
    List<String>? serviceNames,
    DateTime? createdAt,
    String? title,
    String? notes,
    String? eventId,
    String? eventName,
  }) {
    return SavedComparison(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceType: serviceType ?? this.serviceType,
      serviceIds: serviceIds ?? this.serviceIds,
      serviceNames: serviceNames ?? this.serviceNames,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      eventId: eventId ?? this.eventId,
      eventName: eventName ?? this.eventName,
    );
  }

  /// Convert saved comparison to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'serviceType': serviceType,
      'serviceIds': serviceIds,
      'serviceNames': serviceNames,
      'createdAt': createdAt.toIso8601String(),
      'title': title,
      'notes': notes,
      'eventId': eventId,
      'eventName': eventName,
    };
  }

  /// Create saved comparison from JSON
  factory SavedComparison.fromJson(Map<String, dynamic> json) {
    try {
      return SavedComparison(
        id: json['id'] as String? ?? '',
        userId: json['userId'] as String? ?? 'anonymous',
        serviceType: json['serviceType'] as String? ?? '',
        serviceIds:
            json['serviceIds'] != null
                ? List<String>.from(json['serviceIds'])
                : <String>[],
        serviceNames:
            json['serviceNames'] != null
                ? List<String>.from(json['serviceNames'])
                : <String>[],
        createdAt:
            json['createdAt'] != null
                ? DateTime.parse(json['createdAt'])
                : DateTime.now(),
        title: json['title'] as String? ?? 'Untitled Comparison',
        notes: json['notes'] as String? ?? '',
        eventId: json['eventId'] as String?,
        eventName: json['eventName'] as String?,
      );
    } catch (e) {
      debugPrint('Error parsing SavedComparison from JSON: $e');
      // Return a default comparison in case of parsing error
      return SavedComparison(
        id: '',
        userId: 'anonymous',
        serviceType: '',
        serviceIds: [],
        serviceNames: [],
        createdAt: DateTime.now(),
        title: 'Error: Corrupted Comparison',
        notes: 'This comparison could not be loaded correctly.',
      );
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SavedComparison &&
        other.id == id &&
        other.userId == userId &&
        other.serviceType == serviceType &&
        listEquals(other.serviceIds, serviceIds) &&
        listEquals(other.serviceNames, serviceNames) &&
        other.createdAt == createdAt &&
        other.title == title &&
        other.notes == notes &&
        other.eventId == eventId &&
        other.eventName == eventName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        serviceType.hashCode ^
        serviceIds.hashCode ^
        serviceNames.hashCode ^
        createdAt.hashCode ^
        title.hashCode ^
        notes.hashCode ^
        eventId.hashCode ^
        eventName.hashCode;
  }
}
