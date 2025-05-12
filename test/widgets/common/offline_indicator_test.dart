import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:eventati_book/services/utils/network_connectivity_service.dart';
import 'package:eventati_book/widgets/common/offline_indicator.dart';

// Mock classes
class MockNetworkConnectivityService extends Mock
    implements NetworkConnectivityService {}

void main() {
  late MockNetworkConnectivityService mockConnectivityService;

  // Create a StreamController to simulate connectivity changes
  late Stream<bool> connectivityStream;

  setUp(() {
    mockConnectivityService = MockNetworkConnectivityService();

    // Set up the mock connectivity service
    connectivityStream = Stream.fromIterable([true]); // Default to online
    when(
      () => mockConnectivityService.connectionStream,
    ).thenAnswer((_) => connectivityStream);
  });

  group('OfflineIndicator', () {
    testWidgets('shows child when online', (WidgetTester tester) async {
      // Arrange
      const childKey = Key('child');
      const child = Text('Online Content', key: childKey);

      when(
        () => mockConnectivityService.isConnected(),
      ).thenAnswer((_) async => true);

      // Set up the connectivity stream to return online status
      connectivityStream = Stream.fromIterable([true]);
      when(
        () => mockConnectivityService.connectionStream,
      ).thenAnswer((_) => connectivityStream);

      // Act
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: OfflineIndicator(child: child))),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(childKey), findsOneWidget);
      expect(
        find.text('You are offline. Some features may be unavailable.'),
        findsNothing,
      );
    });
  });
}
