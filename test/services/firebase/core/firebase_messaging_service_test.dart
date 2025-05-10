import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventati_book/services/firebase/core/firebase_messaging_service.dart';

// Mock classes
class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockUser extends Mock implements User {}

// Mock for NotificationSettings
class MockNotificationSettings extends Mock implements NotificationSettings {
  @override
  final AuthorizationStatus authorizationStatus;

  // Required parameters for iOS
  @override
  final AppleNotificationSetting alert;
  @override
  final AppleNotificationSetting announcement;
  @override
  final AppleNotificationSetting badge;
  @override
  final AppleNotificationSetting carPlay;
  @override
  final AppleNotificationSetting lockScreen;
  @override
  final AppleNotificationSetting notificationCenter;
  @override
  final AppleShowPreviewSetting showPreviews;
  @override
  final AppleNotificationSetting sound;
  @override
  final AppleNotificationSetting criticalAlert;
  @override
  final AppleNotificationSetting timeSensitive;

  MockNotificationSettings({
    this.authorizationStatus = AuthorizationStatus.authorized,
    this.alert = AppleNotificationSetting.enabled,
    this.announcement = AppleNotificationSetting.enabled,
    this.badge = AppleNotificationSetting.enabled,
    this.carPlay = AppleNotificationSetting.enabled,
    this.lockScreen = AppleNotificationSetting.enabled,
    this.notificationCenter = AppleNotificationSetting.enabled,
    this.showPreviews = AppleShowPreviewSetting.always,
    this.sound = AppleNotificationSetting.enabled,
    this.criticalAlert = AppleNotificationSetting.disabled,
    this.timeSensitive = AppleNotificationSetting.enabled,
  });
}

void main() {
  late FirebaseMessagingService messagingService;
  late MockFirebaseMessaging mockMessaging;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockUser mockUser;

  setUp(() {
    mockMessaging = MockFirebaseMessaging();
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockUser = MockUser();

    // Set up mock user
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('test-user-id');

    // Create service with mocks
    messagingService = FirebaseMessagingService(
      messaging: mockMessaging,
      auth: mockAuth,
      firestore: mockFirestore,
    );
  });

  group('FirebaseMessagingService', () {
    test('subscribeToTopic subscribes to FCM topic', () async {
      // Arrange
      const topic = 'test-topic';
      when(
        () => mockMessaging.subscribeToTopic(topic),
      ).thenAnswer((_) async {});

      // Act & Assert
      expect(
        () async => await messagingService.subscribeToTopic(topic),
        returnsNormally,
      );
      verify(() => mockMessaging.subscribeToTopic(topic)).called(1);
    });

    test('getNotificationSettings returns settings map', () async {
      // Arrange
      final mockSettings = MockNotificationSettings(
        authorizationStatus: AuthorizationStatus.authorized,
      );

      when(
        () => mockMessaging.getNotificationSettings(),
      ).thenAnswer((_) async => mockSettings);

      // Act
      final result = await messagingService.getNotificationSettings();

      // Assert
      expect(result, isA<Map<String, bool>>());
      expect(result['authorized'], isTrue);
      expect(result['denied'], isFalse);
    });
  });
}
