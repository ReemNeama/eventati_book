import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/services/recommended_badge.dart';

class ServiceCard extends StatelessWidget {
  final String name;
  final String description;
  final double rating;
  final String imageUrl;
  final Widget? additionalInfo;
  final VoidCallback onTap;
  final bool isRecommended;
  final String? recommendationReason;
  final bool isCompareSelected;
  final Function(bool)? onCompareToggle;
  final bool showCompareCheckbox;

  const ServiceCard({
    super.key,
    required this.name,
    required this.description,
    required this.rating,
    required this.imageUrl,
    this.additionalInfo,
    required this.onTap,
    this.isRecommended = false,
    this.recommendationReason,
    this.isCompareSelected = false,
    this.onCompareToggle,
    this.showCompareCheckbox = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final backgroundColor = isDarkMode ? Colors.grey[800] : Colors.grey[300];
    final iconColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: AppConstants.smallPadding,
        horizontal: AppConstants.mediumPadding,
      ),
      elevation: AppConstants.smallElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.mediumBorderRadius),
                    topRight: Radius.circular(AppConstants.mediumBorderRadius),
                  ),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    color: backgroundColor,
                    child: Center(
                      child: Icon(Icons.image, size: 50, color: iconColor),
                    ),
                  ),
                ),
                if (isRecommended)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: RecommendedBadge(reason: recommendationReason),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.mediumPadding - 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColors.ratingStarColor,
                            size: 20,
                          ),
                          Text(
                            ServiceUtils.formatRating(rating),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(description),
                  if (additionalInfo != null) ...[
                    const SizedBox(height: AppConstants.smallPadding),
                    // Use the non-null additionalInfo directly
                    additionalInfo ?? const SizedBox.shrink(),
                  ],
                  if (showCompareCheckbox && onCompareToggle != null) ...[
                    const SizedBox(height: AppConstants.smallPadding),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Compare',
                          style: TextStyle(
                            color:
                                isDarkMode
                                    ? AppColorsDark.primary
                                    : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Checkbox(
                          value: isCompareSelected,
                          onChanged: (value) {
                            if (value != null && onCompareToggle != null) {
                              // Use null-aware method invocation operator
                              onCompareToggle?.call(value);
                            }
                          },
                          activeColor:
                              isDarkMode
                                  ? AppColorsDark.primary
                                  : AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
