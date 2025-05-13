import 'package:eventati_book/models/notification_models/notification.dart';
import 'package:eventati_book/providers/notification_provider.dart';
import 'package:eventati_book/services/notification/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockNotificationService extends Mock implements NotificationService {}
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}

void main() {
  late NotificationProvider notificationProvider;
  late MockNotificationService mockNotificationService;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockUser mockUser;

  setUp(() {
    mockNotificationService = MockNotificationService();
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockUser = MockUser();

    // Set up mock behavior
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('test-user-id');

    // Create test notifications
    final testNotifications = [
      Notification(
        id: 'notification-1',
        userId: 'test-user-id',
        title: 'Test Notification 1',
        body: 'This is a test notification 1',
        type: NotificationType.system,
        read: false,
      ),
      Notification(
        id: 'notification-2',
        userId: 'test-user-id',
        title: 'Test Notification 2',
        body: 'This is a test notification 2',
        type: NotificationType.system,
        read: true,
      ),
    ];

    // Set up mock service responses
    when(() => mockNotificationService.getNotifications())
        .thenAnswer((_) async => testNotifications);
    when(() => mockNotificationService.getNotificationsStream(any()))
        .thenAnswer((_) => Stream.value(testNotifications));
    when(() => mockNotificationService.markAsRead(any()))
        .thenAnswer((_) async {});
    when(() => mockNotificationService.markAllAsRead())
        .thenAnswer((_) async {});
    when(() => mockNotificationService.deleteNotification(any()))
        .thenAnswer((_) async {});

    // Create the provider with mocks
    notificationProvider = NotificationProvider(
      notificationService: mockNotificationService,
      supabase: mockSupabaseClient,
    );
  });

  group('NotificationProvider', () {
    test('initializes with notifications', () async {
      // Verify initial state
      expect(notificationProvider.isLoading, true);
      expect(notificationProvider.notifications, isEmpty);
      expect(notificationProvider.errorMessage, isNull);

      // Wait for initialization to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify notifications are loaded
      expect(notificationProvider.isLoading, false);
      expect(notificationProvider.notifications.length, 2);
      expect(notificationProvider.errorMessage, isNull);
      expect(notificationProvider.unreadCount, 1);

      // Verify the service was called
      verify(() => mockNotificationService.getNotifications()).called(1);
      verify(() => mockNotificationService.getNotificationsStream(any())).called(1);
    });

    test('refreshNotifications updates notifications', () async {
      // Wait for initialization to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Set up new mock response
      final newNotifications = [
        Notification(
          id: 'notification-3',
          userId: 'test-user-id',
          title: 'Test Notification 3',
          body: 'This is a test notification 3',
          type: NotificationType.system,
          read: false,
        ),
      ];
      when(() => mockNotificationService.getNotifications())
          .thenAnswer((_) async => newNotifications);

      // Refresh notifications
      await notificationProvider.refreshNotifications();

      // Verify notifications are updated
      expect(notificationProvider.isLoading, false);
      expect(notificationProvider.notifications.length, 1);
      expect(notificationProvider.notifications.first.id, 'notification-3');
      expect(notificationProvider.unreadCount, 1);

      // Verify the service was called again
      verify(() => mockNotificationService.getNotifications()).called(1);
    });

    test('markAsRead marks a notification as read', () async {
      // Wait for initialization to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Mark notification as read
      await notificationProvider.markAsRead('notification-1');

      // Verify the service was called
      verify(() => mockNotificationService.markAsRead('notification-1')).called(1);

      // Verify the notification is marked as read in the provider
      expect(
        notificationProvider.notifications
            .firstWhere((n) => n.id == 'notification-1')
            .read,
        true,
      );
      expect(notificationProvider.unreadCount, 0);
    });

    test('markAllAsRead marks all notifications as read', () async {
      // Wait for initialization to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Mark all notifications as read
      await notificationProvider.markAllAsRead();

      // Verify the service was called
      verify(() => mockNotificationService.markAllAsRead()).called(1);

      // Verify all notifications are marked as read in the provider
      expect(
        notificationProvider.notifications.every((n) => n.read),
        true,
      );
      expect(notificationProvider.unreadCount, 0);
    });

    test('deleteNotification removes a notification', () async {
      // Wait for initialization to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Delete notification
      await notificationProvider.deleteNotification('notification-1');

      // Verify the service was called
      verify(() => mockNotificationService.deleteNotification('notification-1')).called(1);

      // Verify the notification is removed from the provider
      expect(
        notificationProvider.notifications.any((n) => n.id == 'notification-1'),
        false,
      );
      expect(notificationProvider.notifications.length, 1);
    });

    test('handles error when loading notifications', () async {
      // Create a new provider with a service that throws an error
      when(() => mockNotificationService.getNotifications())
          .thenThrow(Exception('Test error'));

      final errorProvider = NotificationProvider(
        notificationService: mockNotificationService,
        supabase: mockSupabaseClient,
      );

      // Wait for initialization to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify error state
      expect(errorProvider.isLoading, false);
      expect(errorProvider.errorMessage, 'Failed to load notifications');
      expect(errorProvider.notifications, isEmpty);
    });
  });
}
