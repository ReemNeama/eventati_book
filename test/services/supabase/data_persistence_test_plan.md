# Data Persistence Test Plan

This document outlines a comprehensive test plan for verifying data persistence with all models in the Supabase database.

## Test Approach

1. **Unit Tests**: Test individual database service methods in isolation using mocks
2. **Integration Tests**: Test the interaction between database services and the Supabase client
3. **End-to-End Tests**: Test the complete flow from UI to database and back

## Models to Test

1. User
2. Event
3. Task
4. Task Category
5. Task Dependency
6. Budget Item
7. Guest
8. Service
9. Booking
10. Notification
11. Wizard State
12. Wizard Connection
13. Service Review
14. Payment

## Test Cases for Each Model

### CRUD Operations

For each model, test the following operations:

1. **Create**: Add a new record to the database
2. **Read**: Retrieve a record by ID
3. **Update**: Modify an existing record
4. **Delete**: Remove a record from the database
5. **List**: Retrieve multiple records with filtering and pagination

### Relationships

Test the relationships between models:

1. **One-to-Many**: e.g., Event to Tasks
2. **Many-to-Many**: e.g., Events to Services through Bookings

### Edge Cases

Test the following edge cases:

1. **Empty Values**: Test with empty strings, null values, etc.
2. **Large Data Sets**: Test with a large number of records
3. **Concurrent Operations**: Test multiple operations happening simultaneously
4. **Error Handling**: Test error conditions and recovery

## Test Implementation

### Unit Tests

Create unit tests for each database service method using mocks:

```dart
test('getUserById returns user from Supabase', () async {
  // Arrange
  final mockUser = User(
    id: 'test_user_id',
    name: 'Test User',
    email: 'test@example.com',
    createdAt: DateTime.now(),
  );

  // Setup mock response
  when(() => mockUserService.getUserById('test_user_id'))
      .thenAnswer((_) async => mockUser);

  // Act
  final result = await mockUserService.getUserById('test_user_id');

  // Assert
  expect(result, isNotNull);
  expect(result!.id, equals('test_user_id'));
  expect(result.name, equals('Test User'));
  verify(() => mockUserService.getUserById('test_user_id')).called(1);
});
```

### Integration Tests

Create integration tests that use a test Supabase instance:

```dart
test('addEvent adds event to Supabase and can be retrieved', () async {
  // Arrange
  final event = Event(
    id: 'test_event_id',
    name: 'Test Event',
    type: EventType.wedding,
    date: DateTime.now().add(const Duration(days: 30)),
    location: 'Test Location',
    budget: 5000,
    guestCount: 100,
    userId: 'test_user_id',
  );

  // Act
  final eventId = await eventDatabaseService.addEvent(event);
  final retrievedEvent = await eventDatabaseService.getEventById(eventId);

  // Assert
  expect(retrievedEvent, isNotNull);
  expect(retrievedEvent!.name, equals('Test Event'));
  expect(retrievedEvent.type, equals(EventType.wedding));
});
```

### End-to-End Tests

Create end-to-end tests that simulate user interactions:

```dart
testWidgets('User can create and view an event', (WidgetTester tester) async {
  // Arrange
  await tester.pumpWidget(MyApp());
  
  // Act - Navigate to create event screen
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
  
  // Fill in event details
  await tester.enterText(find.byKey(Key('event_name')), 'Test Event');
  await tester.tap(find.byKey(Key('event_type_wedding')));
  // ... more interactions
  
  // Submit the form
  await tester.tap(find.byKey(Key('submit_button')));
  await tester.pumpAndSettle();
  
  // Assert - Event is displayed in the list
  expect(find.text('Test Event'), findsOneWidget);
});
```

## Test Data

Create test data generators for each model to use in tests:

```dart
class TestDataGenerator {
  static User createTestUser() {
    return User(
      id: 'test_user_id',
      name: 'Test User',
      email: 'test@example.com',
      createdAt: DateTime.now(),
    );
  }
  
  static Event createTestEvent() {
    return Event(
      id: 'test_event_id',
      name: 'Test Event',
      type: EventType.wedding,
      date: DateTime.now().add(const Duration(days: 30)),
      location: 'Test Location',
      budget: 5000,
      guestCount: 100,
      userId: 'test_user_id',
    );
  }
  
  // ... more test data generators
}
```

## Test Environment

Set up a separate test environment in Supabase:

1. Create a test project in Supabase
2. Apply the same schema and RLS policies
3. Use different API keys for testing
4. Clean up test data after each test run

## Test Execution

1. Run unit tests with `flutter test test/services/supabase/database`
2. Run integration tests with `flutter test integration_test/`
3. Run end-to-end tests with `flutter test integration_test/e2e/`

## Test Reporting

Generate test reports to track test coverage and results:

1. Use `flutter test --coverage` to generate coverage reports
2. Use a CI/CD pipeline to run tests automatically
3. Track test results over time to identify regressions
