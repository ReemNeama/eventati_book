import 'package:flutter/material.dart';
import 'package:eventati_book/models/event_models/wizard_state.dart';

/// Status of a milestone
enum MilestoneStatus {
  /// Milestone is locked (criteria not yet available)
  locked,

  /// Milestone is unlocked but not completed
  unlocked,

  /// Milestone is completed
  completed,
}

/// Category of milestone
enum MilestoneCategory {
  /// Basic planning milestones
  planning,

  /// Budget-related milestones
  budget,

  /// Guest list milestones
  guests,

  /// Venue and services milestones
  services,

  /// Timeline and task milestones
  timeline,

  /// Special achievements
  special,
}

/// Operator for milestone conditions
enum MilestoneConditionOperator {
  equals,
  notEquals,
  greaterThan,
  lessThan,
  contains,
  notContains,
  isTrue,
  isFalse,
  isNotNull,
  isNull,
  custom,
}

/// A condition for milestone completion
class MilestoneCondition {
  /// Field to check in the wizard state
  final String field;

  /// Operator to apply
  final MilestoneConditionOperator operator;

  /// Value to compare against (if applicable)
  final dynamic value;

  const MilestoneCondition({
    required this.field,
    required this.operator,
    this.value,
  });

  /// Check if the condition is met
  bool isMet(WizardState state) {
    // Get the field value from the state
    final fieldValue = _getFieldValue(state, field);

    // Apply the operator
    switch (operator) {
      case MilestoneConditionOperator.equals:
        return fieldValue == value;
      case MilestoneConditionOperator.notEquals:
        return fieldValue != value;
      case MilestoneConditionOperator.greaterThan:
        return fieldValue > value;
      case MilestoneConditionOperator.lessThan:
        return fieldValue < value;
      case MilestoneConditionOperator.contains:
        if (field == 'selectedServices') {
          // Special handling for service-related checks
          if (value == 'FIVE_OR_MORE_SERVICES') {
            final services = fieldValue as Map<String, bool>;
            return services.values.where((selected) => selected).length >= 5;
          } else if (value is String) {
            final services = fieldValue as Map<String, bool>;
            return services[value] == true;
          } else if (value == true) {
            final services = fieldValue as Map<String, bool>;
            return services.values.contains(true);
          }
        }

        if (fieldValue is List) {
          return fieldValue.contains(value);
        } else if (fieldValue is String) {
          return fieldValue.contains(value.toString());
        } else if (fieldValue is Map) {
          return fieldValue.containsKey(value) ||
              fieldValue.containsValue(value);
        }
        return false;
      case MilestoneConditionOperator.notContains:
        if (fieldValue is List) {
          return !fieldValue.contains(value);
        } else if (fieldValue is String) {
          return !fieldValue.contains(value.toString());
        } else if (fieldValue is Map) {
          return !fieldValue.containsKey(value) &&
              !fieldValue.containsValue(value);
        }
        return true;
      case MilestoneConditionOperator.isTrue:
        return fieldValue == true;
      case MilestoneConditionOperator.isFalse:
        return fieldValue == false;
      case MilestoneConditionOperator.isNotNull:
        return fieldValue != null;
      case MilestoneConditionOperator.isNull:
        return fieldValue == null;
      case MilestoneConditionOperator.custom:
        if (value is Function) {
          return value(fieldValue);
        }
        return false;
    }
  }

  /// Get a field value from the wizard state
  dynamic _getFieldValue(WizardState state, String field) {
    switch (field) {
      case 'templateId':
        return state.template.id;
      case 'eventName':
        return state.eventName;
      case 'selectedEventType':
        return state.selectedEventType;
      case 'eventDate':
        return state.eventDate;
      case 'guestCount':
        return state.guestCount;
      case 'selectedServices':
        return state.selectedServices;
      case 'eventDuration':
        return state.eventDuration;
      case 'dailyStartTime':
        return state.dailyStartTime;
      case 'dailyEndTime':
        return state.dailyEndTime;
      case 'needsSetup':
        return state.needsSetup;
      case 'setupHours':
        return state.setupHours;
      case 'needsTeardown':
        return state.needsTeardown;
      case 'teardownHours':
        return state.teardownHours;
      case 'isCompleted':
        return state.isCompleted;
      case 'currentStep':
        return state.currentStep;
      case 'totalSteps':
        return state.totalSteps;
      default:
        return null;
    }
  }
}

/// Criteria for completing a milestone
class MilestoneCriteria {
  /// All of these conditions must be met to unlock the milestone
  final List<MilestoneCondition> unlockConditions;

  /// All of these conditions must be met to complete the milestone
  final List<MilestoneCondition> completionConditions;

  const MilestoneCriteria({
    this.unlockConditions = const [],
    required this.completionConditions,
  });

  /// Check if the milestone can be unlocked
  bool canUnlock(WizardState state) {
    // If no unlock conditions, it's always unlocked
    if (unlockConditions.isEmpty) {
      return true;
    }

    // All unlock conditions must be met
    return unlockConditions.every((condition) => condition.isMet(state));
  }

