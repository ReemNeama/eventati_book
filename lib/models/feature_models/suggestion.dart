import 'package:flutter/material.dart';
import 'package:eventati_book/utils/database_utils.dart';
import 'package:eventati_book/models/event_models/wizard_state.dart';
import 'package:eventati_book/styles/app_colors.dart';

/// Categories for different types of suggestions
enum SuggestionCategory {
  venue('Venue', Icons.location_on),
  catering('Catering', Icons.restaurant),
  photography('Photography', Icons.camera_alt),
  entertainment('Entertainment', Icons.music_note),
  decoration('Decoration', Icons.celebration),
  planning('Planning', Icons.event),
  budget('Budget', Icons.attach_money),
  guestList('Guest List', Icons.people),
  timeline('Timeline', Icons.schedule),
  transportation('Transportation', Icons.directions_car),
  accommodation('Accommodation', Icons.hotel),
  attire('Attire', Icons.checkroom),
  beauty('Beauty', Icons.face),
  other('Other', Icons.more_horiz);

  final String label;
  final IconData icon;

  const SuggestionCategory(this.label, this.icon);

  @override
  String toString() => label;
}

/// Priority levels for suggestions
enum SuggestionPriority {
  high('High', AppColors.error),
  medium('Medium', AppColors.warning),
  low('Low', AppColors.primary);

  final String label;
  final Color color;

  const SuggestionPriority(this.label, this.color);

  @override
  String toString() => label;
}

/// Comparison operators for suggestion conditions
enum ConditionOperator {
  equals('='),
  notEquals('≠'),
  greaterThan('>'),
  lessThan('<'),
  greaterThanOrEqual('≥'),
  lessThanOrEqual('≤'),
  contains('contains'),
  notContains('not contains'),
  isTrue('is true'),
  isFalse('is false'),
  isNull('is null'),
  isNotNull('is not null');

  final String symbol;

  const ConditionOperator(this.symbol);

  @override
  String toString() => symbol;
}

/// A condition that determines when a suggestion is relevant
class SuggestionCondition {
  /// The field in the wizard state to check
  final String field;

  /// The comparison operator
  final ConditionOperator operator;

  /// The value to compare against
  final dynamic value;

  const SuggestionCondition({
    required this.field,
    required this.operator,
    this.value,
  });

  /// Evaluate the condition against a wizard state
  bool evaluate(WizardState state) {
    // Get the field value from the wizard state
    dynamic fieldValue;
    switch (field) {
      case 'eventName':
        fieldValue = state.eventName;
        break;
      case 'selectedEventType':
        fieldValue = state.selectedEventType;
        break;
      case 'eventDate':
        fieldValue = state.eventDate;
        break;
      case 'guestCount':
        fieldValue = state.guestCount;
        break;
      case 'selectedServices':
        fieldValue = state.selectedServices;
        break;
      case 'eventDuration':
        fieldValue = state.eventDuration;
        break;
      case 'needsSetup':
        fieldValue = state.needsSetup;
        break;
      case 'needsTeardown':
        fieldValue = state.needsTeardown;
        break;
      case 'templateId':
        fieldValue = state.template.id;
        break;
      default:
        return false; // Unknown field
    }

    // Evaluate the condition based on the operator
    switch (operator) {
      case ConditionOperator.equals:
        return fieldValue == value;
      case ConditionOperator.notEquals:
        return fieldValue != value;
      case ConditionOperator.greaterThan:
        return fieldValue != null && value != null && fieldValue > value;
      case ConditionOperator.lessThan:
        return fieldValue != null && value != null && fieldValue < value;
      case ConditionOperator.greaterThanOrEqual:
        return fieldValue != null && value != null && fieldValue >= value;
      case ConditionOperator.lessThanOrEqual:
        return fieldValue != null && value != null && fieldValue <= value;
      case ConditionOperator.contains:
        if (fieldValue is Map && value is String) {
          return fieldValue.containsKey(value) && fieldValue[value] == true;
        } else if (fieldValue is String && value is String) {
          return fieldValue.contains(value);
        } else if (fieldValue is List) {
          return fieldValue.contains(value);
        }

        return false;
      case ConditionOperator.notContains:
        if (fieldValue is Map && value is String) {
          return !fieldValue.containsKey(value) || fieldValue[value] == false;
        } else if (fieldValue is String && value is String) {
          return !fieldValue.contains(value);
        } else if (fieldValue is List) {
          return !fieldValue.contains(value);
        }

        return true;
      case ConditionOperator.isTrue:
        return fieldValue == true;
      case ConditionOperator.isFalse:
        return fieldValue == false;
      case ConditionOperator.isNull:
        return fieldValue == null;
      case ConditionOperator.isNotNull:
        return fieldValue != null;
    }
  }

