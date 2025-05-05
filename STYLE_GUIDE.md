# Eventati Book Style Guide

## Table of Contents

1. [Introduction](#introduction)
2. [Code Style and Formatting](#code-style-and-formatting)
3. [Naming Conventions](#naming-conventions)
4. [File Organization](#file-organization)
5. [Architecture Guidelines](#architecture-guidelines)
6. [UI/UX Design Guidelines](#uiux-design-guidelines)
7. [Documentation Standards](#documentation-standards)
8. [Testing Standards](#testing-standards)
9. [Git Workflow](#git-workflow)
10. [Performance Guidelines](#performance-guidelines)

## Introduction

### Purpose

This style guide provides a set of standards and best practices for the Eventati Book project. Following these guidelines ensures:

- Consistent code style across the codebase
- Improved code readability and maintainability
- Easier onboarding for new developers
- Reduced technical debt
- Higher quality code

### How to Use This Guide

- **New Developers**: Read this guide thoroughly before contributing to the project
- **Existing Developers**: Use this guide as a reference when writing new code or refactoring existing code
- **Code Reviews**: Reference this guide during code reviews to ensure compliance

### How to Contribute to This Guide

If you believe a guideline should be added, modified, or removed:

1. Discuss the proposed change with the team
2. Create a pull request with the changes
3. Update any affected code to comply with the new guidelines

## Code Style and Formatting

### Dart Formatting

- Use the Dart formatter (`dart format` or `flutter format`) for all Dart files
- Run the formatter before committing code
- Configure your IDE to format on save

```dart
// DO
void main() {
  final greeting = 'Hello';
  print('$greeting, world!');
}

// DON'T
void main(){
final greeting='Hello';
print('$greeting, world!');}
```

### Line Length

- Maximum line length: 80 characters
- Break long lines at logical points
- For method chains, break before the `.`

```dart
// DO
final result = veryLongExpression
    .method1()
    .method2()
    .method3();

// DON'T
final result = veryLongExpression.method1().method2().method3();
```

### Indentation

- Use 2 spaces for indentation, not tabs
- Indent all continuation lines by 4 spaces
- Align parameters in multi-line function calls

```dart
// DO
void someFunction(
  String param1,
  String param2,
  String param3,
) {
  // Function body
}

// DON'T
void someFunction(String param1,
String param2,
String param3) {
  // Function body
}
```

### Comments

- Use `///` for documentation comments
- Use `//` for implementation comments
- Keep comments up-to-date with code changes
- Write comments in complete sentences with proper punctuation
- Avoid unnecessary comments that merely repeat the code

```dart
/// Returns the sum of two numbers.
///
/// The [a] parameter is the first number.
/// The [b] parameter is the second number.
int sum(int a, int b) {
  // Calculate the sum and return it
  return a + b;
}
```

### TODOs

- Format TODOs as `// TODO: Description of what needs to be done`
- Include your name or identifier: `// TODO(username): Description`
- Consider creating an issue for each TODO
- Review and address TODOs regularly

```dart
// TODO(john): Implement error handling for network failures
```

## Naming Conventions

### Files and Directories

- Use `snake_case` for file and directory names
- Use descriptive names that reflect the content
- Group related files in appropriate directories
- Use plural names for directories containing multiple items of the same type

```
lib/
  models/
    user.dart
    event.dart
  screens/
    home_screen.dart
    profile_screen.dart
  widgets/
    custom_button.dart
    loading_indicator.dart
```

### Classes and Types

- Use `PascalCase` for class names, enums, extensions, and typedefs
- Use nouns for class names
- Be specific and descriptive
- Avoid abbreviations and acronyms unless widely understood

```dart
// DO
class EventDetailsScreen extends StatelessWidget { ... }
enum EventType { wedding, business, celebration }

// DON'T
class EvtDtlsScr extends StatelessWidget { ... }
enum EvtType { w, b, c }
```

### Variables and Constants

- Use `camelCase` for variables and parameters
- Use `SCREAMING_SNAKE_CASE` for top-level constants
- Use descriptive names that convey purpose
- Avoid single-letter names except for loop indices

```dart
// DO
final int userCount = 10;
const String API_BASE_URL = 'https://api.example.com';

// DON'T
final int u = 10;
const String url = 'https://api.example.com';
```

### Functions and Methods

- Use `camelCase` for function and method names
- Use verbs for function names
- Be specific about what the function does
- Keep function names concise but descriptive

```dart
// DO
void fetchUserData() { ... }
String formatDateTime(DateTime dateTime) { ... }

// DON'T
void data() { ... }
String dt(DateTime dateTime) { ... }
```

### Parameters

- Use `camelCase` for parameter names
- Use descriptive names that convey purpose
- Use named parameters for functions with many parameters
- Use required for mandatory named parameters

```dart
// DO
void createEvent({
  required String name,
  required DateTime date,
  String? description,
  int guestCount = 0,
}) { ... }

// DON'T
void createEvent(String n, DateTime d, String? desc, int g) { ... }
```

### Providers

- Use `PascalCase` followed by `Provider` for provider class names
- Name providers after the data or functionality they provide
- Be specific about the provider's purpose

```dart
// DO
class AuthProvider extends ChangeNotifier { ... }
class EventProvider extends ChangeNotifier { ... }

// DON'T
class AuthProv extends ChangeNotifier { ... }
class DataProvider extends ChangeNotifier { ... }
```

### Widgets

- Use `PascalCase` for widget class names
- Use descriptive names that reflect the widget's purpose
- Suffix widget classes with the widget type for custom widgets

```dart
// DO
class EventCard extends StatelessWidget { ... }
class CustomButton extends StatelessWidget { ... }

// DON'T
class EvtCrd extends StatelessWidget { ... }
class Button extends StatelessWidget { ... }
```

## File Organization

### Project Structure

Follow this high-level project structure:

```
eventati_book/
  ├── android/
  ├── ios/
  ├── lib/
  │   ├── main.dart
  │   ├── models/
  │   ├── providers/
  │   ├── screens/
  │   ├── services/
  │   ├── utils/
  │   └── widgets/
  ├── test/
  ├── docs/
  ├── assets/
  ├── pubspec.yaml
  └── README.md
```

### Directory Organization

Organize the `lib` directory as follows:

- **models/**: Data models and DTOs
  - Organize into subdirectories by feature or domain
  - Create barrel files for each subdirectory
  
- **providers/**: State management providers
  - Organize into subdirectories by feature or domain
  - Create barrel files for each subdirectory
  
- **screens/**: UI screens
  - Organize into subdirectories by feature or domain
  - Include screen-specific widgets in the same directory
  
- **services/**: Business logic and external services
  - Organize into subdirectories by feature or domain
  - Create barrel files for each subdirectory
  
- **utils/**: Utility functions and constants
  - Organize into subdirectories by functionality
  - Create barrel files for each subdirectory
  
- **widgets/**: Reusable UI components
  - Organize into subdirectories by component type or feature
  - Create barrel files for each subdirectory

### Import Organization

- Organize imports in the following order, separated by blank lines:
  1. Dart SDK imports
  2. Flutter SDK imports
  3. Third-party package imports
  4. Project imports (using relative paths)
- Sort imports alphabetically within each group
- Use relative imports for project files

```dart
// Dart SDK imports
import 'dart:async';
import 'dart:io';

// Flutter SDK imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Third-party package imports
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
```

### Barrel Files

- Create barrel files (e.g., `models.dart`) for directories with 4+ files
- Export all public APIs from the barrel file
- Use the barrel file for imports when possible
- Organize exports alphabetically
- Add comments to group related exports

```dart
// models.dart

// Event models
export 'event/event.dart';
export 'event/event_type.dart';
export 'event/event_preferences.dart';

// User models
export 'user/user.dart';
export 'user/user_preferences.dart';

// Service models
export 'service/venue.dart';
export 'service/catering.dart';
export 'service/photographer.dart';
```

## Architecture Guidelines

### Layers

Follow a layered architecture with clear separation of concerns:

1. **UI Layer**: Screens and widgets
   - Responsible for displaying data and capturing user input
   - Should not contain business logic
   - Communicates with the Business Layer through providers

2. **Business Layer**: Providers and services
   - Responsible for business logic and state management
   - Communicates with the Data Layer to retrieve and store data
   - Provides data to the UI Layer

3. **Data Layer**: Models and repositories
   - Responsible for data storage and retrieval
   - Communicates with external services and local storage
   - Provides data to the Business Layer

### State Management

- Use the Provider pattern for state management
- Follow these guidelines for providers:
  - Keep providers focused on a specific domain or feature
  - Minimize dependencies between providers
  - Use `ChangeNotifier` for simple state management
  - Call `notifyListeners()` after state changes
  - Use `Consumer` or `Provider.of` to access provider state in the UI

```dart
// Provider definition
class CounterProvider extends ChangeNotifier {
  int _count = 0;
  
  int get count => _count;
  
  void increment() {
    _count++;
    notifyListeners();
  }
}

// Provider usage
Consumer<CounterProvider>(
  builder: (context, provider, child) {
    return Text('Count: ${provider.count}');
  },
)
```

### Dependency Injection

- Use Provider for dependency injection
- Register providers at the appropriate level in the widget tree
- Use `ProxyProvider` for providers that depend on other providers
- Avoid circular dependencies between providers

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
      create: (_) => UserProvider(null),
      update: (_, auth, previous) => UserProvider(auth),
    ),
  ],
  child: MaterialApp(...),
)
```

### Error Handling

- Handle errors at the appropriate level
- Use try-catch blocks for error-prone code
- Provide meaningful error messages
- Log errors for debugging
- Display user-friendly error messages in the UI
- Consider using a centralized error handling mechanism

```dart
Future<void> fetchData() async {
  try {
    final data = await api.getData();
    _data = data;
    _error = null;
  } catch (e) {
    _error = 'Failed to fetch data: ${e.toString()}';
    logError('fetchData', e);
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

### Asynchronous Code

- Use `async`/`await` for asynchronous code
- Handle errors in asynchronous code with try-catch blocks
- Show loading indicators during asynchronous operations
- Cancel ongoing operations when appropriate
- Use `Future.wait` for parallel operations

```dart
Future<void> loadData() async {
  setState(() {
    _isLoading = true;
  });
  
  try {
    final results = await Future.wait([
      api.fetchUsers(),
      api.fetchEvents(),
    ]);
    
    setState(() {
      _users = results[0];
      _events = results[1];
      _error = null;
    });
  } catch (e) {
    setState(() {
      _error = e.toString();
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}
```

## UI/UX Design Guidelines

### Colors and Themes

- Use the predefined color palette from `app_colors.dart`
- Use semantic color variables instead of direct color values
- Use the theme system for consistent styling
- Define light and dark themes
- Access colors through `Theme.of(context)`

```dart
// Color definitions
class AppColors {
  static const Color primary = Color(0xFF8B5A2B);
  static const Color secondary = Color(0xFFD2B48C);
  static const Color accent = Color(0xFFFF9800);
  static const Color background = Color(0xFFF5F5F5);
  static const Color error = Color(0xFFB00020);
  static const Color text = Color(0xFF333333);
  static const Color textLight = Color(0xFF666666);
}

// Theme usage
Text(
  'Hello World',
  style: Theme.of(context).textTheme.headline6,
)
```

### Typography

- Use the predefined text styles from `text_styles.dart`
- Use semantic text style variables instead of direct styling
- Use the theme system for consistent typography
- Define a clear typography hierarchy
- Ensure text is readable on all backgrounds

```dart
// Text style definitions
class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.text,
  );
}

// Text style usage
Text(
  'Hello World',
  style: AppTextStyles.headline1,
)
```

### Spacing and Layout

- Use consistent spacing throughout the application
- Define spacing constants in `app_dimensions.dart`
- Use semantic spacing variables instead of direct values
- Use responsive layouts that adapt to different screen sizes
- Use `EdgeInsets` for padding and margins

```dart
// Spacing definitions
class AppDimensions {
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
}

// Spacing usage
Padding(
  padding: EdgeInsets.all(AppDimensions.spacingM),
  child: Text('Hello World'),
)
```

### Responsive Design

- Design for multiple screen sizes and orientations
- Use `MediaQuery` to access screen dimensions
- Use `LayoutBuilder` for responsive layouts
- Use `FractionallySizedBox` for proportional sizing
- Use `Flexible` and `Expanded` for flexible layouts
- Test on different device sizes

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return WideLayout();
    } else {
      return NarrowLayout();
    }
  },
)
```

### Accessibility

- Ensure sufficient color contrast
- Provide text scaling support
- Add meaningful labels to interactive elements
- Use semantic widgets (`Semantics`, `ExcludeSemantics`)
- Support screen readers with appropriate text alternatives
- Test with accessibility tools

```dart
// Accessible button
ElevatedButton(
  onPressed: _handlePress,
  child: Text('Submit'),
  semanticsLabel: 'Submit form',
)
```

### Common Widgets

- Use the predefined widgets from the `widgets` directory
- Maintain consistent styling across similar widgets
- Create reusable widgets for common UI patterns
- Document widget parameters and behavior
- Test widgets for different configurations

```dart
// Custom button usage
CustomButton(
  label: 'Submit',
  onPressed: _handleSubmit,
  type: ButtonType.primary,
)
```

## Documentation Standards

### Code Documentation

- Document all public APIs with `///` comments
- Include a brief description of what the class or function does
- Document parameters, return values, and exceptions
- Include examples for complex APIs
- Keep documentation up-to-date with code changes

```dart
/// A service that manages user authentication.
///
/// This service handles user login, registration, and session management.
class AuthService {
  /// Logs in a user with the provided credentials.
  ///
  /// The [email] and [password] parameters are required.
  ///
  /// Returns a [User] object if login is successful.
  ///
  /// Throws [AuthException] if login fails.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final user = await authService.login('user@example.com', 'password');
  ///   print('Logged in as ${user.name}');
  /// } catch (e) {
  ///   print('Login failed: $e');
  /// }
  /// ```
  Future<User> login(String email, String password) async {
    // Implementation
  }
}
```

### Architecture Documentation

- Document the overall architecture in the `docs` directory
- Create diagrams for complex features
- Document the relationships between components
- Keep architecture documentation up-to-date with code changes
- Use ASCII diagrams for version control friendliness

### README Files

- Include a README.md file in the root directory
- Include README.md files in major directories
- Document the purpose and contents of the directory
- Include setup instructions and usage examples
- Keep README files up-to-date with code changes

### Diagrams

- Use ASCII diagrams for version control friendliness
- Include diagrams for complex features and flows
- Document the relationships between components
- Keep diagrams up-to-date with code changes
- Use consistent diagram styles

## Testing Standards

### Unit Tests

- Write unit tests for all business logic
- Use the `test` package for unit tests
- Follow the Arrange-Act-Assert pattern
- Mock dependencies for isolated testing
- Aim for high test coverage of business logic

```dart
void main() {
  group('Counter', () {
    test('should increment value', () {
      // Arrange
      final counter = Counter();
      
      // Act
      counter.increment();
      
      // Assert
      expect(counter.value, 1);
    });
  });
}
```

### Widget Tests

- Write widget tests for all custom widgets
- Use the `flutter_test` package for widget tests
- Test widget rendering and behavior
- Test widget interactions
- Test widget edge cases

```dart
void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
```

### Integration Tests

- Write integration tests for critical user flows
- Use the `integration_test` package for integration tests
- Test end-to-end functionality
- Test app startup and navigation
- Test interactions with external services

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete login flow', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Navigate to login screen
    await tester.tap(find.byType(LoginButton));
    await tester.pumpAndSettle();

    // Enter credentials
    await tester.enterText(find.byType(EmailField), 'user@example.com');
    await tester.enterText(find.byType(PasswordField), 'password');
    await tester.tap(find.byType(SubmitButton));
    await tester.pumpAndSettle();

    // Verify successful login
    expect(find.text('Welcome, User!'), findsOneWidget);
  });
}
```

### Test Naming

- Use descriptive test names that explain what is being tested
- Follow the pattern: `should [expected behavior] when [condition]`
- Group related tests together
- Use nested groups for complex test suites

```dart
group('AuthService', () {
  group('login', () {
    test('should return user when credentials are valid', () {
      // Test implementation
    });
    
    test('should throw AuthException when credentials are invalid', () {
      // Test implementation
    });
  });
});
```

### Test Organization

- Organize tests to mirror the structure of the source code
- Place test files in the `test` directory
- Use subdirectories to match the structure of the `lib` directory
- Name test files with a `_test` suffix

```
test/
  models/
    user_test.dart
    event_test.dart
  providers/
    auth_provider_test.dart
    event_provider_test.dart
  widgets/
    custom_button_test.dart
```

## Git Workflow

### Branch Naming

- Use descriptive branch names that reflect the purpose of the branch
- Follow the pattern: `type/description`
- Use lowercase and hyphens for branch names
- Common types: `feature`, `bugfix`, `hotfix`, `refactor`, `docs`

```
feature/add-event-wizard
bugfix/fix-login-validation
refactor/improve-error-handling
docs/update-readme
```

### Commit Messages

- Write clear and descriptive commit messages
- Follow the pattern: `type: description`
- Use the imperative mood (e.g., "Add" instead of "Added")
- Keep the first line under 50 characters
- Add details in the commit body if necessary
- Reference issue numbers when applicable

```
feat: add event wizard screen

- Add step-by-step wizard for creating events
- Implement validation for each step
- Connect to event provider for data persistence

Fixes #123
```

### Pull Requests

- Create pull requests for all changes
- Write clear and descriptive pull request titles
- Include a detailed description of the changes
- Reference issue numbers when applicable
- Request reviews from appropriate team members
- Address review comments promptly

### Code Reviews

- Review code for adherence to this style guide
- Check for potential bugs and edge cases
- Verify that tests are included and passing
- Provide constructive feedback
- Approve only when all issues are addressed

## Performance Guidelines

### Memory Management

- Dispose of resources when they are no longer needed
- Use `dispose` method in `StatefulWidget` to clean up resources
- Cancel subscriptions and listeners when they are no longer needed
- Avoid memory leaks by not holding references to objects that are no longer needed
- Use weak references when appropriate

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  StreamSubscription _subscription;
  
  @override
  void initState() {
    super.initState();
    _subscription = stream.listen(_handleData);
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
  
  // Rest of the implementation
}
```

### UI Performance

- Use `const` constructors for widgets that don't change
- Use `RepaintBoundary` to optimize painting
- Use `ListView.builder` for long lists
- Use `FutureBuilder` and `StreamBuilder` for asynchronous UI updates
- Avoid expensive operations in the build method
- Use `compute` for CPU-intensive operations

```dart
// Use const constructors
const MyWidget(
  key: Key('my-widget'),
  value: 42,
)

// Use ListView.builder for long lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(items[index].title),
    );
  },
)
```

### Network Requests

- Use caching for network requests
- Implement retry logic for failed requests
- Show loading indicators during network requests
- Handle network errors gracefully
- Use pagination for large data sets
- Cancel network requests when they are no longer needed

```dart
Future<void> fetchData() async {
  setState(() {
    _isLoading = true;
  });
  
  try {
    final data = await api.fetchData();
    setState(() {
      _data = data;
      _error = null;
    });
  } catch (e) {
    setState(() {
      _error = e.toString();
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}
```

### Image Handling

- Use appropriate image formats (JPEG for photos, PNG for graphics)
- Optimize images for size and quality
- Use cached network images for remote images
- Use appropriate resolution images for different screen sizes
- Lazy load images when appropriate
- Use placeholders for loading images

```dart
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

---

This style guide is a living document and will evolve as the project grows and best practices change. All team members are encouraged to contribute to its improvement.
