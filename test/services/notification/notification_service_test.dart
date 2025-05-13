import 'package:eventati_book/models/notification_models/notification.dart';
import 'package:eventati_book/models/service_models/booking.dart';
import 'package:eventati_book/services/interfaces/messaging_service_interface.dart';
import 'package:eventati_book/services/notification/notification_service.dart';
import 'package:eventati_book/services/supabase/database/notification_database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockNotificationDatabaseService extends Mock
    implements NotificationDatabaseService {}

class MockMessagingService extends Mock implements MessagingServiceInterface {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

void main() {
  late NotificationService notificationService;
  late MockNotificationDatabaseService mockDatabaseService;
  late MockMessagingService mockMessagingService;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockUser mockUser;

  setUp(() {
    mockDatabaseService = MockNotificationDatabaseService();
    mockMessagingService = MockMessagingService();
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockUser = MockUser();

    // Set up mock behavior
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('test-user-id');

    // Create the service with mocks
    notificationService = NotificationService(
      supabase: mockSupabaseClient,
      notificationDatabaseService: mockDatabaseService,
      messagingService: mockMessagingService,
    );
  });

  group('NotificationService', () {
    test(
      'getNotifications returns notifications from database service',
      () async {
        // Create test notifications
        final testNotifications = [
          Notification(
            id: 'notification-1',
            userId: 'test-user-id',
            title: 'Test Notification 1',
            body: 'This is a test notification 1',
            type: NotificationType.system,
          ),
          Notification(
            id: 'notification-2',
            userId: 'test-user-id',
            title: 'Test Notification 2',
            body: 'This is a test notification 2',
            type: NotificationType.system,
          ),
        ];

        // Set up mock response
        when(
          () => mockDatabaseService.getNotifications(any()),
        ).thenAnswer((_) async => testNotifications);

        // Call the method
        final result = await notificationService.getNotifications();

        // Verify the result
        expect(result, equals(testNotifications));
        verify(
          () => mockDatabaseService.getNotifications('test-user-id'),
        ).called(1);
      },
    );

    test(
      'getUnreadNotifications returns unread notifications from database service',
      () async {
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
        ];

        // Set up mock response
        when(
          () => mockDatabaseService.getUnreadNotifications(any()),
        ).thenAnswer((_) async => testNotifications);

        // Call the method
        final result = await notificationService.getUnreadNotifications();

        // Verify the result
        expect(result, equals(testNotifications));
        verify(
          () => mockDatabaseService.getUnreadNotifications('test-user-id'),
        ).called(1);
      },
    );

    test('markAsRead calls database service', () async {
      // Set up mock response
      when(
        () => mockDatabaseService.markAsRead(any()),
      ).thenAnswer((_) async {});

      // Call the method
      await notificationService.markAsRead('notification-1');

      // Verify the database service was called
      verify(() => mockDatabaseService.markAsRead('notification-1')).called(1);
    });

    test('markAllAsRead calls database service', () async {
      // Set up mock response
      when(
        () => mockDatabaseService.markAllAsRead(any()),
      ).thenAnswer((_) async {});

      // Call the method
      await notificationService.markAllAsRead();

      // Verify the database service was called
      verify(() => mockDatabaseService.markAllAsRead('test-user-id')).called(1);
    });

    test('deleteNotification calls database service', () async {
      // Set up mock response
      when(
        () => mockDatabaseService.deleteNotification(any()),
      ).thenAnswer((_) async {});

      // Call the method
      await notificationService.deleteNotification('notification-1');

      // Verify the database service was called
      verify(
        () => mockDatabaseService.deleteNotification('notification-1'),
      ).called(1);
    });

    test(
      'createBookingConfirmationNotification creates and sends notifications',
      () async {
        // Create test booking
        final booking = Booking(
          id: 'booking-1',
          userId: 'test-user-id',
          serviceId: 'service-1',
          serviceType: 'venue',
          serviceName: 'Test Service',
          bookingDateTime: DateTime(2023, 1, 1, 10, 0),
          duration: 2,
          guestCount: 50,
          totalPrice: 100,
          status: BookingStatus.confirmed,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
          contactName: 'Test User',
          contactEmail: 'test@example.com',
          contactPhone: '123-456-7890',
        );

        // Set up mock responses
        when(
          () => mockDatabaseService.createNotification(any()),
        ).thenAnswer((_) async => 'notification-id');
        when(
          () => mockMessagingService.sendMessageToUser(
            userId: any(named: 'userId'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) async {});

        // Call the method
        await notificationService.createBookingConfirmationNotification(
          booking,
        );

        // Verify the database service was called
        verify(() => mockDatabaseService.createNotification(any())).called(1);

        // Verify the messaging service was called
        verify(
          () => mockMessagingService.sendMessageToUser(
            userId: 'test-user-id',
            title: 'Booking Confirmed',
            body: any(that: contains('Test Service')),
            data: any(named: 'data'),
          ),
        ).called(1);
      },
    );

    test(
      'createBookingReminderNotification creates and sends notifications',
      () async {
        // Create test booking
        final booking = Booking(
          id: 'booking-1',
          userId: 'test-user-id',
          serviceId: 'service-1',
          serviceType: 'venue',
          serviceName: 'Test Service',
          bookingDateTime: DateTime(2023, 1, 1, 10, 0),
          duration: 2,
          guestCount: 50,
          totalPrice: 100,
          status: BookingStatus.confirmed,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
          contactName: 'Test User',
          contactEmail: 'test@example.com',
          contactPhone: '123-456-7890',
        );

        // Set up mock responses
        when(
          () => mockDatabaseService.createNotification(any()),
        ).thenAnswer((_) async => 'notification-id');
        when(
          () => mockMessagingService.sendMessageToUser(
            userId: any(named: 'userId'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) async {});

        // Call the method
        await notificationService.createBookingReminderNotification(booking, 3);

        // Verify the database service was called
        verify(() => mockDatabaseService.createNotification(any())).called(1);

        // Verify the messaging service was called
        verify(
          () => mockMessagingService.sendMessageToUser(
            userId: 'test-user-id',
            title: 'Upcoming Booking Reminder',
            body: any(that: contains('3 days')),
            data: any(named: 'data'),
          ),
        ).called(1);
      },
    );

    test('handles error when user is not authenticated', () async {
      // Set up mock behavior for unauthenticated user
      when(() => mockGoTrueClient.currentUser).thenReturn(null);

      // Call the method
      final result = await notificationService.getNotifications();

      // Verify the result is empty
      expect(result, isEmpty);
      verifyNever(() => mockDatabaseService.getNotifications(any()));
    });
  });
}
