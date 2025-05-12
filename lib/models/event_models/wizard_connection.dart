import 'package:eventati_book/utils/database_utils.dart';

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

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'event_id': eventId,
      'wizard_state_id': wizardStateId,
      'budget_enabled': budgetEnabled,
      'guest_list_enabled': guestListEnabled,
      'timeline_enabled': timelineEnabled,
      'service_recommendations_enabled': serviceRecommendationsEnabled,
      'budget_item_ids': budgetItemIds,
      'guest_group_ids': guestGroupIds,
      'task_ids': taskIds,
      'service_recommendation_ids': serviceRecommendationIds,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON from Supabase
  factory WizardConnection.fromJson(Map<String, dynamic> json) {
    return WizardConnection(
      userId: json['user_id'] ?? '',
      eventId: json['event_id'] ?? '',
      wizardStateId: json['wizard_state_id'] ?? '',
      budgetEnabled: json['budget_enabled'] ?? true,
      guestListEnabled: json['guest_list_enabled'] ?? true,
      timelineEnabled: json['timeline_enabled'] ?? true,
      serviceRecommendationsEnabled:
          json['service_recommendations_enabled'] ?? true,
      budgetItemIds: List<String>.from(json['budget_item_ids'] ?? []),
      guestGroupIds: List<String>.from(json['guest_group_ids'] ?? []),
      taskIds: List<String>.from(json['task_ids'] ?? []),
      serviceRecommendationIds: List<String>.from(
        json['service_recommendation_ids'] ?? [],
      ),
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : DateTime.now(),
    );
  }

  /// Convert to database document
  Map<String, dynamic> toDatabaseDoc() {
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
      'createdAt': DbFieldValue.serverTimestamp(),
      'updatedAt': DbFieldValue.serverTimestamp(),
    };
  }

  /// Create from database document
  factory WizardConnection.fromDatabaseDoc(
    Map<String, dynamic> data,
    String id,
  ) {
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
              ? DateTime.parse(data['createdAt'])
              : DateTime.now(),
      updatedAt:
          data['updatedAt'] != null
              ? DateTime.parse(data['updatedAt'])
              : DateTime.now(),
    );
  }
}
