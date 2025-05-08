import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventati_book/services/firebase/migration/budget_migration_utility.dart';
import 'package:eventati_book/services/firebase/migration/event_migration_utility.dart';
import 'package:eventati_book/services/firebase/migration/guest_migration_utility.dart';
import 'package:eventati_book/services/firebase/migration/migration_result.dart';
import 'package:eventati_book/services/firebase/migration/task_migration_utility.dart';
import 'package:eventati_book/services/firebase/migration/user_migration_utility.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';

/// Service for migrating data from tempDB to Firebase
class DataMigrationService {
  /// Firebase Auth instance
  final firebase_auth.FirebaseAuth _auth;

  /// Firestore instance - used for direct Firestore operations when needed
  final FirebaseFirestore _firestore;

  /// Constructor
  DataMigrationService({
    firebase_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  /// Migrate all data from tempDB to Firebase
  Future<MigrationResult> migrateAllData() async {
    final startTime = DateTime.now();
    final results = <MigrationResult>[];

    try {
      // Check if platform is supported
      if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
        Logger.i(
          'Firebase is not supported on this platform',
          tag: 'DataMigrationService',
        );
        return MigrationResult.failure(
          errorMessage: 'Firebase is not supported on this platform',
          entitiesMigrated: 0,
          entitiesFailed: 0,
          migratedIds: const [],
          failedIds: const [],
          idMap: const {},
          startTime: startTime,
          endTime: DateTime.now(),
        );
      }

      // Check if user is logged in
      if (_auth.currentUser == null) {
        throw Exception('User must be logged in to migrate data');
      }

      // Start migration
      Logger.i('Starting data migration...', tag: 'DataMigrationService');

      // 1. Migrate users
      Logger.i('Migrating users...', tag: 'DataMigrationService');
      final userMigrationUtility = UserMigrationUtility();
      final userResult = await userMigrationUtility.migrateAllUsers();
      results.add(userResult);

      if (!userResult.success) {
        Logger.e(
          'User migration failed: ${userResult.errorMessage}',
          tag: 'DataMigrationService',
        );
        return MigrationResult.combine(results);
      }

      // 2. Migrate events
      Logger.i('Migrating events...', tag: 'DataMigrationService');
      final eventMigrationUtility = EventMigrationUtility();
      final eventResult = await eventMigrationUtility.migrateAllEvents();
      results.add(eventResult);

      if (!eventResult.success) {
        Logger.e(
          'Event migration failed: ${eventResult.errorMessage}',
          tag: 'DataMigrationService',
        );
        return MigrationResult.combine(results);
      }

      // 3. Migrate planning data for each event
      for (final eventId in eventResult.idMap.values) {
        // 3.1 Migrate budget data
        Logger.i(
          'Migrating budget data for event $eventId...',
          tag: 'DataMigrationService',
        );
        final budgetMigrationUtility = BudgetMigrationUtility(eventId: eventId);
        final budgetResult = await budgetMigrationUtility.migrateFullBudget();
        results.add(budgetResult);

        // 3.2 Migrate guest data
        Logger.i(
          'Migrating guest data for event $eventId...',
          tag: 'DataMigrationService',
        );
        final guestMigrationUtility = GuestMigrationUtility(eventId: eventId);
        final guestResult = await guestMigrationUtility.migrateFullGuestList();
        results.add(guestResult);

        // 3.3 Migrate task data
        Logger.i(
          'Migrating task data for event $eventId...',
          tag: 'DataMigrationService',
        );
        final taskMigrationUtility = TaskMigrationUtility(eventId: eventId);
        final taskResult = await taskMigrationUtility.migrateFullTaskData();
        results.add(taskResult);
      }

      // Migration complete
      final combinedResult = MigrationResult.combine(results);

      if (combinedResult.success) {
        Logger.i(
          'Data migration completed successfully. Migrated ${combinedResult.entitiesMigrated} entities.',
          tag: 'DataMigrationService',
        );
      } else {
        Logger.w(
          'Data migration completed with issues. Migrated ${combinedResult.entitiesMigrated} entities, failed ${combinedResult.entitiesFailed} entities.',
          tag: 'DataMigrationService',
        );
      }

      return combinedResult;
    } catch (e) {
      Logger.e('Error migrating data: $e', tag: 'DataMigrationService');

      // Attempt rollback if there are any successful migrations
      if (results.isNotEmpty) {
        await _rollbackMigration(results);
      }

      return MigrationResult.failure(
        errorMessage: 'Error migrating data: $e',
        exception: e,
        entitiesMigrated: results.fold(
          0,
          (total, result) => total + result.entitiesMigrated,
        ),
        entitiesFailed:
            results.fold(0, (total, result) => total + result.entitiesFailed) +
            1,
        migratedIds: results.expand((result) => result.migratedIds).toList(),
        failedIds: results.expand((result) => result.failedIds).toList(),
        idMap: results.fold({}, (map, result) => map..addAll(result.idMap)),
        startTime: startTime,
        endTime: DateTime.now(),
      );
    }
  }

  /// Rollback a migration
  Future<void> _rollbackMigration(List<MigrationResult> results) async {
    try {
      Logger.i('Rolling back migration...', tag: 'DataMigrationService');

      // Rollback in reverse order (dependencies first)
      for (final result in results.reversed) {
        if (result.success && result.migratedIds.isNotEmpty) {
          // Extract collection path from the first migrated ID
          final collectionPath = result.migratedIds.first.split('/').first;

          // Delete all migrated documents
          for (final id in result.migratedIds) {
            try {
              await _firestore.collection(collectionPath).doc(id).delete();
            } catch (e) {
              Logger.e(
                'Error deleting document $id during rollback: $e',
                tag: 'DataMigrationService',
              );
            }
          }
        }
      }

      Logger.i('Rollback completed', tag: 'DataMigrationService');
    } catch (e) {
      Logger.e('Error during rollback: $e', tag: 'DataMigrationService');
    }
  }

  /// Migrate data for a specific user
  Future<MigrationResult> migrateUserData(String userId) async {
    final startTime = DateTime.now();
    final results = <MigrationResult>[];

    try {
      // Check if platform is supported
      if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
        Logger.i(
          'Firebase is not supported on this platform',
          tag: 'DataMigrationService',
        );
        return MigrationResult.failure(
          errorMessage: 'Firebase is not supported on this platform',
          entitiesMigrated: 0,
          entitiesFailed: 0,
          migratedIds: const [],
          failedIds: const [],
          idMap: const {},
          startTime: startTime,
          endTime: DateTime.now(),
        );
      }

      // Check if user is logged in
      if (_auth.currentUser == null) {
        throw Exception('User must be logged in to migrate data');
      }

      // Start migration
      Logger.i(
        'Starting data migration for user $userId...',
        tag: 'DataMigrationService',
      );

      // 1. Migrate user
      Logger.i('Migrating user $userId...', tag: 'DataMigrationService');
      final userMigrationUtility = UserMigrationUtility();
      final userResult = await userMigrationUtility.migrateUser(userId);
      results.add(userResult);

      if (!userResult.success) {
        Logger.e(
          'User migration failed: ${userResult.errorMessage}',
          tag: 'DataMigrationService',
        );
        return MigrationResult.combine(results);
      }

      // 2. Migrate events for the user
      Logger.i(
        'Migrating events for user $userId...',
        tag: 'DataMigrationService',
      );
      final eventMigrationUtility = EventMigrationUtility();
      final eventResult = await eventMigrationUtility.migrateUserEvents(userId);
      results.add(eventResult);

      if (!eventResult.success) {
        Logger.e(
          'Event migration failed: ${eventResult.errorMessage}',
          tag: 'DataMigrationService',
        );
        return MigrationResult.combine(results);
      }

      // 3. Migrate planning data for each event
      for (final eventId in eventResult.idMap.values) {
        // 3.1 Migrate budget data
        Logger.i(
          'Migrating budget data for event $eventId...',
          tag: 'DataMigrationService',
        );
        final budgetMigrationUtility = BudgetMigrationUtility(eventId: eventId);
        final budgetResult = await budgetMigrationUtility.migrateFullBudget();
        results.add(budgetResult);

        // 3.2 Migrate guest data
        Logger.i(
          'Migrating guest data for event $eventId...',
          tag: 'DataMigrationService',
        );
        final guestMigrationUtility = GuestMigrationUtility(eventId: eventId);
        final guestResult = await guestMigrationUtility.migrateFullGuestList();
        results.add(guestResult);

        // 3.3 Migrate task data
        Logger.i(
          'Migrating task data for event $eventId...',
          tag: 'DataMigrationService',
        );
        final taskMigrationUtility = TaskMigrationUtility(eventId: eventId);
        final taskResult = await taskMigrationUtility.migrateFullTaskData();
        results.add(taskResult);
      }

      // Migration complete
      final combinedResult = MigrationResult.combine(results);

      if (combinedResult.success) {
        Logger.i(
          'Data migration for user $userId completed successfully. Migrated ${combinedResult.entitiesMigrated} entities.',
          tag: 'DataMigrationService',
        );
      } else {
        Logger.w(
          'Data migration for user $userId completed with issues. Migrated ${combinedResult.entitiesMigrated} entities, failed ${combinedResult.entitiesFailed} entities.',
          tag: 'DataMigrationService',
        );
      }

      return combinedResult;
    } catch (e) {
      Logger.e(
        'Error migrating data for user $userId: $e',
        tag: 'DataMigrationService',
      );

      // Attempt rollback if there are any successful migrations
      if (results.isNotEmpty) {
        await _rollbackMigration(results);
      }

      return MigrationResult.failure(
        errorMessage: 'Error migrating data for user $userId: $e',
        exception: e,
        entitiesMigrated: results.fold(
          0,
          (total, result) => total + result.entitiesMigrated,
        ),
        entitiesFailed:
            results.fold(0, (total, result) => total + result.entitiesFailed) +
            1,
        migratedIds: results.expand((result) => result.migratedIds).toList(),
        failedIds: results.expand((result) => result.failedIds).toList(),
        idMap: results.fold({}, (map, result) => map..addAll(result.idMap)),
        startTime: startTime,
        endTime: DateTime.now(),
      );
    }
  }

