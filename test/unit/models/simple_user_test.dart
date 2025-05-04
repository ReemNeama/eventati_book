import 'package:flutter_test/flutter_test.dart';
import 'package:eventati_book/models/models.dart';

void main() {
  group('User Model Tests', () {
    test('should create a User with required parameters', () {
      // Arrange
      final user = User(
        id: 'test_id',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime(2023, 1, 1),
      );

      // Assert
      expect(user.id, equals('test_id'));
      expect(user.name, equals('Test User'));
      expect(user.email, equals('test@example.com'));
      expect(user.createdAt, equals(DateTime(2023, 1, 1)));
      expect(user.favoriteVenues, isEmpty);
      expect(user.favoriteServices, isEmpty);
    });

    test('should create a User with all parameters', () {
      // Arrange
      final user = User(
        id: 'test_id',
        name: 'Test User',
        email: 'test@example.com',
        phoneNumber: '123-456-7890',
        profileImageUrl: 'https://example.com/image.jpg',
        createdAt: DateTime(2023, 1, 1),
        favoriteVenues: ['venue1', 'venue2'],
        favoriteServices: ['service1', 'service2'],
      );

      // Assert
      expect(user.id, equals('test_id'));
      expect(user.name, equals('Test User'));
      expect(user.email, equals('test@example.com'));
      expect(user.phoneNumber, equals('123-456-7890'));
      expect(user.profileImageUrl, equals('https://example.com/image.jpg'));
      expect(user.createdAt, equals(DateTime(2023, 1, 1)));
      expect(user.favoriteVenues, equals(['venue1', 'venue2']));
      expect(user.favoriteServices, equals(['service1', 'service2']));
    });

    test('should create a copy with updated values', () {
      // Arrange
      final user = User(
        id: 'test_id',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime(2023, 1, 1),
      );

      // Act
      final updatedUser = user.copyWith(
        name: 'Updated Name',
        email: 'updated@example.com',
        favoriteVenues: ['venue1'],
      );

      // Assert
      expect(updatedUser.id, equals('test_id')); // Unchanged
      expect(updatedUser.name, equals('Updated Name')); // Changed
      expect(updatedUser.email, equals('updated@example.com')); // Changed
      expect(updatedUser.createdAt, equals(DateTime(2023, 1, 1))); // Unchanged
      expect(updatedUser.favoriteVenues, equals(['venue1'])); // Changed
      expect(updatedUser.favoriteServices, isEmpty); // Unchanged
    });

    test('should convert to and from JSON', () {
      // Arrange
      final user = User(
        id: 'test_id',
        name: 'Test User',
        email: 'test@example.com',
        phoneNumber: '123-456-7890',
        profileImageUrl: 'https://example.com/image.jpg',
        createdAt: DateTime(2023, 1, 1),
        favoriteVenues: ['venue1', 'venue2'],
        favoriteServices: ['service1', 'service2'],
      );

      // Act
      final json = user.toJson();
      final fromJson = User.fromJson(json);

      // Assert
      expect(fromJson.id, equals(user.id));
      expect(fromJson.name, equals(user.name));
      expect(fromJson.email, equals(user.email));
      expect(fromJson.phoneNumber, equals(user.phoneNumber));
      expect(fromJson.profileImageUrl, equals(user.profileImageUrl));
      expect(
        fromJson.createdAt.toIso8601String(),
        equals(user.createdAt.toIso8601String()),
      );
      expect(fromJson.favoriteVenues, equals(user.favoriteVenues));
      expect(fromJson.favoriteServices, equals(user.favoriteServices));
    });
  });
}
