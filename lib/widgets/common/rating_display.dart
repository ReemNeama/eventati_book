import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// A widget to display ratings with stars
class RatingDisplay extends StatelessWidget {
  /// The rating value (0.0 to 5.0)
  final double rating;

  /// The size of the star icons
  final double starSize;

  /// Whether to show the rating text
  final bool showText;

  /// Whether to show the rating as a percentage
  final bool showAsPercentage;

  /// Whether to show all 5 stars (filled based on rating)
  final bool showAllStars;

  /// Custom text style for the rating text
  final TextStyle? textStyle;

  /// Custom color for the star icons
  final Color? starColor;

  /// Constructor
  const RatingDisplay({
    super.key,
    required this.rating,
    this.starSize = 16,
    this.showText = true,
    this.showAsPercentage = false,
    this.showAllStars = false,
    this.textStyle,
    this.starColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStarColor = starColor ?? AppColors.ratingStarColor;
    final defaultTextStyle =
        textStyle ??
        TextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold);

    final formattedRating =
        showAsPercentage
            ? '${(rating * 20).toInt()}%'
            : ServiceUtils.formatRating(rating);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showAllStars) ...[
          // Show all 5 stars with appropriate fill
          ...List.generate(5, (index) {
            final double value = index + 1.0;

            // Full star
            if (value <= rating) {
              return Icon(Icons.star, color: defaultStarColor, size: starSize);
            }
            // Half star
            else if (value - 0.5 <= rating && rating < value) {
              return Icon(
                Icons.star_half,
                color: defaultStarColor,
                size: starSize,
              );
            }
            // Empty star
            else {
              return Icon(
                Icons.star_border,
                color: defaultStarColor,
                size: starSize,
              );
            }
          }),
        ] else ...[
          // Just show a single star icon
          Icon(Icons.star, color: defaultStarColor, size: starSize),
        ],

        if (showText) ...[
          const SizedBox(width: 4),
          Text(formattedRating, style: defaultTextStyle),
        ],
      ],
    );
  }
}