  /// Check if migration is needed
  Future<bool> isMigrationNeeded() async {
    try {
      // Check if platform is supported
      if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
        Logger.i(
          'Firebase is not supported on this platform',
          tag: 'DataMigrationService',
        );
        return false;
      }

      // Check if user is logged in
      if (_auth.currentUser == null) {
        Logger.i(
          'User must be logged in to check migration status',
          tag: 'DataMigrationService',
        );
        return false;
      }

      // Check if users already exist in Firebase
      final usersCollection = _firestore.collection('users');
      final querySnapshot = await usersCollection.limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        // If users exist, migration is not needed
        return false;
      }

      // Migration is needed
      return true;
    } catch (e) {
      Logger.e(
        'Error checking migration status: $e',
        tag: 'DataMigrationService',
      );
      return false;
    }
  }

  /// Create sample data in Firebase for testing
  Future<void> createSampleData() async {
    try {
      // Check if platform is supported
      if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
        Logger.i(
          'Firebase is not supported on this platform',
          tag: 'DataMigrationService',
        );
        return;
      }

      // Check if user is logged in
      if (_auth.currentUser == null) {
        throw Exception('User must be logged in to create sample data');
      }

      // Start creating sample data
      Logger.i('Creating sample data...', tag: 'DataMigrationService');

      // Log Firestore settings to verify connection
      final settings = _firestore.settings;
      Logger.i(
        'Using Firestore with host: ${settings.host}',
        tag: 'DataMigrationService',
      );

      // Create sample user document directly in Firestore
      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        'name': _auth.currentUser!.displayName ?? 'Sample User',
        'email': _auth.currentUser!.email ?? 'user@example.com',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Logger.i('Sample user created', tag: 'DataMigrationService');

      // Create sample event document directly in Firestore
      final eventId = 'sample-event-${DateTime.now().millisecondsSinceEpoch}';
      await _firestore.collection('events').doc(eventId).set({
        'name': 'Sample Event',
        'description': 'This is a sample event created for testing',
        'type': 'wedding',
        'date': DateTime.now().add(const Duration(days: 90)),
        'location': 'Sample Location',
        'budget': 10000.0,
        'guestCount': 100,
        'userId': _auth.currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      Logger.i('Sample event created', tag: 'DataMigrationService');

      // Sample data creation complete
      Logger.i('Sample data created successfully', tag: 'DataMigrationService');
    } catch (e) {
      Logger.e('Error creating sample data: $e', tag: 'DataMigrationService');
      rethrow;
    }
  }
}
