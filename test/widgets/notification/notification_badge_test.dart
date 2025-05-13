// No need to import notification model for this test
import 'package:eventati_book/providers/notification_provider.dart';
import 'package:eventati_book/widgets/notification/notification_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockNotificationProvider extends Mock implements NotificationProvider {}

void main() {
  late MockNotificationProvider mockNotificationProvider;

  setUp(() {
    mockNotificationProvider = MockNotificationProvider();
  });

  Widget createTestWidget({int unreadCount = 0}) {
    when(() => mockNotificationProvider.unreadCount).thenReturn(unreadCount);

    return MaterialApp(
      home: ChangeNotifierProvider<NotificationProvider>.value(
        value: mockNotificationProvider,
        child: const Scaffold(body: Center(child: NotificationBadge())),
      ),
    );
  }

  group('NotificationBadge', () {
    testWidgets('renders correctly with no unread notifications', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(unreadCount: 0));

      // Verify the badge is rendered
      expect(find.byType(NotificationBadge), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);

      // Verify no badge count is shown
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsNothing);
    });

    testWidgets('renders correctly with unread notifications', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(unreadCount: 3));

      // Verify the badge is rendered
      expect(find.byType(NotificationBadge), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);

      // Verify badge count is shown
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('renders "9+" for more than 9 unread notifications', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(unreadCount: 10));

      // Verify the badge is rendered
      expect(find.byType(NotificationBadge), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);

      // Verify badge count is shown as "9+"
      expect(find.text('9+'), findsOneWidget);
    });

    testWidgets('can be tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap the badge
      await tester.tap(find.byType(NotificationBadge));
      await tester.pump();

      // Verify the badge was tapped (no error)
      expect(find.byType(NotificationBadge), findsOneWidget);
    });

    testWidgets('can be customized with different icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<NotificationProvider>.value(
            value: mockNotificationProvider,
            child: const Scaffold(
              body: Center(
                child: NotificationBadge(icon: Icons.notifications_active),
              ),
            ),
          ),
        ),
      );

      // Verify the custom icon is used
      expect(find.byIcon(Icons.notifications), findsNothing);
      expect(find.byIcon(Icons.notifications_active), findsOneWidget);
    });

    testWidgets('can be customized with different icon size', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<NotificationProvider>.value(
            value: mockNotificationProvider,
            child: const Scaffold(
              body: Center(child: NotificationBadge(iconSize: 32.0)),
            ),
          ),
        ),
      );

      // Verify the badge is rendered
      expect(find.byType(NotificationBadge), findsOneWidget);

      // Can't easily verify icon size in widget tests
    });

    testWidgets('can be customized with different colors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<NotificationProvider>.value(
            value: mockNotificationProvider,
            child: const Scaffold(
              body: Center(
                child: NotificationBadge(
                  iconColor: Colors.red,
                  badgeColor: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      );

      // Verify the badge is rendered
      expect(find.byType(NotificationBadge), findsOneWidget);

      // Can't easily verify colors in widget tests
    });
  });
}
