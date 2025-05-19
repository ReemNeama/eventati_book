import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/interfaces/auth_service_interface.dart';
import 'package:eventati_book/services/supabase/database/user_database_service.dart';
import 'package:eventati_book/services/auth/biometric/biometric_auth_service.dart';
import 'package:eventati_book/di/service_locator.dart';

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
  /// Authentication service
  final AuthServiceInterface _authService = serviceLocator.authService;

  /// Biometric authentication service
  final BiometricAuthService _biometricAuthService =
      serviceLocator.biometricAuthService;

  /// User database service
  final UserDatabaseService _userDatabaseService =
      serviceLocator.userDatabaseService;

  /// Current authentication status
  AuthStatus _status = AuthStatus.unauthenticated;

  /// Current user
  User? _user;

  /// Error message if authentication fails
  String? _errorMessage;

  /// Stream subscription for auth state changes
  StreamSubscription<User?>? _authStateSubscription;

  /// Get current authentication status
  AuthStatus get status => _status;

  /// Get current user
  User? get user => _user;

  /// Get current user (alias for user)
  User? get currentUser => _user;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Check if user is authenticated
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Check if the current user's email is verified
  bool get isEmailVerified => _user?.emailVerified ?? false;

  /// Constructor
  AuthProvider() {
    _initAuthStateListener();
  }

  /// Initialize auth state listener
  void _initAuthStateListener() {
    _authStateSubscription = _authService.authStateChanges.listen((user) {
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
      } else {
        _user = null;
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  /// Initialize the provider
  Future<void> initialize() async {
    try {
      // Check if user is already signed in
      final user = _authService.currentUser;
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Failed to initialize authentication: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Login with email and password
  Future<AuthResult> login(String email, String password) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      final result = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (result.isSuccess) {
        _user = result.user;
        _status = AuthStatus.authenticated;
        notifyListeners();

        // Check if email is verified for non-social auth users
        if (_user != null &&
            !_user!.emailVerified &&
            _user!.authProvider == 'email') {
          return AuthResult(
            isSuccess: true,
            user: _user,
            requiresEmailVerification: true,
          );
        }

        return AuthResult(
          isSuccess: true,
          user: _user,
          requiresEmailVerification: false,
        );
      } else {
        _status = AuthStatus.error;
        _errorMessage = result.errorMessage ?? 'Login failed';
        notifyListeners();
        return AuthResult(isSuccess: false, errorMessage: _errorMessage);
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Login failed: ${e.toString()}';
      notifyListeners();
      return AuthResult(isSuccess: false, errorMessage: _errorMessage);
    }
  }

  /// Login with Google
  Future<AuthResult> loginWithGoogle() async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      final result = await _authService.signInWithGoogle();

      if (result.isSuccess) {
        _user = result.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return result;
      } else {
        _status = AuthStatus.error;
        _errorMessage = result.errorMessage ?? 'Google login failed';
        notifyListeners();
        return result;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Google login failed: ${e.toString()}';
      notifyListeners();
      return AuthResult.failure(_errorMessage!);
    }
  }

  /// Register a new user
  Future<AuthResult> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      final result = await _authService.createUserWithEmailAndPassword(
        email,
        password,
        name,
      );

      if (result.isSuccess) {
        _user = result.user;
        _status = AuthStatus.authenticated;
        notifyListeners();

        // Email verification is always required for new email/password users
        return AuthResult(
          isSuccess: true,
          user: _user,
          requiresEmailVerification: true,
        );
      } else {
        _status = AuthStatus.error;
        _errorMessage = result.errorMessage ?? 'Registration failed';
        notifyListeners();
        return AuthResult.failure(_errorMessage!);
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Registration failed: ${e.toString()}';
      notifyListeners();
      return AuthResult.failure(_errorMessage!);
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    try {
      await _authService.signOut();
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Logout failed: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    return await _biometricAuthService.isBiometricAvailable();
  }

  /// Get available biometric types
  Future<List<dynamic>> getAvailableBiometrics() async {
    return await _biometricAuthService.getAvailableBiometrics();
  }

  /// Authenticate with biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      // Check if biometric authentication is enabled
      final isBiometricEnabled =
          await _biometricAuthService.isBiometricEnabled();
      if (!isBiometricEnabled) {
        return false;
      }

      // Check if credentials are saved
      final hasCredentials = await _biometricAuthService.hasCredentials();
      if (!hasCredentials) {
        return false;
      }

      // Authenticate with biometrics
      final isAuthenticated = await _biometricAuthService.authenticate(
        localizedReason: 'Authenticate to sign in to Eventati Book',
      );

      if (isAuthenticated) {
        // Get saved credentials
        final credentials = await _biometricAuthService.getCredentials();
        final email = credentials['email'];
        final password = credentials['password'];

        if (email != null && password != null) {
          // Login with saved credentials
          final result = await login(email, password);
          return result.isSuccess;
        }
      }

      return false;
    } catch (e) {
      _errorMessage = 'Biometric authentication failed: ${e.toString()}';
      return false;
    }
  }

  /// Enable biometric authentication
  Future<bool> enableBiometricAuthentication(
    String email,
    String password,
  ) async {
    try {
      // Check if biometric authentication is available
      final isBiometricAvailable =
          await _biometricAuthService.isBiometricAvailable();
      if (!isBiometricAvailable) {
        _errorMessage =
            'Biometric authentication is not available on this device';
        return false;
      }

      // Save credentials
      final credentialsSaved = await _biometricAuthService.saveCredentials(
        email,
        password,
      );
      if (!credentialsSaved) {
        _errorMessage =
            'Failed to save credentials for biometric authentication';
        return false;
      }

      // Enable biometric authentication
      return await _biometricAuthService.setBiometricEnabled(true);
    } catch (e) {
      _errorMessage =
          'Failed to enable biometric authentication: ${e.toString()}';
      return false;
    }
  }

  /// Disable biometric authentication
  Future<bool> disableBiometricAuthentication() async {
    try {
      // Delete saved credentials
      await _biometricAuthService.deleteCredentials();

      // Disable biometric authentication
      return await _biometricAuthService.setBiometricEnabled(false);
    } catch (e) {
      _errorMessage =
          'Failed to disable biometric authentication: ${e.toString()}';
      return false;
    }
  }

  /// Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    return await _biometricAuthService.isBiometricEnabled();
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      final result = await _authService.sendPasswordResetEmail(email);
      if (!result.isSuccess) {
        _errorMessage = result.errorMessage;
        notifyListeners();
      }
      return result.isSuccess;
    } catch (e) {
      _errorMessage = 'Password reset failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Verify password reset code
  Future<bool> verifyPasswordResetCode(String code) async {
    try {
      final result = await _authService.verifyPasswordResetCode(code);
      if (!result.isSuccess) {
        _errorMessage = result.errorMessage;
        notifyListeners();
      }
      return result.isSuccess;
    } catch (e) {
      _errorMessage = 'Verification failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Confirm password reset
  Future<bool> confirmPasswordReset(String code, String newPassword) async {
    try {
      final result = await _authService.confirmPasswordReset(code, newPassword);
      if (!result.isSuccess) {
        _errorMessage = result.errorMessage;
        notifyListeners();
      }
      return result.isSuccess;
    } catch (e) {
      _errorMessage = 'Password reset failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Change password for authenticated user
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      if (_user == null) {
        _errorMessage = 'No user is logged in';
        notifyListeners();
        return false;
      }

      final result = await _authService.changePassword(
        currentPassword,
        newPassword,
      );

      if (!result.isSuccess) {
        _errorMessage = result.errorMessage;
        notifyListeners();
      }
      return result.isSuccess;
    } catch (e) {
      _errorMessage = 'Password change failed: ${e.toString()}';
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

      final result = await _authService.updateProfile(
        displayName: name,
        photoUrl: profileImageUrl,
      );

      if (result.isSuccess) {
        _user = result.user;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.errorMessage;
        notifyListeners();
        return false;
      }
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

      // Add to favorites in database
      await _userDatabaseService.addFavoriteVenue(_user!.id, venueId);

      // Update local state
      final updatedFavorites = List<String>.from(_user!.favoriteVenues)
        ..add(venueId);
      final updatedUser = _user!.copyWith(favoriteVenues: updatedFavorites);
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

      // Remove from favorites in database
      await _userDatabaseService.removeFavoriteVenue(_user!.id, venueId);

      // Update local state
      final updatedFavorites = List<String>.from(_user!.favoriteVenues)
        ..removeWhere((id) => id == venueId);
      final updatedUser = _user!.copyWith(favoriteVenues: updatedFavorites);
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

      // Add to favorites in database
      await _userDatabaseService.addFavoriteService(_user!.id, serviceId);

      // Update local state
      final updatedFavorites = List<String>.from(_user!.favoriteServices)
        ..add(serviceId);
      final updatedUser = _user!.copyWith(favoriteServices: updatedFavorites);
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

      // Remove from favorites in database
      await _userDatabaseService.removeFavoriteService(_user!.id, serviceId);

      // Update local state
      final updatedFavorites = List<String>.from(_user!.favoriteServices)
        ..removeWhere((id) => id == serviceId);
      final updatedUser = _user!.copyWith(favoriteServices: updatedFavorites);
      _user = updatedUser;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to remove favorite: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Send email verification to the current user
  Future<bool> verifyEmail() async {
    try {
      final result = await _authService.verifyEmail();
      if (!result.isSuccess) {
        _errorMessage = result.errorMessage;
        notifyListeners();
      }
      return result.isSuccess;
    } catch (e) {
      _errorMessage = 'Email verification failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Reload the current user to get the latest data
  Future<void> reloadUser() async {
    try {
      await _authService.reloadUser();
      final user = _authService.currentUser;
      if (user != null) {
        _user = user;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to reload user: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Dispose of resources
  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
