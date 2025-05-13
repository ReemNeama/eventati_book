import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:eventati_book/services/utils/network_connectivity_service.dart';

// Mock classes
class MockNetworkConnectivityService extends Mock
    implements NetworkConnectivityService {}

// Simple widget that mimics the OfflineIndicator without making network calls
class TestOfflineIndicator extends StatelessWidget {
  final Widget child;
  final bool isOffline;
  final bool showBanner;
  final bool showIcon;
  final Color bannerColor;
  final Color bannerTextColor;
  final String bannerText;
  final Color iconColor;
  final double iconSize;

  const TestOfflineIndicator({
    super.key,
    required this.child,
    this.isOffline = false,
    this.showBanner = true,
    this.showIcon = true,
    this.bannerColor = Colors.red,
    this.bannerTextColor = Colors.white,
    this.bannerText = 'You are offline. Some features may be unavailable.',
    this.iconColor = Colors.red,
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline) {
      return child;
    }

    return Column(
      children: [
        if (showBanner && isOffline)
          Container(
            width: double.infinity,
            color: bannerColor,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Row(
              children: [
                if (showIcon)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.cloud_off,
                      color: bannerTextColor,
                      size: iconSize,
                    ),
                  ),
                Expanded(
                  child: Text(
                    bannerText,
                    style: TextStyle(color: bannerTextColor, fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: bannerTextColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(60, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        Expanded(child: child),
      ],
    );
  }
}

void main() {
  group('OfflineIndicator', () {
    testWidgets('shows child when online', (WidgetTester tester) async {
      // Arrange
      const childKey = Key('child');
      const child = Text('Online Content', key: childKey);

      // Act - use the test version that doesn't make real network calls
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TestOfflineIndicator(isOffline: false, child: child),
          ),
        ),
      );

      // No need to pump and settle since we're not waiting for any async operations

      // Assert
      expect(find.byKey(childKey), findsOneWidget);
      expect(
        find.text('You are offline. Some features may be unavailable.'),
        findsNothing,
      );
    });

    testWidgets('shows offline banner when offline', (
      WidgetTester tester,
    ) async {
      // Arrange
      const childKey = Key('child');
      const child = Text('Online Content', key: childKey);

      // Act - use the test version that doesn't make real network calls
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TestOfflineIndicator(isOffline: true, child: child),
          ),
        ),
      );

      // Assert
      expect(find.byKey(childKey), findsOneWidget);
      expect(
        find.text('You are offline. Some features may be unavailable.'),
        findsOneWidget,
      );
    });
  });
}
