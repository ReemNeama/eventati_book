// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures
import 'dart:io';

/// A script to help migrate from utils/styles.dart to the proper styles.
///
/// This script:
/// 1. Scans all Dart files in the lib directory
/// 2. Identifies files that import utils/styles.dart
/// 3. Identifies files that use AppColors, AppTextStyles, AppPadding, etc. from utils/styles.dart
/// 4. Provides guidance on how to update these files
///
/// Usage: dart run tool/styles_migration.dart
void main() async {
  print('🚀 Running styles migration helper...\n');

  // Get all Dart files in the lib directory
  final dartFiles = await _getDartFiles();
  print('Found ${dartFiles.length} Dart files to scan.\n');

  // Files that import utils/styles.dart
  final filesWithStylesImport = <File>[];

  // Files that use AppColors, AppTextStyles, etc. from utils/styles.dart
  final filesUsingDeprecatedStyles = <File, List<String>>{};

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
  print('   - AppTextStyles.heading1 -> TextStyles.title');
  print('   - AppTextStyles.heading2 -> TextStyles.subtitle');
  print('   - AppTextStyles.heading3 -> TextStyles.sectionTitle');
  print('   - AppTextStyles.bodyText -> TextStyles.bodyLarge');
  print('   - AppTextStyles.smallText -> TextStyles.bodyMedium');
  print('   - AppTextStyles.captionText -> TextStyles.bodySmall');
  print('   - AppTextStyles.buttonText -> TextStyles.buttonText');
  print('');
  print('   - Replace AppPadding constants with explicit values:');
  print('     - AppPadding.small -> 8.0');
  print('     - AppPadding.medium -> 16.0');
  print('     - AppPadding.large -> 24.0');
  print('     - AppPadding.extraLarge -> 32.0');
  print('');
  print('   - Replace AppBorderRadius constants with explicit values:');
  print('     - AppBorderRadius.small -> 4.0');
  print('     - AppBorderRadius.medium -> 8.0');
  print('     - AppBorderRadius.large -> 12.0');
  print('     - AppBorderRadius.extraLarge -> 16.0');
  print('     - AppBorderRadius.circular -> 50.0');
  print('');
  print('3. For dark mode support:');
  print('   final isDarkMode = UIUtils.isDarkMode(context);');
  print(
    '   final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;',
  );
  print('');
  print(
    '4. Update the CODE_REVIEW_CHECKLIST.md to include checks for proper styles usage.',
  );
  print('');
  print(
    '5. Update the STYLE_GUIDE.md to emphasize the use of centralized styles.',
  );
  print('');
  print(
    '6. Consider adding linting rules to enforce the use of centralized styles.',
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
