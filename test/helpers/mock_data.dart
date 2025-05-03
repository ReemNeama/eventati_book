import 'package:eventati_book/models/user.dart';
import 'package:eventati_book/models/vendor_message.dart';

/// Mock data for testing
class MockData {
  /// Get a mock user
  static User getMockUser() {
    return User(
      id: 'test_user_id',
      name: 'Test User',
      email: 'test@example.com',
      createdAt: DateTime(2023, 1, 1),
      favoriteVenues: ['venue1', 'venue2'],
      favoriteServices: ['service1', 'service2'],
    );
  }

  /// Get a list of mock users
  static List<User> getMockUsers() {
    return [
      getMockUser(),
      User(
        id: 'user2',
        name: 'Jane Smith',
        email: 'jane@example.com',
        createdAt: DateTime(2023, 2, 15),
      ),
      User(
        id: 'user3',
        name: 'Bob Johnson',
        email: 'bob@example.com',
        createdAt: DateTime(2023, 3, 20),
      ),
    ];
  }

  /// Get a mock vendor
  static Vendor getMockVendor() {
    return Vendor(
      id: 'vendor1',
      name: 'Test Vendor',
      serviceType: 'Venue',
      email: 'vendor@example.com',
      phone: '123-456-7890',
      contactPerson: 'Vendor Contact',
    );
  }

  /// Get a mock message
  static Message getMockMessage() {
    return Message(
      id: 'message1',
      vendorId: 'vendor1',
      content: 'Test message content',
      timestamp: DateTime(2023, 4, 15, 10, 30),
      isFromUser: true,
    );
  }
}
