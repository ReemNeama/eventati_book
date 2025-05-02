@echo off
echo Running code quality checks...
echo.

echo 1. Running Flutter analyze...
flutter analyze
if %ERRORLEVEL% NEQ 0 (
  echo Flutter analyze found issues. Please fix them before committing.
  exit /b 1
)
echo Flutter analyze passed.
echo.

echo 2. Checking for unused imports...
echo This is a manual check. Please review your code for unused imports.
echo.

echo 3. Checking for deprecated APIs...
echo This is a manual check. Please review your code for deprecated APIs like withOpacity().
echo.

echo 4. Formatting code...
flutter format .
echo Code formatting complete.
echo.

echo 5. Running Flutter pub outdated to check for outdated dependencies...
flutter pub outdated
echo.

echo All automated checks complete. Please review the CODE_REVIEW_CHECKLIST.md file for manual checks.
echo.
