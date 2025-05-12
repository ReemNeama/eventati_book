import 'package:flutter/material.dart';
import 'package:eventati_book/utils/database_utils.dart';

/// Enum representing the type of event
enum EventType { wedding, business, celebration, other }

/// Extension to add helper methods to EventType
extension EventTypeExtension on EventType {
  /// Get the display name of the event type
  String get displayName {
    switch (this) {
      case EventType.wedding:
        return 'Wedding';
      case EventType.business:
        return 'Business Event';
      case EventType.celebration:
        return 'Celebration';
      case EventType.other:
        return 'Other';
    }
  }

  /// Get the icon for the event type
  IconData get icon {
    switch (this) {
      case EventType.wedding:
        return Icons.favorite;
      case EventType.business:
        return Icons.business;
      case EventType.celebration:
        return Icons.celebration;
      case EventType.other:
        return Icons.event;
    }
  }
}

/// Model representing an event
class Event {
  /// Unique identifier for the event
  final String id;

  /// Name of the event
  final String name;

  /// Type of event (wedding, business, celebration, etc.)
  final EventType type;

  /// Date of the event
  final DateTime date;

  /// Location of the event
  final String location;

  /// Budget for the event
  final double budget;

  /// Expected number of guests
  final int guestCount;

  /// Description of the event
  final String? description;

  /// User ID of the event creator
  final String? userId;

  /// When the event was created
  final DateTime? createdAt;

  /// When the event was last updated
  final DateTime? updatedAt;

  /// Status of the event (draft, active, completed, etc.)
  final String? status;

  /// List of image URLs for the event
  final List<String> imageUrls;

  /// Creates a new Event
  const Event({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    required this.location,
    required this.budget,
    required this.guestCount,
    this.description,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.imageUrls = const [],
  });

  /// Creates a copy of this Event with the given fields replaced with the new values
  Event copyWith({
    String? id,
    String? name,
    EventType? type,
    DateTime? date,
    String? location,
    double? budget,
    int? guestCount,
    String? description,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    List<String>? imageUrls,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      date: date ?? this.date,
      location: location ?? this.location,
      budget: budget ?? this.budget,
      guestCount: guestCount ?? this.guestCount,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }

  /// Creates an Event from a JSON object
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      name: json['name'] as String,
      type: EventType.values[json['type'] as int],
      date: DateTime.parse(json['date'] as String),
      location: json['location'] as String,
      budget: json['budget'] as double,
      guestCount: json['guestCount'] as int,
      description: json['description'] as String?,
      userId: json['userId'] as String?,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
      status: json['status'] as String?,
      imageUrls:
          json['imageUrls'] != null
              ? List<String>.from(json['imageUrls'] as List)
              : [],
    );
  }

  /// Converts this Event to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'date': date.toIso8601String(),
      'location': location,
      'budget': budget,
      'guestCount': guestCount,
      'description': description,
      'userId': userId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status,
      'imageUrls': imageUrls,
    };
  }

  @override
  String toString() {
    return 'Event{id: $id, name: $name, type: ${type.displayName}, date: $date, location: $location, budget: $budget, guestCount: $guestCount, description: $description, userId: $userId, status: $status}';
  }

  /// Creates an Event from a database document
  factory Event.fromDatabaseDoc(DbDocumentSnapshot doc) {
    final data = doc.getData();
    if (data.isEmpty) {
      throw Exception('Document data was null');
    }

    return Event(
      id: doc.id,
      name: data['name'] ?? '',
      type: _getEventTypeFromDatabase(data['type']),
      date:
          data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
      location: data['location'] ?? '',
      budget: (data['budget'] ?? 0.0).toDouble(),
      guestCount: (data['guestCount'] ?? 0) as int,
      description: data['description'],
      userId: data['userId'],
      createdAt:
          data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
      updatedAt:
          data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
      status: data['status'],
      imageUrls:
          data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : [],
    );
  }

  /// Helper method to get EventType from database data
  static EventType _getEventTypeFromDatabase(dynamic typeData) {
    if (typeData is int) {
      return EventType.values[typeData];
    } else if (typeData is String) {
      try {
        return EventType.values.firstWhere(
          (e) =>
              e.toString().split('.').last.toLowerCase() ==
              typeData.toLowerCase(),
        );
      } catch (_) {
        return EventType.other;
      }
    }
    return EventType.other;
  }

  /// Converts this Event to a database document
  Map<String, dynamic> toDatabaseDoc() {
    return {
      'name': name,
      'type': type.index,
      'date': DbTimestamp.fromDate(date).toIso8601String(),
      'location': location,
      'budget': budget,
      'guestCount': guestCount,
      'description': description,
      'userId': userId,
      'createdAt':
          createdAt != null
              ? DbTimestamp.fromDate(createdAt!).toIso8601String()
              : DbFieldValue.serverTimestamp(),
      'updatedAt': DbFieldValue.serverTimestamp(),
      'status': status ?? 'active',
      'imageUrls': imageUrls,
    };
  }
}
