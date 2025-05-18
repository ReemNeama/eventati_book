// ignore_for_file: avoid_print
import 'dart:io';

/// An enhanced script to fix withOpacity issues in the codebase.
///
/// This script:
/// 1. Scans all Dart files in the lib directory
/// 2. Replaces withOpacity with Color.fromRGBO
/// 3. Adds necessary imports
///
/// Usage: dart run tool/fix_with_opacity_enhanced.dart [--dry-run] [--verbose] [path]
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

  print('🚀 Running Enhanced withOpacity fixer...\n');
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

/// Processes a single file and fixes withOpacity issues.
Future<ProcessResult> _processFile(File file, bool dryRun, bool verbose) async {
  final originalContent = await file.readAsString();
  var content = originalContent;
  final fixes = <String>[];

  // Fix withOpacity issues
  content = _fixWithOpacityIssues(content, fixes);

  // Write the changes to the file if there were any
  if (content != originalContent && !dryRun) {
    await file.writeAsString(content);
  }

  return ProcessResult(fixes.length, fixes);
}

/// Fixes withOpacity issues in the content.
String _fixWithOpacityIssues(String content, List<String> fixes) {
  var newContent = content;

  // Fix withOpacity pattern
  final withOpacityRegex = RegExp(
    r'(AppColors\.\w+|Colors\.\w+)\.withOpacity\(([0-9.]+)\)',
  );
  final withOpacityMatches = withOpacityRegex.allMatches(newContent);

  for (final match in withOpacityMatches) {
    final fullMatch = match.group(0)!;
    final colorName = match.group(1)!;
    final opacity = match.group(2)!;

    final replacement =
        'Color.fromRGBO($colorName.r.toInt(), $colorName.g.toInt(), $colorName.b.toInt(), $opacity)';
    newContent = newContent.replaceAll(fullMatch, replacement);
    fixes.add('Replaced $fullMatch with $replacement');
  }

  // Fix withAlpha pattern
  final withAlphaRegex = RegExp(
    r'(AppColors\.\w+|Colors\.\w+)\.withAlpha\((\d+)\)',
  );
  final withAlphaMatches = withAlphaRegex.allMatches(newContent);

  for (final match in withAlphaMatches) {
    final fullMatch = match.group(0)!;
    final colorName = match.group(1)!;
    final alpha = int.parse(match.group(2)!);
    final opacity = alpha / 255;

    final replacement =
        'Color.fromRGBO($colorName.r.toInt(), $colorName.g.toInt(), $colorName.b.toInt(), ${opacity.toStringAsFixed(2)})';
    newContent = newContent.replaceAll(fullMatch, replacement);
    fixes.add('Replaced $fullMatch with $replacement');
  }

  // Fix primaryWithAlpha pattern in app_colors.dart
  if (content.contains('static Color primaryWithAlpha(double opacity)')) {
    final primaryWithAlphaRegex = RegExp(
      r'static Color primaryWithAlpha\(double opacity\) \{\s*return primary\.withAlpha\(\(opacity \* 255\)\.round\(\)\);\s*\}',
    );
    const replacement =
        'static Color primaryWithAlpha(double opacity) {\n'
        '    return Color.fromRGBO(primary.r.toInt(), primary.g.toInt(), primary.b.toInt(), opacity);\n'
        '  }';

    newContent = newContent.replaceAll(primaryWithAlphaRegex, replacement);
    if (newContent != content) {
      fixes.add('Replaced primaryWithAlpha method with Color.fromRGBO version');
    }
  }

  return newContent;
}
