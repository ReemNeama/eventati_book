import 'dart:io';

/// A script to run all code quality checks at once.
/// 
/// Usage: dart run tool/run_checks.dart [--fix]
/// 
/// Options:
///   --fix  Automatically fix issues when possible
void main(List<String> arguments) async {
  final bool fix = arguments.contains('--fix');
  
  print('🚀 Running all code quality checks...\n');
  
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
  print('\n${success ? '✅' : '❌'} Code quality checks ${success ? 'passed' : 'failed'}!');
  
  // Exit with appropriate code
  exit(success ? 0 : 1);
}

Future<bool> _runFormatter(bool fix) async {
  print('📝 Running dart format...');
  
  final List<String> args = [
    'format',
    if (!fix) '--set-exit-if-changed',
    '.',
  ];
  
  final result = await Process.run('dart', args);
  
  if (result.exitCode != 0) {
    print('❌ Dart format found issues:');
    print(result.stdout);
    print('\nRun with --fix to automatically fix formatting issues.');
    return false;
  }
  
  print('✅ Dart format passed!\n');
  return true;
}

Future<bool> _runAnalyzer() async {
  print('🔍 Running flutter analyze...');
  
  final result = await Process.run('flutter', ['analyze']);
  
  if (result.exitCode != 0) {
    print('❌ Flutter analyze found issues:');
    print(result.stdout);
    print(result.stderr);
    return false;
  }
  
  print('✅ Flutter analyze passed!\n');
  return true;
}

Future<bool> _runDartCodeMetrics(bool fix) async {
  print('📊 Running dart_code_metrics...');
  
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
  print(result.stdout);
  
  if (result.exitCode != 0) {
    print('❌ Dart code metrics found issues:');
    print(result.stderr);
    if (!fix) {
      print('\nRun with --fix to automatically fix some issues.');
    }
    return false;
  }
  
  print('✅ Dart code metrics passed!\n');
  return true;
}

Future<bool> _runTests() async {
  print('🧪 Running flutter test...');
  
  final result = await Process.run('flutter', ['test']);
  
  if (result.exitCode != 0) {
    print('❌ Tests failed:');
    print(result.stdout);
    print(result.stderr);
    return false;
  }
  
  print('✅ Tests passed!\n');
  return true;
}

Future<bool> _generateCoverage() async {
  print('📈 Generating coverage report...');
  
  // Run tests with coverage
  final testResult = await Process.run(
    'flutter',
    ['test', '--coverage'],
  );
  
  if (testResult.exitCode != 0) {
    print('❌ Failed to generate coverage:');
    print(testResult.stderr);
    return false;
  }
  
  // Generate coverage badge
  final badgeResult = await Process.run(
    'flutter',
    ['pub', 'run', 'flutter_coverage_badge'],
  );
  
  if (badgeResult.exitCode != 0) {
    print('⚠️ Failed to generate coverage badge:');
    print(badgeResult.stderr);
    // Don't fail the build for this
  }
  
  // Display coverage in console
  final consoleResult = await Process.run(
    'flutter',
    ['pub', 'run', 'test_cov_console'],
  );
  
  if (consoleResult.exitCode != 0) {
    print('⚠️ Failed to display coverage in console:');
    print(consoleResult.stderr);
    // Don't fail the build for this
  } else {
    print(consoleResult.stdout);
  }
  
  print('✅ Coverage report generated!\n');
  return true;
}
