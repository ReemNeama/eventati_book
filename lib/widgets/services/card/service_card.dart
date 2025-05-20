import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/services/card/recommended_badge.dart';
import 'package:eventati_book/widgets/services/card/featured_badge.dart';
import 'package:eventati_book/widgets/services/card/availability_indicator.dart';
import 'package:eventati_book/widgets/details/chip_group.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/widgets/common/rating_display.dart';
import 'package:eventati_book/widgets/common/quick_action_button.dart';

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

  // New parameters
  final double? price;
  final PriceType? priceType;
  final String currency;
  final int? minCapacity;
  final int? maxCapacity;
  final List<String> tags;
  final bool isAvailable;
  final bool isFeatured;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final bool isSaved;

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

    // New parameters
    this.price,
    this.priceType,
    this.currency = '\$',
    this.minCapacity,
    this.maxCapacity,
    this.tags = const [],
    this.isAvailable = true,
    this.isFeatured = false,
    this.onShare,
    this.onSave,
    this.isSaved = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final backgroundColor = Color.fromRGBO(
      AppColors.disabled.r.toInt(),
      AppColors.disabled.g.toInt(),
      AppColors.disabled.b.toInt(),
      isDarkMode ? 0.8 : 0.3,
    );
    final iconColor = Color.fromRGBO(
      AppColors.disabled.r.toInt(),
      AppColors.disabled.g.toInt(),
      AppColors.disabled.b.toInt(),
      isDarkMode ? 0.4 : 0.6,
    );

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
        borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with badges
            Stack(
              children: [
                // Image container
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.mediumBorderRadius),
                    topRight: Radius.circular(AppConstants.mediumBorderRadius),
                  ),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    color: backgroundColor,
                    child:
                        imageUrl.isNotEmpty
                            ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 50,
                                    color: iconColor,
                                  ),
                                );
                              },
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                    color: primaryColor,
                                  ),
                                );
                              },
                            )
                            : Center(
                              child: Icon(
                                Icons.image,
                                size: 50,
                                color: iconColor,
                              ),
                            ),
                  ),
                ),

                // Badges and indicators
                if (isRecommended)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: RecommendedBadge(reason: recommendationReason),
                  ),
                if (isFeatured)
                  const Positioned(top: 10, left: 10, child: FeaturedBadge()),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: AvailabilityIndicator(isAvailable: isAvailable),
                ),
              ],
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(AppConstants.mediumPadding - 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with name and rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyles.sectionTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      RatingDisplay(rating: rating, starSize: 20),
                    ],
                  ),

                  // Info section
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(
                        primaryColor.r.toInt(),
                        primaryColor.g.toInt(),
                        primaryColor.b.toInt(),
                        0.05,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppConstants.smallBorderRadius,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price row
                        if (price != null && priceType != null)
                          Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                size: 16,
                                color:
                                    isDarkMode
                                        ? AppColorsDark.textSecondary
                                        : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ServiceUtils.formatPrice(
                                  price!,
                                  showPerPerson:
                                      priceType == PriceType.perPerson,
                                  showPerEvent: priceType == PriceType.perEvent,
                                ),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),

                        // Capacity row
                        if (minCapacity != null && maxCapacity != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                size: 16,
                                color:
                                    isDarkMode
                                        ? AppColorsDark.textSecondary
                                        : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ServiceUtils.formatCapacityRange(
                                  minCapacity!,
                                  maxCapacity!,
                                ),
                                style: TextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Description
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.bodySmall,
                  ),

                  // Tags
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ChipGroup(items: tags, maxChips: 3),
                  ],

                  // Additional info
                  if (additionalInfo != null) ...[
                    const SizedBox(height: 8),
                    additionalInfo!,
                  ],

                  // Action buttons row
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quick action buttons
                      Row(
                        children: [
                          // Save button
                          if (onSave != null)
                            QuickActionButton(
                              icon:
                                  isSaved
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                              onPressed: onSave!,
                              tooltip: isSaved ? 'Saved' : 'Save',
                              isActive: isSaved,
                              activeColor:
                                  isDarkMode
                                      ? AppColorsDark.warning
                                      : AppColors.warning,
                            ),

                          // Share button
                          if (onShare != null)
                            QuickActionButton(
                              icon: Icons.share,
                              onPressed: onShare!,
                              tooltip: 'Share',
                            ),

                          // View details button
                          QuickActionButton(
                            icon: Icons.visibility,
                            onPressed: onTap,
                            tooltip: 'View details',
                            label: 'Details',
                          ),
                        ],
                      ),

                      // Compare button/checkbox
                      if (showCompareCheckbox && onCompareToggle != null)
                        QuickActionButton(
                          icon:
                              isCompareSelected
                                  ? Icons.compare_arrows
                                  : Icons.compare_arrows_outlined,
                          onPressed: () {
                            onCompareToggle!(!isCompareSelected);
                          },
                          tooltip:
                              isCompareSelected
                                  ? 'Remove from comparison'
                                  : 'Add to comparison',
                          isActive: isCompareSelected,
                          label: 'Compare',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
