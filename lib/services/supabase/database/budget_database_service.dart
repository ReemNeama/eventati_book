import 'package:eventati_book/models/planning_models/budget_item.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling budget-related database operations with Supabase
class BudgetDatabaseService {
  /// Supabase client
  final SupabaseClient _supabase;

  /// Table name for budget items
  static const String _budgetItemsTable = 'budget_items';

  /// Table name for budget categories
  static const String _categoriesTable = 'budget_categories';

  /// Constructor
  BudgetDatabaseService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  /// Get all budget items for an event
  Future<List<BudgetItem>> getBudgetItems(String eventId) async {
    try {
      final response = await _supabase
          .from(_budgetItemsTable)
          .select()
          .eq('event_id', eventId);

      return response
          .map<BudgetItem>((data) => BudgetItem.fromJson(data))
          .toList();
    } catch (e) {
      Logger.e('Error getting budget items: $e', tag: 'BudgetDatabaseService');
      return [];
    }
  }

  /// Get a stream of budget items for an event
  Stream<List<BudgetItem>> getBudgetItemsStream(String eventId) {
    return _supabase
        .from(_budgetItemsTable)
        .stream(primaryKey: ['id'])
        .eq('event_id', eventId)
        .map(
          (data) =>
              data
                  .map<BudgetItem>((item) => BudgetItem.fromJson(item))
                  .toList(),
        );
  }

  /// Get a budget item by ID
  Future<BudgetItem?> getBudgetItem(String itemId) async {
    try {
      final response =
          await _supabase
              .from(_budgetItemsTable)
              .select()
              .eq('id', itemId)
              .maybeSingle();

      if (response == null) {
        return null;
      }

      return BudgetItem.fromJson(response);
    } catch (e) {
      Logger.e('Error getting budget item: $e', tag: 'BudgetDatabaseService');
      return null;
    }
  }

  /// Add a new budget item
  Future<String> addBudgetItem(String eventId, BudgetItem item) async {
    try {
      final itemData = item.toJson();

      // Convert to snake_case for Supabase
      final supabaseData = {
        'event_id': eventId,
        'category_id': itemData['categoryId'],
        'description': itemData['description'],
        'estimated_cost': itemData['estimatedCost'],
        'actual_cost': itemData['actualCost'],
        'is_paid': itemData['isPaid'],
        'payment_date': itemData['paymentDate'],
        'notes': itemData['notes'],
        'vendor_name': itemData['vendorName'],
        'vendor_contact': itemData['vendorContact'],
        'due_date': itemData['dueDate'],
        'is_booked': itemData['isBooked'],
        'booking_id': itemData['bookingId'],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabase
              .from(_budgetItemsTable)
              .insert(supabaseData)
              .select()
              .single();

      return response['id'];
    } catch (e) {
      Logger.e('Error adding budget item: $e', tag: 'BudgetDatabaseService');
      rethrow;
    }
  }

  /// Update an existing budget item
  Future<void> updateBudgetItem(String eventId, BudgetItem item) async {
    try {
      final itemData = item.toJson();

      // Convert to snake_case for Supabase
      final supabaseData = {
        'event_id': eventId,
        'category_id': itemData['categoryId'],
        'description': itemData['description'],
        'estimated_cost': itemData['estimatedCost'],
        'actual_cost': itemData['actualCost'],
        'is_paid': itemData['isPaid'],
        'payment_date': itemData['paymentDate'],
        'notes': itemData['notes'],
        'vendor_name': itemData['vendorName'],
        'vendor_contact': itemData['vendorContact'],
        'due_date': itemData['dueDate'],
        'is_booked': itemData['isBooked'],
        'booking_id': itemData['bookingId'],
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from(_budgetItemsTable)
          .update(supabaseData)
          .eq('id', item.id)
          .eq('event_id', eventId);
    } catch (e) {
      Logger.e('Error updating budget item: $e', tag: 'BudgetDatabaseService');
      rethrow;
    }
  }

  /// Delete a budget item
  Future<void> deleteBudgetItem(String itemId, String eventId) async {
    try {
      await _supabase
          .from(_budgetItemsTable)
          .delete()
          .eq('id', itemId)
          .eq('event_id', eventId);
    } catch (e) {
      Logger.e('Error deleting budget item: $e', tag: 'BudgetDatabaseService');
      rethrow;
    }
  }

  /// Get all budget categories
  Future<List<BudgetCategory>> getBudgetCategories() async {
    try {
      final response = await _supabase.from(_categoriesTable).select();

      return response
          .map<BudgetCategory>(
            (data) => BudgetCategory(
              id: data['id'],
              name: data['name'],
              icon:
                  Icon(
                    IconData(
                      data['icon_code_point'] ?? 0,
                      fontFamily: data['icon_font_family'],
                      fontPackage: data['icon_font_package'],
                    ),
                  ).icon!,
            ),
          )
          .toList();
    } catch (e) {
      Logger.e(
        'Error getting budget categories: $e',
        tag: 'BudgetDatabaseService',
      );
      return [];
    }
  }

  /// Add a new budget category
  Future<String> addBudgetCategory(BudgetCategory category) async {
    try {
      final supabaseData = {
        'name': category.name,
        'icon_code_point': category.icon.codePoint,
        'icon_font_family': category.icon.fontFamily,
        'icon_font_package': category.icon.fontPackage,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabase
              .from(_categoriesTable)
              .insert(supabaseData)
              .select()
              .single();

      return response['id'];
    } catch (e) {
      Logger.e(
        'Error adding budget category: $e',
        tag: 'BudgetDatabaseService',
      );
      rethrow;
    }
  }
}
