import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventati_book/services/firebase/migration/migration_result.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Base class for migration utilities
abstract class BaseMigrationUtility<T> {
  /// Firestore instance
  final FirebaseFirestore _firestore;

  /// Firebase Auth instance
  final firebase_auth.FirebaseAuth _auth;

  /// Collection name in Firestore
  final String _collectionName;

  /// Entity type name for logging
  final String _entityTypeName;

  /// Constructor
  BaseMigrationUtility({
    FirebaseFirestore? firestore,
    firebase_auth.FirebaseAuth? auth,
    required String collectionName,
    required String entityTypeName,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? firebase_auth.FirebaseAuth.instance,
       _collectionName = collectionName,
       _entityTypeName = entityTypeName;

  /// Get the Firestore collection reference
  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(_collectionName);

  /// Get the current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if the current user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Validate a single entity
  ///
  /// Returns a list of validation errors. Empty list means valid.
  List<String> validateEntity(T entity);

  /// Convert an entity to a Firestore document
  Map<String, dynamic> entityToFirestore(T entity);

  /// Get the ID of an entity
  String getEntityId(T entity);

  /// Create a new entity in Firestore
  Future<String> createEntity(T entity) async {
    final docRef = await collection.add(entityToFirestore(entity));
    return docRef.id;
  }

  /// Create a new entity in Firestore with a specific ID
  Future<void> createEntityWithId(String id, T entity) async {
    await collection.doc(id).set(entityToFirestore(entity));
  }

  /// Migrate a list of entities to Firestore
  ///
  /// Returns a [MigrationResult] with details about the migration
  Future<MigrationResult> migrateEntities(List<T> entities) async {
    final startTime = DateTime.now();
    final migratedIds = <String>[];
    final failedIds = <String>[];
    final idMap = <String, String>{};

    // Check if user is authenticated
    if (!isAuthenticated) {
      return MigrationResult.failure(
        errorMessage: 'User must be logged in to migrate data',
        entitiesMigrated: 0,
        entitiesFailed: entities.length,
        migratedIds: migratedIds,
        failedIds: entities.map((e) => getEntityId(e)).toList(),
        idMap: idMap,
        startTime: startTime,
        endTime: DateTime.now(),
      );
    }

    try {
      // Start a batch for transaction-like behavior
      var batch = _firestore.batch();
      var batchCount = 0;
      const batchLimit = 500; // Firestore batch limit is 500 operations

      for (final entity in entities) {
        try {
          // Validate the entity
          final validationErrors = validateEntity(entity);
          if (validationErrors.isNotEmpty) {
            Logger.w(
              'Validation failed for $_entityTypeName ${getEntityId(entity)}: ${validationErrors.join(', ')}',
              tag: 'BaseMigrationUtility',
            );
            failedIds.add(getEntityId(entity));
            continue;
          }

          // Create a new document reference
          final oldId = getEntityId(entity);
          final docRef = collection.doc();
          final newId = docRef.id;

          // Add to batch
          batch.set(docRef, entityToFirestore(entity));
          batchCount++;

          // Store ID mapping
          idMap[oldId] = newId;
          migratedIds.add(newId);

          // Commit batch if limit reached
          if (batchCount >= batchLimit) {
            await batch.commit();
            batch = _firestore.batch();
            batchCount = 0;
          }
        } catch (e) {
          Logger.e(
            'Error migrating $_entityTypeName ${getEntityId(entity)}: $e',
            tag: 'BaseMigrationUtility',
          );
          failedIds.add(getEntityId(entity));
        }
      }

      // Commit any remaining operations
      if (batchCount > 0) {
        await batch.commit();
      }

      // Create success result
      return MigrationResult.success(
        entitiesMigrated: migratedIds.length,
        migratedIds: migratedIds,
        idMap: idMap,
        startTime: startTime,
        endTime: DateTime.now(),
      );
    } catch (e) {
      Logger.e(
        'Error migrating $_entityTypeName entities: $e',
        tag: 'BaseMigrationUtility',
      );

      // Attempt rollback if possible
      try {
        await rollback(migratedIds);
      } catch (rollbackError) {
        Logger.e(
          'Error rolling back $_entityTypeName migration: $rollbackError',
          tag: 'BaseMigrationUtility',
        );
      }

      // Create failure result
      return MigrationResult.failure(
        errorMessage: 'Error migrating $_entityTypeName entities: $e',
        exception: e,
        entitiesMigrated: migratedIds.length,
        entitiesFailed: failedIds.length,
        migratedIds: migratedIds,
        failedIds: failedIds,
        idMap: idMap,
        startTime: startTime,
        endTime: DateTime.now(),
      );
    }
  }

  /// Rollback a migration by deleting the migrated entities
  Future<void> rollback(List<String> migratedIds) async {
    if (migratedIds.isEmpty) {
      return;
    }

    Logger.i(
      'Rolling back migration of ${migratedIds.length} $_entityTypeName entities',
      tag: 'BaseMigrationUtility',
    );

    // Use batched deletes for efficiency
    var batch = _firestore.batch();
    var batchCount = 0;
    const batchLimit = 500; // Firestore batch limit is 500 operations

    for (final id in migratedIds) {
      batch.delete(collection.doc(id));
      batchCount++;

      // Commit batch if limit reached
      if (batchCount >= batchLimit) {
        await batch.commit();
        batch = _firestore.batch();
        batchCount = 0;
      }
    }

    // Commit any remaining operations
    if (batchCount > 0) {
      await batch.commit();
    }

    Logger.i(
      'Rollback completed for $_entityTypeName entities',
      tag: 'BaseMigrationUtility',
    );
  }
}
