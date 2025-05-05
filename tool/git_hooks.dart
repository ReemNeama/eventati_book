import 'dart:io';
import 'package:git_hooks_dart/git_hooks_dart.dart';

void main(List<String> arguments) {
  // Register git hooks
  GitHooks.init(
    preCommit: _preCommit,
    prePush: _prePush,
  );

  // Run git hooks
  GitHooks.run(arguments);
}

Future<bool> _preCommit() async {
  print('Running pre-commit hooks...');
  
  // Run formatter
  print('\n📝 Running dart format...');
  final formatResult = await Process.run(
    'dart',
    ['format', '--set-exit-if-changed', '.'],
  );
  
  if (formatResult.exitCode != 0) {
    print('\n❌ Dart format found issues:');
    print(formatResult.stdout);
    print('\nPlease format your code with: dart format .');
    return false;
  }
  
  print('✅ Dart format passed!');
  
  // Run analyzer
  print('\n🔍 Running flutter analyze...');
  final analyzeResult = await Process.run(
    'flutter',
    ['analyze'],
  );
  
  if (analyzeResult.exitCode != 0) {
    print('\n❌ Flutter analyze found issues:');
    print(analyzeResult.stdout);
    print(analyzeResult.stderr);
    return false;
  }
  
  print('✅ Flutter analyze passed!');
  
  // Run dart_code_metrics
  print('\n📊 Running dart_code_metrics...');
  final metricsResult = await Process.run(
    'flutter',
    ['pub', 'run', 'dart_code_metrics:metrics', 'analyze', 'lib'],
  );
  
  if (metricsResult.exitCode != 0) {
    print('\n❌ Dart code metrics found issues:');
    print(metricsResult.stdout);
    print(metricsResult.stderr);
    return false;
  }
  
  print('✅ Dart code metrics passed!');
  
  print('\n✨ All pre-commit checks passed!');
  return true;
}

Future<bool> _prePush() async {
  print('Running pre-push hooks...');
  
  // Run tests
  print('\n🧪 Running flutter test...');
  final testResult = await Process.run(
    'flutter',
    ['test'],
  );
  
  if (testResult.exitCode != 0) {
    print('\n❌ Tests failed:');
    print(testResult.stdout);
    print(testResult.stderr);
    return false;
  }
  
  print('✅ Tests passed!');
  
  print('\n✨ All pre-push checks passed!');
  return true;
}
