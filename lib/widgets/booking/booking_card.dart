import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// A card widget to display booking information
class BookingCard extends StatelessWidget {
  /// The booking to display
  final Booking booking;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Whether to show the event information
  final bool showEventInfo;

  /// Whether to show the price
  final bool showPrice;

  /// Constructor
  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.showEventInfo = true,
    this.showPrice = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final cardBackground =
        isDarkMode ? AppColorsDark.cardBackground : AppColors.cardBackground;
    final textColor =
        isDarkMode ? AppColorsDark.textPrimary : AppColors.textPrimary;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: cardBackground,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      booking.serviceName,
                      style: TextStyles.subtitle.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: booking.status.color.withAlpha(
                        51,
                      ), // 0.2 * 255 = 51
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: booking.status.color),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          booking.status.icon,
                          size: 12,
                          color: booking.status.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          booking.status.displayName,
                          style: TextStyles.bodySmall.copyWith(
                            color: booking.status.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                booking.serviceType,
                style: TextStyles.bodySmall.copyWith(color: textColor),
              ),
              const SizedBox(height: 8),

              // Date, time, and price
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    DateTimeUtils.formatDate(booking.bookingDateTime),
                    style: TextStyles.bodyMedium.copyWith(color: textColor),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    DateTimeUtils.formatTime(booking.bookingDateTime),
                    style: TextStyles.bodyMedium.copyWith(color: textColor),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        '${booking.guestCount} guests',
                        style: TextStyles.bodyMedium.copyWith(color: textColor),
                      ),
                    ],
                  ),
                  if (showPrice)
                    Text(
                      booking.formattedPrice,
                      style: TextStyles.bodyMedium.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),

              // Event info if available
              if (showEventInfo && booking.eventId != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(26), // 0.1 * 255 = 25.5 ≈ 26
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event, size: 14, color: primaryColor),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Event: ${booking.eventName ?? 'Your Event'}',
                          style: TextStyles.bodySmall.copyWith(
                            color: primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
