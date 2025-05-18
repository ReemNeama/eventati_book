// ignore_for_file: avoid_print
import 'dart:io';

/// A script to automatically fix common style issues in the codebase.
///
/// This script:
/// 1. Scans all Dart files in the lib directory
/// 2. Automatically fixes common style issues:
///    - Replaces hardcoded TextStyle with TextStyles
///    - Replaces hardcoded Colors with AppColors
///    - Adds missing imports for styles
///    - Replaces deprecated styles with new styles
///
/// Usage: dart run tool/auto_fix_styles.dart [--dry-run] [--verbose] [path]
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

  print('🚀 Running auto style fixer...');
  print('Mode: ${dryRun ? 'Dry run' : 'Fix'}');
  print('Path: $path');

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

/// Processes a single file and fixes style issues.
Future<ProcessResult> _processFile(File file, bool dryRun, bool verbose) async {
  final originalContent = await file.readAsString();
  var content = originalContent;
  final fixes = <String>[];

  // Check if the file already imports the styles
  final bool hasAppColorsImport = content.contains(
    "import 'package:eventati_book/styles/app_colors.dart'",
  );
  final bool hasAppColorsDarkImport = content.contains(
    "import 'package:eventati_book/styles/app_colors_dark.dart'",
  );
  final bool hasTextStylesImport = content.contains(
    "import 'package:eventati_book/styles/text_styles.dart'",
  );
  final bool hasUtilsImport = content.contains(
    "import 'package:eventati_book/utils/utils.dart'",
  );

  // Check if the file uses styles
  final bool usesAppColors = content.contains('AppColors.');
  final bool usesAppColorsDark = content.contains('AppColorsDark.');
  final bool usesTextStyles = content.contains('TextStyles.');
  final bool usesUIUtils = content.contains('UIUtils.');

  // Check if the file has hardcoded styles
  final bool hasHardcodedTextStyle = content.contains('TextStyle(');
  final bool hasHardcodedColors = content.contains('Colors.');

  // Add missing imports
  if ((usesAppColors || hasHardcodedColors) && !hasAppColorsImport) {
    content = _addImport(
      content,
      "import 'package:eventati_book/styles/app_colors.dart';",
    );
    fixes.add('Added import for app_colors.dart');
  }

  if (usesAppColorsDark && !hasAppColorsDarkImport) {
    content = _addImport(
      content,
      "import 'package:eventati_book/styles/app_colors_dark.dart';",
    );
    fixes.add('Added import for app_colors_dark.dart');
  }

  if ((usesTextStyles || hasHardcodedTextStyle) && !hasTextStylesImport) {
    content = _addImport(
      content,
      "import 'package:eventati_book/styles/text_styles.dart';",
    );
    fixes.add('Added import for text_styles.dart');
  }

  if ((usesUIUtils || (usesAppColors && usesAppColorsDark)) &&
      !hasUtilsImport) {
    content = _addImport(
      content,
      "import 'package:eventati_book/utils/utils.dart';",
    );
    fixes.add('Added import for utils.dart');
  }

  // Replace deprecated styles with new styles
  content = _replaceDeprecatedStyles(content, fixes);

  // Replace hardcoded styles with centralized styles
  if (hasHardcodedTextStyle || hasHardcodedColors) {
    content = _replaceHardcodedStyles(content, fixes);
  }

  // Write the changes to the file if there were any
  if (content != originalContent && !dryRun) {
    await file.writeAsString(content);
  }

  return ProcessResult(fixes.length, fixes);
}

/// Adds an import statement to the content.
String _addImport(String content, String importStatement) {
  // Find the last import statement
  final importRegex = RegExp(r"import '.*';");
  final matches = importRegex.allMatches(content);

  if (matches.isEmpty) {
    // No imports found, add at the beginning
    return '$importStatement\n\n$content';
  } else {
    // Add after the last import
    final lastMatch = matches.last;
    final index = lastMatch.end;
    return '${content.substring(0, index)}\n$importStatement${content.substring(index)}';
  }
}

