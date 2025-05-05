import 'dart:io';

/// A script to fix missing blank lines before return statements.
///
/// This script scans Dart files in the lib directory and adds blank lines
/// before return statements when they are missing.
///
/// Usage: dart run tool/fix_blank_lines.dart [--dry-run]
///
/// Options:
///   --dry-run  Show what would be changed without making actual changes
void main(List<String> arguments) async {
  final bool dryRun = arguments.contains('--dry-run');

  stdout.writeln(
    '🔍 Scanning for missing blank lines before return statements...\n',
  );

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

  stdout.writeln(
    '\n✅ Fixed $totalFixes missing blank lines in $fixedFiles files.',
  );

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

/// Processes a single file and fixes missing blank lines before return statements.
Future<int> _processFile(File file, bool dryRun) async {
  final content = await file.readAsString();
  final lines = content.split('\n');
  final newLines = <String>[];
  bool changed = false;
  int fixes = 0;

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmedLine = line.trim();

    // Check if this line is a return statement
    if (trimmedLine.startsWith('return ') || trimmedLine == 'return;') {
      // Check if the previous line is not empty and not a comment
      if (i > 0 &&
          lines[i - 1].trim().isNotEmpty &&
          !lines[i - 1].trim().startsWith('//')) {
        // Check if we're not inside a one-line function or lambda
        if (!_isInOneLiner(lines, i)) {
          // Add a blank line before the return statement
          newLines.add('');
          changed = true;
          fixes++;
        }
      }
    }

    newLines.add(line);
  }

  if (changed && !dryRun) {
    await file.writeAsString(newLines.join('\n'));
    stdout.writeln('Fixed $fixes missing blank lines in ${file.path}');
  } else if (changed) {
    stdout.writeln('Would fix $fixes missing blank lines in ${file.path}');
  }

  return fixes;
}

/// Checks if the return statement is inside a one-line function or lambda.
bool _isInOneLiner(List<String> lines, int returnLineIndex) {
  // Check if the previous line contains => or { and the next line contains } or ;
  final previousLine =
      returnLineIndex > 0 ? lines[returnLineIndex - 1].trim() : '';
  final nextLine =
      returnLineIndex < lines.length - 1
          ? lines[returnLineIndex + 1].trim()
          : '';

  return (previousLine.contains('=>') || previousLine.endsWith('{')) &&
      (nextLine.startsWith('}') || nextLine.startsWith('});'));
}
