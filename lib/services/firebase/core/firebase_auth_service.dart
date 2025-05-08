import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/interfaces/auth_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';

/// Implementation of AuthServiceInterface using Firebase Authentication
class FirebaseAuthService implements AuthServiceInterface {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  /// Constructor
  FirebaseAuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

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
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Begin interactive sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult.failure('Google sign-in was cancelled by the user');
      }

      // Obtain auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential for Firebase
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user == null) {
        return AuthResult.failure('Google sign-in failed: No user returned');
      }

      // Check if this is a new user
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        // Create user document in Firestore for new users
        final userData = {
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'profileImageUrl': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'favoriteVenues': <String>[],
          'favoriteServices': <String>[],
          'role': 'user',
          'hasPremiumSubscription': false,
          'isBetaTester': false,
          'emailVerified': user.emailVerified,
          'authProvider': 'google',
        };

        await _firestore.collection('users').doc(user.uid).set(userData);
        Logger.i(
          'Created new user document for Google user: ${user.displayName}',
          tag: 'FirebaseAuthService',
        );
      }

      // Get additional user data from Firestore
      final userData = await _getUserDataFromFirestore(user.uid);
      final appUser = _mapFirebaseUserToUser(user, userData);

      return AuthResult.success(appUser);
    } on firebase_auth.FirebaseAuthException catch (e) {
      Logger.e(
        'Firebase Auth error during Google sign-in: ${e.code}',
        tag: 'FirebaseAuthService',
      );
      return AuthResult.failure(_mapFirebaseAuthError(e.code));
    } catch (e) {
      Logger.e('Error during Google sign-in: $e', tag: 'FirebaseAuthService');
      return AuthResult.failure('Google sign-in failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in with Google
      await _googleSignIn.signOut();
      // Sign out from Firebase
      await _firebaseAuth.signOut();

      Logger.i('User signed out successfully', tag: 'FirebaseAuthService');
    } catch (e) {
      Logger.e('Error signing out: $e', tag: 'FirebaseAuthService');
      rethrow;
    }
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

  @override
  Future<void> reloadUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.reload();
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      Logger.e('Error reloading user: ${e.code}', tag: 'FirebaseAuthService');
      throw Exception(_mapFirebaseAuthError(e.code));
    } catch (e) {
      Logger.e('Error reloading user: $e', tag: 'FirebaseAuthService');
      throw Exception('Failed to reload user: ${e.toString()}');
    }
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
    return User.fromFirebaseUser(firebaseUser, userData);
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
