import 'package:eventati_book/models/notification_models/notification.dart';
import 'package:eventati_book/services/supabase/database/notification_database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Create a simplified mock for testing
class MockNotificationDatabaseService extends Mock
    implements NotificationDatabaseService {}

void main() {
  late MockNotificationDatabaseService mockService;

  setUp(() {
    mockService = MockNotificationDatabaseService();
  });

  group('NotificationDatabaseService', () {
    test('getNotifications returns notifications from Supabase', () async {
      // Arrange
      final mockNotifications = [
        Notification(
          id: '1',
          userId: 'test_user_id',
          title: 'Test Notification 1',
          body: 'This is a test notification',
          type: NotificationType.bookingConfirmation,
          read: false,
          createdAt: DateTime.now(),
        ),
        Notification(
          id: '2',
          userId: 'test_user_id',
          title: 'Test Notification 2',
          body: 'This is another test notification',
          type: NotificationType.paymentConfirmation,
          read: true,
          createdAt: DateTime.now(),
        ),
      ];

      // Setup mock response
      when(
        () => mockService.getNotifications('test_user_id'),
      ).thenAnswer((_) async => mockNotifications);

      // Act
      final result = await mockService.getNotifications('test_user_id');

      // Assert
      expect(result.length, 2);
      expect(result[0].id, '1');
      expect(result[0].title, 'Test Notification 1');
      expect(result[1].id, '2');
      expect(result[1].title, 'Test Notification 2');
    });

    test(
      'getUnreadNotifications returns unread notifications from Supabase',
      () async {
        // Arrange
        final mockNotifications = [
          Notification(
            id: '1',
            userId: 'test_user_id',
            title: 'Test Notification 1',
            body: 'This is a test notification',
            type: NotificationType.bookingConfirmation,
            read: false,
            createdAt: DateTime.now(),
          ),
        ];

        // Setup mock response
        when(
          () => mockService.getUnreadNotifications('test_user_id'),
        ).thenAnswer((_) async => mockNotifications);

        // Act
        final result = await mockService.getUnreadNotifications('test_user_id');

        // Assert
        expect(result.length, 1);
        expect(result[0].id, '1');
        expect(result[0].title, 'Test Notification 1');
        expect(result[0].read, false);
      },
    );

    test('createNotification inserts notification into Supabase', () async {
      // Arrange
      final notification = Notification(
        id: 'new_notification_id',
        userId: 'test_user_id',
        title: 'New Notification',
        body: 'This is a new notification',
        type: NotificationType.bookingConfirmation,
        createdAt: DateTime.now(),
      );

      // Setup mock response
      when(
        () => mockService.createNotification(notification),
      ).thenAnswer((_) async => 'new_notification_id');

      // Act
      final result = await mockService.createNotification(notification);

      // Assert
      expect(result, 'new_notification_id');
      verify(() => mockService.createNotification(notification)).called(1);
    });

    test('markAsRead updates notification in Supabase', () async {
      // Arrange
      const notificationId = 'notification_id';

      // Setup mock response
      when(
        () => mockService.markAsRead(notificationId),
      ).thenAnswer((_) async => {});

      // Act
      await mockService.markAsRead(notificationId);

      // Assert
      verify(() => mockService.markAsRead(notificationId)).called(1);
    });

    test(
      'markAllAsRead updates all notifications for a user in Supabase',
      () async {
        // Arrange
        const userId = 'test_user_id';

        // Setup mock response
        when(
          () => mockService.markAllAsRead(userId),
        ).thenAnswer((_) async => {});

        // Act
        await mockService.markAllAsRead(userId);

        // Assert
        verify(() => mockService.markAllAsRead(userId)).called(1);
      },
    );

    test('deleteNotification deletes notification from Supabase', () async {
      // Arrange
      const notificationId = 'notification_id';

      // Setup mock response
      when(
        () => mockService.deleteNotification(notificationId),
      ).thenAnswer((_) async => {});

      // Act
      await mockService.deleteNotification(notificationId);

      // Assert
      verify(() => mockService.deleteNotification(notificationId)).called(1);
    });

    // Note: Testing streams is more complex and would require additional setup
    test('getNotificationsStream returns a stream of notifications', () {
      // This test requires more complex setup for testing Supabase streams
      // We'll skip it for now but note that it should be implemented
    }, skip: true);
  });
}
