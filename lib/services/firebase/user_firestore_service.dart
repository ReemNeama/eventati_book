import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/firebase/firestore_service.dart';
import 'package:eventati_book/services/interfaces/database_service_interface.dart';

/// Service for handling user-related Firestore operations
class UserFirestoreService {
  /// Firestore service
  final DatabaseServiceInterface _firestoreService;

  /// Collection name for users
  static const String _collection = 'users';

  /// Constructor
  UserFirestoreService({DatabaseServiceInterface? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  /// Get a user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final userData = await _firestoreService.getDocument(_collection, userId);
      if (userData == null) return null;
      return User.fromFirestore(
        DocumentSnapshot.fromJson({
          'data': userData,
          'id': userId,
          'exists': true,
          'metadata': {'hasPendingWrites': false, 'isFromCache': false},
          'reference': {
            'id': userId,
            'path': '$_collection/$userId',
            'parent': {'id': '', 'path': _collection}
          }
        }),
      );
    } catch (e) {
      print('Error getting user by ID: $e');
      rethrow;
    }
  }

  /// Get a stream of a user by ID
  Stream<User?> getUserStream(String userId) {
    return _firestoreService.documentStream(_collection, userId).map((data) {
      if (data == null) return null;
      return User.fromFirestore(
        DocumentSnapshot.fromJson({
          'data': data,
          'id': userId,
          'exists': true,
          'metadata': {'hasPendingWrites': false, 'isFromCache': false},
          'reference': {
            'id': userId,
            'path': '$_collection/$userId',
            'parent': {'id': '', 'path': _collection}
          }
        }),
      );
    });
  }

  /// Create a new user
  Future<void> createUser(User user) async {
    try {
      await _firestoreService.setDocument(
        _collection,
        user.id,
        user.toFirestore(),
      );
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  /// Update a user
  Future<void> updateUser(User user) async {
    try {
      await _firestoreService.updateDocument(
        _collection,
        user.id,
        user.toFirestore(),
      );
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  /// Delete a user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestoreService.deleteDocument(_collection, userId);
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  /// Add a venue to favorites
  Future<void> addFavoriteVenue(String userId, String venueId) async {
    try {
      await _firestoreService.updateDocument(
        _collection,
        userId,
        {
          'favoriteVenues': FieldValue.arrayUnion([venueId]),
        },
      );
    } catch (e) {
      print('Error adding favorite venue: $e');
      rethrow;
    }
  }

  /// Remove a venue from favorites
  Future<void> removeFavoriteVenue(String userId, String venueId) async {
    try {
      await _firestoreService.updateDocument(
        _collection,
        userId,
        {
          'favoriteVenues': FieldValue.arrayRemove([venueId]),
        },
      );
    } catch (e) {
      print('Error removing favorite venue: $e');
      rethrow;
    }
  }

  /// Add a service to favorites
  Future<void> addFavoriteService(String userId, String serviceId) async {
    try {
      await _firestoreService.updateDocument(
        _collection,
        userId,
        {
          'favoriteServices': FieldValue.arrayUnion([serviceId]),
        },
      );
    } catch (e) {
      print('Error adding favorite service: $e');
      rethrow;
    }
  }

  /// Remove a service from favorites
  Future<void> removeFavoriteService(String userId, String serviceId) async {
    try {
      await _firestoreService.updateDocument(
        _collection,
        userId,
        {
          'favoriteServices': FieldValue.arrayRemove([serviceId]),
        },
      );
    } catch (e) {
      print('Error removing favorite service: $e');
      rethrow;
    }
  }

  /// Get custom suggestions for a user
  Future<List<Suggestion>> getCustomSuggestions(String userId) async {
    try {
      final suggestions = await _firestoreService.getSubcollectionAs(
        _collection,
        userId,
        'custom_suggestions',
        (data, id) => Suggestion.fromJson({'id': id, ...data}),
      );
      return suggestions;
    } catch (e) {
      print('Error getting custom suggestions: $e');
      rethrow;
    }
  }

  /// Add a custom suggestion for a user
  Future<String> addCustomSuggestion(
      String userId, Suggestion suggestion) async {
    try {
      final suggestionId = await _firestoreService.addSubcollectionDocument(
        _collection,
        userId,
        'custom_suggestions',
        suggestion.toJson()..remove('id'),
      );
      return suggestionId;
    } catch (e) {
      print('Error adding custom suggestion: $e');
      rethrow;
    }
  }

  /// Update a custom suggestion for a user
  Future<void> updateCustomSuggestion(
      String userId, Suggestion suggestion) async {
    try {
      await _firestoreService.updateSubcollectionDocument(
        _collection,
        userId,
        'custom_suggestions',
        suggestion.id,
        suggestion.toJson()..remove('id'),
      );
    } catch (e) {
      print('Error updating custom suggestion: $e');
      rethrow;
    }
  }

  /// Delete a custom suggestion for a user
  Future<void> deleteCustomSuggestion(
      String userId, String suggestionId) async {
    try {
      await _firestoreService.deleteSubcollectionDocument(
        _collection,
        userId,
        'custom_suggestions',
        suggestionId,
      );
    } catch (e) {
      print('Error deleting custom suggestion: $e');
      rethrow;
    }
  }
}
