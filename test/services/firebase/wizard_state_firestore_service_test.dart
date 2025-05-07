import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/firebase/firestore/wizard_state_firestore_service.dart';
import 'package:eventati_book/services/interfaces/database_service_interface.dart';

// Mock DatabaseServiceInterface
class MockDatabaseService extends Mock implements DatabaseServiceInterface {}

void main() {
  late WizardStateFirestoreService service;
  late MockDatabaseService mockFirestoreService;
  late WizardState testWizardState;
  
  const String userId = 'test_user_id';
  const String eventId = 'test_event_id';
  
  setUp(() {
    mockFirestoreService = MockDatabaseService();
    service = WizardStateFirestoreService(firestoreService: mockFirestoreService);
    
    // Create a test wizard state
    final template = EventTemplate(
      id: 'wedding',
      name: 'Wedding',
      description: 'Plan your wedding',
      icon: 'wedding',
      defaultServices: {
        'Venue': true,
        'Catering': true,
        'Photography': true,
      },
    );
    
    testWizardState = WizardState(
      template: template,
      eventName: 'Test Wedding',
      selectedEventType: 'Traditional',
      eventDate: DateTime(2023, 6, 15),
      guestCount: 150,
      isCompleted: true,
    );
  });
  
  group('WizardStateFirestoreService', () {
    test('saveWizardState should call setDocument with correct data', () async {
      // Arrange
      final documentId = '${userId}_${eventId}';
      final expectedData = {
        'userId': userId,
        'eventId': eventId,
        ...testWizardState.toFirestore(),
      };
      
      when(mockFirestoreService.setDocument(
        'wizard_states',
        documentId,
        any,
      )).thenAnswer((_) => Future.value());
      
      // Act
      await service.saveWizardState(userId, eventId, testWizardState);
      
      // Assert
      verify(mockFirestoreService.setDocument(
        'wizard_states',
        documentId,
        any,
      )).called(1);
    });
    
    test('getWizardState should return null when document does not exist', () async {
      // Arrange
      final documentId = '${userId}_${eventId}';
      
      when(mockFirestoreService.getDocument(
        'wizard_states',
        documentId,
      )).thenAnswer((_) => Future.value(null));
      
      // Act
      final result = await service.getWizardState(userId, eventId);
      
      // Assert
      expect(result, isNull);
      verify(mockFirestoreService.getDocument(
        'wizard_states',
        documentId,
      )).called(1);
    });
    
    test('deleteWizardState should call deleteDocument with correct parameters', () async {
      // Arrange
      final documentId = '${userId}_${eventId}';
      
      when(mockFirestoreService.deleteDocument(
        'wizard_states',
        documentId,
      )).thenAnswer((_) => Future.value());
      
      // Act
      await service.deleteWizardState(userId, eventId);
      
      // Assert
      verify(mockFirestoreService.deleteDocument(
        'wizard_states',
        documentId,
      )).called(1);
    });
  });
}
