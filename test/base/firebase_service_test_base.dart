import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import '../helpers/firebase_mock_classes.dart';

/// Base class for Firebase service tests
///
/// This class provides common setup and utility methods for testing Firebase services.
abstract class FirebaseServiceTestBase {
  /// Setup method to be called in the setUp function of each test
  void setupTest() {
    // Register fallback values for common Firebase types
    registerFallbackValue(MockDocumentReference<Map<String, dynamic>>());
    registerFallbackValue(MockQuerySnapshot<Map<String, dynamic>>());
    registerFallbackValue(MockDocumentSnapshot<Map<String, dynamic>>());
    registerFallbackValue(FieldValue.serverTimestamp());
    registerFallbackValue(<String, dynamic>{});
  }

  /// Create a mock document snapshot that can be used in tests
  MockDocumentSnapshot<Map<String, dynamic>> createMockDocumentSnapshot({
    required String id,
    required Map<String, dynamic> data,
    bool exists = true,
  }) {
    // Create a mock document snapshot
    final snapshot = MockDocumentSnapshot<Map<String, dynamic>>();

    // Set up the behavior
    when(() => snapshot.id).thenReturn(id);
    when(() => snapshot.exists).thenReturn(exists);
    when(() => snapshot.data()).thenReturn(data);

    return snapshot;
  }

  /// Create a mock query snapshot that can be used in tests
  MockQuerySnapshot<Map<String, dynamic>> createMockQuerySnapshot({
    required List<MockDocumentSnapshot<Map<String, dynamic>>> documents,
  }) {
    // Create a mock query snapshot
    final snapshot = MockQuerySnapshot<Map<String, dynamic>>();

    // Create mock query document snapshots
    final queryDocs =
        documents.map((doc) {
          final queryDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
          when(() => queryDoc.id).thenReturn(doc.id);
          when(() => queryDoc.data()).thenReturn(doc.data() ?? {});
          return queryDoc;
        }).toList();

    // Set up the behavior
    when(() => snapshot.docs).thenReturn(queryDocs);
    when(() => snapshot.size).thenReturn(documents.length);

    return snapshot;
  }

  /// Create a mock document reference that can be used in tests
  MockDocumentReference<Map<String, dynamic>> createMockDocumentReference({
    required String id,
    MockDocumentSnapshot<Map<String, dynamic>>? snapshot,
  }) {
    final docRef = MockDocumentReference<Map<String, dynamic>>();
    when(() => docRef.id).thenReturn(id);

    if (snapshot != null) {
      when(() => docRef.get()).thenAnswer((_) async => snapshot);
      when(() => docRef.snapshots()).thenAnswer((_) => Stream.value(snapshot));
    }

    return docRef;
  }

  /// Create a mock collection reference that can be used in tests
  MockCollectionReference<Map<String, dynamic>> createMockCollectionReference({
    required String id,
    List<MockDocumentReference<Map<String, dynamic>>>? documents,
  }) {
    final colRef = MockCollectionReference<Map<String, dynamic>>();
    when(() => colRef.id).thenReturn(id);

    if (documents != null) {
      for (final doc in documents) {
        when(() => colRef.doc(doc.id)).thenReturn(doc);
      }
    }

    return colRef;
  }

  /// Create a mock query that can be used in tests
  MockQuery<Map<String, dynamic>> createMockQuery({
    MockQuerySnapshot<Map<String, dynamic>>? snapshot,
  }) {
    final query = MockQuery<Map<String, dynamic>>();

    if (snapshot != null) {
      when(() => query.get()).thenAnswer((_) async => snapshot);
      when(() => query.snapshots()).thenAnswer((_) => Stream.value(snapshot));
    }

    return query;
  }

  /// Create a mock user
  firebase_auth.User createMockUser({
    required String uid,
    String? email,
    String? displayName,
    String? photoURL,
  }) {
    final user = MockUser();
    when(() => user.uid).thenReturn(uid);
    when(() => user.email).thenReturn(email);
    when(() => user.displayName).thenReturn(displayName);
    when(() => user.photoURL).thenReturn(photoURL);

    // Mock provider data
    final mockProviderData = [MockUserInfo()];
    when(() => user.providerData).thenReturn(mockProviderData);
    when(() => mockProviderData[0].providerId).thenReturn('google.com');

    // Mock metadata
    final mockUserMetadata = MockUserMetadata();
    when(() => user.metadata).thenReturn(mockUserMetadata);
    when(() => mockUserMetadata.creationTime).thenReturn(DateTime.now());

    // Mock other properties
    when(() => user.emailVerified).thenReturn(true);
    when(() => user.phoneNumber).thenReturn(null);

    return user;
  }

  /// Create a mock user credential
  firebase_auth.UserCredential createMockUserCredential({
    required firebase_auth.User user,
  }) {
    final credential = MockUserCredential();
    when(() => credential.user).thenReturn(user);
    return credential;
  }

  /// Create a mock storage reference
  Reference createMockStorageReference({required String path}) {
    final ref = MockStorageReference();
    when(() => ref.fullPath).thenReturn(path);
    return ref;
  }

  /// Create a mock upload task
  UploadTask createMockUploadTask({required TaskSnapshot snapshot}) {
    final task = MockUploadTask();
    when(() => task.snapshot).thenReturn(snapshot);
    when(() => task.snapshotEvents).thenAnswer((_) => Stream.value(snapshot));
    return task;
  }

  /// Create a mock task snapshot
  TaskSnapshot createMockTaskSnapshot({
    required Reference ref,
    int bytesTransferred = 100,
    int totalBytes = 100,
  }) {
    final snapshot = MockTaskSnapshot();
    when(() => snapshot.ref).thenReturn(ref);
    when(() => snapshot.bytesTransferred).thenReturn(bytesTransferred);
    when(() => snapshot.totalBytes).thenReturn(totalBytes);
    return snapshot;
  }
}
