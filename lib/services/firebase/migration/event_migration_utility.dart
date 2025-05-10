import 'package:eventati_book/models/event_models/event.dart';
import 'package:eventati_book/services/firebase/migration/base_migration_utility.dart';
import 'package:eventati_book/services/firebase/migration/migration_result.dart';
import 'package:eventati_book/tempDB/events.dart';
import 'package:eventati_book/utils/logger.dart';

/// Utility for migrating event data from tempDB to Firestore
class EventMigrationUtility extends BaseMigrationUtility<Event> {
  /// Constructor
  EventMigrationUtility({super.firestore, super.auth})
    : super(collectionName: 'events', entityTypeName: 'Event');

  @override
  List<String> validateEntity(Event entity) {
    final errors = <String>[];

    // Validate required fields
    if (entity.id.isEmpty) {
      errors.add('Event ID is required');
    }
    if (entity.name.isEmpty) {
      errors.add('Name is required');
    }
    if (entity.location.isEmpty) {
      errors.add('Location is required');
    }
    if (entity.budget < 0) {
      errors.add('Budget must be non-negative');
    }
    if (entity.guestCount < 0) {
      errors.add('Guest count must be non-negative');
    }
    if (entity.date.isBefore(DateTime(2000))) {
      errors.add('Date is invalid');
    }

    // Validate relationships
    if (entity.userId == null || entity.userId!.isEmpty) {
      errors.add('User ID is required');
    }

    return errors;
  }

  @override
  Map<String, dynamic> entityToFirestore(Event entity) {
    return entity.toFirestore();
  }

  @override
  String getEntityId(Event entity) {
    return entity.id;
  }

  /// Migrate all events from tempDB to Firestore
  Future<MigrationResult> migrateAllEvents() async {
    try {
      // Get events from tempDB
      final events = EventDB.getEvents();

      Logger.i(
        'Migrating ${events.length} events from tempDB to Firestore',
        tag: 'EventMigrationUtility',
      );

      // Migrate events
      final result = await migrateEntities(events);

      // Log result
      if (result.success) {
        Logger.i(
          'Successfully migrated ${result.entitiesMigrated} events to Firestore',
          tag: 'EventMigrationUtility',
        );
      } else {
        Logger.e(
          'Failed to migrate events to Firestore: ${result.errorMessage}',
          tag: 'EventMigrationUtility',
        );
      }

      return result;
    } catch (e) {
      Logger.e('Error migrating events: $e', tag: 'EventMigrationUtility');
      return MigrationResult.failure(
        errorMessage: 'Error migrating events: $e',
        exception: e,
        entitiesMigrated: 0,
        entitiesFailed: 0,
        migratedIds: const [],
        failedIds: const [],
        idMap: const {},
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      );
    }
  }

  /// Migrate events for a specific user from tempDB to Firestore
  Future<MigrationResult> migrateUserEvents(String userId) async {
    try {
      // Get events from tempDB
      final allEvents = EventDB.getEvents();

      // Filter events for the specified user
      final userEvents =
          allEvents.where((event) => event.userId == userId).toList();

      if (userEvents.isEmpty) {
        Logger.i(
          'No events found for user $userId',
          tag: 'EventMigrationUtility',
        );
        return MigrationResult.success(
          entitiesMigrated: 0,
          migratedIds: const [],
          idMap: const {},
          startTime: DateTime.now(),
          endTime: DateTime.now(),
        );
      }

      Logger.i(
        'Migrating ${userEvents.length} events for user $userId from tempDB to Firestore',
        tag: 'EventMigrationUtility',
      );

      // Migrate events
      final result = await migrateEntities(userEvents);

      // Log result
      if (result.success) {
        Logger.i(
          'Successfully migrated ${result.entitiesMigrated} events for user $userId to Firestore',
          tag: 'EventMigrationUtility',
        );
      } else {
        Logger.e(
          'Failed to migrate events for user $userId to Firestore: ${result.errorMessage}',
          tag: 'EventMigrationUtility',
        );
      }

      return result;
    } catch (e) {
      Logger.e(
        'Error migrating events for user $userId: $e',
        tag: 'EventMigrationUtility',
      );
      return MigrationResult.failure(
        errorMessage: 'Error migrating events for user $userId: $e',
        exception: e,
        entitiesMigrated: 0,
        entitiesFailed: 0,
        migratedIds: const [],
        failedIds: const [],
        idMap: const {},
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      );
    }
  }

  /// Migrate a specific event from tempDB to Firestore
  Future<MigrationResult> migrateEvent(String eventId) async {
    try {
      // Get events from tempDB
      final events = EventDB.getEvents();

      // Find the event with the specified ID
      final event = events.firstWhere(
        (event) => event.id == eventId,
        orElse: () => throw Exception('Event not found: $eventId'),
      );

      Logger.i(
        'Migrating event $eventId from tempDB to Firestore',
        tag: 'EventMigrationUtility',
      );

      // Migrate the event
      final result = await migrateEntities([event]);

      // Log result
      if (result.success) {
        Logger.i(
          'Successfully migrated event $eventId to Firestore',
          tag: 'EventMigrationUtility',
        );
      } else {
        Logger.e(
          'Failed to migrate event $eventId to Firestore: ${result.errorMessage}',
          tag: 'EventMigrationUtility',
        );
      }

      return result;
    } catch (e) {
      Logger.e(
        'Error migrating event $eventId: $e',
        tag: 'EventMigrationUtility',
      );
      return MigrationResult.failure(
        errorMessage: 'Error migrating event $eventId: $e',
        exception: e,
        entitiesMigrated: 0,
        entitiesFailed: 1,
        migratedIds: const [],
        failedIds: [eventId],
        idMap: const {},
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      );
    }
  }
}