  /// Convert the condition to a JSON map
  Map<String, dynamic> toJson() {
    return {'field': field, 'operator': operator.name, 'value': value};
  }

  /// Create a condition from a JSON map
  factory SuggestionCondition.fromJson(Map<String, dynamic> json) {
    return SuggestionCondition(
      field: json['field'],
      operator: ConditionOperator.values.firstWhere(
        (op) => op.name == json['operator'],
        orElse: () => ConditionOperator.equals,
      ),
      value: json['value'],
    );
  }
}

/// A suggestion for the user based on their event details
class Suggestion {
  /// Unique identifier
  final String id;

  /// Short title of the suggestion
  final String title;

  /// Detailed description
  final String description;

  /// The category this suggestion belongs to
  final SuggestionCategory category;

  /// How important this suggestion is
  final SuggestionPriority priority;

  /// Base relevance score (0-100) before adjustments
  final int baseRelevanceScore;

  /// Conditions that must be met for this suggestion to be relevant
  final List<SuggestionCondition> conditions;

  /// Event types this suggestion applies to
  final List<String> applicableEventTypes;

  /// Tags for categorizing and filtering the suggestion
  final List<String> tags;

  /// Optional image URL to illustrate the suggestion
  final String? imageUrl;

  /// Optional link to a related action in the app
  final String? actionUrl;

  /// Whether this is a custom suggestion added by the user
  final bool isCustom;

  const Suggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.baseRelevanceScore,
    required this.conditions,
    required this.applicableEventTypes,
    this.tags = const [],
    this.imageUrl,
    this.actionUrl,
    this.isCustom = false,
  });

  /// Check if this suggestion is relevant for the given wizard state
  bool isRelevantFor(WizardState state) {
    // Check if the event type is applicable
    if (!applicableEventTypes.contains(state.template.id)) {
      return false;
    }

    // Check if all conditions are met
    for (final condition in conditions) {
      if (!condition.evaluate(state)) {
        return false;
      }
    }

    return true;
  }

  /// Calculate the final relevance score based on the wizard state
  int calculateRelevanceScore(WizardState state) {
    if (!isRelevantFor(state)) {
      return 0;
    }

    // Start with the base score
    int score = baseRelevanceScore;

    // Adjust score based on various factors

    // 1. Adjust based on event date proximity (if applicable)
    if (state.eventDate != null) {
      final daysUntilEvent = state.eventDate!.difference(DateTime.now()).inDays;

      // Higher relevance for suggestions that should be done soon
      if (daysUntilEvent < 30) {
        score += 20; // Very soon, high priority
      } else if (daysUntilEvent < 90) {
        score += 10; // Soon, medium priority
      }
    }

    // 2. Adjust based on guest count (if applicable)
    if (state.guestCount != null) {
      // Some suggestions are more important for larger events
      if (category == SuggestionCategory.venue ||
          category == SuggestionCategory.catering) {
        if (state.guestCount! > 100) {
          score += 15; // Large event, these categories are more important
        } else if (state.guestCount! > 50) {
          score += 10; // Medium event
        }
      }
    }

    // 3. Adjust based on selected services
    if (category == SuggestionCategory.venue &&
        state.selectedServices.containsKey('Venue') &&
        state.selectedServices['Venue'] == true) {
      score +=
          15; // Venue is selected as a service, so venue suggestions are more relevant
    }

    // Cap the score at 100
    return score > 100 ? 100 : score;
  }

  /// Convert the suggestion to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'baseRelevanceScore': baseRelevanceScore,
      'conditions': conditions.map((c) => c.toJson()).toList(),
      'applicableEventTypes': applicableEventTypes,
      'tags': tags,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'isCustom': isCustom,
    };
  }

  /// Create a suggestion from a JSON map
  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: SuggestionCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => SuggestionCategory.other,
      ),
      priority: SuggestionPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => SuggestionPriority.medium,
      ),
      baseRelevanceScore: json['baseRelevanceScore'],
      conditions:
          (json['conditions'] as List)
              .map((c) => SuggestionCondition.fromJson(c))
              .toList(),
      applicableEventTypes: List<String>.from(json['applicableEventTypes']),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : const [],
      imageUrl: json['imageUrl'],
      actionUrl: json['actionUrl'],
      isCustom: json['isCustom'] ?? false,
    );
  }

  /// Convert to database document
  Map<String, dynamic> toDatabaseDoc() {
    return {
      'title': title,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'baseRelevanceScore': baseRelevanceScore,
      'conditions': conditions.map((c) => c.toJson()).toList(),
      'applicableEventTypes': applicableEventTypes,
      'tags': tags,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'isCustom': isCustom,
      'createdAt': DbFieldValue.serverTimestamp(),
      'updatedAt': DbFieldValue.serverTimestamp(),
    };
  }

  /// Create from database document
  factory Suggestion.fromDatabaseDoc(DbDocumentSnapshot doc) {
    final data = doc.getData();
    if (data.isEmpty) {
      throw Exception('Document data was null');
    }

    return Suggestion(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: SuggestionCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => SuggestionCategory.other,
      ),
      priority: SuggestionPriority.values.firstWhere(
        (p) => p.name == data['priority'],
        orElse: () => SuggestionPriority.medium,
      ),
      baseRelevanceScore: data['baseRelevanceScore'] ?? 50,
      conditions:
          data['conditions'] != null
              ? (data['conditions'] as List)
                  .map((c) => SuggestionCondition.fromJson(c))
                  .toList()
              : [],
      applicableEventTypes:
          data['applicableEventTypes'] != null
              ? List<String>.from(data['applicableEventTypes'])
              : ['all'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : const [],
      imageUrl: data['imageUrl'],
      actionUrl: data['actionUrl'],
      isCustom: data['isCustom'] ?? false,
    );
  }

  /// Create a copy of this suggestion with modified fields
  Suggestion copyWith({
    String? id,
    String? title,
    String? description,
    SuggestionCategory? category,
    SuggestionPriority? priority,
    int? baseRelevanceScore,
    List<SuggestionCondition>? conditions,
    List<String>? applicableEventTypes,
    List<String>? tags,
    String? imageUrl,
    String? actionUrl,
    bool? isCustom,
  }) {
    return Suggestion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      baseRelevanceScore: baseRelevanceScore ?? this.baseRelevanceScore,
      conditions: conditions ?? this.conditions,
      applicableEventTypes: applicableEventTypes ?? this.applicableEventTypes,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}

