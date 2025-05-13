import 'package:eventati_book/models/notification_models/notification.dart';
import 'package:eventati_book/services/supabase/database/notification_database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockPostgrestBuilder extends Mock implements PostgrestBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}
class MockPostgrestQueryBuilder extends Mock implements PostgrestQueryBuilder {}

void main() {
  late NotificationDatabaseService notificationDatabaseService;
  late MockSupabaseClient mockSupabaseClient;
  late MockPostgrestQueryBuilder mockQueryBuilder;
  late MockPostgrestBuilder mockBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockQueryBuilder = MockPostgrestQueryBuilder();
    mockBuilder = MockPostgrestBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();

    // Set up mock behavior
    when(() => mockSupabaseClient.from(any())).thenReturn(mockQueryBuilder);
    when(() => mockQueryBuilder.select()).thenReturn(mockBuilder);
    when(() => mockBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);
    when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')))
        .thenReturn(mockFilterBuilder);

    // Create the service with mocks
    notificationDatabaseService = NotificationDatabaseService(
      supabase: mockSupabaseClient,
    );
  });

  group('NotificationDatabaseService', () {
    test('getNotifications returns notifications from Supabase', () async {
      // Create test notifications
      final testNotificationsJson = [
        {
          'id': 'notification-1',
          'user_id': 'test-user-id',
          'title': 'Test Notification 1',
          'body': 'This is a test notification 1',
          'type': 0,
          'read': false,
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 'notification-2',
          'user_id': 'test-user-id',
          'title': 'Test Notification 2',
          'body': 'This is a test notification 2',
          'type': 1,
          'read': true,
          'created_at': DateTime.now().toIso8601String(),
        },
      ];

      // Set up mock response
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')))
          .thenAnswer((_) async => testNotificationsJson);

      // Call the method
      final result = await notificationDatabaseService.getNotifications('test-user-id');

      // Verify the result
      expect(result.length, 2);
      expect(result[0].id, 'notification-1');
      expect(result[1].id, 'notification-2');

      // Verify Supabase was called correctly
      verify(() => mockSupabaseClient.from('notifications')).called(1);
      verify(() => mockQueryBuilder.select()).called(1);
      verify(() => mockBuilder.eq('user_id', 'test-user-id')).called(1);
      verify(() => mockFilterBuilder.order('created_at', ascending: false)).called(1);
    });

    test('getUnreadNotifications returns unread notifications from Supabase', () async {
      // Create test notifications
      final testNotificationsJson = [
        {
          'id': 'notification-1',
          'user_id': 'test-user-id',
          'title': 'Test Notification 1',
          'body': 'This is a test notification 1',
          'type': 0,
          'read': false,
          'created_at': DateTime.now().toIso8601String(),
        },
      ];

      // Set up mock behavior
      when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);
      
      // Set up mock response
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')))
          .thenAnswer((_) async => testNotificationsJson);

      // Call the method
      final result = await notificationDatabaseService.getUnreadNotifications('test-user-id');

      // Verify the result
      expect(result.length, 1);
      expect(result[0].id, 'notification-1');
      expect(result[0].read, false);

      // Verify Supabase was called correctly
      verify(() => mockSupabaseClient.from('notifications')).called(1);
      verify(() => mockQueryBuilder.select()).called(1);
      verify(() => mockBuilder.eq('user_id', 'test-user-id')).called(1);
      verify(() => mockFilterBuilder.eq('read', false)).called(1);
      verify(() => mockFilterBuilder.order('created_at', ascending: false)).called(1);
    });

    test('createNotification inserts notification into Supabase', () async {
      // Create test notification
      final notification = Notification(
        userId: 'test-user-id',
        title: 'Test Notification',
        body: 'This is a test notification',
        type: NotificationType.system,
      );

      // Set up mock behavior
      when(() => mockQueryBuilder.insert(any())).thenAnswer((_) async => null);

      // Call the method
      await notificationDatabaseService.createNotification(notification);

      // Verify Supabase was called correctly
      verify(() => mockSupabaseClient.from('notifications')).called(1);
      verify(() => mockQueryBuilder.insert(any())).called(1);
    });

    test('markAsRead updates notification in Supabase', () async {
      // Set up mock behavior
      when(() => mockQueryBuilder.update(any())).thenReturn(mockBuilder);
      when(() => mockBuilder.eq(any(), any())).thenAnswer((_) async => null);

      // Call the method
      await notificationDatabaseService.markAsRead('notification-1');

      // Verify Supabase was called correctly
      verify(() => mockSupabaseClient.from('notifications')).called(1);
      verify(() => mockQueryBuilder.update({'read': true})).called(1);
      verify(() => mockBuilder.eq('id', 'notification-1')).called(1);
    });

    test('markAllAsRead updates all notifications for a user in Supabase', () async {
      // Set up mock behavior
      when(() => mockQueryBuilder.update(any())).thenReturn(mockBuilder);
      when(() => mockBuilder.eq(any(), any())).thenAnswer((_) async => null);

      // Call the method
      await notificationDatabaseService.markAllAsRead('test-user-id');

      // Verify Supabase was called correctly
      verify(() => mockSupabaseClient.from('notifications')).called(1);
      verify(() => mockQueryBuilder.update({'read': true})).called(1);
      verify(() => mockBuilder.eq('user_id', 'test-user-id')).called(1);
    });

    test('deleteNotification deletes notification from Supabase', () async {
      // Set up mock behavior
      when(() => mockQueryBuilder.delete()).thenReturn(mockBuilder);
      when(() => mockBuilder.eq(any(), any())).thenAnswer((_) async => null);

      // Call the method
      await notificationDatabaseService.deleteNotification('notification-1');

      // Verify Supabase was called correctly
      verify(() => mockSupabaseClient.from('notifications')).called(1);
      verify(() => mockQueryBuilder.delete()).called(1);
      verify(() => mockBuilder.eq('id', 'notification-1')).called(1);
    });

    test('getNotificationsStream returns a stream of notifications', () {
      // Create test notifications
      final testNotificationsJson = [
        {
          'id': 'notification-1',
          'user_id': 'test-user-id',
          'title': 'Test Notification 1',
          'body': 'This is a test notification 1',
          'type': 0,
          'read': false,
          'created_at': DateTime.now().toIso8601String(),
        },
      ];

      // Set up mock behavior
      final mockStream = Stream.value(testNotificationsJson);
      when(() => mockQueryBuilder.stream(primaryKey: any(named: 'primaryKey')))
          .thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')))
          .thenReturn(mockStream);

      // Call the method
      final result = notificationDatabaseService.getNotificationsStream('test-user-id');

      // Verify the stream
      expect(result, isA<Stream<List<Notification>>>());

      // Verify Supabase was called correctly
      verify(() => mockSupabaseClient.from('notifications')).called(1);
      verify(() => mockQueryBuilder.stream(primaryKey: ['id'])).called(1);
      verify(() => mockFilterBuilder.eq('user_id', 'test-user-id')).called(1);
      verify(() => mockFilterBuilder.order('created_at', ascending: false)).called(1);
    });
  });
}
