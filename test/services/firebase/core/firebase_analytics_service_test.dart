import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:eventati_book/services/firebase/core/firebase_analytics_service.dart';
import '../../../helpers/firebase_test_helper.dart';

void main() {
  late FirebaseAnalyticsService analyticsService;
  late MockFirebaseAnalytics mockAnalytics;

  setUp(() {
    // Create mocks
    mockAnalytics = MockFirebaseAnalytics();

    // Create service with mocks
    analyticsService = FirebaseAnalyticsService(analytics: mockAnalytics);
  });

  group('FirebaseAnalyticsService', () {
    test('can be instantiated', () {
      expect(analyticsService, isNotNull);
    });

    test('trackScreenView logs screen view event', () async {
      // Arrange
      when(
        () => mockAnalytics.logScreenView(
          screenName: any(named: 'screenName'),
          screenClass: any(named: 'screenClass'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await analyticsService.trackScreenView('TestScreen');

      // Assert
      verify(
        () => mockAnalytics.logScreenView(
          screenName: 'TestScreen',
          screenClass: any(named: 'screenClass'),
        ),
      ).called(1);
    });

    test('trackUserAction logs custom event', () async {
      // Arrange
      when(
        () => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await analyticsService.trackUserAction(
        'test_action',
        parameters: {'param1': 'value1'},
      );

      // Assert
      verify(
        () => mockAnalytics.logEvent(
          name: 'test_action',
          parameters: any(named: 'parameters'),
        ),
      ).called(1);
    });

    test('trackError logs error event', () async {
      // Arrange
      when(
        () => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await analyticsService.trackError(
        'test_error',
        parameters: {'param1': 'value1'},
      );

      // Assert
      verify(
        () => mockAnalytics.logEvent(
          name: 'app_error',
          parameters: any(named: 'parameters'),
        ),
      ).called(1);
    });

    test('setUserProperties sets user properties', () async {
      // Arrange
      when(
        () => mockAnalytics.setUserId(id: any(named: 'id')),
      ).thenAnswer((_) async {});
      when(
        () => mockAnalytics.setUserProperty(
          name: any(named: 'name'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await analyticsService.setUserProperties(
        userId: 'test-user-id',
        properties: {'prop1': 'value1', 'prop2': 'value2'},
      );

      // Assert
      verify(() => mockAnalytics.setUserId(id: 'test-user-id')).called(1);
      verify(
        () => mockAnalytics.setUserProperty(name: 'prop1', value: 'value1'),
      ).called(1);
      verify(
        () => mockAnalytics.setUserProperty(name: 'prop2', value: 'value2'),
      ).called(1);
    });

    test('trackFeatureUsage logs feature usage event', () async {
      // Arrange
      when(
        () => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await analyticsService.trackFeatureUsage(
        featureName: 'test_feature',
        action: 'test_action',
      );

      // Assert
      verify(
        () => mockAnalytics.logEvent(
          name: 'feature_usage',
          parameters: any(named: 'parameters'),
        ),
      ).called(1);
    });

    test('trackConversion logs conversion event', () async {
      // Arrange
      when(
        () => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await analyticsService.trackConversion(
        conversionName: 'test_conversion',
        conversionType: 'test_type',
        value: 10.0,
        currency: 'USD',
      );

      // Assert
      verify(
        () => mockAnalytics.logEvent(
          name: 'conversion',
          parameters: any(named: 'parameters'),
        ),
      ).called(1);
    });
  });
}
