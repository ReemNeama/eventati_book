import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Exception for Supabase authentication errors
class SupabaseAuthException implements Exception {
  /// The error message
  final String message;

  /// The error code
  final String? code;

  /// The original error
  final dynamic originalError;

  /// Constructor
  SupabaseAuthException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'SupabaseAuthException: $message (code: $code)';
}

/// Exception for Supabase database errors
class SupabaseDatabaseException implements Exception {
  /// The error message
  final String message;

  /// The error code
  final String? code;

  /// The original error
  final dynamic originalError;

  /// Constructor
  SupabaseDatabaseException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'SupabaseDatabaseException: $message (code: $code)';
}

/// Exception for Supabase storage errors
class SupabaseStorageException implements Exception {
  /// The error message
  final String message;

  /// The error code
  final String? code;

  /// The original error
  final dynamic originalError;

  /// Constructor
  SupabaseStorageException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'SupabaseStorageException: $message (code: $code)';
}

/// Exception for Supabase network errors
class SupabaseNetworkException implements Exception {
  /// The error message
  final String message;

  /// The original error
  final dynamic originalError;

  /// Constructor
  SupabaseNetworkException(this.message, {this.originalError});

  @override
  String toString() => 'SupabaseNetworkException: $message';
}

/// Exception for Supabase timeout errors
class SupabaseTimeoutException implements Exception {
  /// The error message
  final String message;

  /// The original error
  final dynamic originalError;

  /// Constructor
  SupabaseTimeoutException(this.message, {this.originalError});

  @override
  String toString() => 'SupabaseTimeoutException: $message';
}

/// Exception for Supabase permission errors
class SupabasePermissionException implements Exception {
  /// The error message
  final String message;

  /// The original error
  final dynamic originalError;

  /// Constructor
  SupabasePermissionException(this.message, {this.originalError});

  @override
  String toString() => 'SupabasePermissionException: $message';
}

/// Utility class for handling Supabase exceptions
class SupabaseExceptions {
  /// Convert a Supabase error to a user-friendly message
  static String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return getAuthErrorMessage(error);
    } else if (error is PostgrestException) {
      return getDatabaseErrorMessage(error);
    } else if (error is StorageException) {
      return getStorageErrorMessage(error);
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Get a user-friendly message for authentication errors
  static String getAuthErrorMessage(dynamic error) {
    if (error is AuthException) {
      Logger.e('Auth error: ${error.message}', tag: 'SupabaseExceptions');

      // Handle specific auth error messages
      if (error.message.contains('Invalid login credentials')) {
        return 'Invalid email or password. Please try again.';
      } else if (error.message.contains('Email not confirmed')) {
        return 'Please verify your email before logging in.';
      } else if (error.message.contains('User already registered')) {
        return 'An account with this email already exists.';
      } else if (error.message.contains('Password should be at least')) {
        return 'Password is too short. Please use at least 6 characters.';
      } else if (error.message.contains('rate limit')) {
        return 'Too many attempts. Please try again later.';
      }

      return error.message;
    } else if (error is SupabaseAuthException) {
      return error.message;
    }

    return 'Authentication error. Please try again.';
  }

  /// Get a user-friendly message for database errors
  static String getDatabaseErrorMessage(dynamic error) {
    if (error is PostgrestException) {
      Logger.e('Database error: ${error.message}', tag: 'SupabaseExceptions');

      if (error.code == '23505') {
        return 'This record already exists.';
      } else if (error.code == '23503') {
        return 'This operation references a record that doesn\'t exist.';
      } else if (error.code == '42P01') {
        return 'The requested data could not be found.';
      } else if (error.code == '42501') {
        return 'You don\'t have permission to perform this action.';
      }

      return 'Database error: ${error.message}';
    } else if (error is SupabaseDatabaseException) {
      return error.message;
    }

    return 'Database error. Please try again.';
  }

  /// Get a user-friendly message for storage errors
  static String getStorageErrorMessage(dynamic error) {
    if (error is StorageException) {
      Logger.e('Storage error: ${error.message}', tag: 'SupabaseExceptions');

      final statusCode = int.tryParse(error.statusCode ?? '0') ?? 0;

      if (statusCode == 404) {
        return 'The requested file could not be found.';
      } else if (statusCode == 403) {
        return 'You don\'t have permission to access this file.';
      } else if (statusCode == 413) {
        return 'The file is too large to upload.';
      }

      return 'Storage error: ${error.message}';
    } else if (error is SupabaseStorageException) {
      return error.message;
    }

    return 'Storage error. Please try again.';
  }
}
