import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper function to wrap a widget with MaterialApp for testing
Widget wrapWithMaterialApp(Widget child) {
  return MaterialApp(home: child);
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

/// Helper function to find a widget by type and text
Finder findWidgetByTypeAndText(Type type, String text) {
  return find.ancestor(of: find.text(text), matching: find.byType(type));
}

/// Helper function to find a widget by key and text
Finder findWidgetByKeyAndText(Key key, String text) {
  return find.ancestor(of: find.text(text), matching: find.byKey(key));
}