/// Replaces deprecated styles with new styles.
String _replaceDeprecatedStyles(String content, List<String> fixes) {
  var newContent = content;

  // Replace deprecated AppColors
  final replacements = {
    'AppColors.primaryColor': 'AppColors.primary',
    'AppColors.secondaryColor': 'AppColors.hintColor',
    'AppColors.accentColor': 'AppColors.primary.withAlpha(50)',
    'AppColors.backgroundColor': 'AppColors.background',
    'AppColors.textColor': 'AppColors.textPrimary',
    'AppColors.lightTextColor': 'AppColors.textSecondary',
    'AppColors.errorColor': 'AppColors.error',
    'AppColors.successColor': 'AppColors.success',
    'AppColors.warningColor': 'AppColors.warning',
    'AppColors.infoColor': 'AppColors.info',
    'AppColors.disabledColor': 'AppColors.disabled',
    'AppColors.dividerColor': 'AppColors.divider',
    'AppColors.cardColor': 'AppColors.card',
    'AppColors.shadowColor': 'Colors.black.withAlpha(26)',
  };

  for (final entry in replacements.entries) {
    if (newContent.contains(entry.key)) {
      newContent = newContent.replaceAll(entry.key, entry.value);
      fixes.add('Replaced ${entry.key} with ${entry.value}');
    }
  }

  // Replace deprecated AppTextStyles
  final textStyleReplacements = {
    'AppTextStyles.heading1': 'TextStyles.title',
    'AppTextStyles.heading2': 'TextStyles.subtitle',
    'AppTextStyles.heading3': 'TextStyles.sectionTitle',
    'AppTextStyles.bodyText': 'TextStyles.bodyLarge',
    'AppTextStyles.smallText': 'TextStyles.bodyMedium',
    'AppTextStyles.captionText': 'TextStyles.bodySmall',
    'AppTextStyles.buttonText': 'TextStyles.buttonText',
  };

  for (final entry in textStyleReplacements.entries) {
    if (newContent.contains(entry.key)) {
      newContent = newContent.replaceAll(entry.key, entry.value);
      fixes.add('Replaced ${entry.key} with ${entry.value}');
    }
  }

  return newContent;
}

/// Replaces hardcoded styles with centralized styles.
String _replaceHardcodedStyles(String content, List<String> fixes) {
  var newContent = content;

  // Replace hardcoded Colors with AppColors
  final colorReplacements = {
    'Colors.blue': 'AppColors.primary',
    'Colors.red': 'AppColors.error',
    'Colors.green': 'AppColors.success',
    'Colors.orange': 'AppColors.warning',
    'Colors.amber': 'AppColors.ratingStarColor',
    'Colors.grey[300]': 'AppColors.disabled.withOpacity(0.3)',
    'Colors.grey[400]': 'AppColors.disabled.withOpacity(0.4)',
    'Colors.grey[500]': 'AppColors.disabled.withOpacity(0.5)',
    'Colors.grey[600]': 'AppColors.disabled.withOpacity(0.6)',
    'Colors.grey[700]': 'AppColors.disabled.withOpacity(0.7)',
    'Colors.grey[800]': 'AppColors.disabled.withOpacity(0.8)',
    'Colors.grey[900]': 'AppColors.disabled.withOpacity(0.9)',
    'Colors.grey.shade100': 'AppColors.disabled.withOpacity(0.1)',
    'Colors.grey.shade200': 'AppColors.disabled.withOpacity(0.2)',
    'Colors.grey.shade300': 'AppColors.disabled.withOpacity(0.3)',
    'Colors.grey.shade400': 'AppColors.disabled.withOpacity(0.4)',
    'Colors.grey.shade500': 'AppColors.disabled.withOpacity(0.5)',
    'Colors.grey.shade600': 'AppColors.disabled.withOpacity(0.6)',
    'Colors.grey.shade700': 'AppColors.disabled.withOpacity(0.7)',
    'Colors.grey.shade800': 'AppColors.disabled.withOpacity(0.8)',
    'Colors.grey.shade900': 'AppColors.disabled.withOpacity(0.9)',
  };

  for (final entry in colorReplacements.entries) {
    if (newContent.contains(entry.key)) {
      newContent = newContent.replaceAll(entry.key, entry.value);
      fixes.add('Replaced ${entry.key} with ${entry.value}');
    }
  }

  // Fix common color getter issues
  newContent = _fixColorGetterIssues(newContent, fixes);

  // Replace common TextStyle patterns with TextStyles
  newContent = _replaceTextStyles(newContent, fixes);

  return newContent;
}

