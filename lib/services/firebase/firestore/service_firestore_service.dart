import 'package:eventati_book/models/service_models/catering_service.dart';
import 'package:eventati_book/models/service_models/photographer.dart';
import 'package:eventati_book/models/service_models/venue.dart';
import 'package:eventati_book/services/firebase/utils/firestore_service.dart';
import 'package:eventati_book/utils/logger.dart';

/// Service for handling service-related Firestore operations
class ServiceFirestoreService {
  /// Firestore service
  final FirestoreService _firestoreService;

  /// Collection names
  final String _venuesCollection = 'venues';
  final String _cateringCollection = 'catering';
  final String _photographyCollection = 'photography';

  /// Constructor
  ServiceFirestoreService({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  /// Get all venues
  Future<List<Venue>> getVenues() async {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      // Get all venues
      final querySnapshot = await firestore.collection(_venuesCollection).get();

      // Convert to Venue objects
      return querySnapshot.docs.map((doc) => Venue.fromFirestore(doc)).toList();
    } catch (e) {
      Logger.e('Error getting venues: $e', tag: 'ServiceFirestoreService');
      rethrow;
    }
  }

  /// Get a venue by ID
  Future<Venue?> getVenueById(String venueId) async {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      // Get the venue document
      final docSnapshot =
          await firestore.collection(_venuesCollection).doc(venueId).get();

      // Return null if the document doesn't exist
      if (!docSnapshot.exists) return null;

      // Convert to Venue object
      return Venue.fromFirestore(docSnapshot);
    } catch (e) {
      Logger.e('Error getting venue by ID: $e', tag: 'ServiceFirestoreService');
      rethrow;
    }
  }

