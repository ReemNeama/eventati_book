// ignore_for_file: avoid_print
import 'dart:io';

/// A custom linting tool to enforce the use of centralized styles.
///
/// This tool:
/// 1. Scans all Dart files in the lib directory
/// 2. Checks for hardcoded styles (TextStyle, Colors, etc.)
/// 3. Checks for deprecated styles (AppColors.primaryColor, etc.)
/// 4. Checks for missing imports (app_colors.dart, text_styles.dart, etc.)
/// 5. Generates a report of violations
///
/// Usage: dart run tool/custom_lint_rules.dart [--fix] [--verbose]
///
/// Options:
///   --fix     Automatically fix some common issues (experimental)
///   --verbose Show detailed information about violations
void main(List<String> arguments) async {
  final bool autoFix = arguments.contains('--fix');
  final bool verbose = arguments.contains('--verbose');

  print('🔍 Running custom lint rules...\n');

  // Get all Dart files in the lib directory
  final dartFiles = await _getDartFiles();
  print('Found ${dartFiles.length} Dart files to scan.\n');

  // Define rules
  final rules = [
    HardcodedColorsRule(),
    HardcodedTextStyleRule(),
    DeprecatedStylesRule(),
    MissingImportsRule(),
    WithOpacityRule(),
  ];

  // Apply rules to all files
  final violations = <Violation>[];
  for (final file in dartFiles) {
    final content = await file.readAsString();

    for (final rule in rules) {
      final ruleViolations = rule.check(file.path, content);
      violations.addAll(ruleViolations);

      // Auto-fix if requested
      if (autoFix && rule.canFix) {
        final fixedContent = rule.fix(content, ruleViolations);
        if (fixedContent != content) {
          await file.writeAsString(fixedContent);
          print(
            'Auto-fixed ${ruleViolations.length} violations in ${file.path}',
          );
        }
      }
    }
  }

  // Print violations
  if (violations.isEmpty) {
    print('✅ No violations found!');
  } else {
    print('❌ Found ${violations.length} violations:');

    // Group violations by file
    final violationsByFile = <String, List<Violation>>{};
    for (final violation in violations) {
      violationsByFile.putIfAbsent(violation.filePath, () => []).add(violation);
    }

    // Print violations by file
    for (final entry in violationsByFile.entries) {
      print('\n${entry.key}:');
      for (final violation in entry.value) {
        if (verbose) {
          print(
            '  - [${violation.rule}] Line ${violation.line}: ${violation.message}',
          );
        } else {
          print('  - Line ${violation.line}: ${violation.message}');
        }
      }
    }

    // Print summary by rule
    print('\nSummary by rule:');
    final violationsByRule = <String, int>{};
    for (final violation in violations) {
      violationsByRule.update(
        violation.rule,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
    for (final entry in violationsByRule.entries) {
      print('  - ${entry.key}: ${entry.value} violations');
    }
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

/// A violation of a lint rule.
class Violation {
  final String rule;
  final String filePath;
  final int line;
  final String message;
  final String code;

  Violation({
    required this.rule,
    required this.filePath,
    required this.line,
    required this.message,
    required this.code,
  });
}

/// A lint rule.
abstract class LintRule {
  String get name;
  bool get canFix;

  List<Violation> check(String filePath, String content);

  String fix(String content, List<Violation> violations) {
    // Default implementation does nothing
    return content;
  }
}

/// A rule that checks for hardcoded colors.
class HardcodedColorsRule extends LintRule {
  @override
  String get name => 'no-hardcoded-colors';

  @override
  bool get canFix => true;

  @override
  List<Violation> check(String filePath, String content) {
    final violations = <Violation>[];

    // Check for hardcoded colors
    final regex = RegExp(r'Colors\.([a-zA-Z0-9]+)');
    final matches = regex.allMatches(content);

    for (final match in matches) {
      final color = match.group(1);
      if (color == null) continue;

      // Skip allowed colors
      if (['white', 'black', 'transparent'].contains(color)) {
        continue;
      }

      // Get line number
      final lineNumber = content.substring(0, match.start).split('\n').length;

      violations.add(
        Violation(
          rule: name,
          filePath: filePath,
          line: lineNumber,
          message: 'Hardcoded color: Colors.$color. Use AppColors instead.',
          code: match.group(0)!,
        ),
      );
    }

    return violations;
  }

  @override
  String fix(String content, List<Violation> violations) {
    var newContent = content;

    // Define replacements
    final replacements = {
      'Colors.blue': 'AppColors.primary',
      'Colors.red': 'AppColors.error',
      'Colors.green': 'AppColors.success',
      'Colors.orange': 'AppColors.warning',
      'Colors.amber': 'AppColors.ratingStarColor',
      'Colors.grey': 'AppColors.disabled',
    };

    // Apply replacements
    for (final entry in replacements.entries) {
      newContent = newContent.replaceAll(entry.key, entry.value);
    }

    return newContent;
  }
}

/// A rule that checks for hardcoded text styles.
class HardcodedTextStyleRule extends LintRule {
  @override
  String get name => 'no-hardcoded-text-styles';

  @override
  bool get canFix => false;

  @override
  List<Violation> check(String filePath, String content) {
    final violations = <Violation>[];

    // Check for hardcoded text styles
    final regex = RegExp(r'TextStyle\(');
    final matches = regex.allMatches(content);

    for (final match in matches) {
      // Get line number
      final lineNumber = content.substring(0, match.start).split('\n').length;

      violations.add(
        Violation(
          rule: name,
          filePath: filePath,
          line: lineNumber,
          message: 'Hardcoded TextStyle. Use TextStyles instead.',
          code: match.group(0)!,
        ),
      );
    }

    return violations;
  }
}

/// A rule that checks for deprecated styles.
class DeprecatedStylesRule extends LintRule {
  @override
  String get name => 'no-deprecated-styles';

  @override
  bool get canFix => true;

  @override
  List<Violation> check(String filePath, String content) {
    final violations = <Violation>[];

    // Check for deprecated styles
    final deprecatedStyles = [
      'AppColors.primaryColor',
      'AppColors.secondaryColor',
      'AppColors.accentColor',
      'AppColors.backgroundColor',
      'AppColors.textColor',
      'AppColors.lightTextColor',
      'AppColors.errorColor',
      'AppColors.successColor',
      'AppColors.warningColor',
      'AppColors.infoColor',
      'AppColors.disabledColor',
      'AppColors.dividerColor',
      'AppColors.cardColor',
      'AppColors.shadowColor',
      'AppTextStyles.heading1',
      'AppTextStyles.heading2',
      'AppTextStyles.heading3',
      'AppTextStyles.bodyText',
      'AppTextStyles.smallText',
      'AppTextStyles.captionText',
      'AppTextStyles.buttonText',
    ];

    for (final style in deprecatedStyles) {
      final regex = RegExp(style);
      final matches = regex.allMatches(content);

      for (final match in matches) {
        // Get line number
        final lineNumber = content.substring(0, match.start).split('\n').length;

        violations.add(
          Violation(
            rule: name,
            filePath: filePath,
            line: lineNumber,
            message: 'Deprecated style: $style',
            code: match.group(0)!,
          ),
        );
      }
    }

    return violations;
  }

  @override
  String fix(String content, List<Violation> violations) {
    var newContent = content;

    // Define replacements
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
      'AppTextStyles.heading1': 'TextStyles.title',
      'AppTextStyles.heading2': 'TextStyles.subtitle',
      'AppTextStyles.heading3': 'TextStyles.sectionTitle',
      'AppTextStyles.bodyText': 'TextStyles.bodyLarge',
      'AppTextStyles.smallText': 'TextStyles.bodyMedium',
      'AppTextStyles.captionText': 'TextStyles.bodySmall',
      'AppTextStyles.buttonText': 'TextStyles.buttonText',
    };

    // Apply replacements
    for (final entry in replacements.entries) {
      newContent = newContent.replaceAll(entry.key, entry.value);
    }

    return newContent;
  }
}

/// A rule that checks for missing imports.
class MissingImportsRule extends LintRule {
  @override
  String get name => 'missing-imports';

  @override
  bool get canFix => true;

  @override
  List<Violation> check(String filePath, String content) {
    final violations = <Violation>[];

    // Check for missing imports
    final hasAppColors = content.contains('AppColors.');
    final hasAppColorsDark = content.contains('AppColorsDark.');
    final hasTextStyles = content.contains('TextStyles.');

    final hasAppColorsImport = content.contains(
      "import 'package:eventati_book/styles/app_colors.dart'",
    );
    final hasAppColorsDarkImport = content.contains(
      "import 'package:eventati_book/styles/app_colors_dark.dart'",
    );
    final hasTextStylesImport = content.contains(
      "import 'package:eventati_book/styles/text_styles.dart'",
    );

    if (hasAppColors && !hasAppColorsImport) {
      violations.add(
        Violation(
          rule: name,
          filePath: filePath,
          line: 1,
          message:
              "Missing import: import 'package:eventati_book/styles/app_colors.dart';",
          code: '',
        ),
      );
    }

    if (hasAppColorsDark && !hasAppColorsDarkImport) {
      violations.add(
        Violation(
          rule: name,
          filePath: filePath,
          line: 1,
          message:
              "Missing import: import 'package:eventati_book/styles/app_colors_dark.dart';",
          code: '',
        ),
      );
    }

    if (hasTextStyles && !hasTextStylesImport) {
      violations.add(
        Violation(
          rule: name,
          filePath: filePath,
          line: 1,
          message:
              "Missing import: import 'package:eventati_book/styles/text_styles.dart';",
          code: '',
        ),
      );
    }

    return violations;
  }

  @override
  String fix(String content, List<Violation> violations) {
    var newContent = content;

    // Add missing imports
    for (final violation in violations) {
      if (violation.message.contains(
        "import 'package:eventati_book/styles/app_colors.dart'",
      )) {
        newContent = _addImport(
          newContent,
          "import 'package:eventati_book/styles/app_colors.dart';",
        );
      } else if (violation.message.contains(
        "import 'package:eventati_book/styles/app_colors_dark.dart'",
      )) {
        newContent = _addImport(
          newContent,
          "import 'package:eventati_book/styles/app_colors_dark.dart';",
        );
      } else if (violation.message.contains(
        "import 'package:eventati_book/styles/text_styles.dart'",
      )) {
        newContent = _addImport(
          newContent,
          "import 'package:eventati_book/styles/text_styles.dart';",
        );
      }
    }

    return newContent;
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
}

/// A rule that checks for withOpacity usage.
class WithOpacityRule extends LintRule {
  @override
  String get name => 'no-with-opacity';

  @override
  bool get canFix => false;

  @override
  List<Violation> check(String filePath, String content) {
    final violations = <Violation>[];

    // Check for withOpacity usage
    final regex = RegExp(r'\.withOpacity\(');
    final matches = regex.allMatches(content);

    for (final match in matches) {
      // Get line number
      final lineNumber = content.substring(0, match.start).split('\n').length;

      violations.add(
        Violation(
          rule: name,
          filePath: filePath,
          line: lineNumber,
          message: 'Use Color.fromRGBO() instead of withOpacity().',
          code: match.group(0)!,
        ),
      );
    }

    return violations;
  }
}