/// Fix common color getter issues like .shade100, .shade900, etc.
String _fixColorGetterIssues(String content, List<String> fixes) {
  var newContent = content;

  // Fix color[index] pattern
  final colorIndexRegex = RegExp(r'(AppColors\.\w+)\[(\d+)\]');
  final colorIndexMatches = colorIndexRegex.allMatches(newContent);

  for (final match in colorIndexMatches) {
    final fullMatch = match.group(0)!;
    final colorName = match.group(1)!;
    final index = int.parse(match.group(2)!);
    final opacity = index / 1000;

    final replacement =
        'Color.fromRGBO($colorName.r.toInt(), $colorName.g.toInt(), $colorName.b.toInt(), $opacity)';
    newContent = newContent.replaceAll(fullMatch, replacement);
    fixes.add('Replaced $fullMatch with $replacement');
  }

  // Fix color.shade100, color.shade900 pattern
  final shadeRegex = RegExp(r'(AppColors\.\w+)\.shade(\d+)');
  final shadeMatches = shadeRegex.allMatches(newContent);

  for (final match in shadeMatches) {
    final fullMatch = match.group(0)!;
    final colorName = match.group(1)!;
    final shade = int.parse(match.group(2)!);
    final opacity = shade / 1000;

    final replacement =
        'Color.fromRGBO($colorName.r.toInt(), $colorName.g.toInt(), $colorName.b.toInt(), $opacity)';
    newContent = newContent.replaceAll(fullMatch, replacement);
    fixes.add('Replaced $fullMatch with $replacement');
  }

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

  return newContent;
}

