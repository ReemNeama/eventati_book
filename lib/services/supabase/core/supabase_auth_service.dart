import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/interfaces/auth_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

/// Implementation of AuthServiceInterface using Supabase Auth
class SupabaseAuthService implements AuthServiceInterface {
  /// Supabase client instance
  final SupabaseClient _supabase;

  /// Constructor
  SupabaseAuthService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  @override
  User? get currentUser {
    final supabaseUser = _supabase.auth.currentUser;
    if (supabaseUser == null) return null;
    return _mapSupabaseUserToUser(supabaseUser);
  }

  @override
  String? get currentUserId => _supabase.auth.currentUser?.id;

  @override
  bool get isSignedIn => _supabase.auth.currentUser != null;

  @override
  Stream<User?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((event) {
      final supabaseUser = event.session?.user;
      if (supabaseUser == null) return null;
      return _mapSupabaseUserToUser(supabaseUser);
    });
  }

  @override
  Stream<User?> get userChanges {
    return _supabase.auth.onAuthStateChange.map((event) {
      final supabaseUser = event.session?.user;
      if (supabaseUser == null) return null;
      return _mapSupabaseUserToUser(supabaseUser);
    });
  }

  @override
  Future<void> reloadUser() async {
    try {
      await _supabase.auth.refreshSession();
    } catch (e) {
      Logger.e('Error reloading user: $e', tag: 'SupabaseAuthService');
    }
  }

  @override
  Future<AuthResult> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AuthResult.failure('Failed to sign in with email and password');
      }

      return AuthResult.success(_mapSupabaseUserToUser(response.user!));
    } catch (e) {
      Logger.e('Error signing in with email: $e', tag: 'SupabaseAuthService');
      return AuthResult.failure('Error signing in: $e');
    }
  }

  @override
  Future<AuthResult> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user == null) {
        return AuthResult.failure('Failed to sign up with email and password');
      }

      // Create user profile in database
      await _createUserProfile(response.user!, name: name);

      return AuthResult.success(_mapSupabaseUserToUser(response.user!));
    } catch (e) {
      Logger.e('Error signing up with email: $e', tag: 'SupabaseAuthService');
      return AuthResult.failure('Error signing up: $e');
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.eventati://login-callback/',
      );

      if (!response) {
        return AuthResult.failure('Failed to sign in with Google');
      }

      // Note: The actual user will be available through the authStateChanges stream
      // after the OAuth flow completes
      return AuthResult.success(null);
    } catch (e) {
      Logger.e('Error signing in with Google: $e', tag: 'SupabaseAuthService');
      return AuthResult.failure('Error signing in with Google: $e');
    }
  }

  @override
  Future<AuthResult> signInWithApple() async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.eventati://login-callback/',
      );

      if (!response) {
        return AuthResult.failure('Failed to sign in with Apple');
      }

      // Note: The actual user will be available through the authStateChanges stream
      // after the OAuth flow completes
      return AuthResult.success(null);
    } catch (e) {
      Logger.e('Error signing in with Apple: $e', tag: 'SupabaseAuthService');
      return AuthResult.failure('Error signing in with Apple: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      Logger.e('Error signing out: $e', tag: 'SupabaseAuthService');
      rethrow;
    }
  }

  @override
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.eventati://reset-callback/',
      );
      return AuthResult.success(null);
    } catch (e) {
      Logger.e(
        'Error sending password reset email: $e',
        tag: 'SupabaseAuthService',
      );
      return AuthResult.failure('Error sending password reset email: $e');
    }
  }

  @override
  Future<AuthResult> verifyPasswordResetCode(String code) async {
    // Not directly applicable for Supabase - handled by the redirect flow
    return AuthResult.success(null);
  }

  @override
  Future<AuthResult> confirmPasswordReset(
    String code,
    String newPassword,
  ) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      return AuthResult.success(null);
    } catch (e) {
      Logger.e(
        'Error confirming password reset: $e',
        tag: 'SupabaseAuthService',
      );
      return AuthResult.failure('Error confirming password reset: $e');
    }
  }

  @override
  Future<AuthResult> verifyEmail() async {
    // Not directly applicable for Supabase - handled by the redirect flow
    return AuthResult.success(null);
  }

  @override
  Future<AuthResult> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            if (displayName != null) 'name': displayName,
            if (photoUrl != null) 'avatar_url': photoUrl,
          },
        ),
      );

      // Update user profile in database
      if (currentUser != null) {
        await _updateUserProfile(currentUser!.uid, {
          if (displayName != null) 'name': displayName,
          if (photoUrl != null) 'profile_image_url': photoUrl,
        });
      }

      return AuthResult.success(currentUser);
    } catch (e) {
      Logger.e('Error updating profile: $e', tag: 'SupabaseAuthService');
      return AuthResult.failure('Error updating profile: $e');
    }
  }

  @override
  Future<AuthResult> deleteUser() async {
    try {
      await _supabase.auth.admin.deleteUser(_supabase.auth.currentUser!.id);
      return AuthResult.success(null);
    } catch (e) {
      Logger.e('Error deleting user: $e', tag: 'SupabaseAuthService');
      return AuthResult.failure('Error deleting user: $e');
    }
  }

  /// Map a Supabase user to our app's User model
  User _mapSupabaseUserToUser(dynamic supabaseUser) {
    return User(
      id: supabaseUser.id,
      name:
          supabaseUser.userMetadata?['name'] as String? ??
          supabaseUser.email?.split('@')[0] ??
          'User',
      email: supabaseUser.email ?? '',
      phoneNumber: supabaseUser.phone,
      profileImageUrl: supabaseUser.userMetadata?['avatar_url'],
      createdAt:
          supabaseUser.createdAt != null
              ? DateTime.parse(supabaseUser.createdAt)
              : DateTime.now(),
      emailVerified: supabaseUser.emailConfirmedAt != null,
      authProvider: _getAuthProvider(supabaseUser),
    );
  }

  /// Get the auth provider from a Supabase user
  String _getAuthProvider(dynamic user) {
    final identities = user.identities;
    if (identities == null || identities.isEmpty) {
      return 'email';
    }

    final identity = identities.first;
    final provider = identity.provider;

    switch (provider) {
      case 'google':
        return 'google.com';
      case 'apple':
        return 'apple.com';
      default:
        return 'email';
    }
  }

  /// Create a user profile in the database
  Future<void> _createUserProfile(dynamic user, {String? name}) async {
    try {
      await _supabase.from('users').insert({
        'id': user.id,
        'name':
            name ??
            user.userMetadata?['name'] ??
            user.email?.split('@')[0] ??
            'User',
        'email': user.email ?? '',
        'profile_image_url': user.userMetadata?['avatar_url'] ?? '',
        'created_at': DateTime.now().toIso8601String(),
        'favorite_venues': [],
        'favorite_services': [],
        'has_premium_subscription': false,
        'is_beta_tester': false,
        'email_verified': user.emailConfirmedAt != null,
        'auth_provider': _getAuthProvider(user),
      });
    } catch (e) {
      Logger.e('Error creating user profile: $e', tag: 'SupabaseAuthService');
    }
  }

  /// Update a user profile in the database
  Future<void> _updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _supabase
          .from('users')
          .update({...data, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', userId);
    } catch (e) {
      Logger.e('Error updating user profile: $e', tag: 'SupabaseAuthService');
    }
  }
}
