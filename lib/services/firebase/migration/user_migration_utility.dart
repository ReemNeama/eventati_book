import 'package:eventati_book/models/user_models/user.dart';
import 'package:eventati_book/services/firebase/migration/base_migration_utility.dart';
import 'package:eventati_book/services/firebase/migration/migration_result.dart';
import 'package:eventati_book/tempDB/users.dart';
import 'package:eventati_book/utils/logger.dart';

/// Utility for migrating user data from tempDB to Firestore
class UserMigrationUtility extends BaseMigrationUtility<User> {
  /// Constructor
  UserMigrationUtility({super.firestore, super.auth})
    : super(collectionName: 'users', entityTypeName: 'User');

  @override
  List<String> validateEntity(User entity) {
    final errors = <String>[];

    // Validate required fields
    if (entity.id.isEmpty) {
      errors.add('User ID is required');
    }
    if (entity.name.isEmpty) {
      errors.add('Name is required');
    }
    if (entity.email.isEmpty) {
      errors.add('Email is required');
    } else if (!_isValidEmail(entity.email)) {
      errors.add('Email is invalid');
    }
    // Note: createdAt is non-nullable in the User model, so no null check needed

    return errors;
  }

  @override
  Map<String, dynamic> entityToFirestore(User entity) {
    return entity.toFirestore();
  }

  @override
  String getEntityId(User entity) {
    return entity.id;
  }

  /// Check if an email is valid
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }

  /// Migrate all users from tempDB to Firestore
  Future<MigrationResult> migrateAllUsers() async {
    try {
      // Get users from tempDB
      final users = UserDB.getUsers();

      Logger.i(
        'Migrating ${users.length} users from tempDB to Firestore',
        tag: 'UserMigrationUtility',
      );

      // Migrate users
      final result = await migrateEntities(users);

      // Log result
      if (result.success) {
        Logger.i(
          'Successfully migrated ${result.entitiesMigrated} users to Firestore',
          tag: 'UserMigrationUtility',
        );
      } else {
        Logger.e(
          'Failed to migrate users to Firestore: ${result.errorMessage}',
          tag: 'UserMigrationUtility',
        );
      }

      return result;
    } catch (e) {
      Logger.e('Error migrating users: $e', tag: 'UserMigrationUtility');
      return MigrationResult.failure(
        errorMessage: 'Error migrating users: $e',
        exception: e,
        entitiesMigrated: 0,
        entitiesFailed: 0,
        migratedIds: const [],
        failedIds: const [],
        idMap: const {},
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      );
    }
  }

  /// Migrate a specific user from tempDB to Firestore
  Future<MigrationResult> migrateUser(String userId) async {
    try {
      // Get users from tempDB
      final users = UserDB.getUsers();

      // Find the user with the specified ID
      final user = users.firstWhere(
        (user) => user.id == userId,
        orElse: () => throw Exception('User not found: $userId'),
      );

      Logger.i(
        'Migrating user $userId from tempDB to Firestore',
        tag: 'UserMigrationUtility',
      );

      // Migrate the user
      final result = await migrateEntities([user]);

      // Log result
      if (result.success) {
        Logger.i(
          'Successfully migrated user $userId to Firestore',
          tag: 'UserMigrationUtility',
        );
      } else {
        Logger.e(
          'Failed to migrate user $userId to Firestore: ${result.errorMessage}',
          tag: 'UserMigrationUtility',
        );
      }

      return result;
    } catch (e) {
      Logger.e('Error migrating user $userId: $e', tag: 'UserMigrationUtility');
      return MigrationResult.failure(
        errorMessage: 'Error migrating user $userId: $e',
        exception: e,
        entitiesMigrated: 0,
        entitiesFailed: 1,
        migratedIds: const [],
        failedIds: [userId],
        idMap: const {},
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      );
    }
  }

  /// Check if a user exists in Firestore
  Future<bool> userExists(String userId) async {
    try {
      final docSnapshot = await collection.doc(userId).get();
      return docSnapshot.exists;
    } catch (e) {
      Logger.e(
        'Error checking if user exists: $e',
        tag: 'UserMigrationUtility',
      );
      return false;
    }
  }

  /// Create a new user in Firestore with the same ID as in tempDB
  Future<MigrationResult> createUserWithSameId(User user) async {
    final startTime = DateTime.now();
    try {
      // Validate the user
      final validationErrors = validateEntity(user);
      if (validationErrors.isNotEmpty) {
        return MigrationResult.failure(
          errorMessage: 'Validation failed: ${validationErrors.join(', ')}',
          entitiesMigrated: 0,
          entitiesFailed: 1,
          migratedIds: const [],
          failedIds: [user.id],
          idMap: const {},
          startTime: startTime,
          endTime: DateTime.now(),
        );
      }

      // Check if the user already exists
      final exists = await userExists(user.id);
      if (exists) {
        return MigrationResult.failure(
          errorMessage: 'User already exists: ${user.id}',
          entitiesMigrated: 0,
          entitiesFailed: 1,
          migratedIds: const [],
          failedIds: [user.id],
          idMap: const {},
          startTime: startTime,
          endTime: DateTime.now(),
        );
      }

      // Create the user with the same ID
      await createEntityWithId(user.id, user);

      return MigrationResult.success(
        entitiesMigrated: 1,
        migratedIds: [user.id],
        idMap: {user.id: user.id},
        startTime: startTime,
        endTime: DateTime.now(),
      );
    } catch (e) {
      Logger.e(
        'Error creating user with same ID: $e',
        tag: 'UserMigrationUtility',
      );
      return MigrationResult.failure(
        errorMessage: 'Error creating user with same ID: $e',
        exception: e,
        entitiesMigrated: 0,
        entitiesFailed: 1,
        migratedIds: const [],
        failedIds: [user.id],
        idMap: const {},
        startTime: startTime,
        endTime: DateTime.now(),
      );
    }
  }
}
