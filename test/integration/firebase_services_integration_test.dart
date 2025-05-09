import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:eventati_book/models/event_models/event_template.dart';
import 'package:eventati_book/services/firebase/core/firebase_auth_service.dart';
import 'package:eventati_book/services/firebase/core/firebase_storage_service.dart';
import 'package:eventati_book/services/firebase/firestore/event_firestore_service.dart';
import 'package:eventati_book/services/firebase/utils/firestore_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import '../helpers/firebase_test_helper.dart';

// Mock File
class MockFile extends Mock implements File {
  @override
  String get path => '/test/path/image.jpg';
}

// Create a real Uint8List for testing
Uint8List createTestData() {
  return Uint8List.fromList([0, 1, 2, 3, 4, 5]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(MockFile());
    // We can't create a mock for Uint8List as it's a final class
    // Instead, we'll use a real Uint8List in our tests
  });

  late FirebaseAuthService authService;
  late FirestoreService firestoreService;
  late FirebaseStorageService storageService;
  late EventFirestoreService eventService;

  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseStorage mockStorage;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;
  late MockCollectionReference<Map<String, dynamic>> mockEventsCollection;
  late MockDocumentReference<Map<String, dynamic>> mockEventDoc;
  late MockStorageReference mockStorageRef;
  late MockUploadTask mockUploadTask;
  late MockTaskSnapshot mockTaskSnapshot;
  late MockFile mockFile;

  setUp(() {
    // Create mocks
    mockAuth = FirebaseTestHelper.mockAuth;
    mockFirestore = FirebaseTestHelper.mockFirestore;
    mockStorage = FirebaseTestHelper.mockStorage;
    mockUser = FirebaseTestHelper.mockUser;
    mockUserCredential = MockUserCredential();
    mockEventsCollection = MockCollectionReference<Map<String, dynamic>>();
    mockEventDoc = MockDocumentReference<Map<String, dynamic>>();
    mockStorageRef = MockStorageReference();
    mockUploadTask = MockUploadTask();
    mockTaskSnapshot = MockTaskSnapshot();
    mockFile = MockFile();

    // Setup default behaviors
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('test-user-id');
    when(() => mockUser.displayName).thenReturn('Test User');
    when(() => mockUser.email).thenReturn('test@example.com');

    // We can't directly mock the collection reference due to sealed classes
    // Instead, we'll set up the behavior for specific test cases

    when(() => mockStorage.ref(any())).thenReturn(mockStorageRef);
    when(() => mockStorage.ref().child(any())).thenReturn(mockStorageRef);
    when(() => mockStorageRef.putFile(any(), any())).thenReturn(mockUploadTask);
    when(() => mockUploadTask.snapshot).thenReturn(mockTaskSnapshot);
    when(() => mockTaskSnapshot.ref).thenReturn(mockStorageRef);
    when(
      () => mockStorageRef.getDownloadURL(),
    ).thenAnswer((_) async => 'https://example.com/test.jpg');

    // Create services
    authService = FirebaseAuthService(
      firebaseAuth: mockAuth,
      firestore: mockFirestore,
      googleSignIn: GoogleSignIn(),
    );
    firestoreService = FirestoreService(firestore: mockFirestore);
    storageService = FirebaseStorageService(storage: mockStorage);
    eventService = EventFirestoreService(firestoreService: firestoreService);
  });

  group('Firebase Services Integration', () {
    test('User sign in, create event, and upload image flow', () async {
      // Step 1: Sign in user
      when(
        () => mockAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => mockUserCredential);
      when(() => mockUserCredential.user).thenReturn(mockUser);

      final signInResult = await authService.signInWithEmailAndPassword(
        'test@example.com',
        'password123',
      );

      expect(signInResult.isSuccess, isTrue);
      expect(signInResult.user, isNotNull);

      // Step 2: Create an event
      when(
        () => mockEventsCollection.add(any()),
      ).thenAnswer((_) async => mockEventDoc);
      when(() => mockEventDoc.id).thenReturn('test-event-id');

      const eventTemplate = EventTemplate(
        id: '',
        name: 'Test Event',
        description: 'Test Description',
        icon: Icons.event,
        subtypes: ['Wedding'],
        defaultServices: {'Venue': false, 'Catering': false},
        suggestedTasks: ['Book venue', 'Hire caterer'],
      );

      final eventId = await eventService.createEvent(eventTemplate);

      expect(eventId, 'test-event-id');

      // Step 3: Upload event image
      when(() => mockFile.path).thenReturn('/test/path/image.jpg');

      final imagePath = 'events/$eventId/cover.jpg';
      final imageUrl = await storageService.uploadFile(imagePath, mockFile);

      expect(imageUrl, 'https://example.com/test.jpg');

      // Step 4: Update event with image URL
      when(
        () => mockEventDoc.update({'imageUrl': imageUrl}),
      ).thenAnswer((_) async {});

      // Create a new event template with the image URL
      final updatedTemplate = eventTemplate.copyWith(id: eventId);

      // Update the event
      await eventService.updateEvent(updatedTemplate);

      verify(() => mockEventDoc.update(any())).called(1);
    });

    test(
      'User registration, profile update, and event creation flow',
      () async {
        // Step 1: Register new user
        when(
          () => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => mockUserCredential);
        when(() => mockUserCredential.user).thenReturn(mockUser);
        when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async {});

        final registerResult = await authService.createUserWithEmailAndPassword(
          'new@example.com',
          'password123',
          'New User',
        );

        expect(registerResult.isSuccess, isTrue);
        expect(registerResult.user, isNotNull);

        // Step 2: Upload profile image
        when(() => mockFile.path).thenReturn('/test/path/profile.jpg');

        const profileImagePath = 'users/test-user-id/profile.jpg';
        final profileImageUrl = await storageService.uploadFile(
          profileImagePath,
          mockFile,
        );

        expect(profileImageUrl, 'https://example.com/test.jpg');

        // Step 3: Update user profile with image URL
        when(
          () => mockUser.updatePhotoURL(profileImageUrl),
        ).thenAnswer((_) async {});

        // Update profile using the updateProfile method
        await authService.updateProfile(
          displayName: 'Updated User',
          photoUrl: profileImageUrl,
        );

        verify(() => mockUser.updatePhotoURL(profileImageUrl)).called(1);

        // Step 4: Create an event for the new user
        when(
          () => mockEventsCollection.add(any()),
        ).thenAnswer((_) async => mockEventDoc);
        when(() => mockEventDoc.id).thenReturn('new-event-id');

        const eventTemplate = EventTemplate(
          id: '',
          name: 'New User Event',
          description: 'First Event',
          icon: Icons.celebration,
          subtypes: ['Birthday Party'],
          defaultServices: {'Venue': false, 'Catering': false},
          suggestedTasks: ['Book venue', 'Hire caterer'],
        );

        final eventId = await eventService.createEvent(eventTemplate);

        expect(eventId, 'new-event-id');
      },
    );
  });
}
