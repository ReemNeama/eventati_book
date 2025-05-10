import 'package:eventati_book/models/auth/user_model.dart';

/// Result of an authentication operation
class AuthResult {
  /// Whether the authentication was successful
  final bool isSuccess;

  /// The authenticated user, if successful
  final UserModel? user;

  /// Error message, if authentication failed
  final String? errorMessage;

  /// Creates a successful authentication result
  AuthResult.success(this.user) : isSuccess = true, errorMessage = null;

  /// Creates a failed authentication result
  AuthResult.failure(this.errorMessage) : isSuccess = false, user = null;
}
