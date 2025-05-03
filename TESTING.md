# Testing Framework for Eventati Book

This document outlines the testing framework and guidelines for the Eventati Book application.

## Current Test Structure

The tests are organized into the following directories:

- `test/unit/`: Unit tests for models and utilities
  - `test/unit/models/`: Tests for model classes (e.g., User model)
  - `test/unit/utils/`: Tests for utility functions (e.g., StringUtils)

- `test/widget/`: Widget tests for UI components
  - `test/widget/widgets/`: Tests for reusable widgets (e.g., LoadingIndicator)

- `test/helpers/`: Helper functions and mock data for tests
  - `test/helpers/test_helpers.dart`: Test helpers for wrapping widgets
  - `test/helpers/mock_data.dart`: Mock data for tests

## Running Tests

### Running Individual Tests

To run a specific test file:

```bash
flutter test test/unit/models/simple_user_test.dart
```

### Running Working Tests

Currently, the following tests are working:

```bash
flutter test test/unit/models/simple_user_test.dart
flutter test test/unit/utils/string_utils_test.dart
flutter test test/widget/widgets/loading_indicator_test.dart
```

### Running All Tests

To run all tests:

```bash
flutter test
```

Or use the provided batch script:

```bash
run_tests.bat
```

## Test Coverage

To view the test coverage report:

1. Install lcov:
   ```bash
   npm install -g lcov
   ```

2. Generate the HTML report:
   ```bash
   genhtml coverage/lcov.info -o coverage/html
   ```

3. Open the report in your browser:
   ```bash
   open coverage/html/index.html
   ```

## Writing Tests

### Unit Tests

Unit tests should follow these guidelines:

1. Test each method or function in isolation
2. Use descriptive test names that explain what is being tested
3. Follow the Arrange-Act-Assert pattern
4. Test both normal and edge cases

Example:

```dart
test('capitalize should capitalize the first letter of a string', () {
  // Arrange
  const input = 'hello';

  // Act
  final result = StringUtils.capitalize(input);

  // Assert
  expect(result, equals('Hello'));
});
```

### Widget Tests

Widget tests should follow these guidelines:

1. Test widget rendering and behavior
2. Test different states (loading, error, empty)
3. Test user interactions
4. Use the provided test helpers

Example:

```dart
testWidgets('should render with message', (WidgetTester tester) async {
  // Arrange
  const testMessage = 'Loading...';

  // Act
  await tester.pumpWidget(
    wrapWithMaterialApp(
      const LoadingIndicator(message: testMessage),
    ),
  );

  // Assert
  expect(find.text(testMessage), findsOneWidget);
});
```

## Mocking

For mocking dependencies, we use the `mocktail` package. Create mock classes in the test files or in the `test/helpers/` directory.

Example:

```dart
class MockAuthProvider extends Mock implements AuthProvider {}
```

## Future Improvements

1. Add more unit tests for models and utilities
2. Fix issues with the existing test structure
3. Implement provider tests
4. Add more widget tests for screens
5. Implement integration tests for critical user flows
6. Set up CI/CD for automated testing

## Known Issues

1. Integration tests are not yet implemented
2. Some model tests (e.g., Milestone) have issues with the model structure
3. Widget tests for screens have issues with provider dependencies
4. Test coverage is currently limited to basic models and utilities
