import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/firebase/firestore_service.dart';
import 'package:eventati_book/services/interfaces/database_service_interface.dart';
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
      final venues = await _firestoreService.getCollectionAs(
        _venuesCollection,
        (data, id) => Venue(
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          rating: (data['rating'] ?? 0).toDouble(),
          venueTypes: List<String>.from(data['venueTypes'] ?? []),
          minCapacity: data['minCapacity'] ?? 0,
          maxCapacity: data['maxCapacity'] ?? 0,
          pricePerEvent: (data['pricePerEvent'] ?? 0).toDouble(),
          imageUrl: data['imageUrl'] ?? '',
          features: List<String>.from(data['features'] ?? []),
        ),
      );
      return venues;
    } catch (e) {
      Logger.e('Error getting venues: $e', tag: 'ServiceFirestoreService');
      rethrow;
    }
  }

  /// Get a venue by ID
  Future<Venue?> getVenueById(String venueId) async {
    try {
      final venueData = await _firestoreService.getDocument(
        _venuesCollection,
        venueId,
      );
      if (venueData == null) return null;
      return Venue(
        name: venueData['name'] ?? '',
        description: venueData['description'] ?? '',
        rating: (venueData['rating'] ?? 0).toDouble(),
        venueTypes: List<String>.from(venueData['venueTypes'] ?? []),
        minCapacity: venueData['minCapacity'] ?? 0,
        maxCapacity: venueData['maxCapacity'] ?? 0,
        pricePerEvent: (venueData['pricePerEvent'] ?? 0).toDouble(),
        imageUrl: venueData['imageUrl'] ?? '',
        features: List<String>.from(venueData['features'] ?? []),
      );
    } catch (e) {
      Logger.e('Error getting venue by ID: $e', tag: 'ServiceFirestoreService');
      rethrow;
    }
  }

  /// Get all catering services
  Future<List<CateringService>> getCateringServices() async {
    try {
      final cateringServices = await _firestoreService.getCollectionAs(
        _cateringCollection,
        (data, id) => CateringService(
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          rating: (data['rating'] ?? 0).toDouble(),
          cuisineTypes: List<String>.from(data['cuisineTypes'] ?? []),
          minCapacity: data['minCapacity'] ?? 0,
          maxCapacity: data['maxCapacity'] ?? 0,
          pricePerPerson: (data['pricePerPerson'] ?? 0).toDouble(),
          imageUrl: data['imageUrl'] ?? '',
        ),
      );
      return cateringServices;
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
      final cateringData = await _firestoreService.getDocument(
        _cateringCollection,
        cateringId,
      );
      if (cateringData == null) return null;
      return CateringService(
        name: cateringData['name'] ?? '',
        description: cateringData['description'] ?? '',
        rating: (cateringData['rating'] ?? 0).toDouble(),
        cuisineTypes: List<String>.from(cateringData['cuisineTypes'] ?? []),
        minCapacity: cateringData['minCapacity'] ?? 0,
        maxCapacity: cateringData['maxCapacity'] ?? 0,
        pricePerPerson: (cateringData['pricePerPerson'] ?? 0).toDouble(),
        imageUrl: cateringData['imageUrl'] ?? '',
      );
    } catch (e) {
      Logger.e(
        'Error getting catering service by ID: $e',
        tag: 'ServiceFirestoreService',
      );
      rethrow;
    }
  }

  /// Get all photographers
  Future<List<Photographer>> getPhotographers() async {
    try {
      final photographers = await _firestoreService.getCollectionAs(
        _photographyCollection,
        (data, id) => Photographer(
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          rating: (data['rating'] ?? 0).toDouble(),
          styles: List<String>.from(data['styles'] ?? []),
          pricePerEvent: (data['pricePerEvent'] ?? 0).toDouble(),
          imageUrl: data['imageUrl'] ?? '',
          equipment: List<String>.from(data['equipment'] ?? []),
          packages: List<String>.from(data['packages'] ?? []),
        ),
      );
      return photographers;
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
      final photographerData = await _firestoreService.getDocument(
        _photographyCollection,
        photographerId,
      );
      if (photographerData == null) return null;
      return Photographer(
        name: photographerData['name'] ?? '',
        description: photographerData['description'] ?? '',
        rating: (photographerData['rating'] ?? 0).toDouble(),
        styles: List<String>.from(photographerData['styles'] ?? []),
        pricePerEvent: (photographerData['pricePerEvent'] ?? 0).toDouble(),
        imageUrl: photographerData['imageUrl'] ?? '',
        equipment: List<String>.from(photographerData['equipment'] ?? []),
        packages: List<String>.from(photographerData['packages'] ?? []),
      );
    } catch (e) {
      Logger.e(
        'Error getting photographer by ID: $e',
        tag: 'ServiceFirestoreService',
      );
      rethrow;
    }
  }

  /// Create a new venue
  Future<String> createVenue(Venue venue) async {
    try {
      final data = {
        'name': venue.name,
        'description': venue.description,
        'rating': venue.rating,
        'venueTypes': venue.venueTypes,
        'minCapacity': venue.minCapacity,
        'maxCapacity': venue.maxCapacity,
        'pricePerEvent': venue.pricePerEvent,
        'imageUrl': venue.imageUrl,
        'features': venue.features,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final venueId = await _firestoreService.addDocument(
        _venuesCollection,
        data,
      );
      return venueId;
    } catch (e) {
      Logger.e('Error creating venue: $e', tag: 'ServiceFirestoreService');
      rethrow;
    }
  }

  /// Search services by name or description
  Future<List<Map<String, dynamic>>> searchServices(String query) async {
    try {
      final results = <Map<String, dynamic>>[];

      // Search venues
      final venues = await _firestoreService.getCollectionWithQuery(
        _venuesCollection,
        [
          QueryFilter(
            field: 'name',
            operation: FilterOperation.equalTo,
            value: query,
          ),
        ],
      );
      for (final venue in venues) {
        venue['type'] = 'venue';
        results.add(venue);
      }

      // Search catering services
      final cateringServices = await _firestoreService.getCollectionWithQuery(
        _cateringCollection,
        [
          QueryFilter(
            field: 'name',
            operation: FilterOperation.equalTo,
            value: query,
          ),
        ],
      );
      for (final catering in cateringServices) {
        catering['type'] = 'catering';
        results.add(catering);
      }

      // Search photographers
      final photographers = await _firestoreService.getCollectionWithQuery(
        _photographyCollection,
        [
          QueryFilter(
            field: 'name',
            operation: FilterOperation.equalTo,
            value: query,
          ),
        ],
      );
      for (final photographer in photographers) {
        photographer['type'] = 'photography';
        results.add(photographer);
      }

      return results;
    } catch (e) {
      Logger.e('Error searching services: $e', tag: 'ServiceFirestoreService');
      rethrow;
    }
  }
}
