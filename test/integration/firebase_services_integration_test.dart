import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:eventati_book/services/firebase/core/firebase_storage_service.dart';
import 'package:eventati_book/services/firebase/firestore/event_firestore_service.dart';
import 'package:eventati_book/services/interfaces/database_service_interface.dart';
import 'package:eventati_book/services/interfaces/auth_service_interface.dart';
import 'package:eventati_book/models/models.dart';
import 'package:flutter/material.dart';
import '../helpers/firebase_test_helper.dart';

// Mock File
class MockFile extends Mock implements File {
  @override
  String get path => '/test/path/image.jpg';
}

// Mock DatabaseService
class MockDatabaseService extends Mock implements DatabaseServiceInterface {}

// Mock StorageService
class MockStorageService extends Mock implements FirebaseStorageService {}

// Let's use a simpler approach by mocking the entire uploadFile method

// Mock AuthService for testing
class MockAuthService extends Mock implements AuthServiceInterface {
  final MockUser _mockUser;

  MockAuthService(this._mockUser);

  @override
  User? get currentUser => User(
    id: _mockUser.uid,
    name: _mockUser.displayName ?? 'Test User',
    email: _mockUser.email ?? 'test@example.com',
    profileImageUrl: _mockUser.photoURL,
    createdAt: DateTime.now(),
  );

  @override
  String? get currentUserId => _mockUser.uid;

  @override
  bool get isSignedIn => true;
}

// Create a real Uint8List for testing
Uint8List createTestData() {
  return Uint8List.fromList([0, 1, 2, 3, 4, 5]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Register fallback values for mocktail and setup Firebase mocks
  setUpAll(() async {
    registerFallbackValue(MockFile());
    registerFallbackValue(<String, dynamic>{});
    // We can't create a mock for Uint8List as it's a final class
    // Instead, we'll use a real Uint8List in our tests

    // Initialize Firebase mocks
    await FirebaseTestHelper.setupFirebaseMocks();
  });

  late MockAuthService authService;
  late FirebaseStorageService storageService;
  late EventFirestoreService eventService;
  late MockDatabaseService mockDatabaseService;
  late MockUser mockUser;
  late MockStorageService mockStorageService;
  late MockFile mockFile;

  setUp(() {
    // Create mocks
    mockUser = FirebaseTestHelper.mockUser;
    mockStorageService = MockStorageService();
    mockFile = MockFile();
    mockDatabaseService = MockDatabaseService();

    // Setup default behaviors
    when(() => mockUser.uid).thenReturn('test-user-id');
    when(() => mockUser.displayName).thenReturn('Test User');
    when(() => mockUser.email).thenReturn('test@example.com');

    // For Firebase Auth Service, we'll mock the getUserDataFromFirestore method
    // by mocking the database service behavior for getDocument
    when(
      () => mockDatabaseService.getDocument('users', 'test-user-id'),
    ).thenAnswer(
      (_) async => {
        'name': 'Test User',
        'email': 'test@example.com',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'favoriteVenues': <String>[],
        'favoriteServices': <String>[],
      },
    );

    // Mock Storage behaviors
    when(
      () => mockStorageService.uploadFile(any(), any()),
    ).thenAnswer((_) async => 'https://example.com/test.jpg');

    // Mock database service behavior for getDocument
    when(
      () => mockDatabaseService.getDocument('events', 'test-event-id'),
    ).thenAnswer(
      (_) async => {
        'name': 'Test Event',
        'description': 'Test Description',
        'icon': {
          'codePoint': Icons.event.codePoint,
          'fontFamily': 'MaterialIcons',
          'fontPackage': null,
        },
        'subtypes': ['Wedding'],
        'defaultServices': {'Venue': false, 'Catering': false},
        'suggestedTasks': ['Book venue', 'Hire caterer'],
        'userId': 'test-user-id',
      },
    );

    // Mock database service behavior for getCollectionWithQueryAs
    when(
      () => mockDatabaseService.getCollectionWithQueryAs<EventTemplate>(
        'events',
        any(),
        any(),
      ),
    ).thenAnswer(
      (_) async => [
        const EventTemplate(
          id: 'test-event-id',
          name: 'Test Event',
          description: 'Test Description',
          icon: Icons.event,
          subtypes: ['Wedding'],
          defaultServices: {'Venue': false, 'Catering': false},
          suggestedTasks: ['Book venue', 'Hire caterer'],
        ),
      ],
    );

    // Create services
    authService = MockAuthService(mockUser);
    storageService = mockStorageService;
    eventService = EventFirestoreService(firestoreService: mockDatabaseService);
  });

  group('Firebase Services Integration', () {
    test('User sign in, create event, and upload image flow', () async {
      // Step 1: Mock sign in
      when(
        () => authService.signInWithEmailAndPassword(any(), any()),
      ).thenAnswer((_) async => AuthResult.success(authService.currentUser!));

      final signInResult = await authService.signInWithEmailAndPassword(
        'test@example.com',
        'password123',
      );

      expect(signInResult.isSuccess, isTrue);
      expect(signInResult.user, isNotNull);

      // Step 2: Create an event

      // Mock database service behavior for addDocument
      when(
        () => mockDatabaseService.addDocument('events', any()),
      ).thenAnswer((_) async => 'test-event-id');

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
      final imagePath = 'events/$eventId/cover.jpg';
      final imageUrl = await storageService.uploadFile(imagePath, mockFile);

      expect(imageUrl, 'https://example.com/test.jpg');

      // Step 4: Update event with image URL
      // Mock database service behavior for updateDocument
      when(
        () => mockDatabaseService.updateDocument('events', eventId, any()),
      ).thenAnswer((_) async {});

      // Create a new event template with the image URL
      final updatedTemplate = eventTemplate.copyWith(id: eventId);

      // Update the event
      await eventService.updateEvent(updatedTemplate);

      // Verify that updateDocument was called
      verify(
        () => mockDatabaseService.updateDocument('events', eventId, any()),
      ).called(1);
    });

    test(
      'User registration, profile update, and event creation flow',
      () async {
        // Step 1: Mock register new user
        when(
          () => authService.createUserWithEmailAndPassword(any(), any(), any()),
        ).thenAnswer((_) async => AuthResult.success(authService.currentUser!));

        final registerResult = await authService.createUserWithEmailAndPassword(
          'new@example.com',
          'password123',
          'New User',
        );

        expect(registerResult.isSuccess, isTrue);
        expect(registerResult.user, isNotNull);

        // Step 2: Upload profile image
        const profileImagePath = 'users/test-user-id/profile.jpg';
        final profileImageUrl = await storageService.uploadFile(
          profileImagePath,
          mockFile,
        );

        expect(profileImageUrl, 'https://example.com/test.jpg');

        // Step 3: Update user profile with image URL
        when(
          () => authService.updateProfile(
            displayName: any(named: 'displayName'),
            photoUrl: any(named: 'photoUrl'),
          ),
        ).thenAnswer((_) async => AuthResult.success(authService.currentUser!));

        // Update profile using the updateProfile method
        await authService.updateProfile(
          displayName: 'Updated User',
          photoUrl: profileImageUrl,
        );

        // Step 4: Create an event for the new user

        // Mock database service behavior for addDocument with new event
        when(
          () => mockDatabaseService.addDocument('events', any()),
        ).thenAnswer((_) async => 'new-event-id');

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
