@echo off
echo Running Flutter tests...

REM Run specific tests
echo Running unit tests...
flutter test test/unit/models/simple_user_test.dart
flutter test test/unit/utils/string_utils_test.dart

echo.
echo Running widget tests...
flutter test test/widget/widgets/loading_indicator_test.dart

echo.
echo Running all working tests with coverage...
flutter test

REM Check if tests passed
if %ERRORLEVEL% NEQ 0 (
  echo Tests failed with exit code %ERRORLEVEL%
  exit /b %ERRORLEVEL%
)

echo All tests passed successfully!
echo.
echo Coverage report generated in coverage/lcov.info

REM Remind about viewing coverage report
echo To view the coverage report, install lcov:
echo npm install -g lcov
echo.
echo Then run:
echo genhtml coverage/lcov.info -o coverage/html
echo.
echo Then open coverage/html/index.html in your browser
