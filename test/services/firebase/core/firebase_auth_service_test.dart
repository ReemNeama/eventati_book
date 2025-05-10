import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:eventati_book/services/firebase/core/firebase_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Mock classes
class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}

class MockUser extends Mock implements firebase_auth.User {}

class MockUserCredential extends Mock implements firebase_auth.UserCredential {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

// Mock FirebaseAuthException
class MockFirebaseAuthException extends Mock
    implements firebase_auth.FirebaseAuthException {
  @override
  final String code;
  MockFirebaseAuthException(this.code);
}

// Mock Firestore
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

// Mock Document Reference
class MockDocumentReference<T> extends Mock {
  String id = 'mock-doc';

  // Add methods as needed for tests
  Future<void> set(T data) async => Future.value();
  Future<void> update(Map<String, dynamic> data) async => Future.value();
}

// Mock User Info and Metadata
class MockUserInfo extends Mock implements firebase_auth.UserInfo {}

class MockUserMetadata extends Mock implements firebase_auth.UserMetadata {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseAuthService authService;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;
  late MockDocumentReference<Map<String, dynamic>> mockUserDoc;

  setUp(() {
    // Create mocks
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    mockUserDoc = MockDocumentReference<Map<String, dynamic>>();

    // Setup default behaviors
    // Use a getter-style syntax for properties
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('test-user-id');
    when(() => mockUser.displayName).thenReturn('Test User');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockUser.photoURL).thenReturn('https://example.com/photo.jpg');

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

    // Register fallback values for any() matchers
    registerFallbackValue(MockUser());
    registerFallbackValue(MockUserCredential());
    registerFallbackValue(<String, dynamic>{});

    // Mock document operations
    when(() => mockUserDoc.set(any())).thenAnswer((_) async {});

    // Create service with mocks
    authService = FirebaseAuthService(
      firebaseAuth: mockAuth,
      firestore: mockFirestore,
      googleSignIn: MockGoogleSignIn(),
    );
  });

  group('FirebaseAuthService - Basic Operations', () {
    test('can be instantiated', () {
      expect(authService, isNotNull);
    });

    test('currentUser returns user when signed in', () {
      // Act
      final result = authService.currentUser;

      // Assert
      expect(result, isNotNull);
      expect(result!.id, 'test-user-id');
      expect(result.name, 'Test User');
      expect(result.email, 'test@example.com');
      expect(result.profileImageUrl, 'https://example.com/photo.jpg');
    });

    test('currentUser returns null when not signed in', () {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act
      final result = authService.currentUser;

      // Assert
      expect(result, isNull);
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
  });

  group('FirebaseAuthService - Authentication', () {
    test(
      'signInWithEmailAndPassword returns success on successful sign in',
      () async {
        // Arrange
        when(
          () => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => mockUserCredential);
        when(() => mockUserCredential.user).thenReturn(mockUser);

        // Act
        final result = await authService.signInWithEmailAndPassword(
          'test@example.com',
          'password123',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.user, isNotNull);
        expect(result.user!.id, 'test-user-id');
        verify(
          () => mockAuth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).called(1);
      },
    );

    test('signInWithEmailAndPassword returns failure on error', () async {
      // Arrange
      when(
        () => mockAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(MockFirebaseAuthException('invalid-email'));

      // Act
      final result = await authService.signInWithEmailAndPassword(
        'invalid-email',
        'password123',
      );

      // Assert
      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('invalid-email'));
    });

    test('signOut signs out the user', () async {
      // Arrange
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      // Act
      await authService.signOut();

      // Assert
      verify(() => mockAuth.signOut()).called(1);
    });

    test('createUserWithEmailAndPassword creates a new user', () async {
      // Arrange
      when(
        () => mockAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => mockUserCredential);
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async {});

      // Act
      final result = await authService.createUserWithEmailAndPassword(
        'new@example.com',
        'password123',
        'New User',
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.user, isNotNull);
      verify(
        () => mockAuth.createUserWithEmailAndPassword(
          email: 'new@example.com',
          password: 'password123',
        ),
      ).called(1);
      verify(() => mockUser.updateDisplayName('New User')).called(1);
      verify(() => mockUserDoc.set(any())).called(1);
    });

    test('createUserWithEmailAndPassword returns failure on error', () async {
      // Arrange
      when(
        () => mockAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(MockFirebaseAuthException('email-already-in-use'));

      // Act
      final result = await authService.createUserWithEmailAndPassword(
        'existing@example.com',
        'password123',
        'Existing User',
      );

      // Assert
      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('email-already-in-use'));
    });
  });

  group('FirebaseAuthService - Error Handling', () {
    test('handles network errors during sign in', () async {
      // Arrange
      when(
        () => mockAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(MockFirebaseAuthException('network-request-failed'));

      // Act
      final result = await authService.signInWithEmailAndPassword(
        'test@example.com',
        'password123',
      );

      // Assert
      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('network'));
    });

    test('handles general exceptions during sign in', () async {
      // Arrange
      when(
        () => mockAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(Exception('Unexpected error'));

      // Act
      final result = await authService.signInWithEmailAndPassword(
        'test@example.com',
        'password123',
      );

      // Assert
      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('Unexpected error'));
    });
  });
}
