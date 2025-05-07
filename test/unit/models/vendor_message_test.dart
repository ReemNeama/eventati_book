import 'package:flutter_test/flutter_test.dart';
import 'package:eventati_book/models/models.dart';

void main() {
  group('Vendor Model Tests', () {
    test('should create a Vendor with required parameters', () {
      // Arrange
      final vendor = Vendor(
        id: 'vendor1',
        name: 'Test Vendor',
        serviceType: 'Venue',
      );

      // Assert
      expect(vendor.id, equals('vendor1'));
      expect(vendor.name, equals('Test Vendor'));
      expect(vendor.serviceType, equals('Venue'));
      expect(vendor.email, isNull);
      expect(vendor.phone, isNull);
      expect(vendor.contactPerson, isNull);
      expect(vendor.notes, isNull);
    });

    test('should create a Vendor with all parameters', () {
      // Arrange
      final vendor = Vendor(
        id: 'vendor1',
        name: 'Test Vendor',
        serviceType: 'Venue',
        email: 'vendor@example.com',
        phone: '123-456-7890',
        contactPerson: 'John Doe',
        notes: 'Some notes about the vendor',
      );

      // Assert
      expect(vendor.id, equals('vendor1'));
      expect(vendor.name, equals('Test Vendor'));
      expect(vendor.serviceType, equals('Venue'));
      expect(vendor.email, equals('vendor@example.com'));
      expect(vendor.phone, equals('123-456-7890'));
      expect(vendor.contactPerson, equals('John Doe'));
      expect(vendor.notes, equals('Some notes about the vendor'));
    });
  });

  group('Message Model Tests', () {
    test('should create a Message with required parameters', () {
      // Arrange
      final timestamp = DateTime(2023, 1, 1, 10, 30);
      final message = Message(
        id: 'message1',
        vendorId: 'vendor1',
        content: 'Test message',
        timestamp: timestamp,
        isFromUser: true,
      );

      // Assert
      expect(message.id, equals('message1'));
      expect(message.vendorId, equals('vendor1'));
      expect(message.content, equals('Test message'));
      expect(message.timestamp, equals(timestamp));
      expect(message.isFromUser, isTrue);
      expect(message.attachments, isEmpty);
      expect(message.isRead, isFalse); // Default value
    });

    test('should create a Message with all parameters', () {
      // Arrange
      final timestamp = DateTime(2023, 1, 1, 10, 30);
      final message = Message(
        id: 'message1',
        vendorId: 'vendor1',
        content: 'Test message',
        timestamp: timestamp,
        isFromUser: true,
        attachments: ['attachment1.jpg', 'attachment2.pdf'],
        isRead: true,
      );

      // Assert
      expect(message.id, equals('message1'));
      expect(message.vendorId, equals('vendor1'));
      expect(message.content, equals('Test message'));
      expect(message.timestamp, equals(timestamp));
      expect(message.isFromUser, isTrue);
      expect(
        message.attachments,
        equals(['attachment1.jpg', 'attachment2.pdf']),
      );
      expect(message.isRead, isTrue);
    });
  });
}
