import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:eventati_book/models/event_models/event_template.dart';
import 'package:eventati_book/models/event_models/wizard_state.dart';
import 'package:eventati_book/services/firebase/firestore/wizard_state_firestore_service.dart';
import 'package:eventati_book/services/interfaces/database_service_interface.dart';

// Mock DatabaseServiceInterface
class MockDatabaseService extends Mock implements DatabaseServiceInterface {}

// Mock EventTemplate
class MockEventTemplate extends Mock implements EventTemplate {}

// Mock WizardState
class MockWizardState extends Mock implements WizardState {}

void main() {
  late WizardStateFirestoreService service;
  late MockDatabaseService mockDatabaseService;
  late MockWizardState mockWizardState;
  late MockEventTemplate mockEventTemplate;

  setUp(() {
    // Create mocks
    mockDatabaseService = MockDatabaseService();
    mockEventTemplate = MockEventTemplate();
    mockWizardState = MockWizardState();

    // Setup mock behavior
    when(() => mockWizardState.template).thenReturn(mockEventTemplate);
    when(() => mockWizardState.toFirestore()).thenReturn({
      'templateId': 'test-template-id',
      'currentStep': 1,
      'totalSteps': 4,
      'eventName': 'Test Event',
    });

    // Create service with mocks
    service = WizardStateFirestoreService(
      firestoreService: mockDatabaseService,
    );
  });

  group('WizardStateFirestoreService', () {
    test('can be instantiated', () {
      expect(service, isNotNull);
    });

    test('getWizardState returns null when state does not exist', () async {
      // Arrange
      when(
        () => mockDatabaseService.getDocument(any(), any()),
      ).thenAnswer((_) async => null);

      // Act
      final result = await service.getWizardState(
        'test-user-id',
        'test-event-id',
      );

      // Assert
      expect(result, isNull);
    });

    test('saveWizardState calls setDocument on database service', () async {
      // Arrange
      when(
        () => mockDatabaseService.setDocument(any(), any(), any()),
      ).thenAnswer((_) async {});

      // Act
      await service.saveWizardState(
        'test-user-id',
        'test-event-id',
        mockWizardState,
      );

      // Assert
      verify(
        () => mockDatabaseService.setDocument(
          'wizard_states',
          'test-user-id_test-event-id',
          any(),
        ),
      ).called(1);
    });
  });
}
