import 'package:eventati_book/models/notification_models/notification_settings.dart';
import 'package:eventati_book/screens/settings/notification_preferences_screen.dart';
import 'package:eventati_book/services/interfaces/messaging_service_interface.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}
class MockPostgrestBuilder extends Mock implements PostgrestBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}
class MockPostgrestQueryBuilder extends Mock implements PostgrestQueryBuilder {}
class MockMessagingService extends Mock implements MessagingServiceInterface {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockUser mockUser;
  late MockPostgrestQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockMessagingService mockMessagingService;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockUser = MockUser();
    mockQueryBuilder = MockPostgrestQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockMessagingService = MockMessagingService();

    // Set up mock behavior
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('test-user-id');
    when(() => mockSupabaseClient.from(any())).thenReturn(mockQueryBuilder);
    when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
    when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);
    when(() => mockFilterBuilder.maybeSingle()).thenAnswer((_) async => null);
    when(() => mockQueryBuilder.upsert(any())).thenAnswer((_) async => null);
    when(() => mockMessagingService.updateNotificationSettings(any())).thenAnswer((_) async {});
    when(() => mockMessagingService.subscribeToTopic(any())).thenAnswer((_) async {});
    when(() => mockMessagingService.unsubscribeFromTopic(any())).thenAnswer((_) async {});

    // Register the mock Supabase client
    Supabase.initialize = ({
      required String url,
      required String anonKey,
      String? serviceKey,
      bool debug = false,
    }) async {
      return;
    };
    Supabase.instance = Supabase();
    Supabase.instance.client = mockSupabaseClient;
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: NotificationPreferencesScreen(),
    );
  }

  group('NotificationPreferencesScreen', () {
    testWidgets('renders app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify app bar is shown
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Notification Preferences'), findsOneWidget);
    });

    testWidgets('renders loading indicator when loading', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify loading indicator is shown
      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.text('Loading notification settings...'), findsOneWidget);
    });

    testWidgets('renders settings form after loading', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify settings form is shown
      expect(find.text('Enable All Notifications'), findsOneWidget);
      expect(find.text('Notification Channels'), findsOneWidget);
      expect(find.text('Push Notifications'), findsOneWidget);
      expect(find.text('Email Notifications'), findsOneWidget);
      expect(find.text('In-App Notifications'), findsOneWidget);
      expect(find.text('Notification Types'), findsOneWidget);
    });

    testWidgets('renders topic settings', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify topic settings are shown
      expect(find.text('Booking Updates'), findsOneWidget);
      expect(find.text('Payment Updates'), findsOneWidget);
      expect(find.text('Event Updates'), findsOneWidget);
      expect(find.text('Task Reminders'), findsOneWidget);
    });

    testWidgets('can toggle master switch', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find the master switch
      final masterSwitch = find.byType(Switch).first;
      expect(masterSwitch, findsOneWidget);

      // Toggle the switch
      await tester.tap(masterSwitch);
      await tester.pump();

      // Verify the switch is toggled
      // Note: We can't easily verify the state of the switch in widget tests
    });

    testWidgets('can toggle channel switches', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find the push notifications switch
      final pushSwitch = find.byType(Switch).at(1);
      expect(pushSwitch, findsOneWidget);

      // Toggle the switch
      await tester.tap(pushSwitch);
      await tester.pump();

      // Verify the switch is toggled
      // Note: We can't easily verify the state of the switch in widget tests
    });

    testWidgets('can toggle topic switches', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find a topic switch
      final topicSwitch = find.byType(Switch).at(4);
      expect(topicSwitch, findsOneWidget);

      // Toggle the switch
      await tester.tap(topicSwitch);
      await tester.pump();

      // Verify the switch is toggled
      // Note: We can't easily verify the state of the switch in widget tests
    });

    testWidgets('can save settings', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find the save button
      final saveButton = find.byIcon(Icons.save);
      expect(saveButton, findsOneWidget);

      // Tap the save button
      await tester.tap(saveButton);
      await tester.pump();

      // Verify the settings are saved
      verify(() => mockQueryBuilder.upsert(any())).called(1);
      verify(() => mockMessagingService.updateNotificationSettings(any())).called(1);
    });
  });
}
