// ignore_for_file: avoid_print
import 'dart:io';

/// An enhanced script to fix TextStyle instances in the codebase.
///
/// This script:
/// 1. Scans all Dart files in the lib directory
/// 2. Replaces hardcoded TextStyle with TextStyles constants
/// 3. Adds necessary imports
///
/// Usage: dart run tool/fix_text_styles_enhanced.dart [--dry-run] [--verbose] [path]
///
/// Options:
///   --dry-run  Show what would be changed without making actual changes
///   --verbose  Show detailed information about changes
///   path       Path to a specific file or directory to process (default: lib)
void main(List<String> arguments) async {
  final bool dryRun = arguments.contains('--dry-run');
  final bool verbose = arguments.contains('--verbose');

  String path = 'lib';
  for (final arg in arguments) {
    if (!arg.startsWith('--') && arg != 'lib') {
      path = arg;
      break;
    }
  }

  print('🚀 Running Enhanced TextStyle fixer...\n');
  print('Mode: ${dryRun ? 'Dry Run' : 'Fix'}');
  print('Path: $path\n');

  // Get all Dart files in the specified directory
  final files = await _getDartFiles(path);
  print('Found ${files.length} Dart files to scan.\n');

  int totalFixedIssues = 0;
  int totalFixedFiles = 0;

  // Process each file
  for (final file in files) {
    final result = await _processFile(file, dryRun, verbose);

    if (result.fixedIssues > 0) {
      totalFixedIssues += result.fixedIssues;
      totalFixedFiles++;

      if (verbose) {
        print('Fixed ${result.fixedIssues} issues in ${file.path}:');
        for (final fix in result.fixes) {
          print('  - $fix');
        }
        print('');
      } else if (!dryRun) {
        print('Fixed ${result.fixedIssues} issues in ${file.path}');
      }
    }
  }

  print('\nSummary:');
  print('- Total files processed: ${files.length}');
  print('- Files with fixes: $totalFixedFiles');
  print('- Total issues fixed: $totalFixedIssues');
}

/// Gets all Dart files in the specified directory.
Future<List<File>> _getDartFiles(String path) async {
  final entity = FileSystemEntity.typeSync(path);
  final files = <File>[];

  if (entity == FileSystemEntityType.file) {
    if (path.endsWith('.dart')) {
      files.add(File(path));
    }
  } else if (entity == FileSystemEntityType.directory) {
    final dir = Directory(path);
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        files.add(entity);
      }
    }
  }

  return files;
}

/// Result of processing a file.
class ProcessResult {
  final int fixedIssues;
  final List<String> fixes;

  ProcessResult(this.fixedIssues, this.fixes);
}

/// Processes a single file and fixes TextStyle instances.
Future<ProcessResult> _processFile(File file, bool dryRun, bool verbose) async {
  final originalContent = await file.readAsString();
  var content = originalContent;
  final fixes = <String>[];

  // Add necessary imports if needed
  if (content.contains('TextStyle(') &&
      !content.contains(
        "import 'package:eventati_book/styles/text_styles.dart'",
      ) &&
      !file.path.contains('text_styles.dart')) {
    content = _addImport(
      content,
      "import 'package:eventati_book/styles/text_styles.dart';",
    );
    fixes.add('Added import for text_styles.dart');
  }

  // Fix TextStyle instances
  content = _fixTextStyles(content, fixes);

  // Write the changes to the file if there were any
  if (content != originalContent && !dryRun) {
    await file.writeAsString(content);
  }

  return ProcessResult(fixes.length, fixes);
}

