import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventati_book/models/planning_models/guest.dart';
import 'package:eventati_book/services/firebase/migration/base_migration_utility.dart';
import 'package:eventati_book/services/firebase/migration/migration_result.dart';
import 'package:eventati_book/tempDB/guests.dart';
import 'package:eventati_book/utils/logger.dart';

/// Utility for migrating guest data from tempDB to Firestore
class GuestMigrationUtility extends BaseMigrationUtility<Guest> {
  /// Event ID for which guests are being migrated
  final String eventId;

  /// Constructor
  GuestMigrationUtility({required this.eventId, super.firestore, super.auth})
    : super(collectionName: 'events/$eventId/guests', entityTypeName: 'Guest');

  @override
  List<String> validateEntity(Guest entity) {
    final errors = <String>[];

    // Validate required fields
    if (entity.id.isEmpty) {
      errors.add('Guest ID is required');
    }
    if (entity.firstName.isEmpty) {
      errors.add('First name is required');
    }
    if (entity.lastName.isEmpty) {
      errors.add('Last name is required');
    }
    if (entity.email != null &&
        entity.email!.isNotEmpty &&
        !_isValidEmail(entity.email!)) {
      errors.add('Email is invalid');
    }
    if (entity.phone != null &&
        entity.phone!.isNotEmpty &&
        !_isValidPhone(entity.phone!)) {
      errors.add('Phone number is invalid');
    }

    return errors;
  }

  @override
  Map<String, dynamic> entityToFirestore(Guest entity) {
    return entity.toFirestore();
  }

  @override
  String getEntityId(Guest entity) {
    return entity.id;
  }

  /// Check if an email is valid
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }

  /// Check if a phone number is valid
  bool _isValidPhone(String phone) {
    // Simple validation for demonstration purposes
    // In a real app, you would use a more sophisticated validation
    final phoneRegExp = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegExp.hasMatch(phone);
  }

  /// Migrate all guests for an event from tempDB to Firestore
  Future<MigrationResult> migrateEventGuests() async {
    try {
      // Get guests from tempDB
      final guests = GuestDB.getGuests(eventId);

      Logger.i(
        'Migrating ${guests.length} guests for event $eventId from tempDB to Firestore',
        tag: 'GuestMigrationUtility',
      );

      // Migrate guests
      final result = await migrateEntities(guests);

      // Log result
      if (result.success) {
        Logger.i(
          'Successfully migrated ${result.entitiesMigrated} guests for event $eventId to Firestore',
          tag: 'GuestMigrationUtility',
        );
      } else {
        Logger.e(
          'Failed to migrate guests for event $eventId to Firestore: ${result.errorMessage}',
          tag: 'GuestMigrationUtility',
        );
      }

      return result;
    } catch (e) {
      Logger.e(
        'Error migrating guests for event $eventId: $e',
        tag: 'GuestMigrationUtility',
      );
      return MigrationResult.failure(
        errorMessage: 'Error migrating guests for event $eventId: $e',
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

  /// Migrate guest groups for an event from tempDB to Firestore
  Future<MigrationResult> migrateGuestGroups() async {
    final startTime = DateTime.now();
    try {
      // Get guest groups from tempDB
      final groups = GuestDB.getGuestGroups(eventId);

      Logger.i(
        'Migrating ${groups.length} guest groups for event $eventId from tempDB to Firestore',
        tag: 'GuestMigrationUtility',
      );

      // Create a subcollection reference for groups
      final groupsCollection = FirebaseFirestore.instance.collection(
        'events/$eventId/guest_groups',
      );

      final migratedIds = <String>[];
      final failedIds = <String>[];
      final idMap = <String, String>{};

      // Start a batch for transaction-like behavior
      var batch = FirebaseFirestore.instance.batch();
      var batchCount = 0;
      const batchLimit = 500; // Firestore batch limit is 500 operations

      for (final group in groups) {
        try {
          // Create a new document reference
          final docRef = groupsCollection.doc();
          final newId = docRef.id;

          // Add to batch
          batch.set(docRef, {
            'name': group.name,
            'description': group.description,
            'color': group.color.toString(),
            'createdAt': FieldValue.serverTimestamp(),
          });
          batchCount++;

          // Store ID mapping
          idMap[group.id] = newId;
          migratedIds.add(newId);

          // Commit batch if limit reached
          if (batchCount >= batchLimit) {
            await batch.commit();
            batch = FirebaseFirestore.instance.batch();
            batchCount = 0;
          }
        } catch (e) {
          Logger.e(
            'Error migrating guest group ${group.id}: $e',
            tag: 'GuestMigrationUtility',
          );
          failedIds.add(group.id);
        }
      }

      // Commit any remaining operations
      if (batchCount > 0) {
        await batch.commit();
      }

      // Create success result
      final result = MigrationResult(
        success: failedIds.isEmpty,
        errorMessage:
            failedIds.isEmpty ? null : 'Some groups failed to migrate',
        exception: null,
        entitiesMigrated: migratedIds.length,
        entitiesFailed: failedIds.length,
        migratedIds: migratedIds,
        failedIds: failedIds,
        idMap: idMap,
        startTime: startTime,
        endTime: DateTime.now(),
      );

      // Log result
      if (result.success) {
        Logger.i(
          'Successfully migrated ${result.entitiesMigrated} guest groups for event $eventId to Firestore',
          tag: 'GuestMigrationUtility',
        );
      } else {
        Logger.e(
          'Failed to migrate some guest groups for event $eventId to Firestore',
          tag: 'GuestMigrationUtility',
        );
      }

      return result;
    } catch (e) {
      Logger.e(
        'Error migrating guest groups for event $eventId: $e',
        tag: 'GuestMigrationUtility',
      );
      return MigrationResult.failure(
        errorMessage: 'Error migrating guest groups for event $eventId: $e',
        exception: e,
        entitiesMigrated: 0,
        entitiesFailed: 0,
        migratedIds: const [],
        failedIds: const [],
        idMap: const {},
        startTime: startTime,
        endTime: DateTime.now(),
      );
    }
  }

  /// Migrate both guests and groups for an event
  Future<MigrationResult> migrateFullGuestList() async {
    final startTime = DateTime.now();
    try {
      // First migrate groups
      final groupsResult = await migrateGuestGroups();

      // Then migrate guests, updating group IDs
      final guests = GuestDB.getGuests(eventId);

      // Update group IDs based on the mapping from the groups migration
      final updatedGuests =
          guests.map((guest) {
            if (guest.groupId != null &&
                groupsResult.idMap.containsKey(guest.groupId)) {
              return guest.copyWith(groupId: groupsResult.idMap[guest.groupId]);
            }
            return guest;
          }).toList();

      // Migrate the updated guests
      final guestsResult = await migrateEntities(updatedGuests);

      // Combine the results
      final combinedResult = MigrationResult.combine([
        groupsResult,
        guestsResult,
      ]);

      return combinedResult;
    } catch (e) {
      Logger.e(
        'Error migrating full guest list for event $eventId: $e',
        tag: 'GuestMigrationUtility',
      );
      return MigrationResult.failure(
        errorMessage: 'Error migrating full guest list for event $eventId: $e',
        exception: e,
        entitiesMigrated: 0,
        entitiesFailed: 0,
        migratedIds: const [],
        failedIds: const [],
        idMap: const {},
        startTime: startTime,
        endTime: DateTime.now(),
      );
    }
  }
}
