import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents the connection between the wizard and planning tools
class WizardConnection {
  /// The ID of the user
  final String userId;

  /// The ID of the event
  final String eventId;

  /// The ID of the wizard state
  final String wizardStateId;

  /// Whether the connection to budget is enabled
  final bool budgetEnabled;

  /// Whether the connection to guest list is enabled
  final bool guestListEnabled;

  /// Whether the connection to timeline is enabled
  final bool timelineEnabled;

  /// Whether the connection to service recommendations is enabled
  final bool serviceRecommendationsEnabled;

  /// The IDs of budget items created from the wizard
  final List<String> budgetItemIds;

  /// The IDs of guest groups created from the wizard
  final List<String> guestGroupIds;

  /// The IDs of tasks created from the wizard
  final List<String> taskIds;

  /// The IDs of service recommendations created from the wizard
  final List<String> serviceRecommendationIds;

  /// The timestamp when the connection was created
  final DateTime createdAt;

  /// The timestamp when the connection was last updated
  final DateTime updatedAt;

  /// Constructor
  WizardConnection({
    required this.userId,
    required this.eventId,
    required this.wizardStateId,
    this.budgetEnabled = true,
    this.guestListEnabled = true,
    this.timelineEnabled = true,
    this.serviceRecommendationsEnabled = true,
    this.budgetItemIds = const [],
    this.guestGroupIds = const [],
    this.taskIds = const [],
    this.serviceRecommendationIds = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Create a copy of this connection with modified fields
  WizardConnection copyWith({
    String? userId,
    String? eventId,
    String? wizardStateId,
    bool? budgetEnabled,
    bool? guestListEnabled,
    bool? timelineEnabled,
    bool? serviceRecommendationsEnabled,
    List<String>? budgetItemIds,
    List<String>? guestGroupIds,
    List<String>? taskIds,
    List<String>? serviceRecommendationIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WizardConnection(
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      wizardStateId: wizardStateId ?? this.wizardStateId,
      budgetEnabled: budgetEnabled ?? this.budgetEnabled,
      guestListEnabled: guestListEnabled ?? this.guestListEnabled,
      timelineEnabled: timelineEnabled ?? this.timelineEnabled,
      serviceRecommendationsEnabled:
          serviceRecommendationsEnabled ?? this.serviceRecommendationsEnabled,
      budgetItemIds: budgetItemIds ?? this.budgetItemIds,
      guestGroupIds: guestGroupIds ?? this.guestGroupIds,
      taskIds: taskIds ?? this.taskIds,
      serviceRecommendationIds:
          serviceRecommendationIds ?? this.serviceRecommendationIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'eventId': eventId,
      'wizardStateId': wizardStateId,
      'budgetEnabled': budgetEnabled,
      'guestListEnabled': guestListEnabled,
      'timelineEnabled': timelineEnabled,
      'serviceRecommendationsEnabled': serviceRecommendationsEnabled,
      'budgetItemIds': budgetItemIds,
      'guestGroupIds': guestGroupIds,
      'taskIds': taskIds,
      'serviceRecommendationIds': serviceRecommendationIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory WizardConnection.fromJson(Map<String, dynamic> json) {
    return WizardConnection(
      userId: json['userId'] ?? '',
      eventId: json['eventId'] ?? '',
      wizardStateId: json['wizardStateId'] ?? '',
      budgetEnabled: json['budgetEnabled'] ?? true,
      guestListEnabled: json['guestListEnabled'] ?? true,
      timelineEnabled: json['timelineEnabled'] ?? true,
      serviceRecommendationsEnabled:
          json['serviceRecommendationsEnabled'] ?? true,
      budgetItemIds: List<String>.from(json['budgetItemIds'] ?? []),
      guestGroupIds: List<String>.from(json['guestGroupIds'] ?? []),
      taskIds: List<String>.from(json['taskIds'] ?? []),
      serviceRecommendationIds: List<String>.from(
        json['serviceRecommendationIds'] ?? [],
      ),
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
    );
  }

  /// Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'eventId': eventId,
      'wizardStateId': wizardStateId,
      'budgetEnabled': budgetEnabled,
      'guestListEnabled': guestListEnabled,
      'timelineEnabled': timelineEnabled,
      'serviceRecommendationsEnabled': serviceRecommendationsEnabled,
      'budgetItemIds': budgetItemIds,
      'guestGroupIds': guestGroupIds,
      'taskIds': taskIds,
      'serviceRecommendationIds': serviceRecommendationIds,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create from Firestore
  factory WizardConnection.fromFirestore(Map<String, dynamic> data, String id) {
    final parts = id.split('_');
    final userId = parts.isNotEmpty ? parts[0] : '';
    final eventId = parts.length > 1 ? parts[1] : '';

    return WizardConnection(
      userId: data['userId'] ?? userId,
      eventId: data['eventId'] ?? eventId,
      wizardStateId: data['wizardStateId'] ?? '',
      budgetEnabled: data['budgetEnabled'] ?? true,
      guestListEnabled: data['guestListEnabled'] ?? true,
      timelineEnabled: data['timelineEnabled'] ?? true,
      serviceRecommendationsEnabled:
          data['serviceRecommendationsEnabled'] ?? true,
      budgetItemIds: List<String>.from(data['budgetItemIds'] ?? []),
      guestGroupIds: List<String>.from(data['guestGroupIds'] ?? []),
      taskIds: List<String>.from(data['taskIds'] ?? []),
      serviceRecommendationIds: List<String>.from(
        data['serviceRecommendationIds'] ?? [],
      ),
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }
}
