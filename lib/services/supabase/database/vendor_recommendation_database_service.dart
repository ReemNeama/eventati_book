import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling vendor recommendation-related database operations
class VendorRecommendationDatabaseService {
  /// Supabase client
  final SupabaseClient _supabase;

  /// Table name for vendor recommendations
  static const String _table = 'vendor_recommendations';

  /// Constructor
  VendorRecommendationDatabaseService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  /// Get all vendor recommendations
  Future<List<Suggestion>> getAllVendorRecommendations() async {
    try {
      final response = await _supabase.from(_table).select();

      return response
          .map<Suggestion>(
            (data) => Suggestion.fromJson({
              'id': data['id'],
              ...Map<String, dynamic>.from(data),
            }),
          )
          .toList();
    } catch (e) {
      Logger.e(
        'Error getting vendor recommendations: $e',
        tag: 'VendorRecommendationDatabaseService',
      );
      return [];
    }
  }

  /// Get vendor recommendations for a specific event type
  Future<List<Suggestion>> getRecommendationsForEventType(
    String eventType,
  ) async {
    try {
      final response = await _supabase.from(_table).select().contains(
        'applicableEventTypes',
        [eventType],
      );

      return response
          .map<Suggestion>(
            (data) => Suggestion.fromJson({
              'id': data['id'],
              ...Map<String, dynamic>.from(data),
            }),
          )
          .toList();
    } catch (e) {
      Logger.e(
        'Error getting recommendations for event type: $e',
        tag: 'VendorRecommendationDatabaseService',
      );
      return [];
    }
  }

  /// Get vendor recommendations for a specific category
  Future<List<Suggestion>> getRecommendationsForCategory(
    SuggestionCategory category,
  ) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('category', category.name);

      return response
          .map<Suggestion>(
            (data) => Suggestion.fromJson({
              'id': data['id'],
              ...Map<String, dynamic>.from(data),
            }),
          )
          .toList();
    } catch (e) {
      Logger.e(
        'Error getting recommendations for category: $e',
        tag: 'VendorRecommendationDatabaseService',
      );
      return [];
    }
  }

  /// Get a vendor recommendation by ID
  Future<Suggestion?> getRecommendationById(String id) async {
    try {
      final response =
          await _supabase.from(_table).select().eq('id', id).maybeSingle();

      if (response == null) return null;

      return Suggestion.fromJson({
        'id': id,
        ...Map<String, dynamic>.from(response),
      });
    } catch (e) {
      Logger.e(
        'Error getting recommendation by ID: $e',
        tag: 'VendorRecommendationDatabaseService',
      );
      return null;
    }
  }

  /// Add a new vendor recommendation
  Future<String> addRecommendation(Suggestion recommendation) async {
    try {
      final response =
          await _supabase
              .from(_table)
              .insert(recommendation.toDatabaseDoc())
              .select()
              .single();

      return response['id'];
    } catch (e) {
      Logger.e(
        'Error adding recommendation: $e',
        tag: 'VendorRecommendationDatabaseService',
      );
      rethrow;
    }
  }

  /// Update a vendor recommendation
  Future<void> updateRecommendation(Suggestion recommendation) async {
    try {
      await _supabase
          .from(_table)
          .update(recommendation.toDatabaseDoc())
          .eq('id', recommendation.id);
    } catch (e) {
      Logger.e(
        'Error updating recommendation: $e',
        tag: 'VendorRecommendationDatabaseService',
      );
      rethrow;
    }
  }

  /// Delete a vendor recommendation
  Future<void> deleteRecommendation(String id) async {
    try {
      await _supabase.from(_table).delete().eq('id', id);
    } catch (e) {
      Logger.e(
        'Error deleting recommendation: $e',
        tag: 'VendorRecommendationDatabaseService',
      );
      rethrow;
    }
  }

  /// Get personalized recommendations based on wizard state
  Future<List<Suggestion>> getPersonalizedRecommendations(
    WizardState wizardState,
  ) async {
    try {
      // Get all recommendations for this event type
      final allRecommendations = await getRecommendationsForEventType(
        wizardState.template.id,
      );

      // Filter and sort recommendations based on relevance
      final relevantRecommendations =
          allRecommendations
              .where(
                (recommendation) => recommendation.isRelevantFor(wizardState),
              )
              .toList();

      // Sort by relevance score
      relevantRecommendations.sort((a, b) {
        final scoreA = a.calculateRelevanceScore(wizardState);
        final scoreB = b.calculateRelevanceScore(wizardState);
        return scoreB.compareTo(scoreA); // Higher score first
      });

      return relevantRecommendations;
    } catch (e) {
      Logger.e(
        'Error getting personalized recommendations: $e',
        tag: 'VendorRecommendationDatabaseService',
      );
      return [];
    }
  }

  /// Seed the database with predefined recommendations
  Future<void> seedPredefinedRecommendations() async {
    try {
      // Check if recommendations already exist
      final response = await _supabase.from(_table).select('id');

      if (response.isNotEmpty) {
        Logger.i(
          'Recommendations already exist, skipping seeding',
          tag: 'VendorRecommendationDatabaseService',
        );
        return;
      }

      // Get predefined recommendations
      final recommendations = SuggestionTemplates.getPredefinedSuggestions();

      // Add each recommendation to the database
      for (final recommendation in recommendations) {
        await _supabase.from(_table).insert({
          'id': recommendation.id,
          ...recommendation.toDatabaseDoc(),
        });
      }

      Logger.i(
        'Successfully seeded ${recommendations.length} recommendations',
        tag: 'VendorRecommendationDatabaseService',
      );
    } catch (e) {
      Logger.e(
        'Error seeding predefined recommendations: $e',
        tag: 'VendorRecommendationDatabaseService',
      );
      rethrow;
    }
  }
}
