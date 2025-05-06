# Eventati Book Documentation

This documentation provides a comprehensive overview of the Eventati Book application.

## API Documentation

The [API Documentation](api/index.html) provides detailed information about the classes, methods, and properties in the codebase.

## Class Diagrams

Class diagrams show the relationships between classes in the codebase:

- [Models Diagram](diagrams/models.md)
- [Providers Diagram](diagrams/providers.md)
- [Services Diagram](diagrams/services.md)

## Widget Documentation

The [Widget Documentation](widgets/index.md) provides information about the custom widgets used in the application.

## How to Generate Documentation

Documentation is generated using the `generate_docs.dart` script:

```bash
# Generate documentation
dart run tool/generate_docs.dart

# Clean and regenerate documentation
dart run tool/generate_docs.dart --clean
```

## Documentation Standards

When writing documentation for the codebase, follow these guidelines:

1. **Class Documentation**: Add a `///` comment before each class explaining its purpose and usage.
2. **Method Documentation**: Add a `///` comment before each public method explaining what it does, its parameters, and return value.
3. **Property Documentation**: Add a `///` comment before each public property explaining what it represents.
4. **Example Usage**: Where appropriate, include example usage in documentation comments.

Example:

```dart
/// A widget that displays a custom button with consistent styling.
///
/// The button can be enabled or disabled, and can show a loading indicator
/// when an action is in progress.
///
/// Example usage:
/// ```dart
/// CustomButton(
///   label: 'Submit',
///   onPressed: () => submitForm(),
///   isLoading: isSubmitting,
/// )
/// ```
class CustomButton extends StatelessWidget {
  // ...
}
```
