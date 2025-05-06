import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'event_template.dart';

/// Represents the current state of the event wizard
class WizardState {
  /// The template for the event type
  final EventTemplate template;

  /// Current step in the wizard
  final int currentStep;

  /// Total number of steps in the wizard
  final int totalSteps;

  /// Event name
  final String eventName;

  /// Selected event subtype
  final String? selectedEventType;

  /// Event date
  final DateTime? eventDate;

  /// Expected number of guests
  final int? guestCount;

  /// Selected services
  final Map<String, bool> selectedServices;

  /// For business events: event duration in days
  final int eventDuration;

  /// For business events: daily start time
  final TimeOfDay? dailyStartTime;

  /// For business events: daily end time
  final TimeOfDay? dailyEndTime;

  /// For business events: whether setup time is needed
  final bool needsSetup;

  /// For business events: setup hours needed
  final int setupHours;

  /// For business events: whether teardown time is needed
  final bool needsTeardown;

  /// For business events: teardown hours needed
  final int teardownHours;

  /// Whether the wizard has been completed
  final bool isCompleted;

  /// When the wizard was last updated
  final DateTime lastUpdated;

  WizardState({
    required this.template,
    this.currentStep = 0,
    this.totalSteps = 4,
    this.eventName = '',
    this.selectedEventType,
    this.eventDate,
    this.guestCount,
    Map<String, bool>? selectedServices,
    this.eventDuration = 1,
    this.dailyStartTime,
    this.dailyEndTime,
    this.needsSetup = false,
    this.setupHours = 2,
    this.needsTeardown = false,
    this.teardownHours = 2,
    this.isCompleted = false,
    DateTime? lastUpdated,
  }) : selectedServices = selectedServices ?? template.defaultServices,
       lastUpdated = lastUpdated ?? DateTime.now();

  /// Create a copy of this state with modified fields
  WizardState copyWith({
    EventTemplate? template,
    int? currentStep,
    int? totalSteps,
    String? eventName,
    String? selectedEventType,
    DateTime? eventDate,
    int? guestCount,
    Map<String, bool>? selectedServices,
    int? eventDuration,
    TimeOfDay? dailyStartTime,
    TimeOfDay? dailyEndTime,
    bool? needsSetup,
    int? setupHours,
    bool? needsTeardown,
    int? teardownHours,
    bool? isCompleted,
  }) {
    return WizardState(
      template: template ?? this.template,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      eventName: eventName ?? this.eventName,
      selectedEventType: selectedEventType ?? this.selectedEventType,
      eventDate: eventDate ?? this.eventDate,
      guestCount: guestCount ?? this.guestCount,
      selectedServices: selectedServices ?? Map.from(this.selectedServices),
      eventDuration: eventDuration ?? this.eventDuration,
      dailyStartTime: dailyStartTime ?? this.dailyStartTime,
      dailyEndTime: dailyEndTime ?? this.dailyEndTime,
      needsSetup: needsSetup ?? this.needsSetup,
      setupHours: setupHours ?? this.setupHours,
      needsTeardown: needsTeardown ?? this.needsTeardown,
      teardownHours: teardownHours ?? this.teardownHours,
      isCompleted: isCompleted ?? this.isCompleted,
      lastUpdated: DateTime.now(),
    );
  }

  /// Calculate the completion percentage of the wizard
  double get completionPercentage {
    if (totalSteps == 0) return 0.0;

    return (currentStep / totalSteps) * 100;
  }

  /// Check if the current step is valid and can proceed
  bool isStepValid(int step) {
    switch (step) {
      case 0: // Event Details

        return eventName.isNotEmpty && selectedEventType != null;
      case 1: // Date & Guests

        return eventDate != null && (guestCount != null && guestCount! > 0);
      case 2: // Required Services

        return selectedServices.values.any((selected) => selected);
      case 3: // Review

        return true;
      default:
        return false;
    }
  }