/// Predefined suggestion templates for different event types
class SuggestionTemplates {
  /// Get all predefined suggestions
  static List<Suggestion> getPredefinedSuggestions() {
    // Create a list of predefined suggestions for the database
    final List<Suggestion> suggestions = [];

    // Venue suggestions
    suggestions.add(
      const Suggestion(
        id: 'venue_wedding_large',
        title: 'Consider a hotel or banquet hall for your large wedding',
        description:
            'For weddings with over 100 guests, hotels and banquet halls offer ample space, in-house catering, and often accommodation for out-of-town guests.',
        category: SuggestionCategory.venue,
        priority: SuggestionPriority.high,
        baseRelevanceScore: 85,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'wedding',
          ),
          SuggestionCondition(
            field: 'guestCount',
            operator: ConditionOperator.greaterThan,
            value: 100,
          ),
        ],
        applicableEventTypes: ['wedding'],
        tags: ['large_venue', 'hotel', 'banquet_hall', 'accommodation'],
        actionUrl: '/services/venues',
      ),
    );

    suggestions.add(
      const Suggestion(
        id: 'venue_business_conference',
        title: 'Book a conference center with modern amenities',
        description:
            'For business events, look for venues with built-in AV equipment, high-speed internet, and breakout rooms for smaller sessions.',
        category: SuggestionCategory.venue,
        priority: SuggestionPriority.high,
        baseRelevanceScore: 90,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'business',
          ),
        ],
        applicableEventTypes: ['business'],
        tags: ['medium_venue', 'modern', 'conference', 'accessible'],
        actionUrl: '/services/venues',
      ),
    );

    // Catering suggestions
    suggestions.add(
      const Suggestion(
        id: 'catering_wedding_buffet',
        title: 'Consider a buffet for cost-effective catering',
        description:
            'Buffet-style service is typically less expensive than plated meals and allows guests to choose what they want to eat.',
        category: SuggestionCategory.catering,
        priority: SuggestionPriority.medium,
        baseRelevanceScore: 75,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'wedding',
          ),
        ],
        applicableEventTypes: ['wedding', 'celebration'],
        tags: ['buffet', 'food_station', 'cost_effective', 'casual'],
        actionUrl: '/services/catering',
      ),
    );

    // Photography suggestions
    suggestions.add(
      const Suggestion(
        id: 'photography_wedding_package',
        title: 'Book a comprehensive wedding photography package',
        description:
            'Look for packages that include engagement photos, full wedding day coverage, and a second shooter for capturing multiple angles.',
        category: SuggestionCategory.photography,
        priority: SuggestionPriority.high,
        baseRelevanceScore: 80,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'wedding',
          ),
        ],
        applicableEventTypes: ['wedding'],
        tags: ['engagement', 'second_shooter', 'album', 'traditional'],
        actionUrl: '/services/photography',
      ),
    );

    // Entertainment suggestions
    suggestions.add(
      const Suggestion(
        id: 'entertainment_celebration_dj',
        title: 'Hire a DJ for your celebration',
        description:
            'A professional DJ can read the crowd and adjust the music to keep your guests entertained throughout the event.',
        category: SuggestionCategory.entertainment,
        priority: SuggestionPriority.medium,
        baseRelevanceScore: 70,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'celebration',
          ),
        ],
        applicableEventTypes: ['celebration', 'wedding'],
        tags: ['dj', 'dance_floor', 'reception_music', 'casual'],
        actionUrl: '/services/entertainment',
      ),
    );

    // Budget suggestions
    suggestions.add(
      const Suggestion(
        id: 'budget_wedding_priorities',
        title: 'Set your wedding budget priorities',
        description:
            'Decide which aspects of your wedding are most important to you and allocate your budget accordingly. This helps ensure you spend on what matters most.',
        category: SuggestionCategory.budget,
        priority: SuggestionPriority.high,
        baseRelevanceScore: 95,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'wedding',
          ),
        ],
        applicableEventTypes: ['wedding'],
        tags: ['budget', 'planning', 'priorities', 'cost_effective'],
        actionUrl: '/event-planning/budget',
      ),
    );

    return suggestions;
  }

  /// Get suggestions for a specific event type
  static List<Suggestion> getSuggestionsForEventType(String eventType) {
    switch (eventType) {
      case 'wedding':
        return getWeddingSuggestions();
      case 'business':
        return getBusinessEventSuggestions();
      case 'celebration':
        return getCelebrationSuggestions();
      default:
        return [];
    }
  }

  /// Get wedding-specific suggestions
  static List<Suggestion> getWeddingSuggestions() {
    return [
      // Venue suggestions
      const Suggestion(
        id: 'wedding_venue_early',
        title: 'Book your wedding venue early',
        description:
            'Wedding venues often book up 12-18 months in advance. Start looking for venues as soon as possible to secure your preferred date and location.',
        category: SuggestionCategory.venue,
        priority: SuggestionPriority.high,
        baseRelevanceScore: 90,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'wedding',
          ),
          SuggestionCondition(
            field: 'selectedServices',
            operator: ConditionOperator.contains,
            value: 'Venue',
          ),
        ],
        applicableEventTypes: ['wedding'],
        actionUrl: '/services/venues',
      ),

      // Photography suggestions
      const Suggestion(
        id: 'wedding_photographer',
        title: 'Book your wedding photographer',
        description:
            'Professional wedding photographers are often booked 8-12 months in advance. Choose a photographer whose style matches your vision for the day.',
        category: SuggestionCategory.photography,
        priority: SuggestionPriority.high,
        baseRelevanceScore: 85,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'wedding',
          ),
          SuggestionCondition(
            field: 'selectedServices',
            operator: ConditionOperator.contains,
            value: 'Photography/Videography',
          ),
        ],
        applicableEventTypes: ['wedding'],
        actionUrl: '/services/photography',
      ),

      // Catering suggestions
      const Suggestion(
        id: 'wedding_catering',
        title: 'Arrange wedding catering',
        description:
            'Decide on your wedding menu and book a caterer at least 6-8 months before your wedding. Consider dietary restrictions of your guests.',
        category: SuggestionCategory.catering,
        priority: SuggestionPriority.high,
        baseRelevanceScore: 80,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'wedding',
          ),
          SuggestionCondition(
            field: 'selectedServices',
            operator: ConditionOperator.contains,
            value: 'Catering',
          ),
        ],
        applicableEventTypes: ['wedding'],
        actionUrl: '/services/catering',
      ),

      // Guest list suggestions
      const Suggestion(
        id: 'wedding_guest_list',
        title: 'Create your wedding guest list',
        description:
            'Start your guest list early to get an accurate headcount for venue and catering planning. Consider your budget and venue capacity when finalizing the list.',
        category: SuggestionCategory.guestList,
        priority: SuggestionPriority.high,
        baseRelevanceScore: 85,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'wedding',
          ),
        ],
        applicableEventTypes: ['wedding'],
        actionUrl: '/event-planning/guest-list',
      ),

      // Budget suggestions
      const Suggestion(
        id: 'wedding_budget',
        title: 'Set your wedding budget',
        description:
            'Establish a realistic budget early in the planning process. Allocate funds to different categories based on your priorities.',
        category: SuggestionCategory.budget,
        priority: SuggestionPriority.high,
        baseRelevanceScore: 95,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'wedding',
          ),
        ],
        applicableEventTypes: ['wedding'],
        actionUrl: '/event-planning/budget',
      ),

      // Timeline suggestions
      const Suggestion(
        id: 'wedding_timeline',
        title: 'Create a wedding planning timeline',
        description:
            'Develop a month-by-month checklist of tasks to ensure nothing is forgotten. Start with booking vendors and venues, then move to details like decor and attire.',
        category: SuggestionCategory.timeline,
        priority: SuggestionPriority.high,
        baseRelevanceScore: 90,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'wedding',
          ),
        ],
        applicableEventTypes: ['wedding'],
        actionUrl: '/event-planning/timeline',
      ),
    ];
  }

  /// Get business event-specific suggestions
  static List<Suggestion> getBusinessEventSuggestions() {
    return [
      // Venue suggestions
      const Suggestion(
        id: 'business_venue',
        title: 'Book an appropriate business venue',
        description:
            'Choose a venue that matches your event type and has the necessary facilities for presentations, networking, and breakout sessions.',
        category: SuggestionCategory.venue,
        priority: SuggestionPriority.high,
        baseRelevanceScore: 90,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'business',
          ),
          SuggestionCondition(
            field: 'selectedServices',
            operator: ConditionOperator.contains,
            value: 'Venue',
          ),
        ],
        applicableEventTypes: ['business'],
        actionUrl: '/services/venues',
      ),

      // AV equipment suggestions
      const Suggestion(
        id: 'business_av_equipment',
        title: 'Arrange audio/visual equipment',
        description:
            'Ensure your venue has the necessary A/V equipment or arrange for rental. Test all equipment before the event to avoid technical issues.',
        category: SuggestionCategory.entertainment,
        priority: SuggestionPriority.high,
        baseRelevanceScore: 85,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'business',
          ),
          SuggestionCondition(
            field: 'selectedServices',
            operator: ConditionOperator.contains,
            value: 'Audio/Visual Equipment',
          ),
        ],
        applicableEventTypes: ['business'],
      ),

      // Catering suggestions
      const Suggestion(
        id: 'business_catering',
        title: 'Arrange business-appropriate catering',
        description:
            'Select catering that fits your event schedule. Consider options like buffet for networking events or plated meals for formal dinners.',
        category: SuggestionCategory.catering,
        priority: SuggestionPriority.medium,
        baseRelevanceScore: 75,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'business',
          ),
          SuggestionCondition(
            field: 'selectedServices',
            operator: ConditionOperator.contains,
            value: 'Catering',
          ),
        ],
        applicableEventTypes: ['business'],
        actionUrl: '/services/catering',
      ),

      // Registration suggestions
      const Suggestion(
        id: 'business_registration',
        title: 'Set up event registration',
        description:
            'Create a registration system for attendees. Consider using digital check-in to streamline the process and collect valuable data.',
        category: SuggestionCategory.guestList,
        priority: SuggestionPriority.high,
        baseRelevanceScore: 85,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'business',
          ),
        ],
        applicableEventTypes: ['business'],
        actionUrl: '/event-planning/guest-list',
      ),

      // Budget suggestions
      const Suggestion(
        id: 'business_budget',
        title: 'Create a business event budget',
        description:
            'Develop a comprehensive budget that includes venue, catering, equipment, marketing, and staff costs. Include a contingency fund for unexpected expenses.',
        category: SuggestionCategory.budget,
        priority: SuggestionPriority.high,
        baseRelevanceScore: 90,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'business',
          ),
        ],
        applicableEventTypes: ['business'],
        actionUrl: '/event-planning/budget',
      ),

      // Timeline suggestions
      const Suggestion(
        id: 'business_agenda',
        title: 'Create a detailed event agenda',
        description:
            'Develop a minute-by-minute schedule for your event. Include setup time, registration, presentations, breaks, and networking opportunities.',
        category: SuggestionCategory.timeline,
        priority: SuggestionPriority.high,
        baseRelevanceScore: 90,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'business',
          ),
        ],
        applicableEventTypes: ['business'],
        actionUrl: '/event-planning/timeline',
      ),
    ];
  }

  /// Get celebration-specific suggestions
  static List<Suggestion> getCelebrationSuggestions() {
    return [
      // Venue suggestions
      const Suggestion(
        id: 'celebration_venue',
        title: 'Find the perfect celebration venue',
        description:
            'Choose a venue that matches your celebration theme and can accommodate your guest count. Consider indoor/outdoor options based on the season.',
        category: SuggestionCategory.venue,
        priority: SuggestionPriority.high,
        baseRelevanceScore: 85,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'celebration',
          ),
          SuggestionCondition(
            field: 'selectedServices',
            operator: ConditionOperator.contains,
            value: 'Venue',
          ),
        ],
        applicableEventTypes: ['celebration'],
        actionUrl: '/services/venues',
      ),

      // Entertainment suggestions
      const Suggestion(
        id: 'celebration_entertainment',
        title: 'Book entertainment for your celebration',
        description:
            'Arrange entertainment that fits your event theme. Options include DJs, live bands, photo booths, or interactive activities.',
        category: SuggestionCategory.entertainment,
        priority: SuggestionPriority.medium,
        baseRelevanceScore: 75,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'celebration',
          ),
          SuggestionCondition(
            field: 'selectedServices',
            operator: ConditionOperator.contains,
            value: 'Music & Entertainment',
          ),
        ],
        applicableEventTypes: ['celebration'],
      ),

      // Catering suggestions
      const Suggestion(
        id: 'celebration_catering',
        title: 'Arrange catering for your celebration',
        description:
            'Choose catering that matches your event style. Consider food stations, buffets, or passed appetizers depending on your event format.',
        category: SuggestionCategory.catering,
        priority: SuggestionPriority.high,
        baseRelevanceScore: 80,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'celebration',
          ),
          SuggestionCondition(
            field: 'selectedServices',
            operator: ConditionOperator.contains,
            value: 'Catering',
          ),
        ],
        applicableEventTypes: ['celebration'],
        actionUrl: '/services/catering',
      ),

      // Decoration suggestions
      const Suggestion(
        id: 'celebration_decorations',
        title: 'Plan your celebration decorations',
        description:
            'Choose decorations that enhance your theme. Consider centerpieces, balloons, lighting, and table settings to create the right atmosphere.',
        category: SuggestionCategory.decoration,
        priority: SuggestionPriority.medium,
        baseRelevanceScore: 70,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'celebration',
          ),
          SuggestionCondition(
            field: 'selectedServices',
            operator: ConditionOperator.contains,
            value: 'Decoration',
          ),
        ],
        applicableEventTypes: ['celebration'],
      ),

      // Guest list suggestions
      const Suggestion(
        id: 'celebration_guest_list',
        title: 'Create your celebration guest list',
        description:
            'Make a comprehensive guest list and collect contact information for invitations. Consider venue capacity when finalizing your list.',
        category: SuggestionCategory.guestList,
        priority: SuggestionPriority.high,
        baseRelevanceScore: 85,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'celebration',
          ),
        ],
        applicableEventTypes: ['celebration'],
        actionUrl: '/event-planning/guest-list',
      ),

      // Budget suggestions
      const Suggestion(
        id: 'celebration_budget',
        title: 'Set your celebration budget',
        description:
            'Create a budget that covers all aspects of your celebration. Prioritize spending on the elements most important to you.',
        category: SuggestionCategory.budget,
        priority: SuggestionPriority.high,
        baseRelevanceScore: 90,
        conditions: [
          SuggestionCondition(
            field: 'templateId',
            operator: ConditionOperator.equals,
            value: 'celebration',
          ),
        ],
        applicableEventTypes: ['celebration'],
        actionUrl: '/event-planning/budget',
      ),
    ];
  }
}
