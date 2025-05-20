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
    final backgroundColor =
        isDarkMode
            ? Color.fromRGBO(
              AppColors.disabled.r.toInt(),
              AppColors.disabled.g.toInt(),
              AppColors.disabled.b.toInt(),
              0.8,
            )
            : Color.fromRGBO(
              AppColors.disabled.r.toInt(),
              AppColors.disabled.g.toInt(),
              AppColors.disabled.b.toInt(),
              0.3,
            );
    final iconColor =
        isDarkMode
            ? Color.fromRGBO(
              AppColors.disabled.r.toInt(),
              AppColors.disabled.g.toInt(),
              AppColors.disabled.b.toInt(),
              0.4,
            )
            : Color.fromRGBO(
              AppColors.disabled.r.toInt(),
              AppColors.disabled.g.toInt(),
              AppColors.disabled.b.toInt(),
              0.6,
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
                // Recommended badge (top right)
                if (isRecommended)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: RecommendedBadge(reason: recommendationReason),
                  ),
                // Featured badge (top left)
                if (isFeatured)
                  const Positioned(top: 10, left: 10, child: FeaturedBadge()),
                // Availability indicator (bottom right)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: AvailabilityIndicator(isAvailable: isAvailable),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.mediumPadding - 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(name, style: TextStyles.sectionTitle),
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

                  // Price (if available)
                  if (price != null && priceType != null) ...[
                    const SizedBox(height: 4),
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
                            showPerPerson: priceType == PriceType.perPerson,
                            showPerEvent: priceType == PriceType.perEvent,
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkMode
                                    ? AppColorsDark.primary
                                    : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: AppConstants.smallPadding),
                  Text(description),

                  // Tags (if available)
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.smallPadding),
                    ChipGroup(items: tags),
                  ],

                  // Capacity (if available)
                  if (minCapacity != null && maxCapacity != null) ...[
                    const SizedBox(height: AppConstants.smallPadding),
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
                        ),
                      ],
                    ),
                  ],

                  // Additional info (if available)
                  if (additionalInfo != null) ...[
                    const SizedBox(height: AppConstants.smallPadding),
                    // Use the non-null additionalInfo directly
                    additionalInfo ?? const SizedBox.shrink(),
                  ],
                  // Action buttons row
                  const SizedBox(height: AppConstants.smallPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quick action buttons
                      Row(
                        children: [
                          // Save button
                          if (onSave != null)
                            IconButton(
                              icon: Icon(
                                isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color:
                                    isSaved
                                        ? (isDarkMode
                                            ? AppColorsDark.warning
                                            : AppColors.warning)
                                        : (isDarkMode
                                            ? AppColorsDark.textSecondary
                                            : AppColors.textSecondary),
                              ),
                              onPressed: onSave,
                              tooltip: isSaved ? 'Saved' : 'Save',
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                              iconSize: 20,
                            ),

                          // Share button
                          if (onShare != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                Icons.share,
                                color:
                                    isDarkMode
                                        ? AppColorsDark.textSecondary
                                        : AppColors.textSecondary,
                              ),
                              onPressed: onShare,
                              tooltip: 'Share',
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                              iconSize: 20,
                            ),
                          ],
                        ],
                      ),

                      // Compare checkbox
                      if (showCompareCheckbox && onCompareToggle != null)
                        Row(
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
