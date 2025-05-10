import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/foundation.dart';
import 'package:eventati_book/services/firebase/core/firebase_crashlytics_service.dart';
import '../../../helpers/firebase_test_helper.dart';

// Mock FlutterErrorDetails for testing
class MockFlutterErrorDetails extends Fake implements FlutterErrorDetails {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Mock FlutterErrorDetails';
  }
}

void main() {
  late FirebaseCrashlyticsService crashlyticsService;
  late MockFirebaseCrashlytics mockCrashlytics;

  setUpAll(() {
    // Register fallback value for FlutterErrorDetails
    registerFallbackValue(MockFlutterErrorDetails());
  });

  setUp(() {
    // Create mocks
    mockCrashlytics = MockFirebaseCrashlytics();

    // Create service with mocks
    crashlyticsService = FirebaseCrashlyticsService(
      crashlytics: mockCrashlytics,
    );
  });

  group('FirebaseCrashlyticsService', () {
    test('can be instantiated', () {
      expect(crashlyticsService, isNotNull);
    });

    test('recordError logs error to Crashlytics', () async {
      // Arrange
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      when(
        () => mockCrashlytics.recordError(
          any(),
          any(),
          reason: any(named: 'reason'),
          fatal: any(named: 'fatal'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await crashlyticsService.recordError(
        error,
        stackTrace,
        reason: 'Test reason',
        fatal: true,
      );

      // Assert
      verify(
        () => mockCrashlytics.recordError(
          error,
          stackTrace,
          reason: 'Test reason',
          fatal: true,
        ),
      ).called(1);
    });

    test('recordFlutterError logs Flutter error to Crashlytics', () async {
      // Arrange
      final flutterError = FlutterErrorDetails(
        exception: Exception('Test Flutter error'),
        stack: StackTrace.current,
        library: 'test_library',
        context: ErrorDescription('Test context'),
      );

      when(
        () => mockCrashlytics.recordFlutterError(any()),
      ).thenAnswer((_) async {});

      // Act
      await crashlyticsService.recordFlutterError(flutterError);

      // Assert
      verify(() => mockCrashlytics.recordFlutterError(flutterError)).called(1);
    });

    test('log adds custom log message to Crashlytics', () async {
      // Arrange
      when(() => mockCrashlytics.log(any())).thenAnswer((_) async {});

      // Act
      crashlyticsService.log('Test log message');

      // Assert
      verify(() => mockCrashlytics.log('Test log message')).called(1);
    });

    test('setUserIdentifier sets user identifier in Crashlytics', () async {
      // Arrange
      when(
        () => mockCrashlytics.setUserIdentifier(any()),
      ).thenAnswer((_) async {});

      // Act
      await crashlyticsService.setUserIdentifier('test-user-id');

      // Assert
      verify(() => mockCrashlytics.setUserIdentifier('test-user-id')).called(1);
    });

    test('setCustomKey sets custom key in Crashlytics', () async {
      // Arrange
      when(
        () => mockCrashlytics.setCustomKey(any(), any()),
      ).thenAnswer((_) async {});

      // Act
      await crashlyticsService.setCustomKey('test-key', 'test-value');

      // Assert
      verify(
        () => mockCrashlytics.setCustomKey('test-key', 'test-value'),
      ).called(1);
    });
  });
}
