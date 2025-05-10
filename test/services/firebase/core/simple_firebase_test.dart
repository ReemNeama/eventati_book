import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:eventati_book/services/firebase/core/firebase_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Mock classes
class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockUser extends Mock implements firebase_auth.User {}

class MockUserInfo extends Mock implements firebase_auth.UserInfo {}

class MockUserMetadata extends Mock implements firebase_auth.UserMetadata {}

void main() {
  late FirebaseAuthService authService;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockUser mockUser;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockGoogleSignIn = MockGoogleSignIn();
    mockUser = MockUser();

    // Register fallback values
    registerFallbackValue({});

    // Setup basic mocks
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('test-user-id');
    when(() => mockUser.displayName).thenReturn('Test User');
    when(() => mockUser.email).thenReturn('test@example.com');

    // Mock provider data
    final mockProviderData = [MockUserInfo()];
    when(() => mockUser.providerData).thenReturn(mockProviderData);
    when(() => mockProviderData[0].providerId).thenReturn('google.com');

    // Mock metadata
    final mockUserMetadata = MockUserMetadata();
    when(() => mockUser.metadata).thenReturn(mockUserMetadata);
    when(() => mockUserMetadata.creationTime).thenReturn(DateTime.now());

    // Mock other properties
    when(() => mockUser.emailVerified).thenReturn(true);
    when(() => mockUser.phoneNumber).thenReturn(null);
    when(() => mockUser.photoURL).thenReturn('https://example.com/photo.jpg');

    // Create service
    authService = FirebaseAuthService(
      firebaseAuth: mockAuth,
      firestore: mockFirestore,
      googleSignIn: mockGoogleSignIn,
    );
  });

  test('currentUser returns user when signed in', () {
    // Act
    final user = authService.currentUser;

    // Assert
    expect(user, isNotNull);
    expect(user!.id, equals('test-user-id'));
    expect(user.name, equals('Test User'));
    expect(user.email, equals('test@example.com'));
  });

  test('isSignedIn returns true when user is signed in', () {
    // Act
    final result = authService.isSignedIn;

    // Assert
    expect(result, isTrue);
  });

  test('isSignedIn returns false when user is not signed in', () {
    // Arrange
    when(() => mockAuth.currentUser).thenReturn(null);

    // Act
    final result = authService.isSignedIn;

    // Assert
    expect(result, isFalse);
  });
}
