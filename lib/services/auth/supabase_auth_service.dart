import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/interfaces/auth_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';

/// Implementation of AuthServiceInterface using Supabase Authentication
class SupabaseAuthService implements AuthServiceInterface {
  final SupabaseClient _supabaseClient;

  SupabaseAuthService({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  User? get currentUser {
    final supabaseUser = _supabaseClient.auth.currentUser;
    if (supabaseUser == null) return null;
    return _mapSupabaseUserToUser(supabaseUser);
  }

  @override
  String? get currentUserId => _supabaseClient.auth.currentUser?.id;

  @override
  bool get isSignedIn => _supabaseClient.auth.currentUser != null;

  @override
  Future<AuthResult> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        return AuthResult(isSuccess: false, errorMessage: 'Unknown error');
      }

      // Get additional user data from Supabase
      final userData = await _getUserDataFromSupabase(user.id);
      final appUser = _mapSupabaseUserToUser(user, userData);

      return AuthResult.success(appUser);
    } on AuthException catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: _mapSupabaseAuthError(e.message),
      );
    } catch (e) {
      Logger.e(
        'Error signing in with email and password: $e',
        tag: 'SupabaseAuthService',
      );
      return AuthResult(isSuccess: false, errorMessage: 'Unknown error');
    }
  }

  @override
  Future<AuthResult> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      final user = response.user;
      if (user == null) {
        return AuthResult(isSuccess: false, errorMessage: 'Unknown error');
      }

      // Create user data in Supabase
      final userData = {
        'id': user.id,
        'name': name,
        'email': email,
        'created_at': DateTime.now().toIso8601String(),
        'last_login_at': DateTime.now().toIso8601String(),
        'email_verified': user.emailConfirmedAt != null,
        'auth_provider': 'email',
      };

      await _supabaseClient.from('users').upsert(userData);

      final appUser = _mapSupabaseUserToUser(user, userData);
      return AuthResult.success(appUser);
    } on AuthException catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: _mapSupabaseAuthError(e.message),
      );
    } catch (e) {
      Logger.e(
        'Error creating user with email and password: $e',
        tag: 'SupabaseAuthService',
      );
      return AuthResult(isSuccess: false, errorMessage: 'Unknown error');
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.eventati://login-callback/',
      );

      // Note: This is handled asynchronously through deep links
      // The actual user will be available through authStateChanges
      return AuthResult(isSuccess: true);
    } catch (e) {
      Logger.e('Error signing in with Google: $e', tag: 'SupabaseAuthService');
      return AuthResult(
        isSuccess: false,
        errorMessage: 'Failed to sign in with Google',
      );
    }
  }

  @override
  Future<AuthResult> signInWithApple() async {
    try {
      await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.eventati://login-callback/',
      );

      // Note: This is handled asynchronously through deep links
      // The actual user will be available through authStateChanges
      return AuthResult(isSuccess: true);
    } catch (e) {
      Logger.e('Error signing in with Apple: $e', tag: 'SupabaseAuthService');
      return AuthResult(
        isSuccess: false,
        errorMessage: 'Failed to sign in with Apple',
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  @override
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
      return AuthResult(isSuccess: true);
    } on AuthException catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: _mapSupabaseAuthError(e.message),
      );
    } catch (e) {
      Logger.e(
        'Error sending password reset email: $e',
        tag: 'SupabaseAuthService',
      );
      return AuthResult(isSuccess: false, errorMessage: 'Unknown error');
    }
  }

  @override
  Future<AuthResult> verifyPasswordResetCode(String code) async {
    // Supabase handles this differently - verification is done when confirming the reset
    return AuthResult(isSuccess: true);
  }

  @override
  Future<AuthResult> confirmPasswordReset(
    String code,
    String newPassword,
  ) async {
    try {
      // In Supabase, this is typically handled through a deep link and updateUser
      final response = await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        return AuthResult(
          isSuccess: false,
          errorMessage: 'Failed to reset password',
        );
      }

      return AuthResult(isSuccess: true);
    } on AuthException catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: _mapSupabaseAuthError(e.message),
      );
    } catch (e) {
      Logger.e(
        'Error confirming password reset: $e',
        tag: 'SupabaseAuthService',
      );
      return AuthResult(isSuccess: false, errorMessage: 'Unknown error');
    }
  }

  @override
  Future<AuthResult> verifyEmail() async {
    // Supabase handles email verification through a link sent to the user's email
    // This method is a placeholder for compatibility
    return AuthResult(isSuccess: true);
  }

  @override
  Future<AuthResult> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        return AuthResult(isSuccess: false, errorMessage: 'User not found');
      }

      // Update Supabase Auth user metadata
      final userAttributes = UserAttributes(
        data: {
          if (displayName != null) 'name': displayName,
          if (photoUrl != null) 'avatar_url': photoUrl,
        },
      );

      final response = await _supabaseClient.auth.updateUser(userAttributes);

      if (response.user == null) {
        return AuthResult(
          isSuccess: false,
          errorMessage: 'Failed to update profile',
        );
      }

      // Update user profile in database
      final updates = <String, dynamic>{};
      if (displayName != null) updates['name'] = displayName;
      if (photoUrl != null) updates['profile_image_url'] = photoUrl;

      if (updates.isNotEmpty) {
        await _supabaseClient.from('users').update(updates).eq('id', user.id);
      }

      final userData = await _getUserDataFromSupabase(user.id);
      final appUser = _mapSupabaseUserToUser(response.user!, userData);
      return AuthResult.success(appUser);
    } on AuthException catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: _mapSupabaseAuthError(e.message),
      );
    } catch (e) {
      Logger.e('Error updating profile: $e', tag: 'SupabaseAuthService');
      return AuthResult(isSuccess: false, errorMessage: 'Unknown error');
    }
  }

  @override
  Future<AuthResult> deleteUser() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        return AuthResult(isSuccess: false, errorMessage: 'User not found');
      }

      // Delete user data from database
      await _supabaseClient.from('users').delete().eq('id', user.id);

      // Note: Deleting a user from Supabase Auth requires admin privileges
      // For client-side, we can sign out instead
      await _supabaseClient.auth.signOut();

      return AuthResult(isSuccess: true);
    } on AuthException catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: _mapSupabaseAuthError(e.message),
      );
    } catch (e) {
      Logger.e('Error deleting user: $e', tag: 'SupabaseAuthService');
      return AuthResult(isSuccess: false, errorMessage: 'Unknown error');
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return _supabaseClient.auth.onAuthStateChange.asyncMap((authState) async {
      final supabaseUser = authState.session?.user;
      if (supabaseUser == null) return null;
      final userData = await _getUserDataFromSupabase(supabaseUser.id);
      return _mapSupabaseUserToUser(supabaseUser, userData);
    });
  }

  @override
  Stream<User?> get userChanges {
    // Supabase doesn't have a direct equivalent to userChanges()
    // We can use the same stream as authStateChanges for now
    return authStateChanges;
  }

  @override
  Future<void> reloadUser() async {
    // Supabase doesn't have a direct equivalent to reloadUser()
    // The session is automatically refreshed
  }

  Future<Map<String, dynamic>?> _getUserDataFromSupabase(String userId) async {
    try {
      final response =
          await _supabaseClient
              .from('users')
              .select()
              .eq('id', userId)
              .single();
      return response;
    } catch (e) {
      Logger.e(
        'Error getting user data from Supabase: $e',
        tag: 'SupabaseAuthService',
      );
      return null;
    }
  }

  User _mapSupabaseUserToUser(
    dynamic supabaseUser, [
    Map<String, dynamic>? userData,
  ]) {
    // Determine auth provider
    String authProvider = 'email';
    if (userData != null && userData.containsKey('auth_provider')) {
      authProvider = userData['auth_provider'];
    } else if (supabaseUser.email?.contains('google') ?? false) {
      authProvider = 'google';
    } else if (supabaseUser.email?.contains('apple') ?? false) {
      authProvider = 'apple';
    }

    return User(
      id: supabaseUser.id,
      name:
          userData?['name'] ??
          supabaseUser.userMetadata?['name'] ??
          supabaseUser.email?.split('@')[0] ??
          'User',
      email: supabaseUser.email ?? '',
      phoneNumber: userData?['phone_number'] ?? supabaseUser.phone,
      profileImageUrl:
          userData?['profile_image_url'] ??
          supabaseUser.userMetadata?['avatar_url'],
      createdAt:
          userData?['created_at'] != null
              ? DateTime.parse(userData!['created_at'])
              : DateTime.now(),
      favoriteVenues:
          userData?['favorite_venues'] != null
              ? List<String>.from(userData!['favorite_venues'])
              : [],
      favoriteServices:
          userData?['favorite_services'] != null
              ? List<String>.from(userData!['favorite_services'])
              : [],
      hasPremiumSubscription: userData?['has_premium_subscription'] ?? false,
      isBetaTester: userData?['is_beta_tester'] ?? false,
      emailVerified:
          userData?['email_verified'] ?? supabaseUser.emailConfirmedAt != null,
      authProvider: authProvider,
    );
  }

  String _mapSupabaseAuthError(String errorMessage) {
    // Supabase error messages are more descriptive and less standardized
    if (errorMessage.contains('User not found') ||
        errorMessage.contains('No user found')) {
      return 'User not found';
    } else if (errorMessage.contains('Invalid login credentials') ||
        errorMessage.contains('Invalid password')) {
      return 'Invalid password';
    } else if (errorMessage.contains('Invalid email')) {
      return 'Invalid email';
    } else if (errorMessage.contains('User is disabled')) {
      return 'User is disabled';
    } else if (errorMessage.contains('already registered')) {
      return 'Email already in use';
    } else if (errorMessage.contains('not allowed')) {
      return 'Operation not allowed';
    } else if (errorMessage.contains('Password should be')) {
      return 'Weak password';
    } else if (errorMessage.contains('recent login')) {
      return 'Requires recent login';
    } else {
      return 'Unknown error';
    }
  }
}
