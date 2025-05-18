import 'dart:async';
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
    // Add a timeout for the operation
    const timeout = Duration(seconds: 10);

    try {
      // Validate input
      if (wizardState.template.id.isEmpty) {
        Logger.e(
          'Wizard template is null or has no ID',
          tag: 'VendorRecommendationDatabaseService',
        );
        return [];
      }

      // Create a completer to handle the timeout
      final completer = Completer<List<Suggestion>>();

      // Set up the timeout
      Timer(timeout, () {
        if (!completer.isCompleted) {
          Logger.w(
            'Personalized recommendations timed out',
            tag: 'VendorRecommendationDatabaseService',
          );
          completer.complete([]);
        }
      });

      // Execute the operation
      Future<void> getRecommendations() async {
        try {
          // Get all recommendations for this event type
          final allRecommendations = await getRecommendationsForEventType(
            wizardState.template.id,
          );

          if (allRecommendations.isEmpty) {
            Logger.i(
              'No recommendations found for event type: ${wizardState.template.id}',
              tag: 'VendorRecommendationDatabaseService',
            );
            if (!completer.isCompleted) {
              completer.complete([]);
            }
            return;
          }

          Logger.i(
            'Found ${allRecommendations.length} recommendations for event type: ${wizardState.template.id}',
            tag: 'VendorRecommendationDatabaseService',
          );

          // Filter recommendations based on relevance
          final relevantRecommendations =
              allRecommendations.where((recommendation) {
                try {
                  return recommendation.isRelevantFor(wizardState);
                } catch (e) {
                  Logger.w(
                    'Error checking relevance for recommendation ${recommendation.id}: $e',
                    tag: 'VendorRecommendationDatabaseService',
                  );
                  return false;
                }
              }).toList();

          Logger.i(
            '${relevantRecommendations.length} recommendations are relevant for this wizard state',
            tag: 'VendorRecommendationDatabaseService',
          );

          // Sort by relevance score
          try {
            relevantRecommendations.sort((a, b) {
              try {
                final scoreA = a.calculateRelevanceScore(wizardState);
                final scoreB = b.calculateRelevanceScore(wizardState);
                return scoreB.compareTo(scoreA); // Higher score first
              } catch (e) {
                Logger.w(
                  'Error calculating relevance score: $e',
                  tag: 'VendorRecommendationDatabaseService',
                );
                return 0; // Keep original order if there's an error
              }
            });
          } catch (e) {
            Logger.w(
              'Error sorting recommendations: $e',
              tag: 'VendorRecommendationDatabaseService',
            );
            // Continue with unsorted recommendations
          }

          if (!completer.isCompleted) {
            completer.complete(relevantRecommendations);
          }
        } catch (e) {
          Logger.e(
            'Error getting personalized recommendations: $e',
            tag: 'VendorRecommendationDatabaseService',
          );
          if (!completer.isCompleted) {
            completer.complete([]);
          }
        }
      }

      // Start the operation
      getRecommendations();

      // Wait for either the operation to complete or the timeout
      return await completer.future;
    } catch (e) {
      Logger.e(
        'Error in getPersonalizedRecommendations: $e',
        tag: 'VendorRecommendationDatabaseService',
      );
      return [];
    }
  }

  /// Seed the database with predefined recommendations
  Future<void> seedPredefinedRecommendations() async {
    try {
      // Check if recommendations already exist
      final response = await _supabase.from(_table).select('id').limit(1);

      if (response.isNotEmpty) {
        Logger.i(
          'Recommendations already exist, skipping seeding',
          tag: 'VendorRecommendationDatabaseService',
        );
        return;
      }

      // Get predefined recommendations
      final recommendations = SuggestionTemplates.getPredefinedSuggestions();

      if (recommendations.isEmpty) {
        Logger.w(
          'No predefined recommendations found',
          tag: 'VendorRecommendationDatabaseService',
        );
        return;
      }

      Logger.i(
        'Seeding ${recommendations.length} recommendations',
        tag: 'VendorRecommendationDatabaseService',
      );

      // Process recommendations in batches to avoid overloading the database
      const batchSize = 10;
      int successCount = 0;
      int failureCount = 0;

      for (int i = 0; i < recommendations.length; i += batchSize) {
        final end =
            (i + batchSize < recommendations.length)
                ? i + batchSize
                : recommendations.length;
        final batch = recommendations.sublist(i, end);

        try {
          // Prepare batch data
          final batchData =
              batch
                  .map(
                    (recommendation) => {
                      'id': recommendation.id,
                      ...recommendation.toDatabaseDoc(),
                    },
                  )
                  .toList();

          // Insert batch
          await _supabase.from(_table).insert(batchData);

          successCount += batch.length;

          Logger.i(
            'Seeded batch ${i ~/ batchSize + 1} (${batch.length} recommendations)',
            tag: 'VendorRecommendationDatabaseService',
          );
        } catch (e) {
          failureCount += batch.length;

          Logger.e(
            'Error seeding batch ${i ~/ batchSize + 1}: $e',
            tag: 'VendorRecommendationDatabaseService',
          );

          // Try to insert recommendations one by one as a fallback
          for (final recommendation in batch) {
            try {
              await _supabase.from(_table).insert({
                'id': recommendation.id,
                ...recommendation.toDatabaseDoc(),
              });

              successCount++;
              failureCount--;

              Logger.i(
                'Seeded individual recommendation: ${recommendation.id}',
                tag: 'VendorRecommendationDatabaseService',
              );
            } catch (individualError) {
              Logger.e(
                'Error seeding individual recommendation ${recommendation.id}: $individualError',
                tag: 'VendorRecommendationDatabaseService',
              );
            }
          }
        }

        // Add a small delay between batches to avoid rate limiting
        if (end < recommendations.length) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      Logger.i(
        'Seeding completed: $successCount succeeded, $failureCount failed',
        tag: 'VendorRecommendationDatabaseService',
      );

      if (failureCount > 0) {
        throw Exception('Failed to seed $failureCount recommendations');
      }
    } catch (e) {
      Logger.e(
        'Error seeding predefined recommendations: $e',
        tag: 'VendorRecommendationDatabaseService',
      );
      rethrow;
    }
  }
}
