import 'package:flutter/material.dart';

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
    };
  }

  @override
  String toString() {
    return 'Event{id: $id, name: $name, type: ${type.displayName}, date: $date, location: $location, budget: $budget, guestCount: $guestCount, description: $description}';
  }
}
