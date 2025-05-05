import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication states
enum AuthStatus {
  /// User is currently authenticating (logging in or registering)
  authenticating,

  /// User is authenticated (logged in)
  authenticated,

  /// User is not authenticated (logged out)
  unauthenticated,

  /// Authentication error occurred
  error,
}

/// Provider for managing authentication state in the application.
///
/// The AuthProvider is responsible for:
/// * User authentication (login, registration, logout)
/// * Storing and retrieving user data
/// * Managing authentication tokens
/// * Tracking authentication status
/// * Handling user profile updates
/// * Managing user favorites
///
/// This provider uses SharedPreferences for persistent storage of authentication data.
/// In a production environment, this would be replaced with secure API calls to a backend.
///
/// Usage example:
/// ```dart
/// // Access the provider
/// final authProvider = Provider.of<AuthProvider>(context);
///
/// // Check authentication status
/// if (authProvider.isAuthenticated) {
///   // User is logged in
///   final user = authProvider.user;
///   print('Logged in as ${user?.name}');
/// } else {
///   // User is not logged in
///   Navigator.of(context).pushNamed('/login');
/// }
///
/// // Login a user
/// final success = await authProvider.login('user@example.com', 'password');
/// if (success) {
///   Navigator.of(context).pushReplacementNamed('/home');
/// } else {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text(authProvider.errorMessage ?? 'Login failed')),
///   );
/// }
/// ```
class AuthProvider with ChangeNotifier {
  /// Current authentication status
  AuthStatus _status = AuthStatus.unauthenticated;

  /// Current user
  User? _user;

  /// Authentication token
  String? _token;

  /// Error message if authentication fails
  String? _errorMessage;

  /// Get current authentication status
  AuthStatus get status => _status;

  /// Get current user
  User? get user => _user;

  /// Get current user (alias for user)
  User? get currentUser => _user;

  /// Get authentication token
  String? get token => _token;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Check if user is authenticated
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Initialize the provider
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if token exists
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();

        return;
      }

      // Check if user data exists
      final userData = prefs.getString(AppConstants.userDataKey);
      if (userData == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();

        return;
      }

      // Parse user data
      _user = User.fromJson(jsonDecode(userData));
      _token = token;
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Failed to initialize authentication: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      // TODO: Replace with actual API call
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // For demo purposes, accept any email with a password length >= 6
      if (password.length < 6) {
        _status = AuthStatus.error;
        _errorMessage = 'Invalid credentials';
        notifyListeners();

        return false;
      }

      // Create mock user and token
      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: email.split('@').first,
        email: email,
        createdAt: DateTime.now(),
      );

      final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, token);
      await prefs.setString(
        AppConstants.userDataKey,
        jsonEncode(user.toJson()),
      );

      // Update state
      _user = user;
      _token = token;
      _status = AuthStatus.authenticated;
      notifyListeners();

      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Login failed: ${e.toString()}';
      notifyListeners();

      return false;
    }
  }

  /// Register a new user
  Future<bool> register(String name, String email, String password) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      // TODO: Replace with actual API call
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Create mock user and token
      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, token);
      await prefs.setString(
        AppConstants.userDataKey,
        jsonEncode(user.toJson()),
      );

      // Update state
      _user = user;
      _token = token;
      _status = AuthStatus.authenticated;
      notifyListeners();

      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Registration failed: ${e.toString()}';
      notifyListeners();

      return false;
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    try {
      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.userDataKey);

      // Update state
      _user = null;
      _token = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Logout failed: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      // TODO: Replace with actual API call
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // For demo purposes, always return success
      return true;
    } catch (e) {
      _errorMessage = 'Password reset failed: ${e.toString()}';
      notifyListeners();

      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      if (_user == null) {
        _errorMessage = 'No user is logged in';
        notifyListeners();

        return false;
      }

      // TODO: Replace with actual API call
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Update user
      final updatedUser = _user!.copyWith(
        name: name,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
      );

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.userDataKey,
        jsonEncode(updatedUser.toJson()),
      );

      // Update state
      _user = updatedUser;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Profile update failed: ${e.toString()}';
      notifyListeners();

      return false;
    }
  }

  /// Add a venue to favorites
  Future<bool> addFavoriteVenue(String venueId) async {
    try {
      if (_user == null) {
        _errorMessage = 'No user is logged in';
        notifyListeners();

        return false;
      }

      // Check if already in favorites
      if (_user!.favoriteVenues.contains(venueId)) {
        return true;
      }

      // Add to favorites
      final updatedFavorites = List<String>.from(_user!.favoriteVenues)
        ..add(venueId);
      final updatedUser = _user!.copyWith(favoriteVenues: updatedFavorites);

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.userDataKey,
        jsonEncode(updatedUser.toJson()),
      );

      // Update state
      _user = updatedUser;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to add favorite: ${e.toString()}';
      notifyListeners();

      return false;
    }
  }

  /// Remove a venue from favorites
  Future<bool> removeFavoriteVenue(String venueId) async {
    try {
      if (_user == null) {
        _errorMessage = 'No user is logged in';
        notifyListeners();

        return false;
      }

      // Remove from favorites
      final updatedFavorites = List<String>.from(_user!.favoriteVenues)
        ..removeWhere((id) => id == venueId);
      final updatedUser = _user!.copyWith(favoriteVenues: updatedFavorites);

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.userDataKey,
        jsonEncode(updatedUser.toJson()),
      );

      // Update state
      _user = updatedUser;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to remove favorite: ${e.toString()}';
      notifyListeners();

      return false;
    }
  }

  /// Add a service to favorites
  Future<bool> addFavoriteService(String serviceId) async {
    try {
      if (_user == null) {
        _errorMessage = 'No user is logged in';
        notifyListeners();

        return false;
      }

      // Check if already in favorites
      if (_user!.favoriteServices.contains(serviceId)) {
        return true;
      }

      // Add to favorites
      final updatedFavorites = List<String>.from(_user!.favoriteServices)
        ..add(serviceId);
      final updatedUser = _user!.copyWith(favoriteServices: updatedFavorites);

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.userDataKey,
        jsonEncode(updatedUser.toJson()),
      );

      // Update state
      _user = updatedUser;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to add favorite: ${e.toString()}';
      notifyListeners();

      return false;
    }
  }

  /// Remove a service from favorites
  Future<bool> removeFavoriteService(String serviceId) async {
    try {
      if (_user == null) {
        _errorMessage = 'No user is logged in';
        notifyListeners();

        return false;
      }

      // Remove from favorites
      final updatedFavorites = List<String>.from(_user!.favoriteServices)
        ..removeWhere((id) => id == serviceId);
      final updatedUser = _user!.copyWith(favoriteServices: updatedFavorites);

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.userDataKey,
        jsonEncode(updatedUser.toJson()),
      );

      // Update state
      _user = updatedUser;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to remove favorite: ${e.toString()}';
      notifyListeners();

      return false;
    }
  }
}
