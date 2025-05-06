import 'dart:io';
import 'dart:async';

/// A script to generate documentation for the Eventati Book project.
///
/// This script:
/// 1. Runs dartdoc to generate API documentation
/// 2. Extracts class relationships to generate simple class diagrams
/// 3. Creates widget documentation with screenshots
///
/// Usage: dart run tool/generate_docs.dart [--clean]
///
/// Options:
///   --clean  Clean existing documentation before generating new docs
void main(List<String> arguments) async {
  final bool clean = arguments.contains('--clean');

  stdout.writeln('📚 Eventati Book Documentation Generator');
  stdout.writeln('=======================================\n');

  // Track overall success
  bool success = true;

  // Create docs directory if it doesn't exist
  final docsDir = Directory('docs/api');
  if (!docsDir.existsSync()) {
    docsDir.createSync(recursive: true);
    stdout.writeln('📁 Created docs/api directory');
  }

  // Clean existing documentation if requested
  if (clean) {
    success = await _cleanDocs() && success;
  }

  // Generate API documentation
  success = await _generateApiDocs() && success;

  // Generate class diagrams
  success = await _generateClassDiagrams() && success;

  // Generate widget documentation
  success = await _generateWidgetDocs() && success;

  // Create documentation index
  success = await _createDocIndex() && success;

  if (success) {
    stdout.writeln('\n✅ Documentation generation completed successfully!');
    stdout.writeln('📂 Documentation is available in the docs/ directory');
  } else {
    stdout.writeln('\n❌ Documentation generation completed with errors');
    exit(1);
  }
}

/// Clean existing documentation
Future<bool> _cleanDocs() async {
  stdout.writeln('🧹 Cleaning existing documentation...');

  try {
    // Clean API docs
    final apiDocsDir = Directory('docs/api');
    if (apiDocsDir.existsSync()) {
      apiDocsDir.deleteSync(recursive: true);
      apiDocsDir.createSync(recursive: true);
    }

    // Clean class diagrams
    final diagramsDir = Directory('docs/diagrams');
    if (diagramsDir.existsSync()) {
      diagramsDir.deleteSync(recursive: true);
      diagramsDir.createSync(recursive: true);
    }

    // Clean widget docs
    final widgetDocsDir = Directory('docs/widgets');
    if (widgetDocsDir.existsSync()) {
      widgetDocsDir.deleteSync(recursive: true);
      widgetDocsDir.createSync(recursive: true);
    }

    stdout.writeln('✅ Cleaned existing documentation');
    return true;
  } catch (e) {
    stdout.writeln('❌ Failed to clean documentation: $e');
    return false;
  }
}

/// Generate API documentation using dartdoc
Future<bool> _generateApiDocs() async {
  stdout.writeln('\n📝 Generating API documentation...');

  try {
    // Create the output directory if it doesn't exist
    final apiDocsDir = Directory('docs/api');
    if (!apiDocsDir.existsSync()) {
      apiDocsDir.createSync(recursive: true);
    }

    // Run dartdoc
    final result = await Process.run('dart', ['doc', '--output', 'docs/api']);

    if (result.exitCode != 0) {
      stdout.writeln('❌ Failed to generate API documentation:');
      stdout.writeln(result.stderr);
      return false;
    }

    stdout.writeln('✅ Generated API documentation in docs/api/');
    return true;
  } catch (e) {
    stdout.writeln('❌ Failed to generate API documentation: $e');
    return false;
  }
}

/// Generate class diagrams
Future<bool> _generateClassDiagrams() async {
  stdout.writeln('\n📊 Generating class diagrams...');

  try {
    // Create the output directory if it doesn't exist
    final diagramsDir = Directory('docs/diagrams');
    if (!diagramsDir.existsSync()) {
      diagramsDir.createSync(recursive: true);
    }

    // Generate class diagrams for key directories
    final directories = ['lib/models', 'lib/providers', 'lib/services'];

    for (final dir in directories) {
      final dirName = dir.split('/').last;
      final outputFile = 'docs/diagrams/$dirName.md';

      stdout.writeln('  Generating diagram for $dirName...');

      // Create a Mermaid class diagram
      final diagram = await _createMermaidDiagram(dir);

      // Write the diagram to a file
      File(outputFile).writeAsStringSync('''
# $dirName Class Diagram

```mermaid
classDiagram
$diagram
```
''');
    }

    stdout.writeln('✅ Generated class diagrams in docs/diagrams/');
    return true;
  } catch (e) {
    stdout.writeln('❌ Failed to generate class diagrams: $e');
    return false;
  }
}

