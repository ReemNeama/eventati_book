// ignore_for_file: avoid_print
import 'dart:io';

/// A script to fix TextStyle instances in the codebase.
///
/// This script:
/// 1. Scans all Dart files in the lib directory
/// 2. Replaces hardcoded TextStyle with TextStyles constants
/// 3. Adds necessary imports
///
/// Usage: dart run tool/fix_text_styles.dart [--dry-run] [--verbose] [path]
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

  print('🚀 Running TextStyle fixer...\n');
  print('Mode: ${dryRun ? 'Dry run' : 'Fix'}');
  print('Path: $path\n');

  // Get all Dart files in the specified path
  final dartFiles = await _getDartFiles(path);
  print('Found ${dartFiles.length} Dart files to scan.\n');

  int totalFixedFiles = 0;
  int totalFixedIssues = 0;

  // Process each file
  for (final file in dartFiles) {
    final result = await _processFile(file, dryRun, verbose);
    if (result.fixedIssues > 0) {
      totalFixedFiles++;
      totalFixedIssues += result.fixedIssues;

      if (verbose) {
        print('Fixed ${result.fixedIssues} issues in ${file.path}');
        for (final fix in result.fixes) {
          print('  - $fix');
        }
        print('');
      } else if (result.fixedIssues > 0) {
        print('Fixed ${result.fixedIssues} issues in ${file.path}');
      }
    }
  }

  print('\nSummary:');
  print('- Total files processed: ${dartFiles.length}');
  print('- Files with fixes: $totalFixedFiles');
  print('- Total issues fixed: $totalFixedIssues');

  if (dryRun) {
    print('\nThis was a dry run. No changes were made.');
    print('Run without --dry-run to apply the changes.');
  }
}

