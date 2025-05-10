import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventati_book/models/planning_models/budget_item.dart';
import 'package:eventati_book/services/firebase/migration/base_migration_utility.dart';
import 'package:eventati_book/services/firebase/migration/migration_result.dart';
import 'package:eventati_book/tempDB/budget.dart';
import 'package:eventati_book/utils/logger.dart';

/// Utility for migrating budget data from tempDB to Firestore
class BudgetMigrationUtility extends BaseMigrationUtility<BudgetItem> {
  /// Event ID for which budget items are being migrated
  final String eventId;

  /// Constructor
  BudgetMigrationUtility({required this.eventId, super.firestore, super.auth})
    : super(
        collectionName: 'events/$eventId/budget_items',
        entityTypeName: 'BudgetItem',
      );

  @override
  List<String> validateEntity(BudgetItem entity) {
    final errors = <String>[];

    // Validate required fields
    if (entity.id.isEmpty) {
      errors.add('Budget item ID is required');
    }
    if (entity.description.isEmpty) {
      errors.add('Description is required');
    }
    if (entity.categoryId.isEmpty) {
      errors.add('Category ID is required');
    }
    if (entity.estimatedCost < 0) {
      errors.add('Estimated cost must be non-negative');
    }
    if (entity.actualCost != null && entity.actualCost! < 0) {
      errors.add('Actual cost must be non-negative');
    }

    return errors;
  }

  @override
  Map<String, dynamic> entityToFirestore(BudgetItem entity) {
    return entity.toFirestore();
  }

  @override
  String getEntityId(BudgetItem entity) {
    return entity.id;
  }

  /// Migrate all budget items for an event from tempDB to Firestore
  Future<MigrationResult> migrateEventBudget() async {
    try {
      // Get budget items from tempDB
      final budgetItems = BudgetDB.getBudgetItems(eventId);

      Logger.i(
        'Migrating ${budgetItems.length} budget items for event $eventId from tempDB to Firestore',
        tag: 'BudgetMigrationUtility',
      );

      // Migrate budget items
      final result = await migrateEntities(budgetItems);

      // Log result
      if (result.success) {
        Logger.i(
          'Successfully migrated ${result.entitiesMigrated} budget items for event $eventId to Firestore',
          tag: 'BudgetMigrationUtility',
        );
      } else {
        Logger.e(
          'Failed to migrate budget items for event $eventId to Firestore: ${result.errorMessage}',
          tag: 'BudgetMigrationUtility',
        );
      }

      return result;
    } catch (e) {
      Logger.e(
        'Error migrating budget items for event $eventId: $e',
        tag: 'BudgetMigrationUtility',
      );
      return MigrationResult.failure(
        errorMessage: 'Error migrating budget items for event $eventId: $e',
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

  /// Migrate budget categories for an event from tempDB to Firestore
  Future<MigrationResult> migrateBudgetCategories() async {
    final startTime = DateTime.now();
    try {
      // Get budget categories from tempDB
      final categories = BudgetDB.getBudgetCategories();

      Logger.i(
        'Migrating ${categories.length} budget categories for event $eventId from tempDB to Firestore',
        tag: 'BudgetMigrationUtility',
      );

      // Create a subcollection reference for categories
      final categoriesCollection = FirebaseFirestore.instance.collection(
        'events/$eventId/budget_categories',
      );

      final migratedIds = <String>[];
      final failedIds = <String>[];
      final idMap = <String, String>{};

      // Start a batch for transaction-like behavior
      var batch = FirebaseFirestore.instance.batch();
      var batchCount = 0;
      const batchLimit = 500; // Firestore batch limit is 500 operations

      for (final category in categories) {
        try {
          // Create a new document reference
          final docRef = categoriesCollection.doc();
          final newId = docRef.id;

          // Add to batch
          batch.set(docRef, {
            'name': category.name,
            'iconCodePoint': category.icon.codePoint,
            'iconFontFamily': category.icon.fontFamily,
            'iconFontPackage': category.icon.fontPackage,
            'createdAt': FieldValue.serverTimestamp(),
          });
          batchCount++;

          // Store ID mapping
          idMap[category.id] = newId;
          migratedIds.add(newId);

          // Commit batch if limit reached
          if (batchCount >= batchLimit) {
            await batch.commit();
            batch = FirebaseFirestore.instance.batch();
            batchCount = 0;
          }
        } catch (e) {
          Logger.e(
            'Error migrating budget category ${category.id}: $e',
            tag: 'BudgetMigrationUtility',
          );
          failedIds.add(category.id);
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
            failedIds.isEmpty ? null : 'Some categories failed to migrate',
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
          'Successfully migrated ${result.entitiesMigrated} budget categories for event $eventId to Firestore',
          tag: 'BudgetMigrationUtility',
        );
      } else {
        Logger.e(
          'Failed to migrate some budget categories for event $eventId to Firestore',
          tag: 'BudgetMigrationUtility',
        );
      }

      return result;
    } catch (e) {
      Logger.e(
        'Error migrating budget categories for event $eventId: $e',
        tag: 'BudgetMigrationUtility',
      );
      return MigrationResult.failure(
        errorMessage:
            'Error migrating budget categories for event $eventId: $e',
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

  /// Migrate both budget items and categories for an event
  Future<MigrationResult> migrateFullBudget() async {
    final startTime = DateTime.now();
    try {
      // First migrate categories
      final categoriesResult = await migrateBudgetCategories();

      // Then migrate budget items, updating category IDs
      final budgetItems = BudgetDB.getBudgetItems(eventId);

      // Update category IDs based on the mapping from the categories migration
      final updatedBudgetItems =
          budgetItems.map((item) {
            if (categoriesResult.idMap.containsKey(item.categoryId)) {
              return item.copyWith(
                categoryId: categoriesResult.idMap[item.categoryId]!,
              );
            }
            return item;
          }).toList();

      // Migrate the updated budget items
      final itemsResult = await migrateEntities(updatedBudgetItems);

      // Combine the results
      final combinedResult = MigrationResult.combine([
        categoriesResult,
        itemsResult,
      ]);

      return combinedResult;
    } catch (e) {
      Logger.e(
        'Error migrating full budget for event $eventId: $e',
        tag: 'BudgetMigrationUtility',
      );
      return MigrationResult.failure(
        errorMessage: 'Error migrating full budget for event $eventId: $e',
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
