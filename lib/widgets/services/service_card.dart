import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/utils/utils.dart';

class ServiceCard extends StatelessWidget {
  final String name;
  final String description;
  final double rating;
  final String imageUrl;
  final Widget? additionalInfo;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.name,
    required this.description,
    required this.rating,
    required this.imageUrl,
    this.additionalInfo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final backgroundColor = isDarkMode ? Colors.grey[800] : Colors.grey[300];
    final iconColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Card(
      margin: EdgeInsets.symmetric(
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
            ClipRRect(
              borderRadius: BorderRadius.only(
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
            Padding(
              padding: EdgeInsets.all(AppConstants.mediumPadding - 4),
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
                  SizedBox(height: AppConstants.smallPadding),
                  Text(description),
                  if (additionalInfo != null) ...[
                    SizedBox(height: AppConstants.smallPadding),
                    additionalInfo!,
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
