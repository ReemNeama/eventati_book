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
  factory AuthResult.success(User user) {
    return AuthResult(
      isSuccess: true,
      user: user,
      requiresEmailVerification:
          !user.emailVerified && user.authProvider == 'email',
    );
  }

  /// Create a failed result with an error message
  factory AuthResult.failure(String errorMessage) {
    return AuthResult(isSuccess: false, errorMessage: errorMessage);
  }
}