  /// Convert the wizard state to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'templateId': template.id,
      'currentStep': currentStep,
      'totalSteps': totalSteps,
      'eventName': eventName,
      'selectedEventType': selectedEventType,
      'eventDate': eventDate?.toIso8601String(),
      'guestCount': guestCount,
      'selectedServices': selectedServices,
      'eventDuration': eventDuration,
      'dailyStartTime':
          dailyStartTime != null
              ? '${dailyStartTime!.hour}:${dailyStartTime!.minute}'
              : null,
      'dailyEndTime':
          dailyEndTime != null
              ? '${dailyEndTime!.hour}:${dailyEndTime!.minute}'
              : null,
      'needsSetup': needsSetup,
      'setupHours': setupHours,
      'needsTeardown': needsTeardown,
      'teardownHours': teardownHours,
      'isCompleted': isCompleted,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Create a wizard state from a JSON map
  static WizardState? fromJson(Map<String, dynamic> json) {
    final templateId = json['templateId'];
    final template = EventTemplates.findById(templateId);

    if (template == null) return null;

    return WizardState(
      template: template,
      currentStep: json['currentStep'] ?? 0,
      totalSteps: json['totalSteps'] ?? 4,
      eventName: json['eventName'] ?? '',
      selectedEventType: json['selectedEventType'],
      eventDate:
          json['eventDate'] != null ? DateTime.parse(json['eventDate']) : null,
      guestCount: json['guestCount'],
      selectedServices: Map<String, bool>.from(json['selectedServices'] ?? {}),
      eventDuration: json['eventDuration'] ?? 1,
      dailyStartTime:
          json['dailyStartTime'] != null
              ? _timeOfDayFromString(json['dailyStartTime'])
              : null,
      dailyEndTime:
          json['dailyEndTime'] != null
              ? _timeOfDayFromString(json['dailyEndTime'])
              : null,
      needsSetup: json['needsSetup'] ?? false,
      setupHours: json['setupHours'] ?? 2,
      needsTeardown: json['needsTeardown'] ?? false,
      teardownHours: json['teardownHours'] ?? 2,
      isCompleted: json['isCompleted'] ?? false,
      lastUpdated:
          json['lastUpdated'] != null
              ? DateTime.parse(json['lastUpdated'])
              : DateTime.now(),
    );
  }

  /// Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'templateId': template.id,
      'currentStep': currentStep,
      'totalSteps': totalSteps,
      'eventName': eventName,
      'selectedEventType': selectedEventType,
      'eventDate': eventDate != null ? Timestamp.fromDate(eventDate!) : null,
      'guestCount': guestCount,
      'selectedServices': selectedServices,
      'eventDuration': eventDuration,
      'dailyStartTime':
          dailyStartTime != null
              ? '${dailyStartTime!.hour}:${dailyStartTime!.minute}'
              : null,
      'dailyEndTime':
          dailyEndTime != null
              ? '${dailyEndTime!.hour}:${dailyEndTime!.minute}'
              : null,
      'needsSetup': needsSetup,
      'setupHours': setupHours,
      'needsTeardown': needsTeardown,
      'teardownHours': teardownHours,
      'isCompleted': isCompleted,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// Create from Firestore
  static WizardState? fromFirestore(Map<String, dynamic> data, String eventId) {
    final templateId = data['templateId'];
    final template = EventTemplates.findById(templateId);

    if (template == null) return null;

    return WizardState(
      template: template,
      currentStep: data['currentStep'] ?? 0,
      totalSteps: data['totalSteps'] ?? 4,
      eventName: data['eventName'] ?? '',
      selectedEventType: data['selectedEventType'],
      eventDate:
          data['eventDate'] != null
              ? (data['eventDate'] as Timestamp).toDate()
              : null,
      guestCount: data['guestCount'],
      selectedServices: Map<String, bool>.from(data['selectedServices'] ?? {}),
      eventDuration: data['eventDuration'] ?? 1,
      dailyStartTime:
          data['dailyStartTime'] != null
              ? _timeOfDayFromString(data['dailyStartTime'])
              : null,
      dailyEndTime:
          data['dailyEndTime'] != null
              ? _timeOfDayFromString(data['dailyEndTime'])
              : null,
      needsSetup: data['needsSetup'] ?? false,
      setupHours: data['setupHours'] ?? 2,
      needsTeardown: data['needsTeardown'] ?? false,
      teardownHours: data['teardownHours'] ?? 2,
      isCompleted: data['isCompleted'] ?? false,
      lastUpdated:
          data['lastUpdated'] != null
              ? (data['lastUpdated'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }

  /// Helper method to convert a string to TimeOfDay
  static TimeOfDay? _timeOfDayFromString(String? timeString) {
    if (timeString == null) return null;

    final parts = timeString.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }
}
