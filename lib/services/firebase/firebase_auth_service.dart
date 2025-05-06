import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/interfaces/auth_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';

/// Implementation of AuthServiceInterface using Firebase Authentication
class FirebaseAuthService implements AuthServiceInterface {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  /// Constructor
  FirebaseAuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  User? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    return _mapFirebaseUserToUser(firebaseUser);
  }

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  @override
  Future<AuthResult> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return AuthResult.failure('Sign in failed: No user returned');
      }

      // Get additional user data from Firestore
      final userData = await _getUserDataFromFirestore(user.uid);
      final appUser = _mapFirebaseUserToUser(user, userData);

      return AuthResult.success(appUser);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseAuthError(e.code));
    } catch (e) {
      return AuthResult.failure('Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return AuthResult.failure('Registration failed: No user returned');
      }

      // Update display name
      await user.updateDisplayName(name);

      // Create user document in Firestore
      final userData = {
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'favoriteVenues': <String>[],
        'favoriteServices': <String>[],
        'role': 'user',
        'hasPremiumSubscription': false,
        'isBetaTester': false,
      };

      await _firestore.collection('users').doc(user.uid).set(userData);

      // Get the updated user
      await user.reload();
      final updatedUser = _firebaseAuth.currentUser;
      if (updatedUser == null) {
        return AuthResult.failure(
          'Registration failed: User not found after creation',
        );
      }

      final appUser = _mapFirebaseUserToUser(updatedUser, userData);
      return AuthResult.success(appUser);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseAuthError(e.code));
    } catch (e) {
      return AuthResult.failure('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return AuthResult(isSuccess: true);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseAuthError(e.code));
    } catch (e) {
      return AuthResult.failure('Password reset failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> verifyEmail() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user is signed in');
      }

      await user.sendEmailVerification();
      return AuthResult(isSuccess: true);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseAuthError(e.code));
    } catch (e) {
      return AuthResult.failure('Email verification failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user is signed in');
      }

      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoUrl);

      // Update Firestore user document
      final updates = <String, dynamic>{};
      if (displayName != null) updates['name'] = displayName;
      if (photoUrl != null) updates['profileImageUrl'] = photoUrl;

      await _firestore.collection('users').doc(user.uid).update(updates);

      // Get the updated user
      await user.reload();
      final updatedUser = _firebaseAuth.currentUser;
      if (updatedUser == null) {
        return AuthResult.failure(
          'Profile update failed: User not found after update',
        );
      }

      final userData = await _getUserDataFromFirestore(updatedUser.uid);
      final appUser = _mapFirebaseUserToUser(updatedUser, userData);
      return AuthResult.success(appUser);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseAuthError(e.code));
    } catch (e) {
      return AuthResult.failure('Profile update failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> deleteUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user is signed in');
      }

      // Delete user document from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Auth user
      await user.delete();

      return AuthResult(isSuccess: true);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseAuthError(e.code));
    } catch (e) {
      return AuthResult.failure('Account deletion failed: ${e.toString()}');
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      final userData = await _getUserDataFromFirestore(firebaseUser.uid);
      return _mapFirebaseUserToUser(firebaseUser, userData);
    });
  }

  @override
  Stream<User?> get userChanges {
    return _firebaseAuth.userChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      final userData = await _getUserDataFromFirestore(firebaseUser.uid);
      return _mapFirebaseUserToUser(firebaseUser, userData);
    });
  }

  // Helper methods
  Future<Map<String, dynamic>?> _getUserDataFromFirestore(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();
      return docSnapshot.data();
    } catch (e) {
      Logger.e(
        'Error getting user data from Firestore: $e',
        tag: 'FirebaseAuthService',
      );
      return null;
    }
  }

  User _mapFirebaseUserToUser(
    firebase_auth.User firebaseUser, [
    Map<String, dynamic>? userData,
  ]) {
    return User(
      id: firebaseUser.uid,
      name: userData?['name'] ?? firebaseUser.displayName ?? 'User',
      email: firebaseUser.email ?? '',
      phoneNumber: userData?['phoneNumber'] ?? firebaseUser.phoneNumber,
      profileImageUrl: userData?['profileImageUrl'] ?? firebaseUser.photoURL,
      createdAt:
          userData?['createdAt'] != null
              ? (userData!['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      favoriteVenues:
          userData?['favoriteVenues'] != null
              ? List<String>.from(userData!['favoriteVenues'])
              : [],
      favoriteServices:
          userData?['favoriteServices'] != null
              ? List<String>.from(userData!['favoriteServices'])
              : [],
      role: userData?['role'] ?? 'user',
      hasPremiumSubscription: userData?['hasPremiumSubscription'] ?? false,
      isBetaTester: userData?['isBetaTester'] ?? false,
      subscriptionExpirationDate:
          userData?['subscriptionExpirationDate'] != null
              ? (userData!['subscriptionExpirationDate'] as Timestamp).toDate()
              : null,
    );
  }

  String _mapFirebaseAuthError(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'The password is invalid.';
      case 'email-already-in-use':
        return 'The email address is already in use.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      default:
        return 'An unknown error occurred: $errorCode';
    }
  }
}
