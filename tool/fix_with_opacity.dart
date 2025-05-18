// ignore_for_file: avoid_print
import 'dart:io';

/// A script to fix withOpacity issues in the codebase.
///
/// This script:
/// 1. Scans all Dart files in the lib directory
/// 2. Replaces withOpacity with Color.fromRGBO
/// 3. Adds necessary imports
///
/// Usage: dart run tool/fix_with_opacity.dart [--dry-run] [--verbose] [path]
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

  print('🚀 Running withOpacity fixer...\n');
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

  // Fix primaryWithAlpha pattern
  final primaryWithAlphaRegex = RegExp(r'Colors\.primaryWithAlpha');
  final primaryWithAlphaMatches = primaryWithAlphaRegex.allMatches(newContent);

  for (final match in primaryWithAlphaMatches) {
    final fullMatch = match.group(0)!;
    const replacement =
        'Color.fromRGBO(AppColors.primary.r.toInt(), AppColors.primary.g.toInt(), AppColors.primary.b.toInt(), 0.5)';
    newContent = newContent.replaceAll(fullMatch, replacement);
    fixes.add('Replaced $fullMatch with $replacement');
  }

  return newContent;
}
