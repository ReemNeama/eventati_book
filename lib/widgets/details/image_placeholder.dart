import 'package:flutter/material.dart';

class ImagePlaceholder extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;
  final IconData icon;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;

  const ImagePlaceholder({
    super.key,
    this.height = 200,
    this.width = double.infinity,
    this.borderRadius = 12,
    this.icon = Icons.image,
    this.iconSize = 50,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor ?? Colors.grey,
        ),
      ),
    );
  }
}
