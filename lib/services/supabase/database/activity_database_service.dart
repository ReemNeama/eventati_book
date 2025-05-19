import 'package:eventati_book/models/activity_models/recent_activity.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Service for managing user activity data in the database
class ActivityDatabaseService {
  final SupabaseClient _supabase;
  final String _collection = 'user_activities';
  final Uuid _uuid = const Uuid();

  /// Constructor
  ActivityDatabaseService({required SupabaseClient supabase})
    : _supabase = supabase;

  /// Get recent activities for a user
  Future<List<RecentActivity>> getRecentActivities(String userId) async {
    try {
      final response = await _supabase
          .from(_collection)
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false)
          .limit(10);

      return response.map<RecentActivity>((data) {
        return RecentActivity(
          id: data['id'],
          userId: data['user_id'],
          type: _activityTypeFromString(data['type']),
          title: data['title'],
          description: data['description'],
          entityId: data['entity_id'],
          entityType: data['entity_type'],
          route: data['route'],
          routeParams: data['route_params'],
          timestamp: DateTime.parse(data['timestamp']),
        );
      }).toList();
    } catch (e) {
      Logger.e(
        'Error getting recent activities: $e',
        tag: 'ActivityDatabaseService',
      );
      return [];
    }
  }

  /// Add a new activity
  Future<void> addActivity(RecentActivity activity) async {
    try {
      // Generate ID if not provided
      final activityId = activity.id.isEmpty ? _uuid.v4() : activity.id;

      // Convert to database format
      final data = {'id': activityId, ...activity.toDatabaseDoc()};

      await _supabase.from(_collection).insert(data);

      Logger.i(
        'Activity added: ${activity.title}',
        tag: 'ActivityDatabaseService',
      );
    } catch (e) {
      Logger.e('Error adding activity: $e', tag: 'ActivityDatabaseService');
      rethrow;
    }
  }

  /// Clear all activities for a user
  Future<void> clearActivities(String userId) async {
    try {
      await _supabase.from(_collection).delete().eq('user_id', userId);

      Logger.i(
        'Activities cleared for user: $userId',
        tag: 'ActivityDatabaseService',
      );
    } catch (e) {
      Logger.e('Error clearing activities: $e', tag: 'ActivityDatabaseService');
      rethrow;
    }
  }

  /// Convert string to ActivityType
  ActivityType _activityTypeFromString(String typeStr) {
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
