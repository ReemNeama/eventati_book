# Code Quality Guidelines

This document outlines the code quality tools and processes used in the Eventati Book project to ensure high-quality, maintainable code.

## Table of Contents

1. [Automated Tools](#automated-tools)
2. [Running Checks Locally](#running-checks-locally)
3. [Git Hooks](#git-hooks)
4. [Continuous Integration](#continuous-integration)
5. [Code Coverage](#code-coverage)
6. [Style Guide](#style-guide)

## Automated Tools

The project uses several automated tools to enforce code quality:

### Dart Analyzer

The Dart analyzer is a static analysis tool that identifies potential errors, style issues, and other problems in your Dart code.

Configuration: [analysis_options.yaml](analysis_options.yaml)

### Flutter Lints

Flutter Lints provides a set of recommended lints to encourage good coding practices.

Configuration: Included in [analysis_options.yaml](analysis_options.yaml)

### Dart Code Metrics

Dart Code Metrics is a static analysis tool that helps improve code quality by providing additional metrics and rules.

Configuration: Included in [analysis_options.yaml](analysis_options.yaml)

Key metrics:
- Cyclomatic complexity: Maximum 20
- Number of parameters: Maximum 4
- Maximum nesting level: Maximum 5
- Source lines of code: Maximum 50
- Maintainability index: Minimum 50

## Running Checks Locally

We provide a script to run all code quality checks locally:

```bash
# Run all checks
dart run tool/run_checks.dart

# Run all checks and fix issues when possible
dart run tool/run_checks.dart --fix
```

This script will:
1. Check code formatting
2. Run the Dart analyzer
3. Run Dart Code Metrics
4. Run tests
5. Generate a coverage report

## Git Hooks

The project uses Git hooks to enforce code quality before commits and pushes:

### Pre-commit Hook

The pre-commit hook runs before each commit and checks:
- Code formatting
- Dart analyzer
- Dart Code Metrics

### Pre-push Hook

The pre-push hook runs before each push and checks:
- Tests

### Setup Git Hooks

To set up the Git hooks, run:

```bash
dart run tool/git_hooks.dart
```

## Continuous Integration

The project uses GitHub Actions for continuous integration:

- **On Pull Request**: Runs all code quality checks and tests
- **On Push to Main/Master**: Runs all code quality checks, tests, and builds the app

The CI workflow is defined in [.github/workflows/flutter.yml](.github/workflows/flutter.yml)

## Code Coverage

The project aims to maintain high test coverage. Coverage reports are generated:

- Locally: When running `dart run tool/run_checks.dart`
- In CI: On each pull request and push to main/master

Coverage badge: ![Coverage](coverage_badge.svg)

## Style Guide

The project follows a comprehensive style guide defined in [STYLE_GUIDE.md](STYLE_GUIDE.md).

Key points:
- Use the Dart formatter (`dart format`)
- Follow naming conventions
- Keep methods small and focused
- Write meaningful comments
- Write tests for all business logic

## Best Practices

1. **Run checks locally** before pushing changes
2. **Address all warnings** from the analyzer and Dart Code Metrics
3. **Write tests** for all new features and bug fixes
4. **Keep methods small** and focused on a single responsibility
5. **Follow the style guide** for consistent code
6. **Review the code quality reports** in pull requests
