# Testing Structure

This directory contains tests for the Eventati Book application.

## Directory Structure

- `unit/`: Unit tests for models, utilities, and providers
  - `models/`: Tests for model classes
  - `utils/`: Tests for utility functions
  - `providers/`: Tests for provider classes
- `widget/`: Widget tests for UI components
  - `screens/`: Tests for screen widgets
  - `widgets/`: Tests for reusable widgets
- `helpers/`: Helper functions and mock data for tests

## Running Tests

To run all tests:

```bash
flutter test
```

To run tests with coverage:

```bash
flutter test --coverage
```

To generate a coverage report:

```bash
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html
```

## Test Guidelines

1. **Naming Convention**: Test files should be named `{file_name}_test.dart`
2. **Test Groups**: Use `group()` to organize related tests
3. **Test Description**: Write clear test descriptions that explain what is being tested
4. **Mocking**: Use mockito or mocktail for mocking dependencies
5. **Coverage**: Aim for high test coverage of models and utilities
