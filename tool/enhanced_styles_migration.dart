// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures
import 'dart:io';

/// An enhanced script to help migrate from hardcoded styles to the proper styles.
///
/// This script:
/// 1. Scans all Dart files in the lib directory
/// 2. Identifies files that import utils/styles.dart
/// 3. Identifies files that use AppColors, AppTextStyles, AppPadding, etc. from utils/styles.dart
/// 4. Identifies files that use hardcoded styles (TextStyle, Colors, etc.)
/// 5. Provides guidance on how to update these files
///
/// Usage: dart run tool/enhanced_styles_migration.dart [--fix]
///
/// Options:
///   --fix  Automatically fix some common issues (experimental)
void main(List<String> arguments) async {
  final bool autoFix = arguments.contains('--fix');

  print('🚀 Running enhanced styles migration helper...\n');

  // Get all Dart files in the lib directory
  final dartFiles = await _getDartFiles();
  print('Found ${dartFiles.length} Dart files to scan.\n');

  // Files that import utils/styles.dart
  final filesWithStylesImport = <File>[];

  // Files that use AppColors, AppTextStyles, etc. from utils/styles.dart
  final filesUsingDeprecatedStyles = <File, List<String>>{};

  // Files that use hardcoded styles
  final filesWithHardcodedStyles = <File, Map<String, int>>{};

  // Scan all files
  for (final file in dartFiles) {
    final content = await file.readAsString();

    // Check if the file imports utils/styles.dart
    if (content.contains("import 'package:eventati_book/utils/styles.dart'")) {
      filesWithStylesImport.add(file);
    }

    // Check if the file uses deprecated styles
    final deprecatedStylesUsed = _findDeprecatedStylesUsage(content);
    if (deprecatedStylesUsed.isNotEmpty) {
      filesUsingDeprecatedStyles[file] = deprecatedStylesUsed;
    }

    // Check if the file uses hardcoded styles
    final hardcodedStyles = _findHardcodedStyles(content);
    if (hardcodedStyles.isNotEmpty) {
      filesWithHardcodedStyles[file] = hardcodedStyles;
    }

    // Auto-fix if requested
    if (autoFix) {
      final fixedContent = _autoFixStyles(content);
      if (fixedContent != content) {
        await file.writeAsString(fixedContent);
        print('Auto-fixed: ${file.path}');
      }
    }
  }

  // Print results
  print(
    'Files that import utils/styles.dart (${filesWithStylesImport.length}):',
  );
  for (final file in filesWithStylesImport) {
    print('  - ${file.path.replaceAll('\\', '/')}');
  }
  print('');

  print(
    'Files that use deprecated styles (${filesUsingDeprecatedStyles.length}):',
  );
  for (final entry in filesUsingDeprecatedStyles.entries) {
    print('  - ${entry.key.path.replaceAll('\\', '/')}:');
    for (final style in entry.value) {
      print('    - $style');
    }
  }
  print('');

  print('Files with hardcoded styles (${filesWithHardcodedStyles.length}):');
  for (final entry in filesWithHardcodedStyles.entries) {
    print('  - ${entry.key.path.replaceAll('\\', '/')}:');
    for (final style in entry.value.entries) {
      print('    - ${style.key}: ${style.value} occurrences');
    }
  }
  print('');

  // Print migration guidance
  print('Migration Guidance:');
  print('1. Update imports:');
  print('   - Remove: import \'package:eventati_book/utils/styles.dart\'');
  print('   - Add: import \'package:eventati_book/styles/app_colors.dart\'');
  print(
    '   - Add: import \'package:eventati_book/styles/app_colors_dark.dart\' (if needed for dark mode)',
  );
  print('   - Add: import \'package:eventati_book/styles/text_styles.dart\'');
  print('   - Add: import \'package:eventati_book/utils/utils.dart\'');
  print('');
  print('2. Update style references:');
  print('   - AppColors.primaryColor -> AppColors.primary');
  print('   - AppColors.secondaryColor -> AppColors.hintColor');
  print('   - AppColors.accentColor -> AppColors.primary.withAlpha(50)');
  print('   - AppColors.backgroundColor -> AppColors.background');
  print('   - AppColors.textColor -> AppColors.textPrimary');
  print('   - AppColors.lightTextColor -> AppColors.textSecondary');
  print('   - AppColors.errorColor -> AppColors.error');
  print('   - AppColors.successColor -> AppColors.success');
  print('   - AppColors.warningColor -> AppColors.warning');
  print('   - AppColors.infoColor -> AppColors.info');
  print('   - AppColors.disabledColor -> AppColors.disabled');
  print('   - AppColors.dividerColor -> AppColors.divider');
  print('   - AppColors.cardColor -> AppColors.card');
  print('   - AppColors.shadowColor -> Colors.black.withAlpha(26)');
  print('');
  print('3. Replace hardcoded styles:');
  print(
    '   - TextStyle(...) -> TextStyles.bodyLarge or another appropriate style',
  );
  print('   - Colors.blue -> AppColors.primary or another appropriate color');
  print(
    '   - Colors.grey -> AppColors.textSecondary or another appropriate color',
  );
  print('   - Colors.red -> AppColors.error');
  print('   - Colors.green -> AppColors.success');
  print('   - Colors.orange -> AppColors.warning');
  print('   - Colors.white -> Colors.white (this is OK to use directly)');
  print('   - Colors.black -> AppColors.textPrimary');
  print('');
  print('4. For dark mode support:');
  print('   final isDarkMode = UIUtils.isDarkMode(context);');
  print(
    '   final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;',
  );
  print('');
  print(
    '5. Update the CODE_REVIEW_CHECKLIST.md to include checks for proper styles usage.',
  );
  print('');
  print(
    '6. Update the STYLE_GUIDE.md to emphasize the use of centralized styles.',
  );
  print('');
  print(
    '7. Consider adding linting rules to enforce the use of centralized styles.',
  );
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

/// Finds usage of deprecated styles in the given content.
List<String> _findDeprecatedStylesUsage(String content) {
  final deprecatedStyles = <String>[];

  // Check for AppColors usage
  if (content.contains('AppColors.primaryColor'))
    deprecatedStyles.add('AppColors.primaryColor');
  if (content.contains('AppColors.secondaryColor'))
    deprecatedStyles.add('AppColors.secondaryColor');
  if (content.contains('AppColors.accentColor'))
    deprecatedStyles.add('AppColors.accentColor');
  if (content.contains('AppColors.backgroundColor'))
    deprecatedStyles.add('AppColors.backgroundColor');
  if (content.contains('AppColors.textColor'))
    deprecatedStyles.add('AppColors.textColor');
  if (content.contains('AppColors.lightTextColor'))
    deprecatedStyles.add('AppColors.lightTextColor');
  if (content.contains('AppColors.errorColor'))
    deprecatedStyles.add('AppColors.errorColor');
  if (content.contains('AppColors.successColor'))
    deprecatedStyles.add('AppColors.successColor');
  if (content.contains('AppColors.warningColor'))
    deprecatedStyles.add('AppColors.warningColor');
  if (content.contains('AppColors.infoColor'))
    deprecatedStyles.add('AppColors.infoColor');
  if (content.contains('AppColors.disabledColor'))
    deprecatedStyles.add('AppColors.disabledColor');
  if (content.contains('AppColors.dividerColor'))
    deprecatedStyles.add('AppColors.dividerColor');
  if (content.contains('AppColors.cardColor'))
    deprecatedStyles.add('AppColors.cardColor');
  if (content.contains('AppColors.shadowColor'))
    deprecatedStyles.add('AppColors.shadowColor');

  // Check for AppTextStyles usage
  if (content.contains('AppTextStyles.heading1'))
    deprecatedStyles.add('AppTextStyles.heading1');
  if (content.contains('AppTextStyles.heading2'))
    deprecatedStyles.add('AppTextStyles.heading2');
  if (content.contains('AppTextStyles.heading3'))
    deprecatedStyles.add('AppTextStyles.heading3');
  if (content.contains('AppTextStyles.bodyText'))
    deprecatedStyles.add('AppTextStyles.bodyText');
  if (content.contains('AppTextStyles.smallText'))
    deprecatedStyles.add('AppTextStyles.smallText');
  if (content.contains('AppTextStyles.captionText'))
    deprecatedStyles.add('AppTextStyles.captionText');
  if (content.contains('AppTextStyles.buttonText'))
    deprecatedStyles.add('AppTextStyles.buttonText');

  // Check for AppPadding usage
  if (content.contains('AppPadding.')) deprecatedStyles.add('AppPadding');

  // Check for AppBorderRadius usage
  if (content.contains('AppBorderRadius.'))
    deprecatedStyles.add('AppBorderRadius');

  // Check for AppElevation usage
  if (content.contains('AppElevation.')) deprecatedStyles.add('AppElevation');

  // Check for AppDurations usage
  if (content.contains('AppDurations.')) deprecatedStyles.add('AppDurations');

  return deprecatedStyles;
}

/// Finds hardcoded styles in the given content.
Map<String, int> _findHardcodedStyles(String content) {
  final hardcodedStyles = <String, int>{};

  // Count occurrences of hardcoded styles
  final textStyleRegex = RegExp(r'TextStyle\(');
  final colorsRegex = RegExp(r'Colors\.');

  final textStyleMatches = textStyleRegex.allMatches(content);
  final colorsMatches = colorsRegex.allMatches(content);

  if (textStyleMatches.isNotEmpty) {
    hardcodedStyles['TextStyle'] = textStyleMatches.length;
  }

  if (colorsMatches.isNotEmpty) {
    hardcodedStyles['Colors'] = colorsMatches.length;
  }

  return hardcodedStyles;
}

/// Auto-fixes some common style issues.
String _autoFixStyles(String content) {
  var newContent = content;

  // Replace deprecated styles with new styles
  newContent = newContent.replaceAll(
    'AppColors.primaryColor',
    'AppColors.primary',
  );
  newContent = newContent.replaceAll(
    'AppColors.secondaryColor',
    'AppColors.hintColor',
  );
  newContent = newContent.replaceAll(
    'AppColors.backgroundColor',
    'AppColors.background',
  );
  newContent = newContent.replaceAll(
    'AppColors.textColor',
    'AppColors.textPrimary',
  );
  newContent = newContent.replaceAll(
    'AppColors.lightTextColor',
    'AppColors.textSecondary',
  );
  newContent = newContent.replaceAll('AppColors.errorColor', 'AppColors.error');
  newContent = newContent.replaceAll(
    'AppColors.successColor',
    'AppColors.success',
  );
  newContent = newContent.replaceAll(
    'AppColors.warningColor',
    'AppColors.warning',
  );
  newContent = newContent.replaceAll('AppColors.infoColor', 'AppColors.info');
  newContent = newContent.replaceAll(
    'AppColors.disabledColor',
    'AppColors.disabled',
  );
  newContent = newContent.replaceAll(
    'AppColors.dividerColor',
    'AppColors.divider',
  );
  newContent = newContent.replaceAll('AppColors.cardColor', 'AppColors.card');

  // Replace imports
  if (newContent.contains("import 'package:eventati_book/utils/styles.dart'")) {
    newContent = newContent.replaceAll(
      "import 'package:eventati_book/utils/styles.dart'",
      "import 'package:eventati_book/styles/app_colors.dart';\nimport 'package:eventati_book/styles/text_styles.dart'",
    );
  }

  return newContent;
}
