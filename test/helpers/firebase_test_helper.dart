import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

// Mock Firebase Auth
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

// Mock User
class MockUser extends Mock implements User {}

// Mock UserCredential
class MockUserCredential extends Mock implements UserCredential {}

// Mock Firestore
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

// Note: These classes are marked as sealed in newer Firebase versions
// We're using them for testing purposes only, with the understanding
// that they might not fully replicate the behavior of the real classes

// Mock CollectionReference
class MockCollectionReference<T> extends Mock {
  String id = 'mock-collection';

  // Add methods as needed for tests
  MockDocumentReference<T> doc(String path) => MockDocumentReference<T>();

  // Add document to collection
  Future<MockDocumentReference<T>> add(T data) async =>
      MockDocumentReference<T>();

  // Get collection as stream
  Stream<MockQuerySnapshot<T>> snapshots() =>
      Stream.value(MockQuerySnapshot<T>());

  // Get collection once
  Future<MockQuerySnapshot<T>> get() async => MockQuerySnapshot<T>();

  // Where query
  MockQuery<T> where(String field, {dynamic isEqualTo}) => MockQuery<T>();
}

// Mock DocumentReference
class MockDocumentReference<T> extends Mock {
  String id = 'mock-doc';

  // Add methods as needed for tests
  Future<MockDocumentSnapshot<T>> get() async => MockDocumentSnapshot<T>();

  // Set document data
  Future<void> set(T data) async => Future.value();

  // Update document data
  Future<void> update(Map<String, dynamic> data) async => Future.value();

  // Delete document
  Future<void> delete() async => Future.value();

  // Get document as stream
  Stream<MockDocumentSnapshot<T>> snapshots() =>
      Stream.value(MockDocumentSnapshot<T>());
}

// Mock DocumentSnapshot
class MockDocumentSnapshot<T> extends Mock {
  String id = 'mock-snapshot';
  bool exists = true;
  T? _data;

  // Add methods as needed for tests
  T? data() => _data;

  // Set data for testing
  void setData(T data) {
    _data = data;
  }
}

// Mock QuerySnapshot
class MockQuerySnapshot<T> extends Mock {
  List<dynamic> docs = [];
  int size = 0;

  // Set docs for testing
  void setDocs(List<dynamic> documents) {
    docs = documents;
    size = documents.length;
  }
}

// Mock Query
class MockQuery<T> extends Mock {
  // Add methods as needed for tests
  Future<MockQuerySnapshot<T>> get() async => MockQuerySnapshot<T>();

  // Get query as stream
  Stream<MockQuerySnapshot<T>> snapshots() =>
      Stream.value(MockQuerySnapshot<T>());

  // Where query
  MockQuery<T> where(String field, {dynamic isEqualTo}) => MockQuery<T>();

  // Order by
  MockQuery<T> orderBy(String field, {bool descending = false}) =>
      MockQuery<T>();

  // Limit
  MockQuery<T> limit(int limit) => MockQuery<T>();
}

// Mock Firebase Storage
class MockFirebaseStorage extends Mock implements FirebaseStorage {}

// Mock Reference (Storage)
class MockStorageReference extends Mock implements Reference {}

// Mock UploadTask
class MockUploadTask extends Mock implements UploadTask {}

// Mock TaskSnapshot
class MockTaskSnapshot extends Mock implements TaskSnapshot {}

// Mock Firebase Messaging
class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

// Mock RemoteMessage
class MockRemoteMessage extends Mock implements RemoteMessage {}

// Mock Firebase Analytics
class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

// Mock AnalyticsEventItem
class MockAnalyticsEventItem extends Mock implements AnalyticsEventItem {}

// Mock Firebase Crashlytics
class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

/// Setup Firebase mocks for testing
class FirebaseTestHelper {
  // Singleton instances
  static final MockFirebaseAuth _mockAuth = MockFirebaseAuth();
  static final MockFirebaseFirestore _mockFirestore = MockFirebaseFirestore();
  static final MockFirebaseStorage _mockStorage = MockFirebaseStorage();
  static final MockFirebaseMessaging _mockMessaging = MockFirebaseMessaging();
  static final MockFirebaseAnalytics _mockAnalytics = MockFirebaseAnalytics();
  static final MockFirebaseCrashlytics _mockCrashlytics =
      MockFirebaseCrashlytics();
  static final MockUser _mockUser = MockUser();

  // Getters for mock instances
  static MockFirebaseAuth get mockAuth => _mockAuth;
  static MockFirebaseFirestore get mockFirestore => _mockFirestore;
  static MockFirebaseStorage get mockStorage => _mockStorage;
  static MockFirebaseMessaging get mockMessaging => _mockMessaging;
  static MockFirebaseAnalytics get mockAnalytics => _mockAnalytics;
  static MockFirebaseCrashlytics get mockCrashlytics => _mockCrashlytics;
  static MockUser get mockUser => _mockUser;

  /// Initialize Firebase mocks for testing
  static Future<void> setupFirebaseMocks() async {
    // Setup default behaviors
    _setupDefaultBehaviors();
  }

  /// Setup default behaviors for mock Firebase services
  static void _setupDefaultBehaviors() {
    // Mock FirebaseAuth behaviors
    when(() => _mockAuth.currentUser).thenReturn(_mockUser);
    when(() => _mockUser.uid).thenReturn('test-user-id');
    when(() => _mockUser.displayName).thenReturn('Test User');
    when(() => _mockUser.email).thenReturn('test@example.com');

    // Mock Firestore behaviors
    // We can't directly return our mock due to sealed classes, so we'll use a workaround
    // by setting up specific collection behaviors as needed in tests

    // Mock Storage behaviors
    when(() => _mockStorage.ref(any())).thenReturn(MockStorageReference());

    // Mock Messaging behaviors
    when(
      () => _mockMessaging.getToken(),
    ).thenAnswer((_) async => 'mock-fcm-token');
    when(() => _mockMessaging.subscribeToTopic(any())).thenAnswer((_) async {});

    // Mock Analytics behaviors
    when(
      () => _mockAnalytics.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer((_) async {});

    // Mock Crashlytics behaviors
    when(
      () => _mockCrashlytics.recordError(
        any(),
        any(),
        reason: any(named: 'reason'),
        fatal: any(named: 'fatal'),
      ),
    ).thenAnswer((_) async {});
  }

  /// Create a mock collection reference
  static MockCollectionReference<Map<String, dynamic>> mockCollection() {
    return MockCollectionReference<Map<String, dynamic>>();
  }

  /// Create a mock document reference
  static MockDocumentReference<Map<String, dynamic>> mockDocument() {
    return MockDocumentReference<Map<String, dynamic>>();
  }

  /// Create a mock document snapshot
  static MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot({
    bool exists = true,
    Map<String, dynamic>? data,
  }) {
    final snapshot = MockDocumentSnapshot<Map<String, dynamic>>();
    when(() => snapshot.exists).thenReturn(exists);
    when(() => snapshot.data()).thenReturn(data ?? {});
    return snapshot;
  }

  /// Wrap a widget with mock Firebase services for testing
  static Widget wrapWithMockFirebaseServices(Widget child) {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuth>.value(value: _mockAuth),
        Provider<FirebaseFirestore>.value(value: _mockFirestore),
        Provider<FirebaseStorage>.value(value: _mockStorage),
        Provider<FirebaseMessaging>.value(value: _mockMessaging),
        Provider<FirebaseAnalytics>.value(value: _mockAnalytics),
        Provider<FirebaseCrashlytics>.value(value: _mockCrashlytics),
      ],
      child: MaterialApp(home: child),
    );
  }
}
