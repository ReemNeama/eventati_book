import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';

// Mock classes for testing
// Note: These classes are marked as sealed in newer Firebase versions
// We're using them for testing purposes only, with the understanding
// that they might not fully replicate the behavior of the real classes

// Firebase Firestore mocks
class MockDocumentSnapshot<T> extends Mock {
  String id = 'mock-doc-id';
  bool exists = true;
  T? _data;

  T? data() => _data;
}

class MockDocumentReference<T> extends Mock {
  String id = 'mock-doc-id';

  Future<MockDocumentSnapshot<T>> get() async => MockDocumentSnapshot<T>();
  Stream<MockDocumentSnapshot<T>> snapshots() =>
      Stream.value(MockDocumentSnapshot<T>());
  Future<void> set(T data) async {}
  Future<void> update(Map<String, dynamic> data) async {}
}

class MockQuerySnapshot<T> extends Mock {
  List<MockQueryDocumentSnapshot<T>> docs = [];
  int size = 0;
}

class MockQueryDocumentSnapshot<T> extends Mock {
  String id = 'mock-query-doc-id';
  T? _data;

  T data() => _data as T;
}

class MockCollectionReference<T> extends Mock {
  String id = 'mock-collection-id';

  MockDocumentReference<T> doc(String path) => MockDocumentReference<T>();
  Future<MockQuerySnapshot<T>> get() async => MockQuerySnapshot<T>();
  Stream<MockQuerySnapshot<T>> snapshots() =>
      Stream.value(MockQuerySnapshot<T>());
}

class MockQuery<T> extends Mock {
  Future<MockQuerySnapshot<T>> get() async => MockQuerySnapshot<T>();
  Stream<MockQuerySnapshot<T>> snapshots() =>
      Stream.value(MockQuerySnapshot<T>());
}

// Firebase Auth mocks
class MockUser extends Mock implements firebase_auth.User {}

class MockUserCredential extends Mock implements firebase_auth.UserCredential {}

class MockUserInfo extends Mock implements firebase_auth.UserInfo {}

class MockUserMetadata extends Mock implements firebase_auth.UserMetadata {}

// Firebase Storage mocks
class MockStorageReference extends Mock implements Reference {}

class MockUploadTask extends Mock implements UploadTask {}

class MockTaskSnapshot extends Mock implements TaskSnapshot {}
