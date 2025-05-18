import 'package:flutter/material.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';

class ToolCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ToolCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final cardColor =
        isDarkMode
            ? Color.fromRGBO(
              AppColors.disabled.r.toInt(),
              AppColors.disabled.g.toInt(),
              AppColors.disabled.b.toInt(),
              0.8,
            )
            : Colors.white;

    final shadowColor =
        isDarkMode
            ? AppColorsDark.primaryWithAlpha(0.1)
            : Color.fromRGBO(
              AppColors.primary.r.toInt(),
              AppColors.primary.g.toInt(),
              AppColors.primary.b.toInt(),
              0.1,
            );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.mediumPadding),
              decoration: BoxDecoration(
                color: color.withAlpha(51), // 0.2 * 255 = 51
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            Text(
              title,
              style: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
