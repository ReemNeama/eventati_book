// ignore_for_file: avoid_print
import 'dart:io';

/// A script to run style usage tests.
///
/// This script:
/// 1. Runs the enhanced_styles_migration.dart tool to check for hardcoded styles
/// 2. Runs the custom_lint_rules.dart tool to check for specific style issues
/// 3. Reports the results
///
/// Usage: dart run tool/run_style_tests.dart
void main() async {
  print('🚀 Running style usage tests...\n');

  // Run enhanced_styles_migration.dart
  print('Running enhanced_styles_migration.dart...');
  final enhancedStylesMigrationResult = await Process.run('dart', [
    'run',
    'tool/enhanced_styles_migration.dart',
  ]);

  if (enhancedStylesMigrationResult.exitCode != 0) {
    print('Error running enhanced_styles_migration.dart:');
    print(enhancedStylesMigrationResult.stderr);
    exit(1);
  }

  // Parse the results
  final output = enhancedStylesMigrationResult.stdout as String;
  final filesWithHardcodedStyles = _parseFilesWithHardcodedStyles(output);

  // Run custom_lint_rules.dart
  print('\nRunning custom_lint_rules.dart...');
  final customLintRulesResult = await Process.run('dart', [
    'run',
    'tool/custom_lint_rules.dart',
  ]);

  if (customLintRulesResult.exitCode != 0) {
    print('Error running custom_lint_rules.dart:');
    print(customLintRulesResult.stderr);
    exit(1);
  }

  // Parse the results
  final lintOutput = customLintRulesResult.stdout as String;
  final lintViolations = _parseLintViolations(lintOutput);

  // Report the results
  print('\nStyle Usage Test Results:');
  print('Files with hardcoded styles: ${filesWithHardcodedStyles.length}');
  print('Lint violations: ${lintViolations.length}');

  if (filesWithHardcodedStyles.isEmpty && lintViolations.isEmpty) {
    print('\n✅ All style usage tests passed!');
    exit(0);
  } else {
    print('\n❌ Style usage tests failed!');

    if (filesWithHardcodedStyles.isNotEmpty) {
      print('\nFiles with hardcoded styles:');
      for (final file in filesWithHardcodedStyles) {
        print('  - $file');
      }
    }

    if (lintViolations.isNotEmpty) {
      print('\nLint violations:');
      for (final violation in lintViolations) {
        print('  - $violation');
      }
    }

    exit(1);
  }
}

/// Parses the output of enhanced_styles_migration.dart to get the list of files with hardcoded styles.
List<String> _parseFilesWithHardcodedStyles(String output) {
  final filesWithHardcodedStyles = <String>[];

  // Find the section with files with hardcoded styles
  final startIndex = output.indexOf('Files with hardcoded styles');
  if (startIndex == -1) {
    return filesWithHardcodedStyles;
  }

  final endIndex = output.indexOf('Migration Guidance:', startIndex);
  if (endIndex == -1) {
    return filesWithHardcodedStyles;
  }

  final filesSection = output.substring(startIndex, endIndex);
  final lines = filesSection.split('\n');

  for (final line in lines) {
    if (line.contains('lib/') && line.contains(':')) {
      final file = line.trim().split(':').first;
      filesWithHardcodedStyles.add(file);
    }
  }

  return filesWithHardcodedStyles;
}

/// Parses the output of custom_lint_rules.dart to get the list of lint violations.
List<String> _parseLintViolations(String output) {
  final lintViolations = <String>[];

  final lines = output.split('\n');

  for (final line in lines) {
    if (line.contains('Hardcoded') && line.contains('Line')) {
      lintViolations.add(line.trim());
    }
  }

  return lintViolations;
}
