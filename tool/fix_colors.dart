// ignore_for_file: avoid_print
import 'dart:io';

/// A script to fix hardcoded Colors instances in the codebase.
///
/// This script:
/// 1. Scans all Dart files in the lib directory
/// 2. Replaces hardcoded Colors with AppColors constants
/// 3. Adds necessary imports
///
/// Usage: dart run tool/fix_colors.dart [--dry-run] [--verbose] [path]
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

  print('🚀 Running Colors fixer...\n');
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

/// Processes a single file and fixes hardcoded Colors.
Future<ProcessResult> _processFile(File file, bool dryRun, bool verbose) async {
  final originalContent = await file.readAsString();
  var content = originalContent;
  final fixes = <String>[];

  // Add necessary imports if needed
  if (content.contains('Colors.') &&
      !content.contains(
        "import 'package:eventati_book/styles/app_colors.dart'",
      ) &&
      !file.path.contains('app_colors.dart')) {
    content = _addImport(
      content,
      "import 'package:eventati_book/styles/app_colors.dart';",
    );
    fixes.add('Added import for app_colors.dart');
  }

  // Fix hardcoded Colors
  content = _fixHardcodedColors(content, fixes);

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

/// Fixes hardcoded Colors in the content.
String _fixHardcodedColors(String content, List<String> fixes) {
  var newContent = content;

  // Define replacements
  final replacements = {
    'Colors.blue': 'AppColors.primary',
    'Colors.red': 'AppColors.error',
    'Colors.green': 'AppColors.success',
    'Colors.orange': 'AppColors.warning',
    'Colors.amber': 'AppColors.ratingStarColor',
    'Colors.grey': 'AppColors.disabled',
    'Colors.purple': 'AppColors.primary',
    'Colors.yellow': 'AppColors.warning',
    'Colors.cyan': 'AppColors.info',
    'Colors.pink': 'AppColors.primary',
    'Colors.teal': 'AppColors.info',
    'Colors.lightGreen': 'AppColors.success',
    'Colors.black87': 'AppColors.textPrimary',
    'Colors.black54': 'AppColors.textSecondary',
    'Colors.white70': 'Colors.white.withOpacity(0.7)',
    'Colors.white60': 'Colors.white.withOpacity(0.6)',
    'Colors.white54': 'Colors.white.withOpacity(0.54)',
  };

  // Apply replacements
  for (final entry in replacements.entries) {
    final regex = RegExp(entry.key);
    final matches = regex.allMatches(newContent);

    if (matches.isNotEmpty) {
      newContent = newContent.replaceAll(entry.key, entry.value);
      fixes.add(
        'Replaced ${entry.key} with ${entry.value} (${matches.length} occurrences)',
      );
    }
  }

  return newContent;
}
