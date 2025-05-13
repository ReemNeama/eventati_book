import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

/// Service for handling user-related Supabase operations
class UserDatabaseService {
  /// Supabase client
  final SupabaseClient _supabase;

  /// Collection name for users
  static const String _collection = 'users';

  /// Constructor
  UserDatabaseService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  /// Get a user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final data =
          await _supabase
              .from(_collection)
              .select()
              .eq('id', userId)
              .maybeSingle();

      if (data == null) {
        return null;
      }

      return User.fromJson(data);
    } catch (e) {
      Logger.e('Error getting user by ID: $e', tag: 'UserDatabaseService');
      return null;
    }
  }

  /// Get a user by ID (alias for getUserById for compatibility)
  Future<User?> getUser(String userId) async {
    return getUserById(userId);
  }

  /// Create a new user
  Future<void> createUser(User user) async {
    try {
      await _supabase.from(_collection).insert(user.toJson()).select();
    } catch (e) {
      Logger.e('Error creating user: $e', tag: 'UserDatabaseService');
      rethrow;
    }
  }

  /// Update a user
  Future<void> updateUser(User user) async {
    try {
      await _supabase.from(_collection).update(user.toJson()).eq('id', user.id);
    } catch (e) {
      Logger.e('Error updating user: $e', tag: 'UserDatabaseService');
      rethrow;
    }
  }

  /// Delete a user
  Future<void> deleteUser(String userId) async {
    try {
      await _supabase.from(_collection).delete().eq('id', userId);
    } catch (e) {
      Logger.e('Error deleting user: $e', tag: 'UserDatabaseService');
      rethrow;
    }
  }

  /// Add a venue to user's favorites
  Future<void> addFavoriteVenue(String userId, String venueId) async {
    try {
      // Get current user data
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if venue is already in favorites
      if (user.favoriteVenues.contains(venueId)) {
        return;
      }

      // Add venue to favorites
      final updatedFavorites = List<String>.from(user.favoriteVenues)
        ..add(venueId);

      // Update user data
      await _supabase
          .from(_collection)
          .update({
            'favorite_venues': updatedFavorites,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      Logger.e('Error adding favorite venue: $e', tag: 'UserDatabaseService');
      rethrow;
    }
  }

  /// Remove a venue from user's favorites
  Future<void> removeFavoriteVenue(String userId, String venueId) async {
    try {
      // Get current user data
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Remove venue from favorites
      final updatedFavorites = List<String>.from(user.favoriteVenues)
        ..removeWhere((id) => id == venueId);

      // Update user data
      await _supabase
          .from(_collection)
          .update({
            'favorite_venues': updatedFavorites,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      Logger.e('Error removing favorite venue: $e', tag: 'UserDatabaseService');
      rethrow;
    }
  }

  /// Add a service to user's favorites
  Future<void> addFavoriteService(String userId, String serviceId) async {
    try {
      // Get current user data
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if service is already in favorites
      if (user.favoriteServices.contains(serviceId)) {
        return;
      }

      // Add service to favorites
      final updatedFavorites = List<String>.from(user.favoriteServices)
        ..add(serviceId);

      // Update user data
      await _supabase
          .from(_collection)
          .update({
            'favorite_services': updatedFavorites,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      Logger.e('Error adding favorite service: $e', tag: 'UserDatabaseService');
      rethrow;
    }
  }

  /// Remove a service from user's favorites
  Future<void> removeFavoriteService(String userId, String serviceId) async {
    try {
      // Get current user data
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Remove service from favorites
      final updatedFavorites = List<String>.from(user.favoriteServices)
        ..removeWhere((id) => id == serviceId);

      // Update user data
      await _supabase
          .from(_collection)
          .update({
            'favorite_services': updatedFavorites,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      Logger.e(
        'Error removing favorite service: $e',
        tag: 'UserDatabaseService',
      );
      rethrow;
    }
  }
}
