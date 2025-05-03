import 'package:eventati_book/models/user.dart';

/// Temporary database for user data
class UserDB {
  /// Get mock users
  static List<User> getUsers() {
    return [
      User(
        id: 'user_1',
        name: 'John Doe',
        email: 'john.doe@example.com',
        createdAt: DateTime(2023, 1, 15),
      ),
      User(
        id: 'user_2',
        name: 'Jane Smith',
        email: 'jane.smith@example.com',
        createdAt: DateTime(2023, 2, 20),
      ),
      User(
        id: 'user_3',
        name: 'Michael Johnson',
        email: 'michael.johnson@example.com',
        createdAt: DateTime(2023, 3, 10),
      ),
      User(
        id: 'user_4',
        name: 'Emily Davis',
        email: 'emily.davis@example.com',
        createdAt: DateTime(2023, 4, 5),
      ),
      User(
        id: 'user_5',
        name: 'Robert Wilson',
        email: 'robert.wilson@example.com',
        createdAt: DateTime(2023, 5, 12),
      ),
    ];
  }

  /// Get user by ID
  static User? getUserById(String id) {
    final users = getUsers();
    try {
      return users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get user by email
  static User? getUserByEmail(String email) {
    final users = getUsers();
    try {
      return users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  /// Authenticate user (mock implementation)
  static User? authenticateUser(String email, String password) {
    // In a real implementation, this would check password hashes
    // For mock purposes, we'll accept any password with length >= 6
    if (password.length < 6) {
      return null;
    }

    return getUserByEmail(email);
  }
}
