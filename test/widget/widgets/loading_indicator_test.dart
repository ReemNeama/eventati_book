import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import '../../helpers/simple_test_helpers.dart';

void main() {
  group('LoadingIndicator Widget Tests', () {
    testWidgets('should render with default properties', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(wrapWithMaterialApp(const LoadingIndicator()));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing); // No message by default
    });

    testWidgets('should render with message', (WidgetTester tester) async {
      // Arrange
      const testMessage = 'Loading...';

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(const LoadingIndicator(message: testMessage)),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(testMessage), findsOneWidget);
    });

    testWidgets('should render with custom size', (WidgetTester tester) async {
      // Arrange
      const customSize = 60.0;

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(const LoadingIndicator(size: customSize)),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Find the SizedBox that wraps the CircularProgressIndicator
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        ),
      );

      // Verify the size
      expect(sizedBox.width, equals(customSize));
      expect(sizedBox.height, equals(customSize));
    });
  });
}