/// Adds an import statement to the content.
String _addImport(String content, String importStatement) {
  // Find the last import statement
  final importRegex = RegExp(r"import\s+'[^']+';");
  final matches = importRegex.allMatches(content).toList();

  if (matches.isNotEmpty) {
    final lastImport = matches.last;
    final index = lastImport.end;
    return '${content.substring(0, index)}\n$importStatement${content.substring(index)}';
  } else {
    // If no imports found, add after any comments at the top
    final lines = content.split('\n');
    int insertIndex = 0;

    for (int i = 0; i < lines.length; i++) {
      if (!lines[i].trim().startsWith('//') &&
          !lines[i].trim().startsWith('/*') &&
          lines[i].trim().isNotEmpty) {
        insertIndex = i;
        break;
      }
    }

    lines.insert(insertIndex, importStatement);
    return lines.join('\n');
  }
}

/// Fixes TextStyle instances in the content.
String _fixTextStyles(String content, List<String> fixes) {
  var newContent = content;

  // Define patterns to look for and their replacements
  final patterns = [
    // Empty TextStyle
    {
      'pattern': RegExp(r'TextStyle\(\s*\)'),
      'replacement': 'TextStyles.bodyMedium',
      'description': 'Empty TextStyle',
    },

    // Title styles
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontSize:\s*24(\.\d+)?\s*,\s*fontWeight:\s*FontWeight\.bold',
      ),
      'replacement': 'TextStyles.title',
      'description': 'Title TextStyle',
    },
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontWeight:\s*FontWeight\.bold\s*,\s*fontSize:\s*24(\.\d+)?',
      ),
      'replacement': 'TextStyles.title',
      'description': 'Title TextStyle',
    },

    // Subtitle styles
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontSize:\s*18(\.\d+)?\s*,\s*fontWeight:\s*FontWeight\.(bold|w600)',
      ),
      'replacement': 'TextStyles.subtitle',
      'description': 'Subtitle TextStyle',
    },
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontWeight:\s*FontWeight\.(bold|w600)\s*,\s*fontSize:\s*18(\.\d+)?',
      ),
      'replacement': 'TextStyles.subtitle',
      'description': 'Subtitle TextStyle',
    },

    // Section title styles
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontSize:\s*16(\.\d+)?\s*,\s*fontWeight:\s*FontWeight\.(bold|w600)',
      ),
      'replacement': 'TextStyles.sectionTitle',
      'description': 'Section title TextStyle',
    },
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontWeight:\s*FontWeight\.(bold|w600)\s*,\s*fontSize:\s*16(\.\d+)?',
      ),
      'replacement': 'TextStyles.sectionTitle',
      'description': 'Section title TextStyle',
    },

    // Body styles
    {
      'pattern': RegExp(r'TextStyle\(\s*fontSize:\s*16(\.\d+)?'),
      'replacement': 'TextStyles.bodyLarge',
      'description': 'Body large TextStyle',
    },
    {
      'pattern': RegExp(r'TextStyle\(\s*fontSize:\s*14(\.\d+)?'),
      'replacement': 'TextStyles.bodyMedium',
      'description': 'Body medium TextStyle',
    },
    {
      'pattern': RegExp(r'TextStyle\(\s*fontSize:\s*12(\.\d+)?'),
      'replacement': 'TextStyles.bodySmall',
      'description': 'Body small TextStyle',
    },
    {
      'pattern': RegExp(r'TextStyle\(\s*fontSize:\s*10(\.\d+)?'),
      'replacement': 'TextStyles.caption',
      'description': 'Caption TextStyle',
    },
  ];

  // Apply patterns
  for (final pattern in patterns) {
    final regex = pattern['pattern'] as RegExp;
    final replacement = pattern['replacement'] as String;
    final description = pattern['description'] as String;

    final matches = regex.allMatches(newContent);
    if (matches.isNotEmpty) {
      for (final match in matches) {
        final fullMatch = match.group(0)!;

        // Get the full TextStyle including all parameters
        final fullTextStyleRegex = RegExp('$fullMatch[^\\)]*\\)');
        final fullTextStyle = fullTextStyleRegex
            .firstMatch(newContent)
            ?.group(0);

        if (fullTextStyle != null) {
          newContent = newContent.replaceAll(fullTextStyle, replacement);
          fixes.add('Replaced $description with $replacement');
        }
      }
    }
  }

  return newContent;
}
