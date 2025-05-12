import 'package:eventati_book/models/models.dart';

/// Result of an authentication operation
class AuthResult {
  /// Whether the operation was successful
  final bool isSuccess;

  /// Error message if the operation failed
  final String? errorMessage;

  /// User object if the operation was successful
  final User? user;

  /// Whether email verification is required
  final bool requiresEmailVerification;

  /// Constructor
  AuthResult({
    required this.isSuccess,
    this.errorMessage,
    this.user,
    this.requiresEmailVerification = false,
  });

  /// Create a successful result with a user
  factory AuthResult.success(User? user) {
    return AuthResult(
      isSuccess: true,
      user: user,
      requiresEmailVerification:
          user != null
              ? (!user.emailVerified && user.authProvider == 'email')
              : false,
    );
  }

  /// Create a failed result with an error message
  factory AuthResult.failure(String errorMessage) {
    return AuthResult(isSuccess: false, errorMessage: errorMessage);
  }
}

/// Interface for authentication services
abstract class AuthServiceInterface {
  /// Get the current authenticated user
  User? get currentUser;

  /// Get the current user ID
  String? get currentUserId;

  /// Check if a user is signed in
  bool get isSignedIn;

  /// Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword(String email, String password);

  /// Create a new user with email and password
  Future<AuthResult> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
  );

  /// Sign in with Google
  Future<AuthResult> signInWithGoogle();

  /// Sign in with Apple
  Future<AuthResult> signInWithApple();

  /// Sign out the current user
  Future<void> signOut();

  /// Send a password reset email
  Future<AuthResult> sendPasswordResetEmail(String email);

  /// Verify a password reset code
  Future<AuthResult> verifyPasswordResetCode(String code);

  /// Confirm a password reset with a code and new password
  Future<AuthResult> confirmPasswordReset(String code, String newPassword);

  /// Verify a user's email
  Future<AuthResult> verifyEmail();

  /// Update a user's profile
  Future<AuthResult> updateProfile({String? displayName, String? photoUrl});

  /// Delete the current user
  Future<AuthResult> deleteUser();

  /// Get a stream of authentication state changes
  Stream<User?> get authStateChanges;

  /// Get a stream of user changes
  Stream<User?> get userChanges;

  /// Reload the current user to get the latest data
  Future<void> reloadUser();
}