  /// Check if the milestone criteria are met
  bool isMet(WizardState state) {
    // All completion conditions must be met
    return completionConditions.every((condition) => condition.isMet(state));
  }
}

/// A milestone that can be achieved during event planning
class Milestone {
  /// Unique identifier
  final String id;

  /// Title of the milestone
  final String title;

  /// Detailed description
  final String description;

  /// Category of the milestone
  final MilestoneCategory category;

  /// Icon to represent the milestone
  final IconData icon;

  /// Points awarded for completing this milestone
  final int points;

  /// Event types this milestone applies to
  final List<String> applicableEventTypes;

  /// Current status of the milestone
  MilestoneStatus status;

  /// When the milestone was completed
  DateTime? completedDate;

  /// Criteria for completing the milestone
  final MilestoneCriteria criteria;

  /// Reward text shown when milestone is completed
  final String rewardText;

  /// Whether this milestone should be hidden until unlocked
  final bool isHidden;

  /// Whether this milestone is a template
  final bool isTemplate;

  Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    this.points = 10,
    required this.applicableEventTypes,
    this.status = MilestoneStatus.locked,
    this.completedDate,
    required this.criteria,
    required this.rewardText,
    this.isHidden = false,
    this.isTemplate = false,
  });

  /// Create a milestone instance from a template
  factory Milestone.fromTemplate(Milestone template, String eventId) {
    if (!template.isTemplate) {
      throw ArgumentError('Cannot create milestone from non-template');
    }

    return Milestone(
      id: '${eventId}_${template.id}',
      title: template.title,
      description: template.description,
      category: template.category,
      icon: template.icon,
      points: template.points,
      applicableEventTypes: template.applicableEventTypes,
      status: MilestoneStatus.locked,
      criteria: template.criteria,
      rewardText: template.rewardText,
      isHidden: template.isHidden,
      isTemplate: false,
    );
  }

  /// Convert this milestone to a template
  Milestone toTemplate() {
    return copyWith(
      status: MilestoneStatus.locked,
      completedDate: null,
      isTemplate: true,
    );
  }

  /// Check if the milestone is completed
  bool get isCompleted => status == MilestoneStatus.completed;

  /// Check if the milestone is applicable for the given event type
  bool isApplicableFor(String eventType) {
    return applicableEventTypes.contains(eventType) ||
        applicableEventTypes.contains('all');
  }

  /// Check if the milestone criteria are met
  bool checkCompletion(WizardState wizardState) {
    if (status == MilestoneStatus.completed) {
      return true;
    }

    if (status == MilestoneStatus.locked) {
      // First check if it should be unlocked
      if (criteria.canUnlock(wizardState)) {
        status = MilestoneStatus.unlocked;
      } else {
        return false;
      }
    }

    // Now check if it's completed
    if (criteria.isMet(wizardState)) {
      status = MilestoneStatus.completed;
      completedDate = DateTime.now();
      return true;
    }

    return false;
  }

  /// Create a copy of this milestone with updated fields
  Milestone copyWith({
    String? id,
    String? title,
    String? description,
    MilestoneCategory? category,
    IconData? icon,
    int? points,
    List<String>? applicableEventTypes,
    MilestoneStatus? status,
    DateTime? completedDate,
    MilestoneCriteria? criteria,
    String? rewardText,
    bool? isHidden,
    bool? isTemplate,
  }) {
    return Milestone(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      points: points ?? this.points,
      applicableEventTypes: applicableEventTypes ?? this.applicableEventTypes,
      status: status ?? this.status,
      completedDate: completedDate ?? this.completedDate,
      criteria: criteria ?? this.criteria,
      rewardText: rewardText ?? this.rewardText,
      isHidden: isHidden ?? this.isHidden,
      isTemplate: isTemplate ?? this.isTemplate,
    );
  }

  /// Convert milestone to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.toString(),
      'points': points,
      'status': status.toString(),
      'completedDate': completedDate?.toIso8601String(),
      'rewardText': rewardText,
      'isHidden': isHidden,
      'isTemplate': isTemplate,
    };
  }

  /// Create milestone from JSON
  factory Milestone.fromJson(
    Map<String, dynamic> json,
    MilestoneCriteria criteria,
  ) {
    return Milestone(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: MilestoneCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => MilestoneCategory.planning,
      ),
      icon: Icons.emoji_events, // Default icon, should be mapped properly
      points: json['points'] ?? 10,
      applicableEventTypes:
          (json['applicableEventTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          ['all'],
      status: MilestoneStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => MilestoneStatus.locked,
      ),
      completedDate:
          json['completedDate'] != null
              ? DateTime.parse(json['completedDate'])
              : null,
      criteria: criteria,
      rewardText: json['rewardText'] ?? 'Milestone completed!',
      isHidden: json['isHidden'] ?? false,
      isTemplate: json['isTemplate'] ?? false,
    );
  }
}
