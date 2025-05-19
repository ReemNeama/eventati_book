import 'package:flutter/foundation.dart';
import 'package:eventati_book/models/activity_models/recent_activity.dart';
import 'package:eventati_book/services/supabase/database/activity_database_service.dart';
import 'package:eventati_book/utils/logger.dart';

/// Provider for managing recent user activities
class RecentActivityProvider extends ChangeNotifier {
  final ActivityDatabaseService _activityDatabaseService;

  /// List of recent activities
  List<RecentActivity> _recentActivities = [];

  /// Loading state
  bool _isLoading = false;

  /// Error message
  String? _errorMessage;

  /// Constructor
  RecentActivityProvider({
    required ActivityDatabaseService activityDatabaseService,
  }) : _activityDatabaseService = activityDatabaseService;

  /// Get recent activities
  List<RecentActivity> get recentActivities => _recentActivities;

  /// Get loading state
  bool get isLoading => _isLoading;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Initialize the provider
  Future<void> initialize(String userId) async {
    _setLoading(true);
    try {
      _recentActivities = await _activityDatabaseService.getRecentActivities(
        userId,
      );
      _errorMessage = null;
    } catch (e) {
      Logger.e(
        'Error initializing RecentActivityProvider: $e',
        tag: 'RecentActivityProvider',
      );
      _errorMessage = 'Failed to load recent activities';
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new activity
  Future<void> addActivity(RecentActivity activity) async {
    try {
      // Add to database
      await _activityDatabaseService.addActivity(activity);

      // Update local list
      _recentActivities = [activity, ..._recentActivities];

      // Limit to 10 most recent activities
      if (_recentActivities.length > 10) {
        _recentActivities = _recentActivities.sublist(0, 10);
      }

      notifyListeners();
    } catch (e) {
      Logger.e('Error adding activity: $e', tag: 'RecentActivityProvider');
      _errorMessage = 'Failed to add activity';
      notifyListeners();
    }
  }

  /// Clear all activities for a user
  Future<void> clearActivities(String userId) async {
    _setLoading(true);
    try {
      await _activityDatabaseService.clearActivities(userId);
      _recentActivities = [];
      _errorMessage = null;
    } catch (e) {
      Logger.e('Error clearing activities: $e', tag: 'RecentActivityProvider');
      _errorMessage = 'Failed to clear activities';
    } finally {
      _setLoading(false);
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
