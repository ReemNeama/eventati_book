import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:timeago/timeago.dart' as timeago;

/// A mini card for displaying service information in a horizontal list
class ServiceMiniCard extends StatelessWidget {
  /// The title of the service
  final String title;

  /// The subtitle or description of the service
  final String subtitle;

  /// The URL of the service image
  final String? imageUrl;

  /// The callback when the card is tapped
  final VoidCallback onTap;

  /// The timestamp when the service was viewed
  final DateTime? timestamp;

  /// Constructor
  const ServiceMiniCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.onTap,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = UIUtils.isDarkMode(context);
    final Color cardBgColor =
        isDarkMode ? AppColorsDark.cardBackground : AppColors.cardBackground;
    final Color borderColor =
        isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
    final Color iconColor =
        isDarkMode ? AppColorsDark.textSecondary : AppColors.textSecondary;
    final Color backgroundColor =
        isDarkMode ? AppColorsDark.background : AppColors.background;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image or placeholder
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.mediumBorderRadius),
                topRight: Radius.circular(AppConstants.mediumBorderRadius),
              ),
              child: Container(
                height: 100,
                width: double.infinity,
                color: backgroundColor,
                child:
                    imageUrl != null && imageUrl!.isNotEmpty
                        ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image,
                                size: 40,
                                color: iconColor,
                              ),
                            );
                          },
                        )
                        : Center(
                          child: Icon(Icons.image, size: 40, color: iconColor),
                        ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: TextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Subtitle
                  Text(
                    subtitle,
                    style: TextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Timestamp
                  if (timestamp != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Viewed ${timeago.format(timestamp!)}',
                      style: TextStyles.caption.copyWith(
                        color:
                            isDarkMode
                                ? Colors.grey.shade500
                                : Colors.grey.shade600,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
