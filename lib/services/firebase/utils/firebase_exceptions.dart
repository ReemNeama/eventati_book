import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';

/// Base class for all Firebase exceptions
abstract class FirebaseServiceException implements Exception {
  /// Error message
  final String message;

  /// Original exception
  final dynamic originalException;

  /// Stack trace
  final StackTrace? stackTrace;

  /// Constructor
  FirebaseServiceException(
    this.message, {
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// Exception for Firebase Authentication errors
class FirebaseAuthException extends FirebaseServiceException {
  /// Authentication method that caused the error
  final String method;

  /// User ID if available
  final String? userId;

  /// Constructor
  FirebaseAuthException(
    super.message, {
    required this.method,
    this.userId,
    super.originalException,
    super.stackTrace,
  });

  /// Create from a Firebase Auth exception
  factory FirebaseAuthException.fromFirebaseException(
    firebase_auth.FirebaseAuthException exception, {
    required String method,
    String? userId,
    StackTrace? stackTrace,
  }) {
    final message = _mapFirebaseAuthErrorToMessage(exception.code);
    return FirebaseAuthException(
      message,
      method: method,
      userId: userId,
      originalException: exception,
      stackTrace: stackTrace,
    );
  }

  /// Map Firebase Auth error code to user-friendly message
  static String _mapFirebaseAuthErrorToMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email address is already in use by another account.';
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many unsuccessful login attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email address but different sign-in credentials.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please log in again.';
      default:
        return 'Authentication error: $code';
    }
  }
}

/// Exception for Firestore database errors
class FirestoreException extends FirebaseServiceException {
  /// Database operation that caused the error
  final String operation;

  /// Collection name
  final String collection;

  /// Document ID if available
  final String? documentId;

  /// Constructor
  FirestoreException(
    super.message, {
    required this.operation,
    required this.collection,
    this.documentId,
    super.originalException,
    super.stackTrace,
  });

  /// Create from a Firestore exception
  factory FirestoreException.fromFirebaseException(
    FirebaseException exception, {
    required String operation,
    required String collection,
    String? documentId,
    StackTrace? stackTrace,
  }) {
    final message = _mapFirestoreErrorToMessage(exception.code);
    return FirestoreException(
      message,
      operation: operation,
      collection: collection,
      documentId: documentId,
      originalException: exception,
      stackTrace: stackTrace,
    );
  }

  /// Map Firestore error code to user-friendly message
  static String _mapFirestoreErrorToMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'You do not have permission to access this data.';
      case 'not-found':
        return 'The requested document was not found.';
      case 'already-exists':
        return 'The document already exists.';
      case 'failed-precondition':
        return 'Operation failed due to a precondition failure.';
      case 'aborted':
        return 'The operation was aborted.';
      case 'out-of-range':
        return 'The operation was attempted past the valid range.';
      case 'unavailable':
        return 'The service is currently unavailable. Please try again later.';
      case 'data-loss':
        return 'Unrecoverable data loss or corruption.';
      case 'unauthenticated':
        return 'You must be logged in to perform this operation.';
      case 'resource-exhausted':
        return 'Resource quota exceeded or rate limit reached.';
      case 'cancelled':
        return 'The operation was cancelled.';
      case 'unknown':
        return 'An unknown error occurred.';
      case 'deadline-exceeded':
        return 'The operation timed out.';
      case 'internal':
        return 'An internal error occurred.';
      default:
        return 'Database error: $code';
    }
  }
}

/// Exception for Firebase Storage errors
class FirebaseStorageException extends FirebaseServiceException {
  /// Storage operation that caused the error
  final String operation;

  /// Storage path
  final String path;

  /// Constructor
  FirebaseStorageException(
    super.message, {
    required this.operation,
    required this.path,
    super.originalException,
    super.stackTrace,
  });

  /// Create from a Firebase Storage exception
  factory FirebaseStorageException.fromFirebaseException(
    FirebaseException exception, {
    required String operation,
    required String path,
    StackTrace? stackTrace,
  }) {
    final message = _mapStorageErrorToMessage(exception.code);
    return FirebaseStorageException(
      message,
      operation: operation,
      path: path,
      originalException: exception,
      stackTrace: stackTrace,
    );
  }

  /// Map Storage error code to user-friendly message
  static String _mapStorageErrorToMessage(String code) {
    switch (code) {
      case 'storage/object-not-found':
        return 'The file does not exist.';
      case 'storage/unauthorized':
        return 'You do not have permission to access this file.';
      case 'storage/canceled':
        return 'The operation was cancelled.';
      case 'storage/unknown':
        return 'An unknown error occurred.';
      case 'storage/invalid-checksum':
        return 'The file on the client does not match the checksum of the file received by the server.';
      case 'storage/retry-limit-exceeded':
        return 'The maximum time limit on an operation was exceeded.';
      case 'storage/invalid-event-name':
        return 'Invalid event name provided.';
      case 'storage/invalid-url':
        return 'Invalid URL provided.';
      case 'storage/invalid-argument':
        return 'Invalid argument provided.';
      case 'storage/no-default-bucket':
        return 'No default bucket found.';
      case 'storage/cannot-slice-blob':
        return 'Cannot slice blob.';
      case 'storage/server-file-wrong-size':
        return 'Server recorded incorrect upload file size.';
      default:
        return 'Storage error: $code';
    }
  }
}

/// Exception for network connectivity issues
class NetworkConnectivityException extends FirebaseServiceException {
  /// Constructor
  NetworkConnectivityException(
    super.message, {
    super.originalException,
    super.stackTrace,
  });
}

/// Exception for offline operations
class OfflineOperationException extends FirebaseServiceException {
  /// Operation that was attempted while offline
  final String operation;

  /// Constructor
  OfflineOperationException(
    super.message, {
    required this.operation,
    super.originalException,
    super.stackTrace,
  });
}
