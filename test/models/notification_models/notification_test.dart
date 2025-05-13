import 'package:eventati_book/models/notification_models/notification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Notification', () {
    test('creates a notification with required fields', () {
      final notification = Notification(
        userId: 'test-user-id',
        title: 'Test Notification',
        body: 'This is a test notification',
        type: NotificationType.system,
      );

      expect(notification.userId, 'test-user-id');
      expect(notification.title, 'Test Notification');
      expect(notification.body, 'This is a test notification');
      expect(notification.type, NotificationType.system);
      expect(notification.read, false);
      expect(notification.id, isNotEmpty);
      expect(notification.createdAt, isNotNull);
      expect(notification.relatedEntityId, isNull);
      expect(notification.data, isNull);
    });

    test('creates a notification with all fields', () {
      final now = DateTime.now();
      final notification = Notification(
        id: 'test-id',
        userId: 'test-user-id',
        title: 'Test Notification',
        body: 'This is a test notification',
        type: NotificationType.bookingConfirmation,
        read: true,
        createdAt: now,
        relatedEntityId: 'related-entity-id',
        data: {'key': 'value'},
      );

      expect(notification.id, 'test-id');
      expect(notification.userId, 'test-user-id');
      expect(notification.title, 'Test Notification');
      expect(notification.body, 'This is a test notification');
      expect(notification.type, NotificationType.bookingConfirmation);
      expect(notification.read, true);
      expect(notification.createdAt, now);
      expect(notification.relatedEntityId, 'related-entity-id');
      expect(notification.data, {'key': 'value'});
    });

    test('copyWith creates a new notification with updated fields', () {
      final notification = Notification(
        id: 'test-id',
        userId: 'test-user-id',
        title: 'Test Notification',
        body: 'This is a test notification',
        type: NotificationType.system,
      );

      final updatedNotification = notification.copyWith(
        title: 'Updated Title',
        body: 'Updated Body',
        read: true,
      );

      expect(updatedNotification.id, notification.id);
      expect(updatedNotification.userId, notification.userId);
      expect(updatedNotification.title, 'Updated Title');
      expect(updatedNotification.body, 'Updated Body');
      expect(updatedNotification.type, notification.type);
      expect(updatedNotification.read, true);
      expect(updatedNotification.createdAt, notification.createdAt);
      expect(updatedNotification.relatedEntityId, notification.relatedEntityId);
      expect(updatedNotification.data, notification.data);
    });

    test('markAsRead creates a new notification with read set to true', () {
      final notification = Notification(
        userId: 'test-user-id',
        title: 'Test Notification',
        body: 'This is a test notification',
        type: NotificationType.system,
        read: false,
      );

      final readNotification = notification.markAsRead();

      expect(readNotification.read, true);
      expect(readNotification.id, notification.id);
      expect(readNotification.userId, notification.userId);
      expect(readNotification.title, notification.title);
      expect(readNotification.body, notification.body);
      expect(readNotification.type, notification.type);
      expect(readNotification.createdAt, notification.createdAt);
      expect(readNotification.relatedEntityId, notification.relatedEntityId);
      expect(readNotification.data, notification.data);
    });

    test('toJson converts notification to JSON', () {
      final now = DateTime.now();
      final notification = Notification(
        id: 'test-id',
        userId: 'test-user-id',
        title: 'Test Notification',
        body: 'This is a test notification',
        type: NotificationType.bookingConfirmation,
        read: true,
        createdAt: now,
        relatedEntityId: 'related-entity-id',
        data: {'key': 'value'},
      );

      final json = notification.toJson();

      expect(json['id'], 'test-id');
      expect(json['userId'], 'test-user-id');
      expect(json['title'], 'Test Notification');
      expect(json['body'], 'This is a test notification');
      expect(json['type'], NotificationType.bookingConfirmation.index);
      expect(json['read'], true);
      expect(json['createdAt'], now.toIso8601String());
      expect(json['relatedEntityId'], 'related-entity-id');
      expect(json['data'], {'key': 'value'});
    });

    test('fromJson creates notification from JSON', () {
      final now = DateTime.now();
      final json = {
        'id': 'test-id',
        'user_id': 'test-user-id',
        'title': 'Test Notification',
        'body': 'This is a test notification',
        'type': 1, // NotificationType.bookingConfirmation
        'read': true,
        'created_at': now.toIso8601String(),
        'related_entity_id': 'related-entity-id',
        'data': {'key': 'value'},
      };

      final notification = Notification.fromJson(json);

      expect(notification.id, 'test-id');
      expect(notification.userId, 'test-user-id');
      expect(notification.title, 'Test Notification');
      expect(notification.body, 'This is a test notification');
      expect(notification.type, NotificationType.bookingUpdate); // Index 1
      expect(notification.read, true);
      expect(notification.createdAt.toIso8601String(), now.toIso8601String());
      expect(notification.relatedEntityId, 'related-entity-id');
      expect(notification.data, {'key': 'value'});
    });

    test('toString returns a string representation', () {
      final notification = Notification(
        id: 'test-id',
        userId: 'test-user-id',
        title: 'Test Notification',
        body: 'This is a test notification',
        type: NotificationType.system,
      );

      final string = notification.toString();

      expect(string, contains('test-id'));
      expect(string, contains('test-user-id'));
      expect(string, contains('Test Notification'));
      expect(string, contains('system'));
    });
  });
}
