import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/firebase/utils/firestore_service.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:eventati_book/services/interfaces/database_service_interface.dart';

/// Service for handling vendor recommendation-related Firestore operations
class VendorRecommendationFirestoreService {
  /// Firestore service
  final DatabaseServiceInterface _firestoreService;

  /// Collection name for vendor recommendations
  static const String _collection = 'vendor_recommendations';

  /// Constructor
  VendorRecommendationFirestoreService({
    DatabaseServiceInterface? firestoreService,
  }) : _firestoreService = firestoreService ?? FirestoreService();

  /// Get all vendor recommendations
  Future<List<Suggestion>> getAllVendorRecommendations() async {
    try {
      final recommendations = await _firestoreService.getCollectionAs(
        _collection,
        (data, id) => Suggestion.fromJson({'id': id, ...data}),
      );
      return recommendations;
    } catch (e) {
      Logger.e(
        'Error getting vendor recommendations: $e',
        tag: 'VendorRecommendationFirestoreService',
      );
      return [];
    }
  }

  /// Get vendor recommendations for a specific event type
  Future<List<Suggestion>> getRecommendationsForEventType(
    String eventType,
  ) async {
    try {
      final recommendations = await _firestoreService
          .getCollectionWithQueryAs(_collection, [
            QueryFilter(
              field: 'applicableEventTypes',
              operation: FilterOperation.arrayContains,
              value: eventType,
            ),
          ], (data, id) => Suggestion.fromJson({'id': id, ...data}));
      return recommendations;
    } catch (e) {
      Logger.e(
        'Error getting recommendations for event type: $e',
        tag: 'VendorRecommendationFirestoreService',
      );
      return [];
    }
  }

  /// Get vendor recommendations for a specific category
  Future<List<Suggestion>> getRecommendationsForCategory(
    SuggestionCategory category,
  ) async {
    try {
      final recommendations = await _firestoreService
          .getCollectionWithQueryAs(_collection, [
            QueryFilter(
              field: 'category',
              operation: FilterOperation.equalTo,
              value: category.name,
            ),
          ], (data, id) => Suggestion.fromJson({'id': id, ...data}));
      return recommendations;
    } catch (e) {
      Logger.e(
        'Error getting recommendations for category: $e',
        tag: 'VendorRecommendationFirestoreService',
      );
      return [];
    }
  }

  /// Get a vendor recommendation by ID
  Future<Suggestion?> getRecommendationById(String id) async {
    try {
      final data = await _firestoreService.getDocument(_collection, id);
      if (data == null) return null;
      return Suggestion.fromJson({'id': id, ...data});
    } catch (e) {
      Logger.e(
        'Error getting recommendation by ID: $e',
        tag: 'VendorRecommendationFirestoreService',
      );
      return null;
    }
  }

  /// Add a new vendor recommendation
  Future<String> addRecommendation(Suggestion recommendation) async {
    try {
      final id = await _firestoreService.addDocument(
        _collection,
        recommendation.toFirestore(),
      );
      return id;
    } catch (e) {
      Logger.e(
        'Error adding recommendation: $e',
        tag: 'VendorRecommendationFirestoreService',
      );
      rethrow;
    }
  }

  /// Update a vendor recommendation
  Future<void> updateRecommendation(Suggestion recommendation) async {
    try {
      await _firestoreService.updateDocument(
        _collection,
        recommendation.id,
        recommendation.toFirestore(),
      );
    } catch (e) {
      Logger.e(
        'Error updating recommendation: $e',
        tag: 'VendorRecommendationFirestoreService',
      );
      rethrow;
    }
  }

  /// Delete a vendor recommendation
  Future<void> deleteRecommendation(String id) async {
    try {
      await _firestoreService.deleteDocument(_collection, id);
    } catch (e) {
      Logger.e(
        'Error deleting recommendation: $e',
        tag: 'VendorRecommendationFirestoreService',
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
        tag: 'VendorRecommendationFirestoreService',
      );
      return [];
    }
  }

  /// Seed the database with predefined recommendations
  Future<void> seedPredefinedRecommendations() async {
    try {
      // Check if recommendations already exist
      final existingRecommendations = await _firestoreService.getCollectionAs(
        _collection,
        (data, id) => id,
      );

      if (existingRecommendations.isNotEmpty) {
        Logger.i(
          'Recommendations already exist, skipping seeding',
          tag: 'VendorRecommendationFirestoreService',
        );
        return;
      }

      // Get predefined recommendations
      final recommendations = SuggestionTemplates.getPredefinedSuggestions();

      // Add each recommendation to Firestore
      final batch = FirebaseFirestore.instance.batch();
      for (final recommendation in recommendations) {
        final docRef = FirebaseFirestore.instance
            .collection(_collection)
            .doc(recommendation.id);
        batch.set(docRef, recommendation.toFirestore());
      }

      await batch.commit();
      Logger.i(
        'Successfully seeded ${recommendations.length} recommendations',
        tag: 'VendorRecommendationFirestoreService',
      );
    } catch (e) {
      Logger.e(
        'Error seeding predefined recommendations: $e',
        tag: 'VendorRecommendationFirestoreService',
      );
      rethrow;
    }
  }
}
