import 'package:eventati_book/utils/database/db_timestamp.dart';

/// Types of activities that can be tracked
enum ActivityType {
  /// Viewed an event
  viewedEvent,

  /// Viewed a service
  viewedService,

  /// Created an event
  createdEvent,

  /// Updated an event
  updatedEvent,

  /// Added a task
  addedTask,

  /// Completed a task
  completedTask,

  /// Added a guest
  addedGuest,

  /// Added a budget item
  addedBudgetItem,

  /// Made a booking
  madeBooking,

  /// Compared services
  comparedServices,

  /// Viewed a recommendation
  viewedRecommendation,

  /// Other activity
  other,
}

/// Model representing a recent user activity
class RecentActivity {
  /// Unique identifier for the activity
  final String id;

  /// User ID associated with the activity
  final String userId;

  /// Type of activity
  final ActivityType type;

  /// Title of the activity
  final String title;

  /// Description of the activity
  final String? description;

  /// ID of the related entity (event, service, etc.)
  final String? entityId;

  /// Type of the related entity
  final String? entityType;

  /// Route to navigate to when clicking on the activity
  final String? route;

  /// Route parameters for navigation
  final Map<String, dynamic>? routeParams;

  /// When the activity occurred
  final DateTime timestamp;

  /// Constructor
  RecentActivity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.description,
    this.entityId,
    this.entityType,
    this.route,
    this.routeParams,
    required this.timestamp,
  });

  /// Create a RecentActivity from JSON data
  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: json['id'],
      userId: json['userId'],
      type: _activityTypeFromString(json['type']),
      title: json['title'],
      description: json['description'],
      entityId: json['entityId'],
      entityType: json['entityType'],
      route: json['route'],
      routeParams:
          json['routeParams'] != null
              ? Map<String, dynamic>.from(json['routeParams'])
              : null,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  /// Convert RecentActivity to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'entityId': entityId,
      'entityType': entityType,
      'route': route,
      'routeParams': routeParams,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Convert RecentActivity to database document
  Map<String, dynamic> toDatabaseDoc() {
    return {
      'user_id': userId,
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'entity_id': entityId,
      'entity_type': entityType,
      'route': route,
      'route_params': routeParams,
      'timestamp': DbTimestamp.fromDate(timestamp).toIso8601String(),
    };
  }

  /// Create a copy of the RecentActivity with updated fields
  RecentActivity copyWith({
    String? id,
    String? userId,
    ActivityType? type,
    String? title,
    String? description,
    String? entityId,
    String? entityType,
    String? route,
    Map<String, dynamic>? routeParams,
    DateTime? timestamp,
  }) {
    return RecentActivity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      route: route ?? this.route,
      routeParams: routeParams ?? this.routeParams,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Convert string to ActivityType
  static ActivityType _activityTypeFromString(String typeStr) {
    switch (typeStr) {
      case 'viewedEvent':
        return ActivityType.viewedEvent;
      case 'viewedService':
        return ActivityType.viewedService;
      case 'createdEvent':
        return ActivityType.createdEvent;
      case 'updatedEvent':
        return ActivityType.updatedEvent;
      case 'addedTask':
        return ActivityType.addedTask;
      case 'completedTask':
        return ActivityType.completedTask;
      case 'addedGuest':
        return ActivityType.addedGuest;
      case 'addedBudgetItem':
        return ActivityType.addedBudgetItem;
      case 'madeBooking':
        return ActivityType.madeBooking;
      case 'comparedServices':
        return ActivityType.comparedServices;
      case 'viewedRecommendation':
        return ActivityType.viewedRecommendation;
      default:
        return ActivityType.other;
    }
  }
}
