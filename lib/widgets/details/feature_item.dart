import 'package:flutter/material.dart';

class FeatureItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final double iconSize;
  final EdgeInsets padding;

  const FeatureItem({
    super.key,
    required this.text,
    this.icon = Icons.check_circle,
    this.iconSize = 16,
    this.padding = const EdgeInsets.only(bottom: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Icon(icon, size: iconSize),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
