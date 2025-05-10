import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../../helpers/testable_network_connectivity_service.dart';
import '../../../helpers/timer_helper.dart';

// Mock classes
class MockConnectivity extends Mock implements Connectivity {}

class MockInternetConnectionChecker extends Mock
    implements InternetConnectionChecker {}

void main() {
  late TestableNetworkConnectivityService connectivityService;
  late MockConnectivity mockConnectivity;
  late MockInternetConnectionChecker mockConnectionChecker;
  late StreamController<ConnectivityResult> connectivityStreamController;
  late StreamController<InternetConnectionStatus>
  internetStatusStreamController;
  late TimerHelper timerHelper;

  setUp(() {
    mockConnectivity = MockConnectivity();
    mockConnectionChecker = MockInternetConnectionChecker();

    // Initialize timer helper
    timerHelper = TimerHelper();

    // Create stream controllers for testing
    connectivityStreamController =
        StreamController<ConnectivityResult>.broadcast();
    internetStatusStreamController =
        StreamController<InternetConnectionStatus>.broadcast();

    // Setup mock behavior
    when(
      () => mockConnectivity.onConnectivityChanged,
    ).thenAnswer((_) => connectivityStreamController.stream);
    when(
      () => mockConnectionChecker.onStatusChange,
    ).thenAnswer((_) => internetStatusStreamController.stream);

    // Create a new instance with mocks for each test
    connectivityService = TestableNetworkConnectivityService(
      connectivity: mockConnectivity,
      connectionChecker: mockConnectionChecker,
    );
  });

  tearDown(() {
    // Clean up resources
    connectivityStreamController.close();
    internetStatusStreamController.close();
    timerHelper.dispose();

    // Clean up service
    connectivityService.dispose();
  });

  group('NetworkConnectivityService', () {
    test('isConnected returns true when connected', () async {
      // Arrange
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => ConnectivityResult.wifi);
      when(
        () => mockConnectionChecker.hasConnection,
      ).thenAnswer((_) async => true);

      // Act
      final result = await connectivityService.isConnected();

      // Assert
      expect(result, isTrue);
    });

    test('isConnected returns false when not connected', () async {
      // Arrange
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => ConnectivityResult.none);

      // Act
      final result = await connectivityService.isConnected();

      // Assert
      expect(result, isFalse);
    });

    test(
      'isConnected returns false when connectivity is available but no internet',
      () async {
        // Arrange
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => ConnectivityResult.wifi);
        when(
          () => mockConnectionChecker.hasConnection,
        ).thenAnswer((_) async => false);

        // Act
        final result = await connectivityService.isConnected();

        // Assert
        expect(result, isFalse);
      },
    );

    testWidgets('connectionStream emits values when connectivity changes', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockConnectionChecker.hasConnection,
      ).thenAnswer((_) async => true);

      // Act & Assert
      expectLater(
        connectivityService.connectionStream,
        emitsInOrder([true, false, true]),
      );

      // Simulate connectivity changes
      connectivityStreamController.add(ConnectivityResult.wifi);
      await tester.pump(Duration.zero);
      connectivityStreamController.add(ConnectivityResult.none);
      await tester.pump(Duration.zero);
      connectivityStreamController.add(ConnectivityResult.mobile);

      // Use pumpAndSettleWithTimeout to handle any pending timers
      await tester.pumpAndSettleWithTimeout(timerHelper);
    });
  });
}
