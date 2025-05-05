import 'dart:io';

/// A script to run all code quality checks at once.
///
/// Usage: dart run tool/run_checks.dart [--fix]
///
/// Options:
///   --fix  Automatically fix issues when possible
void main(List<String> arguments) async {
  final bool fix = arguments.contains('--fix');

  stdout.writeln('🚀 Running all code quality checks...\n');

  // Track overall success
  bool success = true;

  // Run formatter
  success = await _runFormatter(fix) && success;

  // Run analyzer
  success = await _runAnalyzer() && success;

  // Run dart_code_metrics
  success = await _runDartCodeMetrics(fix) && success;

  // Run tests
  success = await _runTests() && success;

  // Generate coverage report if tests pass
  if (success) {
    success = await _generateCoverage() && success;
  }

  // Print summary
  stdout.writeln(
    '\n${success ? '✅' : '❌'} Code quality checks ${success ? 'passed' : 'failed'}!',
  );

  // Exit with appropriate code
  exit(success ? 0 : 1);
}

Future<bool> _runFormatter(bool fix) async {
  stdout.writeln('📝 Running dart format...');

  final List<String> args = ['format', if (!fix) '--set-exit-if-changed', '.'];

  final result = await Process.run('dart', args);

  if (result.exitCode != 0) {
    stdout.writeln('❌ Dart format found issues:');
    stdout.writeln(result.stdout);
    stdout.writeln('\nRun with --fix to automatically fix formatting issues.');
    return false;
  }

  stdout.writeln('✅ Dart format passed!\n');
  return true;
}

Future<bool> _runAnalyzer() async {
  stdout.writeln('🔍 Running flutter analyze...');

  final result = await Process.run('flutter', ['analyze']);

  if (result.exitCode != 0) {
    stdout.writeln('❌ Flutter analyze found issues:');
    stdout.writeln(result.stdout);
    stdout.writeln(result.stderr);
    return false;
  }

  stdout.writeln('✅ Flutter analyze passed!\n');
  return true;
}

Future<bool> _runDartCodeMetrics(bool fix) async {
  stdout.writeln('📊 Running dart_code_metrics...');

  final List<String> args = [
    'pub',
    'run',
    'dart_code_metrics:metrics',
    'analyze',
    'lib',
    if (fix) '--fix',
  ];

  final result = await Process.run('flutter', args);

  // Print output even if successful, as it contains useful metrics
  stdout.writeln(result.stdout);

  if (result.exitCode != 0) {
    stdout.writeln('❌ Dart code metrics found issues:');
    stdout.writeln(result.stderr);
    if (!fix) {
      stdout.writeln('\nRun with --fix to automatically fix some issues.');
    }
    return false;
  }

  stdout.writeln('✅ Dart code metrics passed!\n');
  return true;
}

Future<bool> _runTests() async {
  stdout.writeln('🧪 Running flutter test...');

  final result = await Process.run('flutter', ['test']);

  if (result.exitCode != 0) {
    stdout.writeln('❌ Tests failed:');
    stdout.writeln(result.stdout);
    stdout.writeln(result.stderr);
    return false;
  }

  stdout.writeln('✅ Tests passed!\n');
  return true;
}

Future<bool> _generateCoverage() async {
  stdout.writeln('📈 Generating coverage report...');

  // Run tests with coverage
  final testResult = await Process.run('flutter', ['test', '--coverage']);

  if (testResult.exitCode != 0) {
    stdout.writeln('❌ Failed to generate coverage:');
    stdout.writeln(testResult.stderr);
    return false;
  }

  // Note: Coverage badge generation removed due to null safety issues

  // Display coverage in console
  final consoleResult = await Process.run('flutter', [
    'pub',
    'run',
    'test_cov_console',
  ]);

  if (consoleResult.exitCode != 0) {
    stdout.writeln('⚠️ Failed to display coverage in console:');
    stdout.writeln(consoleResult.stderr);
    // Don't fail the build for this
  } else {
    stdout.writeln(consoleResult.stdout);
  }

  stdout.writeln('✅ Coverage report generated!\n');
  return true;
}
