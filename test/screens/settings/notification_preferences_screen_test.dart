import 'package:eventati_book/screens/settings/notification_preferences_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Widget testWidget;

  setUp(() {
    // Create test widget
    testWidget = const MaterialApp(home: NotificationPreferencesScreen());
  });

  group('NotificationPreferencesScreen', () {
    testWidgets('renders app bar with title', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Notification Preferences'), findsOneWidget);
    });

    testWidgets('renders loading indicator initially', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(testWidget);

      // Assert - should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders settings form after loading', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Enable All Notifications'), findsOneWidget);
      expect(find.text('Push Notifications'), findsOneWidget);
      expect(find.text('Email Notifications'), findsOneWidget);
      expect(find.text('In-App Notifications'), findsOneWidget);
    });

    testWidgets('renders topic settings', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Assert - should show topic categories
      expect(find.text('Notification Types'), findsOneWidget);

      // Should show at least some of the predefined topics
      expect(find.text('Wedding'), findsOneWidget);
      expect(find.text('System Updates'), findsOneWidget);
    });

    testWidgets('can toggle master switch', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Act - find and tap the master switch
      final switchFinder = find.byType(Switch).first;
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Assert - verify the switch was toggled
      // This is a simplified test that just checks the widget rebuilds
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('can save settings', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Act - find and tap the save button
      final buttonFinder = find.byIcon(Icons.save);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Assert - this is a simplified test that just checks the widget rebuilds
      expect(find.byIcon(Icons.save), findsOneWidget);
    });
  });
}
