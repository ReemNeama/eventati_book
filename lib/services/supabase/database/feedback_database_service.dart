import 'package:eventati_book/models/feedback_models/user_feedback.dart';
import 'package:eventati_book/services/supabase/utils/database_service.dart';
import 'package:eventati_book/services/interfaces/database_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';

/// Service for managing user feedback in the database
class FeedbackDatabaseService {
  /// The database service
  final DatabaseService _databaseService;

  /// The name of the feedback collection
  static const String _collection = 'feedback';

  /// Creates a FeedbackDatabaseService
  FeedbackDatabaseService({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService();

  /// Get all feedback
  ///
  /// [page] The page number (0-based)
  /// [pageSize] The number of items per page
  /// [useCache] Whether to use the cache
  /// Returns a list of UserFeedback objects
  Future<List<UserFeedback>> getAllFeedback({
    int? page,
    int? pageSize,
    bool useCache = true,
  }) async {
    try {
      final result = await _databaseService.getCollectionWithCount(
        _collection,
        page: page,
        pageSize: pageSize,
        useCache: useCache,
      );

      final feedbackList =
          (result['data'] as List<Map<String, dynamic>>)
              .map((data) => UserFeedback.fromMap(data, data['id'] as String))
              .toList();

      return feedbackList;
    } catch (e) {
      Logger.e(
        'Error getting all feedback: $e',
        tag: 'FeedbackDatabaseService',
      );
      return [];
    }
  }

  /// Get feedback by ID
  ///
  /// [id] The ID of the feedback
  /// Returns the UserFeedback object, or null if not found
  Future<UserFeedback?> getFeedbackById(String id) async {
    try {
      final data = await _databaseService.getDocument(_collection, id);

      if (data == null) {
        return null;
      }

      return UserFeedback.fromMap(data, id);
    } catch (e) {
      Logger.e(
        'Error getting feedback by ID: $e',
        tag: 'FeedbackDatabaseService',
      );
      return null;
    }
  }

  /// Get feedback by user ID
  ///
  /// [userId] The ID of the user
  /// [page] The page number (0-based)
  /// [pageSize] The number of items per page
  /// Returns a list of UserFeedback objects
  Future<List<UserFeedback>> getFeedbackByUserId(
    String userId, {
    int? page,
    int? pageSize,
  }) async {
    try {
      final result = await _databaseService
          .getCollectionWithQuery(_collection, [
            QueryFilter(
              field: 'user_id',
              operation: FilterOperation.equalTo,
              value: userId,
            ),
          ]);

      final feedbackList =
          result
              .map((data) => UserFeedback.fromMap(data, data['id'] as String))
              .toList();

      // Apply pagination manually if specified
      if (page != null && pageSize != null) {
        final start = page * pageSize;
        final end = start + pageSize;

        if (start < feedbackList.length) {
          return feedbackList.sublist(
            start,
            end < feedbackList.length ? end : feedbackList.length,
          );
        }

        return [];
      }

      return feedbackList;
    } catch (e) {
      Logger.e(
        'Error getting feedback by user ID: $e',
        tag: 'FeedbackDatabaseService',
      );
      return [];
    }
  }

  /// Add feedback
  ///
  /// [feedback] The feedback to add
  /// Returns the ID of the added feedback
  Future<String?> addFeedback(UserFeedback feedback) async {
    try {
      final id = await _databaseService.addDocument(
        _collection,
        feedback.toMap(),
      );

      return id;
    } catch (e) {
      Logger.e('Error adding feedback: $e', tag: 'FeedbackDatabaseService');
      return null;
    }
  }

  /// Update feedback
  ///
  /// [id] The ID of the feedback to update
  /// [feedback] The updated feedback
  /// Returns true if the update was successful
  Future<bool> updateFeedback(String id, UserFeedback feedback) async {
    try {
      await _databaseService.updateDocument(_collection, id, feedback.toMap());

      return true;
    } catch (e) {
      Logger.e('Error updating feedback: $e', tag: 'FeedbackDatabaseService');
      return false;
    }
  }

  /// Mark feedback as read
  ///
  /// [id] The ID of the feedback to mark as read
  /// Returns true if the update was successful
  Future<bool> markFeedbackAsRead(String id) async {
    try {
      await _databaseService.updateDocument(_collection, id, {
        'is_read': true,
        'updated_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      Logger.e(
        'Error marking feedback as read: $e',
        tag: 'FeedbackDatabaseService',
      );
      return false;
    }
  }

  /// Mark feedback as resolved
  ///
  /// [id] The ID of the feedback to mark as resolved
  /// Returns true if the update was successful
  Future<bool> markFeedbackAsResolved(String id) async {
    try {
      await _databaseService.updateDocument(_collection, id, {
        'is_resolved': true,
        'updated_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      Logger.e(
        'Error marking feedback as resolved: $e',
        tag: 'FeedbackDatabaseService',
      );
      return false;
    }
  }

  /// Delete feedback
  ///
  /// [id] The ID of the feedback to delete
  /// Returns true if the deletion was successful
  Future<bool> deleteFeedback(String id) async {
    try {
      await _databaseService.deleteDocument(_collection, id);

      return true;
    } catch (e) {
      Logger.e('Error deleting feedback: $e', tag: 'FeedbackDatabaseService');
      return false;
    }
  }
}
