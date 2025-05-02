# Flutter Linting Guidelines

## Introduction

This document outlines common linting issues encountered in the Eventati Book project and provides guidance on how to fix and prevent them. Following these guidelines will help maintain code quality, improve performance, and make collaboration easier.

Code quality matters because:
- Consistent code style improves readability and maintainability
- Some linting rules (like const constructors) improve application performance
- Following established conventions makes onboarding new developers easier
- Clean code reduces the likelihood of bugs and makes them easier to find

## Common Linting Issues

### 1. `prefer_const_constructors`

**Issue**: Not using the `const` keyword with constructors when all constructor arguments are constant.

**Why it matters**: Using `const` constructors improves performance by allowing Flutter to reuse widget instances rather than creating new ones.

**Example**:

❌ Incorrect:
```dart
SizedBox(height: AppConstants.mediumPadding)
```

✅ Correct:
```dart
const SizedBox(height: AppConstants.mediumPadding)
```

### 2. `prefer_single_quotes`

**Issue**: Using double quotes for string literals when single quotes should be used.

**Why it matters**: Dart style guidelines recommend using single quotes for string literals unless the string contains single quotes.

**Example**:

❌ Incorrect:
```dart
"Wedding Planning Checklist"
```

✅ Correct:
```dart
'Wedding Planning Checklist'
```

### 3. `prefer_final_locals`

**Issue**: Not declaring local variables as `final` when they are only assigned once.

**Why it matters**: Using `final` makes code more robust by preventing accidental reassignment and clarifies intent.

**Example**:

❌ Incorrect:
```dart
List<String> localSelectedCuisineTypes = List.from(_selectedCuisineTypes);
```

✅ Correct:
```dart
final List<String> localSelectedCuisineTypes = List.from(_selectedCuisineTypes);
```

### 4. `prefer_const_declarations`

**Issue**: Using `final` instead of `const` for variables initialized with constant values.

**Why it matters**: Using `const` for compile-time constants improves performance and makes intent clearer.

**Example**:

❌ Incorrect:
```dart
final userTextColor = Colors.white;
```

✅ Correct:
```dart
const userTextColor = Colors.white;
```

## How to Fix Linting Issues

### Manual Fixes

#### For `prefer_const_constructors`:
1. Add the `const` keyword before the constructor
2. Make sure all child widgets are also const if possible
3. For nested widgets, you may need to add const to parent widgets first

#### For `prefer_single_quotes`:
1. Replace double quotes with single quotes for string literals
2. Only use double quotes when the string contains single quotes

#### For `prefer_final_locals`:
1. Add the `final` keyword before variable declarations that are only assigned once

#### For `prefer_const_declarations`:
1. Replace `final` with `const` for variables initialized with constant values

### Using IDE Tools

Most IDEs provide quick fixes for linting issues:

1. In VS Code or Android Studio, hover over the linting error
2. Look for the lightbulb icon or quick fix option
3. Select "Add const" or the appropriate fix

### Using Flutter CLI

Run the following command to see all linting issues:
```
flutter analyze
```

To automatically fix some issues:
```
dart fix --apply
```

## Prevention

### Configure Analysis Options

Ensure your `analysis_options.yaml` file includes appropriate linting rules:

```yaml
linter:
  rules:
    - prefer_const_constructors
    - prefer_single_quotes
    - prefer_final_locals
    - prefer_const_declarations
```

### IDE Setup

1. Install the Dart and Flutter extensions for your IDE
2. Enable "Format on Save" to automatically fix some issues
3. Configure your IDE to show linting errors inline

### Code Review Checklist

Add these items to your code review checklist:
- [ ] Const constructors used where appropriate
- [ ] Consistent use of single quotes for strings
- [ ] Local variables declared as final when possible
- [ ] Const used for compile-time constants

## Examples from Our Codebase

### Fixed `prefer_const_constructors`:

Before:
```dart
padding: EdgeInsets.symmetric(
  horizontal: AppConstants.mediumPadding,
  vertical: AppConstants.smallPadding / 2,
),
```

After:
```dart
padding: const EdgeInsets.symmetric(
  horizontal: AppConstants.mediumPadding,
  vertical: AppConstants.smallPadding / 2,
),
```

### Fixed `prefer_single_quotes`:

Before:
```dart
"Plan Your ${widget.template.name}",
```

After:
```dart
'Plan Your ${widget.template.name}',
```

### Fixed `prefer_final_locals`:

Before:
```dart
RangeValues localPriceRange = _priceRange;
RangeValues localCapacityRange = _capacityRange;
List<String> localSelectedCuisineTypes = List.from(_selectedCuisineTypes);
```

After:
```dart
RangeValues localPriceRange = _priceRange;
RangeValues localCapacityRange = _capacityRange;
final List<String> localSelectedCuisineTypes = List.from(_selectedCuisineTypes);
```

### Fixed `prefer_const_declarations`:

Before:
```dart
final textColor = Colors.black87;
final hintColor = Colors.black54;
final borderColor = Colors.white70;
final fillColor = Colors.white;
```

After:
```dart
const textColor = Colors.black87;
const hintColor = Colors.black54;
const borderColor = Colors.white70;
const fillColor = Colors.white;
```

## Tools and Resources

- [Effective Dart: Style](https://dart.dev/guides/language/effective-dart/style) - Official Dart style guide
- [Flutter Lints Package](https://pub.dev/packages/flutter_lints) - Recommended set of lints
- [Dart Fix](https://dart.dev/tools/dart-fix) - CLI tool to automatically fix issues
- [VS Code Dart Extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code) - Provides linting and quick fixes
- [Android Studio/IntelliJ Dart Plugin](https://plugins.jetbrains.com/plugin/6351-dart) - IDE support for Dart

## Conclusion

Following these linting guidelines will help maintain a clean, efficient, and consistent codebase. While it may seem like extra work initially, these practices will save time in the long run by preventing bugs and making the code easier to understand and maintain.

Remember that linting is just one aspect of code quality. Always consider readability, maintainability, and performance in your coding decisions.
