import 'package:eventati_book/models/notification_models/notification.dart'
    as notification_model;
import 'package:eventati_book/providers/notification_provider.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:eventati_book/widgets/notification/notification_center_new.dart';
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

  Widget createTestWidget({
    bool isLoading = false,
    String? errorMessage,
    List<notification_model.Notification> notifications = const [],
  }) {
    when(() => mockNotificationProvider.isLoading).thenReturn(isLoading);
    when(() => mockNotificationProvider.errorMessage).thenReturn(errorMessage);
    when(
      () => mockNotificationProvider.notifications,
    ).thenReturn(notifications);
    when(
      () => mockNotificationProvider.refreshNotifications(),
    ).thenAnswer((_) async {});
    when(
      () => mockNotificationProvider.markAllAsRead(),
    ).thenAnswer((_) async {});
    when(
      () => mockNotificationProvider.markAsRead(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockNotificationProvider.deleteNotification(any()),
    ).thenAnswer((_) async {});

    return MaterialApp(
      home: ChangeNotifierProvider<NotificationProvider>.value(
        value: mockNotificationProvider,
        child: const Scaffold(body: Center(child: NotificationCenter())),
      ),
    );
  }

  group('NotificationCenter', () {
    testWidgets('renders loading indicator when loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(isLoading: true));

      // Verify loading indicator is shown
      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.text('Loading notifications...'), findsOneWidget);
    });

    testWidgets('renders error message when there is an error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(errorMessage: 'Failed to load notifications'),
      );

      // Verify error message is shown
      expect(find.text('Failed to load notifications'), findsOneWidget);
    });

    testWidgets('renders empty state when there are no notifications', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(notifications: []));

      // Verify empty state is shown
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No Notifications'), findsOneWidget);
      expect(
        find.text('You have no notifications at this time.'),
        findsOneWidget,
      );
    });

    testWidgets('renders notifications when there are notifications', (
      WidgetTester tester,
    ) async {
      final notifications = [
        notification_model.Notification(
          id: 'notification-1',
          userId: 'test-user-id',
          title: 'Test Notification 1',
          body: 'This is a test notification 1',
          type: notification_model.NotificationType.system,
          read: false,
        ),
        notification_model.Notification(
          id: 'notification-2',
          userId: 'test-user-id',
          title: 'Test Notification 2',
          body: 'This is a test notification 2',
          type: notification_model.NotificationType.system,
          read: true,
        ),
      ];

      await tester.pumpWidget(createTestWidget(notifications: notifications));

      // Verify notifications are shown
      expect(find.text('Test Notification 1'), findsOneWidget);
      expect(find.text('This is a test notification 1'), findsOneWidget);
      expect(find.text('Test Notification 2'), findsOneWidget);
      expect(find.text('This is a test notification 2'), findsOneWidget);
    });

    testWidgets('can mark all notifications as read', (
      WidgetTester tester,
    ) async {
      final notifications = [
        notification_model.Notification(
          id: 'notification-1',
          userId: 'test-user-id',
          title: 'Test Notification 1',
          body: 'This is a test notification 1',
          type: notification_model.NotificationType.system,
          read: false,
        ),
      ];

      await tester.pumpWidget(createTestWidget(notifications: notifications));

      // Tap the "Mark All Read" button
      await tester.tap(find.text('Mark All Read'));
      await tester.pump();

      // Verify the provider method was called
      verify(() => mockNotificationProvider.markAllAsRead()).called(1);
    });

    testWidgets('can refresh notifications', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find the refresh button
      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);

      // Tap the refresh button
      await tester.tap(refreshButton);
      await tester.pump();

      // Verify the provider method was called
      verify(() => mockNotificationProvider.refreshNotifications()).called(1);
    });

    testWidgets('can mark a notification as read', (WidgetTester tester) async {
      final notifications = [
        notification_model.Notification(
          id: 'notification-1',
          userId: 'test-user-id',
          title: 'Test Notification 1',
          body: 'This is a test notification 1',
          type: notification_model.NotificationType.system,
          read: false,
        ),
      ];

      await tester.pumpWidget(createTestWidget(notifications: notifications));

      // Tap the notification
      await tester.tap(find.text('Test Notification 1'));
      await tester.pump();

      // Verify the provider method was called
      verify(
        () => mockNotificationProvider.markAsRead('notification-1'),
      ).called(1);
    });

    testWidgets('can delete a notification by dismissing', (
      WidgetTester tester,
    ) async {
      final notifications = [
        notification_model.Notification(
          id: 'notification-1',
          userId: 'test-user-id',
          title: 'Test Notification 1',
          body: 'This is a test notification 1',
          type: notification_model.NotificationType.system,
          read: false,
        ),
      ];

      await tester.pumpWidget(createTestWidget(notifications: notifications));

      // Dismiss the notification
      await tester.drag(
        find.text('Test Notification 1'),
        const Offset(500.0, 0.0),
      );
      await tester.pumpAndSettle();

      // Verify the provider method was called
      verify(
        () => mockNotificationProvider.deleteNotification('notification-1'),
      ).called(1);
    });
  });
}