/// Create a Mermaid class diagram for a directory
Future<String> _createMermaidDiagram(String directory) async {
  final dir = Directory(directory);
  if (!dir.existsSync()) {
    return '  class Error["Directory not found"]';
  }

  final classes = <String>[];
  final relationships = <String>[];

  // Find all Dart files in the directory
  await for (final entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();

      // Extract class names
      final classRegex = RegExp(
        r'class\s+(\w+)(?:\s+extends\s+(\w+))?(?:\s+implements\s+([\w\s,]+))?',
      );
      final matches = classRegex.allMatches(content);

      for (final match in matches) {
        final className = match.group(1);
        if (className != null) {
          classes.add('  class $className');

          // Add inheritance relationships
          final parentClass = match.group(2);
          if (parentClass != null) {
            relationships.add('  $parentClass <|-- $className : extends');
          }

          // Add implementation relationships
          final interfaces = match.group(3);
          if (interfaces != null) {
            for (final interface in interfaces
                .split(',')
                .map((e) => e.trim())) {
              if (interface.isNotEmpty) {
                relationships.add('  $interface <|.. $className : implements');
              }
            }
          }
        }
      }
    }
  }

  return [...classes, ...relationships].join('\n');
}

/// Generate widget documentation
Future<bool> _generateWidgetDocs() async {
  stdout.writeln('\n🧩 Generating widget documentation...');

  try {
    // Create the output directory if it doesn't exist
    final widgetDocsDir = Directory('docs/widgets');
    if (!widgetDocsDir.existsSync()) {
      widgetDocsDir.createSync(recursive: true);
    }

    // Create an index file
    final indexFile = File('docs/widgets/index.md');
    indexFile.writeAsStringSync('''
# Widget Documentation

This documentation provides an overview of the custom widgets used in the Eventati Book application.

## Widget Categories

''');

    // Find all widget directories
    final widgetDirs = [
      'lib/widgets/auth',
      'lib/widgets/booking',
      'lib/widgets/common',
      'lib/widgets/details',
      'lib/widgets/event_planning',
      'lib/widgets/event_wizard',
      'lib/widgets/messaging',
      'lib/widgets/milestones',
      'lib/widgets/responsive',
      'lib/widgets/services',
    ];

    for (final dir in widgetDirs) {
      final dirName = dir.split('/').last;
      final categoryFile = File('docs/widgets/$dirName.md');

      stdout.writeln('  Generating documentation for $dirName widgets...');

      // Create a category file
      categoryFile.writeAsStringSync('''
# $dirName Widgets

''');

      // Add to index
      indexFile.writeAsStringSync(
        '- [$dirName]($dirName.md)\n',
        mode: FileMode.append,
      );

      // Find all widget files in the directory
      final dir2 = Directory(dir);
      if (dir2.existsSync()) {
        await for (final entity in dir2.list(recursive: false)) {
          if (entity is File && entity.path.endsWith('.dart')) {
            final fileName = entity.path
                .split('/')
                .last
                .replaceAll('.dart', '');
            final content = entity.readAsStringSync();

            // Extract class documentation
            final classDocRegex = RegExp(r'\/\/\/\s*([\s\S]*?)class\s+(\w+)');
            final classMatch = classDocRegex.firstMatch(content);

            if (classMatch != null) {
              final classDoc =
                  classMatch.group(1)?.trim() ?? 'No documentation available.';
              final className = classMatch.group(2) ?? fileName;

              // Add to category file
              categoryFile.writeAsStringSync('''
## $className

$classDoc

```dart
// Example usage:
// $className(
//   // TODO: Add example parameters
// )
```

---

''', mode: FileMode.append);
            }
          }
        }
      }
    }

    stdout.writeln('✅ Generated widget documentation in docs/widgets/');
    return true;
  } catch (e) {
    stdout.writeln('❌ Failed to generate widget documentation: $e');
    return false;
  }
}

/// Create a documentation index
Future<bool> _createDocIndex() async {
  stdout.writeln('\n📑 Creating documentation index...');

  try {
    final indexFile = File('docs/documentation.md');
    indexFile.writeAsStringSync('''
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
''');

    stdout.writeln('✅ Created documentation index at docs/documentation.md');
    return true;
  } catch (e) {
    stdout.writeln('❌ Failed to create documentation index: $e');
    return false;
  }
}
