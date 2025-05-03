import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/auth_provider.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes for providers
class MockAuthProvider extends Mock implements AuthProvider {}

/// Helper function to wrap a widget with MaterialApp for testing
Widget wrapWithMaterialApp(Widget child) {
  return MaterialApp(
    home: child,
  );
}

/// Helper function to wrap a widget with auth provider for testing
Widget wrapWithAuthProvider(Widget child, {AuthProvider? authProvider}) {
  return MaterialApp(
    home: ChangeNotifierProvider<AuthProvider>.value(
      value: authProvider ?? MockAuthProvider(),
      child: child,
    ),
  );
}

/// Helper function to pump a widget with a specific size
Future<void> pumpWidgetWithSize(
  WidgetTester tester,
  Widget widget, {
  Size size = const Size(400, 800),
}) async {
  await tester.binding.setSurfaceSize(size);
  await tester.pumpWidget(widget);
}
