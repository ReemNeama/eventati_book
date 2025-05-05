import 'dart:io';

/// A script to automatically fix common style guide violations.
///
/// This script scans Dart files in the lib directory and fixes common style guide violations:
/// - Missing blank lines before return statements
/// - Unnecessary braces in string interpolations
/// - Using `first` and `last` instead of accessing elements by index
///
/// Usage: dart run tool/style_guide_fixer.dart [--dry-run]
///
/// Options:
///   --dry-run  Show what would be changed without making actual changes
void main(List<String> arguments) async {
  final bool dryRun = arguments.contains('--dry-run');

  stdout.writeln('🚀 Running style guide fixer...\n');

  // Get all Dart files in the lib directory
  final dartFiles = await _getDartFiles();

  stdout.writeln('Found ${dartFiles.length} Dart files to process.\n');

  int fixedFiles = 0;
  int totalFixes = 0;

  // Process each file
  for (final file in dartFiles) {
    final fixes = await _processFile(file, dryRun);
    if (fixes > 0) {
      fixedFiles++;
      totalFixes += fixes;
    }
  }

  stdout.writeln('\n✅ Style guide fixer completed!');
  stdout.writeln('Fixed $totalFixes issues in $fixedFiles files.');

  if (dryRun) {
    stdout.writeln('\nThis was a dry run. No actual changes were made.');
    stdout.writeln('Run without --dry-run to apply the changes.');
  }
}

/// Gets all Dart files in the lib directory.
Future<List<File>> _getDartFiles() async {
  final libDir = Directory('lib');
  final files = <File>[];

  await for (final entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      files.add(entity);
    }
  }

  return files;
}

/// Processes a single file and fixes style guide violations.
Future<int> _processFile(File file, bool dryRun) async {
  final originalContent = await file.readAsString();
  var content = originalContent;
  int fixes = 0;

  // Fix missing blank lines before return statements
  fixes += _fixMissingBlankLinesBeforeReturn(file, content, content, dryRun);

  // Fix unnecessary braces in string interpolations
  var newContent = _fixUnnecessaryBracesInStringInterpolations(content);
  if (newContent != content) {
    fixes++;
    if (!dryRun) {
      await file.writeAsString(newContent);
    }
    content = newContent;
  }

  // Fix using first and last instead of accessing elements by index
  newContent = _fixUsingFirstAndLast(content);
  if (newContent != content) {
    fixes++;
    if (!dryRun) {
      await file.writeAsString(newContent);
    }
  }

  return fixes;
}

/// Fixes missing blank lines before return statements.
int _fixMissingBlankLinesBeforeReturn(
  File file,
  String content,
  String newContent,
  bool dryRun,
) {
  final lines = content.split('\n');
  final newLines = <String>[];
  bool changed = false;

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];

    // Check if this line is a return statement
    if (line.trim().startsWith('return ') || line.trim() == 'return;') {
      // Check if the previous line is not empty and not a comment
      if (i > 0 &&
          lines[i - 1].trim().isNotEmpty &&
          !lines[i - 1].trim().startsWith('//')) {
        // Check if the previous line is not already a blank line
        if (i > 1 && lines[i - 2].trim().isNotEmpty) {
          newLines.add('');
          changed = true;
        }
      }
    }

    newLines.add(line);
  }

  if (changed) {
    if (!dryRun) {
      file.writeAsStringSync(newLines.join('\n'));
    }
    stdout.writeln(
      'Fixed missing blank lines before return statements in ${file.path}',
    );
    return 1;
  }

  return 0;
}

/// Fixes unnecessary braces in string interpolations.
String _fixUnnecessaryBracesInStringInterpolations(String content) {
  // This is a simplified implementation that may not catch all cases
  // A more robust implementation would use a proper Dart parser

  // Replace ${variable} with $variable when variable is a simple identifier
  final regex = RegExp(r'\$\{([a-zA-Z_][a-zA-Z0-9_]*)\}');
  final newContent = content.replaceAllMapped(regex, (match) {
    return '\$${match.group(1)}';
  });

  if (newContent != content) {
    stdout.writeln('Fixed unnecessary braces in string interpolations');
  }

  return newContent;
}

/// Fixes using first and last instead of accessing elements by index.
String _fixUsingFirstAndLast(String content) {
  // This is a simplified implementation that may not catch all cases
  // A more robust implementation would use a proper Dart parser

  // Replace list[0] with list.first
  var newContent = content.replaceAllMapped(
    RegExp(r'([a-zA-Z_][a-zA-Z0-9_]*)\[0\]'),
    (match) => '${match.group(1)}.first',
  );

  // Replace list[list.length - 1] with list.last
  newContent = newContent.replaceAllMapped(
    RegExp(r'([a-zA-Z_][a-zA-Z0-9_]*)\[\1\.length - 1\]'),
    (match) => '${match.group(1)}.last',
  );

  if (newContent != content) {
    stdout.writeln(
      'Fixed using first and last instead of accessing elements by index',
    );
  }

  return newContent;
}
