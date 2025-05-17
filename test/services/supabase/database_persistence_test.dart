import 'package:flutter_test/flutter_test.dart';
import 'package:eventati_book/services/supabase/utils/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}

// Mock database services
class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  late MockDatabaseService mockDatabaseService;
  // late MockSupabaseClient mockSupabaseClient;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
  });

  group('Database Service Tests', () {
    test('getDocument returns document from Supabase', () async {
      // Arrange
      final mockDocument = {
        'id': 'test_doc_id',
        'name': 'Test Document',
        'created_at': DateTime.now().toIso8601String(),
      };

      // Setup mock response
      when(
        () => mockDatabaseService.getDocument('test_collection', 'test_doc_id'),
      ).thenAnswer((_) async => mockDocument);

      // Act
      final result = await mockDatabaseService.getDocument(
        'test_collection',
        'test_doc_id',
      );

      // Assert
      expect(result, isNotNull);
      expect(result!['id'], equals('test_doc_id'));
      expect(result['name'], equals('Test Document'));
      verify(
        () => mockDatabaseService.getDocument('test_collection', 'test_doc_id'),
      ).called(1);
    });

    test('addDocument adds document to Supabase', () async {
      // Arrange
      final mockDocument = {
        'name': 'Test Document',
        'description': 'This is a test document',
      };

      // Setup mock response
      when(
        () => mockDatabaseService.addDocument('test_collection', mockDocument),
      ).thenAnswer((_) async => 'test_doc_id');

      // Act
      final result = await mockDatabaseService.addDocument(
        'test_collection',
        mockDocument,
      );

      // Assert
      expect(result, equals('test_doc_id'));
      verify(
        () => mockDatabaseService.addDocument('test_collection', mockDocument),
      ).called(1);
    });
  });

  test('updateDocument updates document in Supabase', () async {
    // Arrange
    final mockDocument = {
      'id': 'test_doc_id',
      'name': 'Updated Document',
      'description': 'This document has been updated',
    };

    // Setup mock response
    when(
      () => mockDatabaseService.updateDocument(
        'test_collection',
        'test_doc_id',
        mockDocument,
      ),
    ).thenAnswer((_) async => {});

    // Act
    await mockDatabaseService.updateDocument(
      'test_collection',
      'test_doc_id',
      mockDocument,
    );

    // Assert
    verify(
      () => mockDatabaseService.updateDocument(
        'test_collection',
        'test_doc_id',
        mockDocument,
      ),
    ).called(1);
  });
}