/// Gets all Dart files in the specified path.
Future<List<File>> _getDartFiles(String path) async {
  final directory = Directory(path);
  final files = <File>[];

  if (await directory.exists()) {
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        files.add(entity);
      }
    }
  } else if (path.endsWith('.dart')) {
    final file = File(path);
    if (await file.exists()) {
      files.add(file);
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

/// Processes a single file and fixes TextStyle issues.
Future<ProcessResult> _processFile(File file, bool dryRun, bool verbose) async {
  final originalContent = await file.readAsString();
  var content = originalContent;
  final fixes = <String>[];

  // Fix TextStyle issues
  content = _fixTextStyleIssues(content, fixes);

  // Add necessary imports if there were any fixes
  if (fixes.isNotEmpty) {
    content = _addNecessaryImports(content, fixes);
  }

  // Write the changes to the file if there were any
  if (content != originalContent && !dryRun) {
    await file.writeAsString(content);
  }

  return ProcessResult(fixes.length, fixes);
}

/// Fixes TextStyle issues in the content.
String _fixTextStyleIssues(String content, List<String> fixes) {
  var newContent = content;

  // Define patterns to look for and their replacements
  final patterns = [
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
        r'TextStyle\(\s*fontSize:\s*20(\.\d+)?\s*,\s*fontWeight:\s*FontWeight\.bold',
      ),
      'replacement': 'TextStyles.subtitle',
      'description': 'Subtitle TextStyle',
    },
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontWeight:\s*FontWeight\.bold\s*,\s*fontSize:\s*20(\.\d+)?',
      ),
      'replacement': 'TextStyles.subtitle',
      'description': 'Subtitle TextStyle',
    },

    // Section title styles
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontSize:\s*18(\.\d+)?\s*,\s*fontWeight:\s*FontWeight\.bold',
      ),
      'replacement': 'TextStyles.sectionTitle',
      'description': 'Section title TextStyle',
    },
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontWeight:\s*FontWeight\.bold\s*,\s*fontSize:\s*18(\.\d+)?',
      ),
      'replacement': 'TextStyles.sectionTitle',
      'description': 'Section title TextStyle',
    },

    // Body large with bold
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontSize:\s*16(\.\d+)?\s*,\s*fontWeight:\s*FontWeight\.bold',
      ),
      'replacement':
          'TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)',
      'description': 'Body large bold TextStyle',
    },
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontWeight:\s*FontWeight\.bold\s*,\s*fontSize:\s*16(\.\d+)?',
      ),
      'replacement':
          'TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)',
      'description': 'Body large bold TextStyle',
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

    // Styles with fontStyle
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontSize:\s*16(\.\d+)?\s*,\s*fontStyle:\s*FontStyle\.italic',
      ),
      'replacement':
          'TextStyles.bodyLarge.copyWith(fontStyle: FontStyle.italic)',
      'description': 'Body large italic TextStyle',
    },
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontStyle:\s*FontStyle\.italic\s*,\s*fontSize:\s*16(\.\d+)?',
      ),
      'replacement':
          'TextStyles.bodyLarge.copyWith(fontStyle: FontStyle.italic)',
      'description': 'Body large italic TextStyle',
    },
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontSize:\s*14(\.\d+)?\s*,\s*fontStyle:\s*FontStyle\.italic',
      ),
      'replacement':
          'TextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic)',
      'description': 'Body medium italic TextStyle',
    },
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontStyle:\s*FontStyle\.italic\s*,\s*fontSize:\s*14(\.\d+)?',
      ),
      'replacement':
          'TextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic)',
      'description': 'Body medium italic TextStyle',
    },

    // Simple TextStyle
    {
      'pattern': RegExp(r'TextStyle\(\s*\)'),
      'replacement': 'TextStyles.bodyMedium',
      'description': 'Empty TextStyle',
    },
  ];

  for (final pattern in patterns) {
    final regex = pattern['pattern'] as RegExp;
    final replacement = pattern['replacement'] as String;
    final description = pattern['description'] as String;

    if (regex.hasMatch(newContent)) {
      final matches = regex.allMatches(newContent);
      for (final match in matches) {
        final fullMatch = match.group(0)!;

        // Extract any color or other properties from the original TextStyle
        final colorMatch = RegExp(r'color:\s*([^,\)]+)').firstMatch(fullMatch);
        final fontStyleMatch = RegExp(
          r'fontStyle:\s*([^,\)]+)',
        ).firstMatch(fullMatch);
        final fontWeightMatch = RegExp(
          r'fontWeight:\s*([^,\)]+)',
        ).firstMatch(fullMatch);
        final letterSpacingMatch = RegExp(
          r'letterSpacing:\s*([^,\)]+)',
        ).firstMatch(fullMatch);
        final heightMatch = RegExp(
          r'height:\s*([^,\)]+)',
        ).firstMatch(fullMatch);

        String newStyle = replacement;

        // If the replacement already has copyWith, we need to modify it
        if (replacement.contains('.copyWith(')) {
          // Extract the base style and existing properties
          final baseStyle = replacement.split('.copyWith(')[0];
          final existingProps = replacement
              .split('.copyWith(')[1]
              .replaceAll(')', '');

          // Start building the new copyWith
          newStyle = '$baseStyle.copyWith(';

          // Add existing properties
          if (existingProps.isNotEmpty) {
            newStyle += '$existingProps, ';
          }

          // Add additional properties
          if (colorMatch != null && !existingProps.contains('color:')) {
            newStyle += 'color: ${colorMatch.group(1)}, ';
          }
          if (fontStyleMatch != null &&
              !existingProps.contains('fontStyle:') &&
              !fullMatch.contains('FontStyle.italic')) {
            newStyle += 'fontStyle: ${fontStyleMatch.group(1)}, ';
          }
          if (fontWeightMatch != null &&
              !existingProps.contains('fontWeight:') &&
              !fullMatch.contains('FontWeight.bold')) {
            newStyle += 'fontWeight: ${fontWeightMatch.group(1)}, ';
          }
          if (letterSpacingMatch != null &&
              !existingProps.contains('letterSpacing:')) {
            newStyle += 'letterSpacing: ${letterSpacingMatch.group(1)}, ';
          }
          if (heightMatch != null && !existingProps.contains('height:')) {
            newStyle += 'height: ${heightMatch.group(1)}, ';
          }

          // Clean up and close
          newStyle = newStyle.trimRight();
          if (newStyle.endsWith(',')) {
            newStyle = newStyle.substring(0, newStyle.length - 1);
          }
          newStyle += ')';
        }
        // Otherwise, check if we need to add copyWith
        else if (colorMatch != null ||
            fontStyleMatch != null ||
            (fontWeightMatch != null && !replacement.contains('fontWeight')) ||
            letterSpacingMatch != null ||
            heightMatch != null) {
          newStyle += '.copyWith(';
          if (colorMatch != null) {
            newStyle += 'color: ${colorMatch.group(1)}, ';
          }
          if (fontStyleMatch != null &&
              !fullMatch.contains('FontStyle.italic')) {
            newStyle += 'fontStyle: ${fontStyleMatch.group(1)}, ';
          }
          if (fontWeightMatch != null &&
              !fullMatch.contains('FontWeight.bold') &&
              !replacement.contains('title') &&
              !replacement.contains('subtitle') &&
              !replacement.contains('fontWeight')) {
            newStyle += 'fontWeight: ${fontWeightMatch.group(1)}, ';
          }
          if (letterSpacingMatch != null) {
            newStyle += 'letterSpacing: ${letterSpacingMatch.group(1)}, ';
          }
          if (heightMatch != null) {
            newStyle += 'height: ${heightMatch.group(1)}, ';
          }
          newStyle = newStyle.trimRight();
          if (newStyle.endsWith(',')) {
            newStyle = newStyle.substring(0, newStyle.length - 1);
          }
          newStyle += ')';
        }

        // Replace the full TextStyle with the new style
        // Escape special regex characters in the fullMatch
        final escapedFullMatch = fullMatch
            .replaceAll('(', '\\(')
            .replaceAll(')', '\\)')
            .replaceAll('[', '\\[')
            .replaceAll(']', '\\]')
            .replaceAll('.', '\\.')
            .replaceAll('*', '\\*')
            .replaceAll('+', '\\+')
            .replaceAll('?', '\\?');

        final fullTextStyleRegex = RegExp('$escapedFullMatch[^\\)]*\\)');
        final fullTextStyle = fullTextStyleRegex
            .firstMatch(newContent)
            ?.group(0);

        if (fullTextStyle != null) {
          newContent = newContent.replaceAll(fullTextStyle, newStyle);
          fixes.add('Replaced $description with $newStyle');
        }
      }
    }
  }

  return newContent;
}

/// Adds necessary imports to the content.
String _addNecessaryImports(String content, List<String> fixes) {
  var newContent = content;

  // Check if we need to add the TextStyles import
  if (fixes.any((fix) => fix.contains('TextStyles'))) {
    if (!newContent.contains(
      "import 'package:eventati_book/styles/text_styles.dart'",
    )) {
      // Find the last import statement
      final importRegex = RegExp(r"import '.*';");
      final matches = importRegex.allMatches(newContent);

      if (matches.isEmpty) {
        // No imports found, add at the beginning
        newContent =
            "import 'package:eventati_book/styles/text_styles.dart';\n\n$newContent";
      } else {
        // Add after the last import
        final lastMatch = matches.last;
        final index = lastMatch.end;
        newContent =
            '${newContent.substring(0, index)}\nimport \'package:eventati_book/styles/text_styles.dart\';${newContent.substring(index)}';
      }
    }
  }

  return newContent;
}
