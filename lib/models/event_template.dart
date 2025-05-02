import 'package:flutter/material.dart';

/// Defines a template for an event type with predefined services and subtypes
class EventTemplate {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<String> subtypes;
  final Map<String, bool> defaultServices;
  final List<String> suggestedTasks;

  const EventTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.subtypes,
    required this.defaultServices,
    required this.suggestedTasks,
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
  }) {
    return EventTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      subtypes: subtypes ?? this.subtypes,
      defaultServices: defaultServices ?? this.defaultServices,
      suggestedTasks: suggestedTasks ?? this.suggestedTasks,
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
