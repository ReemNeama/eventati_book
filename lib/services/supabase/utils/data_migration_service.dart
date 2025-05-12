import 'dart:async';

import 'package:eventati_book/services/interfaces/auth_service_interface.dart';
import 'package:eventati_book/services/interfaces/database_service_interface.dart';
import 'package:eventati_book/services/interfaces/storage_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';

/// Service for migrating data from legacy storage to Supabase
class DataMigrationService {
  /// Auth service
  final AuthServiceInterface _authService;

  /// Database service
  final DatabaseServiceInterface _databaseService;

  // Storage service not used yet
  // final StorageServiceInterface _storageService;

  /// Constructor
  DataMigrationService({
    required AuthServiceInterface authService,
    required DatabaseServiceInterface databaseService,
    // Storage service not used yet
    required StorageServiceInterface storageService,
  }) : _authService = authService,
       _databaseService = databaseService;

  /// Migrate all data for the current user
  Future<MigrationResult> migrateAllData() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        return MigrationResult(success: false, message: 'User not logged in');
      }

      // Migrate user data
      final userResult = await migrateUserData(user.uid);
      if (!userResult.success) {
        return userResult;
      }

      // Migrate events
      final eventsResult = await migrateEvents(user.uid);
      if (!eventsResult.success) {
        return eventsResult;
      }

      // Migrate budget items
      final budgetResult = await migrateBudgetItems(user.uid);
      if (!budgetResult.success) {
        return budgetResult;
      }

      // Migrate guest list
      final guestResult = await migrateGuestList(user.uid);
      if (!guestResult.success) {
        return guestResult;
      }

      // Migrate tasks
      final tasksResult = await migrateTasks(user.uid);
      if (!tasksResult.success) {
        return tasksResult;
      }

      // Migrate bookings
      final bookingsResult = await migrateBookings(user.uid);
      if (!bookingsResult.success) {
        return bookingsResult;
      }

      return MigrationResult(
        success: true,
        message: 'All data migrated successfully',
      );
    } catch (e) {
      Logger.e('Error migrating all data: $e', tag: 'DataMigrationService');
      return MigrationResult(
        success: false,
        message: 'Error migrating all data: $e',
      );
    }
  }

  /// Migrate user data
  Future<MigrationResult> migrateUserData(String userId) async {
    try {
      // Get user data from legacy storage
      final userData = await _databaseService.getDocument('users', userId);
      if (userData == null) {
        return MigrationResult(success: false, message: 'User data not found');
      }

      // Convert timestamps to ISO strings
      final convertedData = _convertTimestamps(userData);

      // Set user data in Supabase
      await _databaseService.setDocument('users', userId, convertedData);

      return MigrationResult(
        success: true,
        message: 'User data migrated successfully',
      );
    } catch (e) {
      Logger.e('Error migrating user data: $e', tag: 'DataMigrationService');
      return MigrationResult(
        success: false,
        message: 'Error migrating user data: $e',
      );
    }
  }

  /// Migrate events
  Future<MigrationResult> migrateEvents(String userId) async {
    try {
      // Get events from legacy storage
      final events = await _databaseService.getCollectionWithQuery('events', [
        QueryFilter(
          field: 'userId',
          operation: FilterOperation.equalTo,
          value: userId,
        ),
      ]);

      // Migrate each event
      for (final eventData in events) {
        final eventId = eventData['id'] as String;

        // Convert timestamps to ISO strings
        final convertedData = _convertTimestamps(eventData);

        // Set event data in Supabase
        await _databaseService.setDocument('events', eventId, convertedData);
      }

      return MigrationResult(
        success: true,
        message: 'Events migrated successfully',
        count: events.length,
      );
    } catch (e) {
      Logger.e('Error migrating events: $e', tag: 'DataMigrationService');
      return MigrationResult(
        success: false,
        message: 'Error migrating events: $e',
      );
    }
  }

  /// Migrate budget items
  Future<MigrationResult> migrateBudgetItems(String userId) async {
    try {
      // Get events from legacy storage
      final events = await _databaseService.getCollectionWithQuery('events', [
        QueryFilter(
          field: 'userId',
          operation: FilterOperation.equalTo,
          value: userId,
        ),
      ]);

      int totalCount = 0;

      // Migrate budget items for each event
      for (final eventData in events) {
        final eventId = eventData['id'] as String;

        // Get budget items from legacy storage
        final budgetItems = await _databaseService
            .getCollectionWithQuery('budget_items', [
              QueryFilter(
                field: 'eventId',
                operation: FilterOperation.equalTo,
                value: eventId,
              ),
            ]);

        // Migrate each budget item
        for (final itemData in budgetItems) {
          final itemId = itemData['id'] as String;

          // Convert timestamps to ISO strings
          final convertedData = _convertTimestamps(itemData);

          // Set budget item data in Supabase
          await _databaseService.setDocument(
            'budget_items',
            itemId,
            convertedData,
          );
        }

        totalCount += budgetItems.length;
      }

      return MigrationResult(
        success: true,
        message: 'Budget items migrated successfully',
        count: totalCount,
      );
    } catch (e) {
      Logger.e('Error migrating budget items: $e', tag: 'DataMigrationService');
      return MigrationResult(
        success: false,
        message: 'Error migrating budget items: $e',
      );
    }
  }

  /// Migrate guest list
  Future<MigrationResult> migrateGuestList(String userId) async {
    try {
      // Get events from legacy storage
      final events = await _databaseService.getCollectionWithQuery('events', [
        QueryFilter(
          field: 'userId',
          operation: FilterOperation.equalTo,
          value: userId,
        ),
      ]);

      int totalCount = 0;

      // Migrate guests for each event
      for (final eventData in events) {
        final eventId = eventData['id'] as String;

        // Get guests from legacy storage
        final guests = await _databaseService.getCollectionWithQuery('guests', [
          QueryFilter(
            field: 'eventId',
            operation: FilterOperation.equalTo,
            value: eventId,
          ),
        ]);

        // Migrate each guest
        for (final guestData in guests) {
          final guestId = guestData['id'] as String;

          // Convert timestamps to ISO strings
          final convertedData = _convertTimestamps(guestData);

          // Set guest data in Supabase
          await _databaseService.setDocument('guests', guestId, convertedData);
        }

        totalCount += guests.length;
      }

      return MigrationResult(
        success: true,
        message: 'Guest list migrated successfully',
        count: totalCount,
      );
    } catch (e) {
      Logger.e('Error migrating guest list: $e', tag: 'DataMigrationService');
      return MigrationResult(
        success: false,
        message: 'Error migrating guest list: $e',
      );
    }
  }

  /// Migrate tasks
  Future<MigrationResult> migrateTasks(String userId) async {
    try {
      // Get events from legacy storage
      final events = await _databaseService.getCollectionWithQuery('events', [
        QueryFilter(
          field: 'userId',
          operation: FilterOperation.equalTo,
          value: userId,
        ),
      ]);

      int totalCount = 0;

      // Migrate tasks for each event
      for (final eventData in events) {
        final eventId = eventData['id'] as String;

        // Get tasks from legacy storage
        final tasks = await _databaseService.getCollectionWithQuery('tasks', [
          QueryFilter(
            field: 'eventId',
            operation: FilterOperation.equalTo,
            value: eventId,
          ),
        ]);

        // Migrate each task
        for (final taskData in tasks) {
          final taskId = taskData['id'] as String;

          // Convert timestamps to ISO strings
          final convertedData = _convertTimestamps(taskData);

          // Set task data in Supabase
          await _databaseService.setDocument('tasks', taskId, convertedData);
        }

        totalCount += tasks.length;
      }

      return MigrationResult(
        success: true,
        message: 'Tasks migrated successfully',
        count: totalCount,
      );
    } catch (e) {
      Logger.e('Error migrating tasks: $e', tag: 'DataMigrationService');
      return MigrationResult(
        success: false,
        message: 'Error migrating tasks: $e',
      );
    }
  }

  /// Migrate bookings
  Future<MigrationResult> migrateBookings(String userId) async {
    try {
      // Get bookings from legacy storage
      final bookings = await _databaseService
          .getCollectionWithQuery('bookings', [
            QueryFilter(
              field: 'userId',
              operation: FilterOperation.equalTo,
              value: userId,
            ),
          ]);

      // Migrate each booking
      for (final bookingData in bookings) {
        final bookingId = bookingData['id'] as String;

        // Convert timestamps to ISO strings
        final convertedData = _convertTimestamps(bookingData);

        // Set booking data in Supabase
        await _databaseService.setDocument(
          'bookings',
          bookingId,
          convertedData,
        );
      }

      return MigrationResult(
        success: true,
        message: 'Bookings migrated successfully',
        count: bookings.length,
      );
    } catch (e) {
      Logger.e('Error migrating bookings: $e', tag: 'DataMigrationService');
      return MigrationResult(
        success: false,
        message: 'Error migrating bookings: $e',
      );
    }
  }

  /// Convert timestamps to ISO strings
  Map<String, dynamic> _convertTimestamps(Map<String, dynamic> data) {
    final result = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (key == 'createdAt' ||
          key == 'updatedAt' ||
          key.endsWith('Date') ||
          key.endsWith('Time')) {
        // Convert timestamp to ISO string
        if (value != null) {
          // Check if value is a map with seconds and nanoseconds (legacy Timestamp)
          if (value is Map &&
              value.containsKey('seconds') &&
              value.containsKey('nanoseconds')) {
            final seconds = value['seconds'] as int;
            final nanoseconds = value['nanoseconds'] as int;
            final milliseconds =
                seconds * 1000 + (nanoseconds / 1000000).round();
            final dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
            result[key] = dateTime.toIso8601String();
          } else if (value is DateTime) {
            result[key] = value.toIso8601String();
          } else {
            result[key] = value;
          }
        } else {
          result[key] = null;
        }
      } else if (value is Map<String, dynamic>) {
        // Recursively convert nested maps
        result[key] = _convertTimestamps(value);
      } else if (value is List) {
        // Convert list items
        result[key] = _convertListItems(value);
      } else {
        result[key] = value;
      }
    }

    return result;
  }

  /// Convert list items
  List _convertListItems(List items) {
    return items.map((item) {
      if (item is Map<String, dynamic>) {
        return _convertTimestamps(item);
      } else if (item is List) {
        return _convertListItems(item);
      } else {
        return item;
      }
    }).toList();
  }
}

/// Result of a migration operation
class MigrationResult {
  /// Whether the migration was successful
  final bool success;

  /// Message describing the result
  final String message;

  /// Number of items migrated
  final int? count;

  /// Constructor
  MigrationResult({required this.success, required this.message, this.count});
}
