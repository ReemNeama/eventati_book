import 'package:flutter/material.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';

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
    this.borderRadius = AppConstants.mediumBorderRadius,
    this.icon = Icons.image,
    this.iconSize = 50,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final defaultBgColor = isDarkMode ? Color.fromRGBO(AppColors.disabled.r.toInt(), AppColors.disabled.g.toInt(), AppColors.disabled.b.toInt(), 0.8) : Color.fromRGBO(AppColors.disabled.r.toInt(), AppColors.disabled.g.toInt(), AppColors.disabled.b.toInt(), 0.3);
    final defaultIconColor = isDarkMode ? Color.fromRGBO(AppColors.disabled.r.toInt(), AppColors.disabled.g.toInt(), AppColors.disabled.b.toInt(), 0.4) : Color.fromRGBO(AppColors.disabled.r.toInt(), AppColors.disabled.g.toInt(), AppColors.disabled.b.toInt(), 0.6);

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBgColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Icon(icon, size: iconSize, color: iconColor ?? defaultIconColor),
      ),
    );
  }
}