/// Replace common TextStyle patterns with TextStyles
String _replaceTextStyles(String content, List<String> fixes) {
  var newContent = content;

  // Define patterns to look for and their replacements
  final patterns = [
    // Title styles
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontSize:\s*24(\.\d+)?\s*,\s*fontWeight:\s*FontWeight\.bold',
      ),
      'replacement': 'TextStyles.title',
      'description': 'Title TextStyle',
    },
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontWeight:\s*FontWeight\.bold\s*,\s*fontSize:\s*24(\.\d+)?',
      ),
      'replacement': 'TextStyles.title',
      'description': 'Title TextStyle',
    },

    // Subtitle styles
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontSize:\s*20(\.\d+)?\s*,\s*fontWeight:\s*FontWeight\.bold',
      ),
      'replacement': 'TextStyles.subtitle',
      'description': 'Subtitle TextStyle',
    },
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontWeight:\s*FontWeight\.bold\s*,\s*fontSize:\s*20(\.\d+)?',
      ),
      'replacement': 'TextStyles.subtitle',
      'description': 'Subtitle TextStyle',
    },

    // Section title styles
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontSize:\s*18(\.\d+)?\s*,\s*fontWeight:\s*FontWeight\.bold',
      ),
      'replacement': 'TextStyles.sectionTitle',
      'description': 'Section title TextStyle',
    },
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontWeight:\s*FontWeight\.bold\s*,\s*fontSize:\s*18(\.\d+)?',
      ),
      'replacement': 'TextStyles.sectionTitle',
      'description': 'Section title TextStyle',
    },

    // Body large with bold
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontSize:\s*16(\.\d+)?\s*,\s*fontWeight:\s*FontWeight\.bold',
      ),
      'replacement':
          'TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)',
      'description': 'Body large bold TextStyle',
    },
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontWeight:\s*FontWeight\.bold\s*,\s*fontSize:\s*16(\.\d+)?',
      ),
      'replacement':
          'TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)',
      'description': 'Body large bold TextStyle',
    },

    // Body styles
    {
      'pattern': RegExp(r'TextStyle\(\s*fontSize:\s*16(\.\d+)?'),
      'replacement': 'TextStyles.bodyLarge',
      'description': 'Body large TextStyle',
    },
    {
      'pattern': RegExp(r'TextStyle\(\s*fontSize:\s*14(\.\d+)?'),
      'replacement': 'TextStyles.bodyMedium',
      'description': 'Body medium TextStyle',
    },
    {
      'pattern': RegExp(r'TextStyle\(\s*fontSize:\s*12(\.\d+)?'),
      'replacement': 'TextStyles.bodySmall',
      'description': 'Body small TextStyle',
    },
    {
      'pattern': RegExp(r'TextStyle\(\s*fontSize:\s*10(\.\d+)?'),
      'replacement': 'TextStyles.caption',
      'description': 'Caption TextStyle',
    },

    // Styles with fontStyle
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontSize:\s*16(\.\d+)?\s*,\s*fontStyle:\s*FontStyle\.italic',
      ),
      'replacement':
          'TextStyles.bodyLarge.copyWith(fontStyle: FontStyle.italic)',
      'description': 'Body large italic TextStyle',
    },
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontStyle:\s*FontStyle\.italic\s*,\s*fontSize:\s*16(\.\d+)?',
      ),
      'replacement':
          'TextStyles.bodyLarge.copyWith(fontStyle: FontStyle.italic)',
      'description': 'Body large italic TextStyle',
    },
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontSize:\s*14(\.\d+)?\s*,\s*fontStyle:\s*FontStyle\.italic',
      ),
      'replacement':
          'TextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic)',
      'description': 'Body medium italic TextStyle',
    },
    {
      'pattern': RegExp(
        r'TextStyle\(\s*fontStyle:\s*FontStyle\.italic\s*,\s*fontSize:\s*14(\.\d+)?',
      ),
      'replacement':
          'TextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic)',
      'description': 'Body medium italic TextStyle',
    },
  ];

  for (final pattern in patterns) {
    final regex = pattern['pattern'] as RegExp;
    final replacement = pattern['replacement'] as String;
    final description = pattern['description'] as String;

    if (regex.hasMatch(newContent)) {
      final matches = regex.allMatches(newContent);
      for (final match in matches) {
        final fullMatch = match.group(0)!;
        // Extract any color or other properties from the original TextStyle
        final colorMatch = RegExp(r'color:\s*([^,\)]+)').firstMatch(fullMatch);
        final fontStyleMatch = RegExp(
          r'fontStyle:\s*([^,\)]+)',
        ).firstMatch(fullMatch);
        final fontWeightMatch = RegExp(
          r'fontWeight:\s*([^,\)]+)',
        ).firstMatch(fullMatch);
        final letterSpacingMatch = RegExp(
          r'letterSpacing:\s*([^,\)]+)',
        ).firstMatch(fullMatch);
        final heightMatch = RegExp(
          r'height:\s*([^,\)]+)',
        ).firstMatch(fullMatch);

        String newStyle = replacement;

        // If the replacement already has copyWith, we need to modify it
        if (replacement.contains('.copyWith(')) {
          // Extract the base style and existing properties
          final baseStyle = replacement.split('.copyWith(')[0];
          final existingProps = replacement
              .split('.copyWith(')[1]
              .replaceAll(')', '');

          // Start building the new copyWith
          newStyle = '$baseStyle.copyWith(';

          // Add existing properties
          if (existingProps.isNotEmpty) {
            newStyle += '$existingProps, ';
          }

          // Add additional properties
          if (colorMatch != null && !existingProps.contains('color:')) {
            newStyle += 'color: ${colorMatch.group(1)}, ';
          }
          if (fontStyleMatch != null &&
              !existingProps.contains('fontStyle:') &&
              !fullMatch.contains('FontStyle.italic')) {
            newStyle += 'fontStyle: ${fontStyleMatch.group(1)}, ';
          }
          if (fontWeightMatch != null &&
              !existingProps.contains('fontWeight:') &&
              !fullMatch.contains('FontWeight.bold')) {
            newStyle += 'fontWeight: ${fontWeightMatch.group(1)}, ';
          }
          if (letterSpacingMatch != null &&
              !existingProps.contains('letterSpacing:')) {
            newStyle += 'letterSpacing: ${letterSpacingMatch.group(1)}, ';
          }
          if (heightMatch != null && !existingProps.contains('height:')) {
            newStyle += 'height: ${heightMatch.group(1)}, ';
          }

          // Clean up and close
          newStyle = newStyle.trimRight();
          if (newStyle.endsWith(',')) {
            newStyle = newStyle.substring(0, newStyle.length - 1);
          }
          newStyle += ')';
        }
        // Otherwise, check if we need to add copyWith
        else if (colorMatch != null ||
            fontStyleMatch != null ||
            (fontWeightMatch != null && !replacement.contains('fontWeight')) ||
            letterSpacingMatch != null ||
            heightMatch != null) {
          // Need to add copyWith
          newStyle += '.copyWith(';
          if (colorMatch != null) {
            newStyle += 'color: ${colorMatch.group(1)}, ';
          }
          if (fontStyleMatch != null &&
              !fullMatch.contains('FontStyle.italic')) {
            newStyle += 'fontStyle: ${fontStyleMatch.group(1)}, ';
          }
          if (fontWeightMatch != null &&
              !fullMatch.contains('FontWeight.bold') &&
              !replacement.contains('title') &&
              !replacement.contains('subtitle') &&
              !replacement.contains('fontWeight')) {
            newStyle += 'fontWeight: ${fontWeightMatch.group(1)}, ';
          }
          if (letterSpacingMatch != null) {
            newStyle += 'letterSpacing: ${letterSpacingMatch.group(1)}, ';
          }
          if (heightMatch != null) {
            newStyle += 'height: ${heightMatch.group(1)}, ';
          }
          newStyle = newStyle.trimRight();
          if (newStyle.endsWith(',')) {
            newStyle = newStyle.substring(0, newStyle.length - 1);
          }
          newStyle += ')';
        }

        // Replace the full TextStyle with the new style
        // Escape special regex characters in the fullMatch
        final escapedFullMatch = fullMatch
            .replaceAll('(', '\\(')
            .replaceAll(')', '\\)')
            .replaceAll('[', '\\[')
            .replaceAll(']', '\\]')
            .replaceAll('.', '\\.')
            .replaceAll('*', '\\*')
            .replaceAll('+', '\\+')
            .replaceAll('?', '\\?');

        final fullTextStyleRegex = RegExp('$escapedFullMatch[^\\)]*\\)');
        final fullTextStyle = fullTextStyleRegex
            .firstMatch(newContent)
            ?.group(0);

        if (fullTextStyle != null) {
          newContent = newContent.replaceAll(fullTextStyle, newStyle);
          fixes.add('Replaced $description with $newStyle');
        }
      }
    }
  }

  // Handle simple TextStyle() cases
  final simpleTextStyleRegex = RegExp(r'TextStyle\(\s*\)');
  final simpleMatches = simpleTextStyleRegex.allMatches(newContent);
  for (final match in simpleMatches) {
    final fullMatch = match.group(0)!;
    newContent = newContent.replaceAll(fullMatch, 'TextStyles.bodyMedium');
    fixes.add('Replaced empty TextStyle() with TextStyles.bodyMedium');
  }

  return newContent;
}
