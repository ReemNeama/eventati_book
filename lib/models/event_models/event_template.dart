import 'package:flutter/material.dart';
import 'package:eventati_book/utils/database_utils.dart';

/// Defines a template for an event type with predefined services and subtypes
class EventTemplate {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<String> subtypes;
  final Map<String, bool> defaultServices;
  final List<String> suggestedTasks;
  final String? userId; // Owner of the event
  final DateTime? createdAt; // When the event was created
  final DateTime? updatedAt; // When the event was last updated
  final String? status; // Status of the event (draft, active, completed, etc.)

  const EventTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.subtypes,
    required this.defaultServices,
    required this.suggestedTasks,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.status,
  });

  /// Create a copy of this template with modified fields
  EventTemplate copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    List<String>? subtypes,
    Map<String, bool>? defaultServices,
    List<String>? suggestedTasks,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) {
    return EventTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      subtypes: subtypes ?? this.subtypes,
      defaultServices: defaultServices ?? this.defaultServices,
      suggestedTasks: suggestedTasks ?? this.suggestedTasks,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  /// Convert IconData to a map
  static Map<String, dynamic> _iconDataToMap(IconData icon) {
    return {
      'codePoint': icon.codePoint,
      'fontFamily': icon.fontFamily,
      'fontPackage': icon.fontPackage,
    };
  }

  /// Create IconData from a map
  static IconData _iconDataFromMap(Map<String, dynamic> map) {
    return IconData(
      map['codePoint'],
      fontFamily: map['fontFamily'],
      fontPackage: map['fontPackage'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': _iconDataToMap(icon),
      'subtypes': subtypes,
      'defaultServices': defaultServices,
      'suggestedTasks': suggestedTasks,
      'userId': userId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status,
    };
  }

  /// Create from JSON
  factory EventTemplate.fromJson(Map<String, dynamic> json) {
    return EventTemplate(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'] is Map ? _iconDataFromMap(json['icon']) : Icons.event,
      subtypes: List<String>.from(json['subtypes'] ?? []),
      defaultServices: Map<String, bool>.from(json['defaultServices'] ?? {}),
      suggestedTasks: List<String>.from(json['suggestedTasks'] ?? []),
      userId: json['userId'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      status: json['status'],
    );
  }

  /// Convert to database document
  Map<String, dynamic> toDatabaseDoc() {
    return {
      'name': name,
      'description': description,
      'icon': _iconDataToMap(icon),
      'subtypes': subtypes,
      'defaultServices': defaultServices,
      'suggestedTasks': suggestedTasks,
      'userId': userId,
      'createdAt':
          createdAt != null
              ? DbTimestamp.fromDate(createdAt!).toIso8601String()
              : DbFieldValue.serverTimestamp(),
      'updatedAt':
          updatedAt != null
              ? DbTimestamp.fromDate(updatedAt!).toIso8601String()
              : DbFieldValue.serverTimestamp(),
      'status': status,
    };
  }

  /// Create from database document
  factory EventTemplate.fromDatabaseDoc(DbDocumentSnapshot doc) {
    final data = doc.getData();
    if (data.isEmpty) {
      throw Exception('Document data was null');
    }

    return EventTemplate(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] is Map ? _iconDataFromMap(data['icon']) : Icons.event,
      subtypes: List<String>.from(data['subtypes'] ?? []),
      defaultServices: Map<String, bool>.from(data['defaultServices'] ?? {}),
      suggestedTasks: List<String>.from(data['suggestedTasks'] ?? []),
      userId: data['userId'],
      createdAt:
          data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
      updatedAt:
          data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
      status: data['status'],
    );
  }
}

/// Predefined event templates
class EventTemplates {
  /// Wedding event template
  static const EventTemplate wedding = EventTemplate(
    id: 'wedding',
    name: 'Wedding',
    description: 'Plan your perfect wedding day',
    icon: Icons.favorite,
    subtypes: [
      'Wedding',
      'Engagement Party',
      'Wedding Shower',
      'Rehearsal Dinner',
    ],
    defaultServices: {
      'Venue': false,
      'Catering': false,
      'Photography/Videography': false,
      'Wedding Dress/Attire': false,
      'Flowers & Decoration': false,
      'Music & Entertainment': false,
      'Wedding Cake': false,
      'Invitations': false,
      'Transportation': false,
      'Accommodation': false,
      'Hair & Makeup': false,
      'Wedding Rings': false,
    },
    suggestedTasks: [
      'Set a budget',
      'Create guest list',
      'Choose wedding party',
      'Book venue',
      'Hire photographer',
      'Order wedding cake',
      'Send invitations',
    ],
  );

  /// Business event template
  static const EventTemplate business = EventTemplate(
    id: 'business',
    name: 'Business Event',
    description: 'Organize a professional business event',
    icon: Icons.business,
    subtypes: [
      'Conference',
      'Seminar',
      'Workshop',
      'Corporate Meeting',
      'Trade Show',
      'Team Building',
      'Product Launch',
      'Award Ceremony',
    ],
    defaultServices: {
      'Venue': false,
      'Catering': false,
      'Audio/Visual Equipment': false,
      'Photography': false,
      'Transportation': false,
      'Accommodation': false,
      'Event Staff': false,
      'Decoration': false,
    },
    suggestedTasks: [
      'Define event objectives',
      'Create event agenda',
      'Book speakers',
      'Arrange audio/visual equipment',
      'Organize catering',
      'Prepare marketing materials',
      'Set up registration system',
    ],
  );

  /// Celebration event template
  static const EventTemplate celebration = EventTemplate(
    id: 'celebration',
    name: 'Celebration',
    description: 'Create a memorable celebration',
    icon: Icons.celebration,
    subtypes: [
      'Birthday Party',
      'Anniversary',
      'Graduation',
      'Baby Shower',
      'Retirement Party',
      'Holiday Party',
      'Family Reunion',
      'Other Celebration',
    ],
    defaultServices: {
      'Venue': false,
      'Catering': false,
      'Photography': false,
      'Music & Entertainment': false,
      'Decoration': false,
      'Invitations': false,
      'Cake & Desserts': false,
      'Party Favors': false,
      'Transportation': false,
      'Activities & Games': false,
    },
    suggestedTasks: [
      'Create guest list',
      'Choose theme',
      'Book venue',
      'Order cake',
      'Plan activities',
      'Send invitations',
      'Arrange decorations',
    ],
  );

  /// Get all available templates
  static List<EventTemplate> get all => const [wedding, business, celebration];

  /// Find a template by ID
  static EventTemplate? findById(String id) {
    try {
      return all.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }
}
