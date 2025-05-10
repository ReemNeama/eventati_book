import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:eventati_book/services/firebase/firestore/wizard_connection_firestore_service.dart';
import 'package:eventati_book/services/interfaces/database_service_interface.dart';

// Mock DatabaseServiceInterface
class MockDatabaseService extends Mock implements DatabaseServiceInterface {}

void main() {
  late WizardConnectionFirestoreService service;
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    // Create mocks
    mockDatabaseService = MockDatabaseService();

    // Create service with mocks
    service = WizardConnectionFirestoreService(
      firestoreService: mockDatabaseService,
    );
  });

  group('WizardConnectionFirestoreService', () {
    test('can be instantiated', () {
      expect(service, isNotNull);
    });

    test(
      'getWizardConnection returns null when connection does not exist',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.getDocument(any(), any()),
        ).thenAnswer((_) async => null);

        // Act
        final result = await service.getWizardConnection(
          'test-user-id',
          'test-event-id',
        );

        // Assert
        expect(result, isNull);
      },
    );

    test(
      'saveWizardConnection calls setDocument on database service',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.setDocument(any(), any(), any()),
        ).thenAnswer((_) async {});

        // Act
        await service.saveWizardConnection('test-user-id', 'test-event-id', {
          'test': 'data',
        });

        // Assert
        verify(
          () => mockDatabaseService.setDocument(
            'wizard_connections',
            'test-user-id_test-event-id',
            any(),
          ),
        ).called(1);
      },
    );
  });
}