  /// Get a stream of venues
  Stream<List<Venue>> getVenuesStream() {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      // Create a stream of venues
      return firestore
          .collection(_venuesCollection)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map((doc) => Venue.fromFirestore(doc)).toList(),
          );
    } catch (e) {
      Logger.e(
        'Error getting venues stream: $e',
        tag: 'ServiceFirestoreService',
      );
      rethrow;
    }
  }

  /// Get venues by user ID
  Future<List<Venue>> getVenuesByUserId(String userId) async {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      // Query venues by user ID
      final querySnapshot =
          await firestore
              .collection(_venuesCollection)
              .where('userId', isEqualTo: userId)
              .get();

      // Convert to Venue objects
      return querySnapshot.docs.map((doc) => Venue.fromFirestore(doc)).toList();
    } catch (e) {
      Logger.e(
        'Error getting venues by user ID: $e',
        tag: 'ServiceFirestoreService',
      );
      rethrow;
    }
  }

  /// Get all catering services
  Future<List<CateringService>> getCateringServices() async {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      // Get all catering services
      final querySnapshot =
          await firestore.collection(_cateringCollection).get();

      // Convert to CateringService objects
      return querySnapshot.docs
          .map((doc) => CateringService.fromFirestore(doc))
          .toList();
    } catch (e) {
      Logger.e(
        'Error getting catering services: $e',
        tag: 'ServiceFirestoreService',
      );
      rethrow;
    }
  }

  /// Get a catering service by ID
  Future<CateringService?> getCateringServiceById(String cateringId) async {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      // Get the catering service document
      final docSnapshot =
          await firestore.collection(_cateringCollection).doc(cateringId).get();

      // Return null if the document doesn't exist
      if (!docSnapshot.exists) return null;

      // Convert to CateringService object
      return CateringService.fromFirestore(docSnapshot);
    } catch (e) {
      Logger.e(
        'Error getting catering service by ID: $e',
        tag: 'ServiceFirestoreService',
      );
      rethrow;
    }
  }

  /// Get a stream of catering services
  Stream<List<CateringService>> getCateringServicesStream() {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      // Create a stream of catering services
      return firestore
          .collection(_cateringCollection)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => CateringService.fromFirestore(doc))
                    .toList(),
          );
    } catch (e) {
      Logger.e(
        'Error getting catering services stream: $e',
        tag: 'ServiceFirestoreService',
      );
      rethrow;
    }
  }

  /// Get catering services by user ID
  Future<List<CateringService>> getCateringServicesByUserId(
    String userId,
  ) async {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      // Query catering services by user ID
      final querySnapshot =
          await firestore
              .collection(_cateringCollection)
              .where('userId', isEqualTo: userId)
              .get();

      // Convert to CateringService objects
      return querySnapshot.docs
          .map((doc) => CateringService.fromFirestore(doc))
          .toList();
    } catch (e) {
      Logger.e(
        'Error getting catering services by user ID: $e',
        tag: 'ServiceFirestoreService',
      );
      rethrow;
    }
  }

  /// Create a new catering service
  Future<String> createCateringService(CateringService cateringService) async {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      // Add the catering service to Firestore
      final docRef = await firestore
          .collection(_cateringCollection)
          .add(cateringService.toFirestore());

      return docRef.id;
    } catch (e) {
      Logger.e(
        'Error creating catering service: $e',
        tag: 'ServiceFirestoreService',
      );
      rethrow;
    }
  }

  /// Update a catering service
  Future<void> updateCateringService(CateringService cateringService) async {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      // Update the catering service in Firestore
      await firestore
          .collection(_cateringCollection)
          .doc(cateringService.id)
          .update(cateringService.toFirestore());
    } catch (e) {
      Logger.e(
        'Error updating catering service: $e',
        tag: 'ServiceFirestoreService',
      );
      rethrow;
    }
  }

  /// Delete a catering service
  Future<void> deleteCateringService(String cateringServiceId) async {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      // Delete the catering service from Firestore
      await firestore
          .collection(_cateringCollection)
          .doc(cateringServiceId)
          .delete();
    } catch (e) {
      Logger.e(
        'Error deleting catering service: $e',
        tag: 'ServiceFirestoreService',
      );
      rethrow;
    }
  }

  /// Get all photographers
  Future<List<Photographer>> getPhotographers() async {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      // Get all photographers
      final querySnapshot =
          await firestore.collection(_photographyCollection).get();

      // Convert to Photographer objects
      return querySnapshot.docs
          .map((doc) => Photographer.fromFirestore(doc))
          .toList();
    } catch (e) {
      Logger.e(
        'Error getting photographers: $e',
        tag: 'ServiceFirestoreService',
      );
      rethrow;
    }
  }

  /// Get a photographer by ID
  Future<Photographer?> getPhotographerById(String photographerId) async {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      // Get the photographer document
      final docSnapshot =
          await firestore
              .collection(_photographyCollection)
              .doc(photographerId)
              .get();

      // Return null if the document doesn't exist
      if (!docSnapshot.exists) return null;

      // Convert to Photographer object
      return Photographer.fromFirestore(docSnapshot);
    } catch (e) {
      Logger.e(
        'Error getting photographer by ID: $e',
        tag: 'ServiceFirestoreService',
      );
      rethrow;
    }
  }

  /// Get a stream of photographers
  Stream<List<Photographer>> getPhotographersStream() {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      // Create a stream of photographers
      return firestore
          .collection(_photographyCollection)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => Photographer.fromFirestore(doc))
                    .toList(),
          );
    } catch (e) {
      Logger.e(
        'Error getting photographers stream: $e',
        tag: 'ServiceFirestoreService',
      );
      rethrow;
    }
  }

  /// Get photographers by user ID
  Future<List<Photographer>> getPhotographersByUserId(String userId) async {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      // Query photographers by user ID
      final querySnapshot =
          await firestore
              .collection(_photographyCollection)
              .where('userId', isEqualTo: userId)
              .get();

      // Convert to Photographer objects
      return querySnapshot.docs
          .map((doc) => Photographer.fromFirestore(doc))
          .toList();
    } catch (e) {
      Logger.e(
        'Error getting photographers by user ID: $e',
        tag: 'ServiceFirestoreService',
      );
      rethrow;
    }
  }

  /// Create a new photographer
  Future<String> createPhotographer(Photographer photographer) async {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      // Add the photographer to Firestore
      final docRef = await firestore
          .collection(_photographyCollection)
          .add(photographer.toFirestore());

      return docRef.id;
    } catch (e) {
      Logger.e(
        'Error creating photographer: $e',
        tag: 'ServiceFirestoreService',
      );
      rethrow;
    }
  }

  /// Update a photographer
  Future<void> updatePhotographer(Photographer photographer) async {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      // Update the photographer in Firestore
      await firestore
          .collection(_photographyCollection)
          .doc(photographer.id)
          .update(photographer.toFirestore());
    } catch (e) {
      Logger.e(
        'Error updating photographer: $e',
        tag: 'ServiceFirestoreService',
      );
      rethrow;
    }
  }

  /// Delete a photographer
  Future<void> deletePhotographer(String photographerId) async {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      // Delete the photographer from Firestore
      await firestore
          .collection(_photographyCollection)
          .doc(photographerId)
          .delete();
    } catch (e) {
      Logger.e(
        'Error deleting photographer: $e',
        tag: 'ServiceFirestoreService',
      );
      rethrow;
    }
  }

  /// Create a new venue
  Future<String> createVenue(Venue venue) async {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      // Add the venue to Firestore
      final docRef = await firestore
          .collection(_venuesCollection)
          .add(venue.toFirestore());

      return docRef.id;
    } catch (e) {
      Logger.e('Error creating venue: $e', tag: 'ServiceFirestoreService');
      rethrow;
    }
  }

  /// Update a venue
  Future<void> updateVenue(Venue venue) async {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      // Update the venue in Firestore
      await firestore
          .collection(_venuesCollection)
          .doc(venue.id)
          .update(venue.toFirestore());
    } catch (e) {
      Logger.e('Error updating venue: $e', tag: 'ServiceFirestoreService');
      rethrow;
    }
  }

  /// Delete a venue
  Future<void> deleteVenue(String venueId) async {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      // Delete the venue from Firestore
      await firestore.collection(_venuesCollection).doc(venueId).delete();
    } catch (e) {
      Logger.e('Error deleting venue: $e', tag: 'ServiceFirestoreService');
      rethrow;
    }
  }

  /// Search services by name or description
  Future<Map<String, List<dynamic>>> searchServices(String query) async {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      final results = <String, List<dynamic>>{
        'venues': <Venue>[],
        'catering': <CateringService>[],
        'photography': <Photographer>[],
      };

      // Search venues
      final venuesSnapshot =
          await firestore
              .collection(_venuesCollection)
              .where('name', isEqualTo: query)
              .get();

      results['venues'] =
          venuesSnapshot.docs.map((doc) => Venue.fromFirestore(doc)).toList();

      // Search catering services
      final cateringSnapshot =
          await firestore
              .collection(_cateringCollection)
              .where('name', isEqualTo: query)
              .get();

      results['catering'] =
          cateringSnapshot.docs
              .map((doc) => CateringService.fromFirestore(doc))
              .toList();

      // Search photographers
      final photographersSnapshot =
          await firestore
              .collection(_photographyCollection)
              .where('name', isEqualTo: query)
              .get();

      results['photography'] =
          photographersSnapshot.docs
              .map((doc) => Photographer.fromFirestore(doc))
              .toList();

      return results;
    } catch (e) {
      Logger.e('Error searching services: $e', tag: 'ServiceFirestoreService');
      rethrow;
    }
  }

  /// Get services by event type
  Future<Map<String, List<dynamic>>> getServicesByEventType(
    String eventType,
  ) async {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      final results = <String, List<dynamic>>{
        'venues': <Venue>[],
        'catering': <CateringService>[],
        'photography': <Photographer>[],
      };

      // Get venues for event type
      final venuesSnapshot =
          await firestore
              .collection(_venuesCollection)
              .where('venueTypes', arrayContains: eventType)
              .get();

      results['venues'] =
          venuesSnapshot.docs.map((doc) => Venue.fromFirestore(doc)).toList();

      // Get catering services for event type
      final cateringSnapshot =
          await firestore
              .collection(_cateringCollection)
              .where('cuisineTypes', arrayContains: eventType)
              .get();

      results['catering'] =
          cateringSnapshot.docs
              .map((doc) => CateringService.fromFirestore(doc))
              .toList();

      // Get photographers for event type
      final photographersSnapshot =
          await firestore
              .collection(_photographyCollection)
              .where('styles', arrayContains: eventType)
              .get();

      results['photography'] =
          photographersSnapshot.docs
              .map((doc) => Photographer.fromFirestore(doc))
              .toList();

      return results;
    } catch (e) {
      Logger.e(
        'Error getting services by event type: $e',
        tag: 'ServiceFirestoreService',
      );
      rethrow;
    }
  }

  /// Get services by price range
  Future<Map<String, List<dynamic>>> getServicesByPriceRange(
    double minPrice,
    double maxPrice,
  ) async {
    try {
      // Get the Firestore instance from the service
      final firestore = _firestoreService.getFirestore();

      final results = <String, List<dynamic>>{
        'venues': <Venue>[],
        'catering': <CateringService>[],
        'photography': <Photographer>[],
      };

      // Get venues in price range
      final venuesSnapshot =
          await firestore
              .collection(_venuesCollection)
              .where('pricePerEvent', isGreaterThanOrEqualTo: minPrice)
              .where('pricePerEvent', isLessThanOrEqualTo: maxPrice)
              .get();

      results['venues'] =
          venuesSnapshot.docs.map((doc) => Venue.fromFirestore(doc)).toList();

      // Get catering services in price range
      final cateringSnapshot =
          await firestore
              .collection(_cateringCollection)
              .where('pricePerPerson', isGreaterThanOrEqualTo: minPrice)
              .where('pricePerPerson', isLessThanOrEqualTo: maxPrice)
              .get();

      results['catering'] =
          cateringSnapshot.docs
              .map((doc) => CateringService.fromFirestore(doc))
              .toList();

      // Get photographers in price range
      final photographersSnapshot =
          await firestore
              .collection(_photographyCollection)
              .where('pricePerEvent', isGreaterThanOrEqualTo: minPrice)
              .where('pricePerEvent', isLessThanOrEqualTo: maxPrice)
              .get();

      results['photography'] =
          photographersSnapshot.docs
              .map((doc) => Photographer.fromFirestore(doc))
              .toList();

      return results;
    } catch (e) {
      Logger.e(
        'Error getting services by price range: $e',
        tag: 'ServiceFirestoreService',
      );
      rethrow;
    }
  }
}
