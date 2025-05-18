import 'package:flutter/material.dart';
import 'package:eventati_book/styles/text_styles.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final Widget content;
  final EdgeInsets padding;
  final EdgeInsets margin;

  const InfoCard({
    super.key,
    required this.title,
    required this.content,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.only(bottom: 16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyles.sectionTitle),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }
}
