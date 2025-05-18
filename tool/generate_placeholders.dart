// A simple script to generate placeholder images for services
// Run with: dart run tool/generate_placeholders.dart

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:eventati_book/utils/logger.dart';

void main() async {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // Define the placeholder types
  final placeholders = [
    'venue_placeholder',
    'catering_placeholder',
    'photographer_placeholder',
    'planner_placeholder',
  ];

  // Create the images directory if it doesn't exist
  final imagesDir = Directory('assets/images');
  if (!await imagesDir.exists()) {
    await imagesDir.create(recursive: true);
  }

  // Generate placeholder images
  for (final placeholder in placeholders) {
    Logger.i('Generating $placeholder.jpg...', tag: 'PlaceholderGenerator');

    // Create a simple placeholder image
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint =
        Paint()
          ..color = Colors.grey[300]!
          ..style = PaintingStyle.fill;

    // Draw a grey background
    canvas.drawRect(const Rect.fromLTWH(0, 0, 400, 300), paint);

    // Draw a darker grey border
    final borderPaint =
        Paint()
          ..color = Colors.grey[500]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10;
    canvas.drawRect(const Rect.fromLTWH(5, 5, 390, 290), borderPaint);

    // Draw the placeholder text
    final textPainter = TextPainter(
      text: TextSpan(
        text: placeholder.split('_').join(' ').toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF616161), // Grey 700
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: 380);
    textPainter.paint(
      canvas,
      Offset((400 - textPainter.width) / 2, (300 - textPainter.height) / 2),
    );

    // Convert to an image
    final picture = recorder.endRecording();
    final img = await picture.toImage(400, 300);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    // Save the image
    final file = File('assets/images/$placeholder.jpg');
    await file.writeAsBytes(buffer);

    Logger.i('Generated $placeholder.jpg', tag: 'PlaceholderGenerator');
  }

  Logger.i(
    'All placeholder images generated successfully!',
    tag: 'PlaceholderGenerator',
  );
  exit(0);
}
