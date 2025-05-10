# Data Migration Utilities

This directory contains utilities for migrating data from the temporary database (tempDB) to Firebase Firestore.

## Overview

The migration utilities provide a framework for migrating different types of data from the temporary database to Firebase Firestore. The utilities include validation, error handling, and rollback mechanisms to ensure data integrity during migration.

## Components

### MigrationResult

The `MigrationResult` class represents the result of a migration operation. It includes information about the success or failure of the migration, the number of entities migrated, and any errors that occurred.

### BaseMigrationUtility

The `BaseMigrationUtility` class is an abstract base class for all migration utilities. It provides common functionality for validating entities, converting them to Firestore documents, and handling the migration process.

### Specific Migration Utilities

- **UserMigrationUtility**: Migrates user data
- **EventMigrationUtility**: Migrates event data
- **BudgetMigrationUtility**: Migrates budget data for events
- **GuestMigrationUtility**: Migrates guest data for events
- **TaskMigrationUtility**: Migrates task data for events

## Usage

The migration utilities are used by the `DataMigrationService` to migrate data from tempDB to Firebase. The service coordinates the migration process, handling dependencies between data types and providing progress tracking.

### Example

```dart
// Migrate all data
final migrationService = DataMigrationService();
final result = await migrationService.migrateAllData();

if (result.success) {
  print('Migration successful! Migrated ${result.entitiesMigrated} entities.');
} else {
  print('Migration failed: ${result.errorMessage}');
}

// Migrate data for a specific user
final userResult = await migrationService.migrateUserData('user_123');

if (userResult.success) {
  print('User migration successful! Migrated ${userResult.entitiesMigrated} entities.');
} else {
  print('User migration failed: ${userResult.errorMessage}');
}
```

## Data Validation

Each migration utility includes validation logic specific to its data type. Validation ensures that required fields are present, data types are correct, and relationships between entities are maintained.

## Rollback Mechanisms

If a migration fails, the utilities provide rollback mechanisms to revert any changes made during the migration. This ensures that the database remains in a consistent state even if the migration fails.

## Adding New Migration Utilities

To add a new migration utility:

1. Create a new class that extends `BaseMigrationUtility<T>` where `T` is the entity type
2. Implement the required methods:
   - `validateEntity(T entity)`: Validate the entity before migration
   - `entityToFirestore(T entity)`: Convert the entity to a Firestore document
   - `getEntityId(T entity)`: Get the ID of the entity
3. Add any additional methods specific to the data type
4. Update the `DataMigrationService` to use the new utility

## Future Improvements

- Add progress reporting for long-running migrations
- Implement incremental migration to handle large datasets
- Add support for migrating additional data types
- Improve error handling and recovery mechanisms
