import 'package:eventati_book/models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// A service for saving and retrieving service comparisons
class ComparisonSavingService {
  /// The Supabase client
  final SupabaseClient _supabaseClient;

  /// Constructor
  ComparisonSavingService({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  /// Save a comparison
  Future<String> saveComparison({
    required String userId,
    required String serviceType,
    required List<dynamic> services,
    required String title,
    String notes = '',
    String? eventId,
    String? eventName,
  }) async {
    try {
      // Extract service IDs and names
      final List<String> serviceIds = [];
      final List<String> serviceNames = [];

      for (final service in services) {
        if (service is Venue) {
          serviceIds.add(service.name); // Using name as ID for now
          serviceNames.add(service.name);
        } else if (service is CateringService) {
          serviceIds.add(service.name); // Using name as ID for now
          serviceNames.add(service.name);
        } else if (service is Photographer) {
          serviceIds.add(service.name); // Using name as ID for now
          serviceNames.add(service.name);
        } else if (service is Planner) {
          serviceIds.add(service.name); // Using name as ID for now
          serviceNames.add(service.name);
        }
      }

      // Create a SavedComparison object
      final savedComparison = SavedComparison(
        id: '', // Will be assigned by the database
        userId: userId,
        serviceType: serviceType,
        serviceIds: serviceIds,
        serviceNames: serviceNames,
        createdAt: DateTime.now(),
        title: title,
        notes: notes,
        eventId: eventId,
        eventName: eventName,
      );

      // Save to Supabase
      final response =
          await _supabaseClient
              .from('saved_comparisons')
              .insert(savedComparison.toDatabaseDoc())
              .select();

      if (response.isEmpty) {
        throw Exception('Failed to save comparison');
      }

      return response[0]['id'];
    } catch (e) {
      debugPrint('Error saving comparison: $e');
      rethrow;
    }
  }

  /// Get all saved comparisons for a user
  Future<List<SavedComparison>> getSavedComparisons(String userId) async {
    try {
      final response = await _supabaseClient
          .from('saved_comparisons')
          .select()
          .eq('userId', userId)
          .order('createdAt', ascending: false);

      // Convert to DbDocumentSnapshot format for compatibility
      final List<SavedComparison> comparisons = [];
      for (final doc in response) {
        comparisons.add(SavedComparison.fromJson(doc));
      }

      return comparisons;
    } catch (e) {
      debugPrint('Error getting saved comparisons: $e');
      return [];
    }
  }

  /// Get a specific saved comparison
  Future<SavedComparison?> getSavedComparison(String comparisonId) async {
    try {
      final response =
          await _supabaseClient
              .from('saved_comparisons')
              .select()
              .eq('id', comparisonId)
              .single();

      return SavedComparison.fromJson(response);
    } catch (e) {
      debugPrint('Error getting saved comparison: $e');
      return null;
    }
  }

  /// Delete a saved comparison
  Future<bool> deleteSavedComparison(String comparisonId) async {
    try {
      await _supabaseClient
          .from('saved_comparisons')
          .delete()
          .eq('id', comparisonId);

      return true;
    } catch (e) {
      debugPrint('Error deleting saved comparison: $e');
      return false;
    }
  }

  /// Share a comparison via a unique link
  Future<String?> shareComparison(String comparisonId) async {
    try {
      // Generate a unique sharing token
      final sharingToken =
          '${DateTime.now().millisecondsSinceEpoch}_$comparisonId';

      // Update the comparison with the sharing token
      await _supabaseClient
          .from('saved_comparisons')
          .update({'sharingToken': sharingToken})
          .eq('id', comparisonId);

      // Return the sharing URL
      return 'https://eventatibook.com/comparison/$sharingToken';
    } catch (e) {
      debugPrint('Error sharing comparison: $e');
      return null;
    }
  }

  /// Get a comparison by sharing token
  Future<SavedComparison?> getComparisonByToken(String token) async {
    try {
      final response =
          await _supabaseClient
              .from('saved_comparisons')
              .select()
              .eq('sharingToken', token)
              .single();

      return SavedComparison.fromJson(response);
    } catch (e) {
      debugPrint('Error getting comparison by token: $e');
      return null;
    }
  }
}
