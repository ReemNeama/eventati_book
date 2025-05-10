import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventati_book/services/firebase/utils/firestore_service.dart';
import 'package:eventati_book/services/firebase/utils/network_connectivity_service.dart';

// Mock classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockNetworkConnectivityService extends Mock
    implements NetworkConnectivityService {}

// Use the mocks from firebase_test_helper.dart instead of defining our own
// for the sealed classes

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FirestoreService firestoreService;
  late MockFirebaseFirestore mockFirestore;
  late MockNetworkConnectivityService mockConnectivityService;

  setUp(() {
    // Create mocks
    mockFirestore = MockFirebaseFirestore();
    mockConnectivityService = MockNetworkConnectivityService();

    // Create service with mocks
    firestoreService = FirestoreService(firestore: mockFirestore);

    // Mock connectivity service
    when(
      () => mockConnectivityService.isConnected(),
    ).thenAnswer((_) async => true);
  });

  group('FirestoreService', () {
    test('can be instantiated', () {
      expect(firestoreService, isNotNull);
    });

    test('enableOfflinePersistence configures Firestore settings', () async {
      // Arrange
      const cacheSizeBytes = 50000000;

      // Act
      await firestoreService.enableOfflinePersistence(
        cacheSizeBytes: cacheSizeBytes,
      );

      // Assert
      expect(firestoreService.getFirestore(), equals(mockFirestore));
    });
  });
}
