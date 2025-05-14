import 'package:eventati_book/models/notification_models/notification_topic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationTopic', () {
    test('creates a topic with required fields', () {
      const topic = NotificationTopic(
        id: 'test-topic',
        name: 'Test Topic',
        description: 'This is a test topic',
        category: NotificationTopicCategory.feature,
      );

      expect(topic.id, 'test-topic');
      expect(topic.name, 'Test Topic');
      expect(topic.description, 'This is a test topic');
      expect(topic.category, NotificationTopicCategory.feature);
      expect(topic.defaultEnabled, true);
    });

    test('creates a topic with all fields', () {
      const topic = NotificationTopic(
        id: 'test-topic',
        name: 'Test Topic',
        description: 'This is a test topic',
        category: NotificationTopicCategory.marketing,
        defaultEnabled: false,
      );

      expect(topic.id, 'test-topic');
      expect(topic.name, 'Test Topic');
      expect(topic.description, 'This is a test topic');
      expect(topic.category, NotificationTopicCategory.marketing);
      expect(topic.defaultEnabled, false);
    });
  });

  group('NotificationTopics', () {
    test('all contains all predefined topics', () {
      expect(NotificationTopics.all, isNotEmpty);

      // Check that all categories are represented
      final categories =
          NotificationTopics.all.map((topic) => topic.category).toSet();

      expect(categories.contains(NotificationTopicCategory.eventType), true);
      expect(categories.contains(NotificationTopicCategory.feature), true);
      expect(categories.contains(NotificationTopicCategory.marketing), true);
      expect(categories.contains(NotificationTopicCategory.system), true);

      // Check specific topics
      expect(
        NotificationTopics.all.any((topic) => topic.id == 'booking'),
        true,
      );
      expect(
        NotificationTopics.all.any((topic) => topic.id == 'payment'),
        true,
      );
      expect(
        NotificationTopics.all.any((topic) => topic.id == 'wedding'),
        true,
      );
      expect(NotificationTopics.all.any((topic) => topic.id == 'system'), true);
    });

    test('getById returns the correct topic', () {
      final topic = NotificationTopics.getById('booking');

      expect(topic, isNotNull);
      expect(topic?.id, 'booking');
      expect(topic?.category, NotificationTopicCategory.feature);
    });

    test('getById returns null for unknown topic', () {
      final topic = NotificationTopics.getById('unknown-topic');

      expect(topic, isNull);
    });

    test('getByCategory returns topics for the specified category', () {
      final topics = NotificationTopics.getByCategory(
        NotificationTopicCategory.eventType,
      );

      expect(topics, isNotEmpty);
      expect(
        topics.every(
          (topic) => topic.category == NotificationTopicCategory.eventType,
        ),
        true,
      );

      // Check specific topics
      expect(topics.any((topic) => topic.id == 'wedding'), true);
      expect(topics.any((topic) => topic.id == 'corporate'), true);
    });

    test('marketing topics have defaultEnabled set to false', () {
      final marketingTopics = NotificationTopics.getByCategory(
        NotificationTopicCategory.marketing,
      );

      expect(marketingTopics, isNotEmpty);
      expect(
        marketingTopics.every((topic) => topic.defaultEnabled == false),
        true,
      );
    });

    test('non-marketing topics have defaultEnabled set to true', () {
      final nonMarketingTopics =
          NotificationTopics.all
              .where(
                (topic) =>
                    topic.category != NotificationTopicCategory.marketing,
              )
              .toList();

      expect(nonMarketingTopics, isNotEmpty);
      expect(
        nonMarketingTopics.every((topic) => topic.defaultEnabled == true),
        true,
      );
    });
  });
}
