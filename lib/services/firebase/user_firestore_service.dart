import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/firebase/firestore_service.dart';
import 'package:eventati_book/utils/logger.dart';
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

      // Create a User object from the Firestore data
      return User(
        id: userId,
        name: userData['name'] ?? '',
        email: userData['email'] ?? '',
        phoneNumber: userData['phoneNumber'],
        profileImageUrl: userData['profileImageUrl'],
        createdAt:
            userData['createdAt'] != null
                ? (userData['createdAt'] as Timestamp).toDate()
                : DateTime.now(),
        favoriteVenues:
            userData['favoriteVenues'] != null
                ? List<String>.from(userData['favoriteVenues'])
                : [],
        favoriteServices:
            userData['favoriteServices'] != null
                ? List<String>.from(userData['favoriteServices'])
                : [],
        role: userData['role'] ?? 'user',
        hasPremiumSubscription: userData['hasPremiumSubscription'] ?? false,
        isBetaTester: userData['isBetaTester'] ?? false,
        subscriptionExpirationDate:
            userData['subscriptionExpirationDate'] != null
                ? (userData['subscriptionExpirationDate'] as Timestamp).toDate()
                : null,
      );
    } catch (e) {
      Logger.e('Error getting user by ID: $e', tag: 'UserFirestoreService');
      rethrow;
    }
  }

  /// Get a stream of a user by ID
  Stream<User?> getUserStream(String userId) {
    return _firestoreService.documentStream(_collection, userId).map((data) {
      if (data == null) return null;

      // Create a User object from the Firestore data
      return User(
        id: userId,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phoneNumber: data['phoneNumber'],
        profileImageUrl: data['profileImageUrl'],
        createdAt:
            data['createdAt'] != null
                ? (data['createdAt'] as Timestamp).toDate()
                : DateTime.now(),
        favoriteVenues:
            data['favoriteVenues'] != null
                ? List<String>.from(data['favoriteVenues'])
                : [],
        favoriteServices:
            data['favoriteServices'] != null
                ? List<String>.from(data['favoriteServices'])
                : [],
        role: data['role'] ?? 'user',
        hasPremiumSubscription: data['hasPremiumSubscription'] ?? false,
        isBetaTester: data['isBetaTester'] ?? false,
        subscriptionExpirationDate:
            data['subscriptionExpirationDate'] != null
                ? (data['subscriptionExpirationDate'] as Timestamp).toDate()
                : null,
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
      Logger.e('Error creating user: $e', tag: 'UserFirestoreService');
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
      Logger.e('Error updating user: $e', tag: 'UserFirestoreService');
      rethrow;
    }
  }

  /// Delete a user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestoreService.deleteDocument(_collection, userId);
    } catch (e) {
      Logger.e('Error deleting user: $e', tag: 'UserFirestoreService');
      rethrow;
    }
  }

  /// Add a venue to favorites
  Future<void> addFavoriteVenue(String userId, String venueId) async {
    try {
      await _firestoreService.updateDocument(_collection, userId, {
        'favoriteVenues': FieldValue.arrayUnion([venueId]),
      });
    } catch (e) {
      Logger.e('Error adding favorite venue: $e', tag: 'UserFirestoreService');
      rethrow;
    }
  }

  /// Remove a venue from favorites
  Future<void> removeFavoriteVenue(String userId, String venueId) async {
    try {
      await _firestoreService.updateDocument(_collection, userId, {
        'favoriteVenues': FieldValue.arrayRemove([venueId]),
      });
    } catch (e) {
      Logger.e(
        'Error removing favorite venue: $e',
        tag: 'UserFirestoreService',
      );
      rethrow;
    }
  }

  /// Add a service to favorites
  Future<void> addFavoriteService(String userId, String serviceId) async {
    try {
      await _firestoreService.updateDocument(_collection, userId, {
        'favoriteServices': FieldValue.arrayUnion([serviceId]),
      });
    } catch (e) {
      Logger.e(
        'Error adding favorite service: $e',
        tag: 'UserFirestoreService',
      );
      rethrow;
    }
  }

  /// Remove a service from favorites
  Future<void> removeFavoriteService(String userId, String serviceId) async {
    try {
      await _firestoreService.updateDocument(_collection, userId, {
        'favoriteServices': FieldValue.arrayRemove([serviceId]),
      });
    } catch (e) {
      Logger.e(
        'Error removing favorite service: $e',
        tag: 'UserFirestoreService',
      );
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
      Logger.e(
        'Error getting custom suggestions: $e',
        tag: 'UserFirestoreService',
      );
      rethrow;
    }
  }

  /// Add a custom suggestion for a user
  Future<String> addCustomSuggestion(
    String userId,
    Suggestion suggestion,
  ) async {
    try {
      final suggestionId = await _firestoreService.addSubcollectionDocument(
        _collection,
        userId,
        'custom_suggestions',
        suggestion.toJson()..remove('id'),
      );
      return suggestionId;
    } catch (e) {
      Logger.e(
        'Error adding custom suggestion: $e',
        tag: 'UserFirestoreService',
      );
      rethrow;
    }
  }

  /// Update a custom suggestion for a user
  Future<void> updateCustomSuggestion(
    String userId,
    Suggestion suggestion,
  ) async {
    try {
      await _firestoreService.updateSubcollectionDocument(
        _collection,
        userId,
        'custom_suggestions',
        suggestion.id,
        suggestion.toJson()..remove('id'),
      );
    } catch (e) {
      Logger.e(
        'Error updating custom suggestion: $e',
        tag: 'UserFirestoreService',
      );
      rethrow;
    }
  }

  /// Delete a custom suggestion for a user
  Future<void> deleteCustomSuggestion(
    String userId,
    String suggestionId,
  ) async {
    try {
      await _firestoreService.deleteSubcollectionDocument(
        _collection,
        userId,
        'custom_suggestions',
        suggestionId,
      );
    } catch (e) {
      Logger.e(
        'Error deleting custom suggestion: $e',
        tag: 'UserFirestoreService',
      );
      rethrow;
    }
  }
}
