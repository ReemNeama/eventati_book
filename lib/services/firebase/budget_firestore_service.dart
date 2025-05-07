import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/firebase/firestore_service.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:flutter/material.dart';

/// Service for handling budget-related Firestore operations
class BudgetFirestoreService {
  /// Firestore service
  final FirestoreService _firestoreService;

  /// Collection name
  final String _collection = 'events';

  /// Constructor
  BudgetFirestoreService({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  /// Get budget categories for an event
  Future<List<BudgetCategory>> getBudgetCategories(String eventId) async {
    try {
      final categories = await _firestoreService.getSubcollectionAs(
        _collection,
        eventId,
        'budget_categories',
        (data, id) => BudgetCategory(
          id: id,
          name: data['name'] ?? '',
          icon: Icons.category, // Default icon, should be mapped properly
        ),
      );
      return categories;
    } catch (e) {
      Logger.e(
        'Error getting budget categories: $e',
        tag: 'BudgetFirestoreService',
      );
      rethrow;
    }
  }

  /// Get budget items for an event
  Future<List<BudgetItem>> getBudgetItems(String eventId) async {
    try {
      final items = await _firestoreService.getSubcollectionAs(
        _collection,
        eventId,
        'budget_items',
        (data, id) => BudgetItem(
          id: id,
          categoryId: data['categoryId'] ?? '',
          description: data['description'] ?? '',
          estimatedCost: (data['estimatedCost'] ?? 0).toDouble(),
          actualCost:
              data['actualCost'] != null
                  ? (data['actualCost'] as num).toDouble()
                  : null,
          isPaid: data['isPaid'] ?? false,
          paymentDate:
              data['paymentDate'] != null
                  ? (data['paymentDate'] as Timestamp).toDate()
                  : null,
          notes: data['notes'],
        ),
      );
      return items;
    } catch (e) {
      Logger.e('Error getting budget items: $e', tag: 'BudgetFirestoreService');
      rethrow;
    }
  }

  /// Add a budget category to an event
  Future<String> addBudgetCategory(
    String eventId,
    BudgetCategory category,
  ) async {
    try {
      final categoryId = await _firestoreService
          .addSubcollectionDocument(_collection, eventId, 'budget_categories', {
            'name': category.name,
            'iconCodePoint': category.icon.codePoint,
            'iconFontFamily': category.icon.fontFamily,
            'iconFontPackage': category.icon.fontPackage,
            'createdAt': FieldValue.serverTimestamp(),
          });
      return categoryId;
    } catch (e) {
      Logger.e(
        'Error adding budget category: $e',
        tag: 'BudgetFirestoreService',
      );
      rethrow;
    }
  }

  /// Update a budget category
  Future<void> updateBudgetCategory(
    String eventId,
    BudgetCategory category,
  ) async {
    try {
      await _firestoreService.updateSubcollectionDocument(
        _collection,
        eventId,
        'budget_categories',
        category.id,
        {
          'name': category.name,
          'iconCodePoint': category.icon.codePoint,
          'iconFontFamily': category.icon.fontFamily,
          'iconFontPackage': category.icon.fontPackage,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      Logger.e(
        'Error updating budget category: $e',
        tag: 'BudgetFirestoreService',
      );
      rethrow;
    }
  }

  /// Delete a budget category
  Future<void> deleteBudgetCategory(String eventId, String categoryId) async {
    try {
      await _firestoreService.deleteSubcollectionDocument(
        _collection,
        eventId,
        'budget_categories',
        categoryId,
      );
    } catch (e) {
      Logger.e(
        'Error deleting budget category: $e',
        tag: 'BudgetFirestoreService',
      );
      rethrow;
    }
  }

  /// Add a budget item to an event
  Future<String> addBudgetItem(String eventId, BudgetItem item) async {
    try {
      final itemId = await _firestoreService
          .addSubcollectionDocument(_collection, eventId, 'budget_items', {
            'categoryId': item.categoryId,
            'description': item.description,
            'estimatedCost': item.estimatedCost,
            'actualCost': item.actualCost,
            'isPaid': item.isPaid,
            'paymentDate':
                item.paymentDate != null
                    ? Timestamp.fromDate(item.paymentDate!)
                    : null,
            'notes': item.notes,
            'createdAt': FieldValue.serverTimestamp(),
          });
      return itemId;
    } catch (e) {
      Logger.e('Error adding budget item: $e', tag: 'BudgetFirestoreService');
      rethrow;
    }
  }

  /// Update a budget item
  Future<void> updateBudgetItem(String eventId, BudgetItem item) async {
    try {
      await _firestoreService.updateSubcollectionDocument(
        _collection,
        eventId,
        'budget_items',
        item.id,
        {
          'categoryId': item.categoryId,
          'description': item.description,
          'estimatedCost': item.estimatedCost,
          'actualCost': item.actualCost,
          'isPaid': item.isPaid,
          'paymentDate':
              item.paymentDate != null
                  ? Timestamp.fromDate(item.paymentDate!)
                  : null,
          'notes': item.notes,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      Logger.e('Error updating budget item: $e', tag: 'BudgetFirestoreService');
      rethrow;
    }
  }

  /// Delete a budget item
  Future<void> deleteBudgetItem(String eventId, String itemId) async {
    try {
      await _firestoreService.deleteSubcollectionDocument(
        _collection,
        eventId,
        'budget_items',
        itemId,
      );
    } catch (e) {
      Logger.e('Error deleting budget item: $e', tag: 'BudgetFirestoreService');
      rethrow;
    }
  }
}
