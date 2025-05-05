import 'dart:io';

/// A script to set up Git hooks for the project.
///
/// This script creates pre-commit and pre-push hooks in the .git/hooks directory.
/// These hooks run code quality checks before commits and pushes.
void main() async {
  // Get the Git hooks directory
  final gitHooksDir = await _getGitHooksDirectory();
  if (gitHooksDir == null) {
    stderr.writeln(
      '❌ Could not find .git/hooks directory. Are you in a Git repository?',
    );
    exit(1);
  }

  // Create pre-commit hook
  await _createPreCommitHook(gitHooksDir);

  // Create pre-push hook
  await _createPrePushHook(gitHooksDir);

  stdout.writeln('✅ Git hooks installed successfully!');
  stdout.writeln(
    'Pre-commit hook will run: dart format, flutter analyze, dart_code_metrics',
  );
  stdout.writeln('Pre-push hook will run: flutter test');
}

/// Gets the Git hooks directory.
Future<Directory?> _getGitHooksDirectory() async {
  // Find the .git directory by traversing up from the current directory
  Directory current = Directory.current;
  while (current.path != current.parent.path) {
    final gitDir = Directory('${current.path}${Platform.pathSeparator}.git');
    if (await gitDir.exists()) {
      final hooksDir = Directory(
        '${gitDir.path}${Platform.pathSeparator}hooks',
      );
      if (!await hooksDir.exists()) {
        await hooksDir.create();
      }
      return hooksDir;
    }
    current = current.parent;
  }
  return null;
}

/// Creates the pre-commit hook.
Future<void> _createPreCommitHook(Directory hooksDir) async {
  final hookFile = File('${hooksDir.path}${Platform.pathSeparator}pre-commit');

  // Create the hook script content
  const hookContent = '''
#!/bin/sh
# Pre-commit hook for Eventati Book
# This hook runs code quality checks before commits

echo "Running pre-commit hooks..."

# Run formatter
echo "\\n📝 Running dart format..."
dart format --set-exit-if-changed .
if [ \$? -ne 0 ]; then
  echo "\\n❌ Dart format found issues."
  echo "Please format your code with: dart format ."
  exit 1
fi
echo "✅ Dart format passed!"

# Run analyzer
echo "\\n🔍 Running flutter analyze..."
flutter analyze
if [ \$? -ne 0 ]; then
  echo "\\n❌ Flutter analyze found issues."
  exit 1
fi
echo "✅ Flutter analyze passed!"

# Run dart_code_metrics
echo "\\n📊 Running dart_code_metrics..."
flutter pub run dart_code_metrics:metrics analyze lib
if [ \$? -ne 0 ]; then
  echo "\\n❌ Dart code metrics found issues."
  exit 1
fi
echo "✅ Dart code metrics passed!"

echo "\\n✨ All pre-commit checks passed!"
exit 0
''';

  // Write the hook script
  await hookFile.writeAsString(hookContent);

  // Make the hook executable
  await _makeExecutable(hookFile.path);

  stdout.writeln('Created pre-commit hook at ${hookFile.path}');
}

/// Creates the pre-push hook.
Future<void> _createPrePushHook(Directory hooksDir) async {
  final hookFile = File('${hooksDir.path}${Platform.pathSeparator}pre-push');

  // Create the hook script content
  const hookContent = '''
#!/bin/sh
# Pre-push hook for Eventati Book
# This hook runs tests before pushing

echo "Running pre-push hooks..."

# Run tests
echo "\\n🧪 Running flutter test..."
flutter test
if [ \$? -ne 0 ]; then
  echo "\\n❌ Tests failed."
  exit 1
fi
echo "✅ Tests passed!"

echo "\\n✨ All pre-push checks passed!"
exit 0
''';

  // Write the hook script
  await hookFile.writeAsString(hookContent);

  // Make the hook executable
  await _makeExecutable(hookFile.path);

  stdout.writeln('Created pre-push hook at ${hookFile.path}');
}

/// Makes a file executable.
Future<void> _makeExecutable(String filePath) async {
  if (Platform.isWindows) {
    // Windows doesn't have the concept of executable bit
    return;
  }

  final result = await Process.run('chmod', ['+x', filePath]);
  if (result.exitCode != 0) {
    stderr.writeln('⚠️ Warning: Could not make $filePath executable.');
    stderr.writeln('You may need to run: chmod +x $filePath');
  }
}
