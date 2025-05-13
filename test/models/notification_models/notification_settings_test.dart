import 'package:eventati_book/models/notification_models/notification_settings.dart';
import 'package:eventati_book/models/notification_models/notification_topic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationSettings', () {
    test('creates settings with default values', () {
      final settings = NotificationSettings();

      expect(settings.allNotificationsEnabled, true);
      expect(settings.pushNotificationsEnabled, true);
      expect(settings.emailNotificationsEnabled, true);
      expect(settings.inAppNotificationsEnabled, true);
      expect(settings.topicSettings, isNotEmpty);

      // Check that default topic settings are set correctly
      for (final topic in NotificationTopics.all) {
        expect(settings.topicSettings.containsKey(topic.id), true);
        expect(settings.topicSettings[topic.id], topic.defaultEnabled);
      }
    });

    test('creates settings with custom values', () {
      final customTopicSettings = {
        'booking': false,
        'payment': false,
      };

      final settings = NotificationSettings(
        allNotificationsEnabled: false,
        pushNotificationsEnabled: false,
        emailNotificationsEnabled: true,
        inAppNotificationsEnabled: false,
        topicSettings: customTopicSettings,
      );

      expect(settings.allNotificationsEnabled, false);
      expect(settings.pushNotificationsEnabled, false);
      expect(settings.emailNotificationsEnabled, true);
      expect(settings.inAppNotificationsEnabled, false);
      
      // Check that custom topic settings are preserved
      expect(settings.topicSettings['booking'], false);
      expect(settings.topicSettings['payment'], false);
      
      // Check that other topic settings have default values
      for (final topic in NotificationTopics.all) {
        if (topic.id != 'booking' && topic.id != 'payment') {
          expect(settings.topicSettings.containsKey(topic.id), true);
          expect(settings.topicSettings[topic.id], topic.defaultEnabled);
        }
      }
    });

    test('copyWith creates a new settings object with updated fields', () {
      final settings = NotificationSettings();

      final updatedSettings = settings.copyWith(
        allNotificationsEnabled: false,
        pushNotificationsEnabled: false,
        emailNotificationsEnabled: false,
      );

      expect(updatedSettings.allNotificationsEnabled, false);
      expect(updatedSettings.pushNotificationsEnabled, false);
      expect(updatedSettings.emailNotificationsEnabled, false);
      expect(updatedSettings.inAppNotificationsEnabled, true);
      expect(updatedSettings.topicSettings, settings.topicSettings);
    });

    test('updateTopicSetting creates a new settings object with updated topic setting', () {
      final settings = NotificationSettings();

      final updatedSettings = settings.updateTopicSetting('booking', false);

      expect(updatedSettings.topicSettings['booking'], false);
      expect(updatedSettings.allNotificationsEnabled, settings.allNotificationsEnabled);
      expect(updatedSettings.pushNotificationsEnabled, settings.pushNotificationsEnabled);
      expect(updatedSettings.emailNotificationsEnabled, settings.emailNotificationsEnabled);
      expect(updatedSettings.inAppNotificationsEnabled, settings.inAppNotificationsEnabled);
    });

    test('toDatabaseDoc converts settings to database document', () {
      final settings = NotificationSettings(
        allNotificationsEnabled: false,
        pushNotificationsEnabled: false,
        emailNotificationsEnabled: true,
        inAppNotificationsEnabled: false,
      );

      final doc = settings.toDatabaseDoc();

      expect(doc['all_notifications_enabled'], false);
      expect(doc['push_notifications_enabled'], false);
      expect(doc['email_notifications_enabled'], true);
      expect(doc['in_app_notifications_enabled'], false);
      expect(doc['topic_settings'], settings.topicSettings);
    });

    test('fromDatabaseDoc creates settings from database document', () {
      final doc = {
        'all_notifications_enabled': false,
        'push_notifications_enabled': false,
        'email_notifications_enabled': true,
        'in_app_notifications_enabled': false,
        'topic_settings': {
          'booking': false,
          'payment': false,
        },
      };

      final settings = NotificationSettings.fromDatabaseDoc(doc);

      expect(settings.allNotificationsEnabled, false);
      expect(settings.pushNotificationsEnabled, false);
      expect(settings.emailNotificationsEnabled, true);
      expect(settings.inAppNotificationsEnabled, false);
      expect(settings.topicSettings['booking'], false);
      expect(settings.topicSettings['payment'], false);
    });

    test('fromDatabaseDoc handles null document', () {
      final settings = NotificationSettings.fromDatabaseDoc(null);

      expect(settings.allNotificationsEnabled, true);
      expect(settings.pushNotificationsEnabled, true);
      expect(settings.emailNotificationsEnabled, true);
      expect(settings.inAppNotificationsEnabled, true);
      expect(settings.topicSettings, isNotEmpty);
    });

    test('fromDatabaseDoc handles missing fields', () {
      final doc = {
        'all_notifications_enabled': false,
      };

      final settings = NotificationSettings.fromDatabaseDoc(doc);

      expect(settings.allNotificationsEnabled, false);
      expect(settings.pushNotificationsEnabled, true);
      expect(settings.emailNotificationsEnabled, true);
      expect(settings.inAppNotificationsEnabled, true);
      expect(settings.topicSettings, isNotEmpty);
    });

    test('toString returns a string representation', () {
      final settings = NotificationSettings(
        allNotificationsEnabled: false,
        pushNotificationsEnabled: false,
        emailNotificationsEnabled: true,
        inAppNotificationsEnabled: false,
      );

      final string = settings.toString();

      expect(string, contains('allNotificationsEnabled: false'));
      expect(string, contains('pushNotificationsEnabled: false'));
      expect(string, contains('emailNotificationsEnabled: true'));
      expect(string, contains('inAppNotificationsEnabled: false'));
      expect(string, contains('topicSettings:'));
    });
  });
}
