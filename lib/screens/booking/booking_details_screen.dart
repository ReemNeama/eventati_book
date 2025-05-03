import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/booking.dart';
import 'package:eventati_book/providers/booking_provider.dart';
import 'package:eventati_book/screens/booking/booking_form_screen.dart';
import 'package:eventati_book/utils/ui_utils.dart';
import 'package:eventati_book/utils/date_utils.dart' as date_utils;
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:eventati_book/widgets/common/error_message.dart';
import 'package:eventati_book/widgets/common/confirmation_dialog.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// Screen to display booking details
class BookingDetailsScreen extends StatefulWidget {
  /// Booking ID
  final String bookingId;

  /// Constructor
  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  // Loading state
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final backgroundColor =
        isDarkMode ? AppColorsDark.background : AppColors.background;
    final cardBackground =
        isDarkMode ? AppColorsDark.cardBackground : AppColors.cardBackground;
    final textColor =
        isDarkMode ? AppColorsDark.textPrimary : AppColors.textPrimary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: primaryColor,
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          final booking = bookingProvider.getBookingById(widget.bookingId);

          if (booking == null) {
            return Center(
              child: ErrorMessage(
                message: 'Booking not found',
                onRetry: () {
                  setState(() {});
                },
              ),
            );
          }

          return Container(
            color: backgroundColor,
            child:
                _isLoading
                    ? const Center(
                      child: LoadingIndicator(message: 'Processing...'),
                    )
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Error message
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ErrorMessage(message: _error!),
                            ),

                          // Booking status card
                          Card(
                            elevation: 2,
                            color: cardBackground,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Booking Status',
                                        style: TextStyles.sectionTitle.copyWith(
                                          color: primaryColor,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: booking.status.color.withAlpha(
                                            51,
                                          ), // 0.2 * 255 = 51
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: booking.status.color,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              booking.status.icon,
                                              size: 16,
                                              color: booking.status.color,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              booking.status.displayName,
                                              style: TextStyles.bodySmall
                                                  .copyWith(
                                                    color: booking.status.color,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Booking ID: ${booking.id.substring(0, 8)}',
                                    style: TextStyles.bodySmall.copyWith(
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    'Created: ${date_utils.DateTimeUtils.formatDateTime(booking.createdAt)}',
                                    style: TextStyles.bodySmall.copyWith(
                                      color: textColor,
                                    ),
                                  ),
                                  if (booking.createdAt != booking.updatedAt)
                                    Text(
                                      'Last Updated: ${date_utils.DateTimeUtils.formatDateTime(booking.updatedAt)}',
                                      style: TextStyles.bodySmall.copyWith(
                                        color: textColor,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // Service details
                          Card(
                            elevation: 2,
                            color: cardBackground,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Service Details',
                                    style: TextStyles.sectionTitle.copyWith(
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Service: ${booking.serviceName}',
                                    style: TextStyles.bodyMedium.copyWith(
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    'Type: ${booking.serviceType}',
                                    style: TextStyles.bodyMedium.copyWith(
                                      color: textColor,
                                    ),
                                  ),
                                  if (booking.eventId != null)
                                    Text(
                                      'Event: ${booking.eventName ?? 'Your Event'}',
                                      style: TextStyles.bodyMedium.copyWith(
                                        color: textColor,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // Booking details
                          Card(
                            elevation: 2,
                            color: cardBackground,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Booking Details',
                                    style: TextStyles.sectionTitle.copyWith(
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 18,
                                        color: primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Date: ${date_utils.DateTimeUtils.formatDate(booking.bookingDateTime)}',
                                        style: TextStyles.bodyMedium.copyWith(
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 18,
                                        color: primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Time: ${date_utils.DateTimeUtils.formatTime(booking.bookingDateTime)}',
                                        style: TextStyles.bodyMedium.copyWith(
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.hourglass_bottom,
                                        size: 18,
                                        color: primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Duration: ${booking.formattedDuration}',
                                        style: TextStyles.bodyMedium.copyWith(
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.people,
                                        size: 18,
                                        color: primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Guests: ${booking.guestCount}',
                                        style: TextStyles.bodyMedium.copyWith(
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (booking.specialRequests.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Special Requests:',
                                      style: TextStyles.bodyMedium.copyWith(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      booking.specialRequests,
                                      style: TextStyles.bodyMedium.copyWith(
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          // Contact information
                          Card(
                            elevation: 2,
                            color: cardBackground,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Contact Information',
                                    style: TextStyles.sectionTitle.copyWith(
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: 18,
                                        color: primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Name: ${booking.contactName}',
                                        style: TextStyles.bodyMedium.copyWith(
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.email,
                                        size: 18,
                                        color: primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Email: ${booking.contactEmail}',
                                        style: TextStyles.bodyMedium.copyWith(
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        size: 18,
                                        color: primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Phone: ${booking.contactPhone}',
                                        style: TextStyles.bodyMedium.copyWith(
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Price summary
                          Card(
                            elevation: 2,
                            color: cardBackground,
                            margin: const EdgeInsets.only(bottom: 24),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Price Summary',
                                    style: TextStyles.sectionTitle.copyWith(
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total Price:',
                                        style: TextStyles.subtitle.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      Text(
                                        booking.formattedPrice,
                                        style: TextStyles.subtitle.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Action buttons
                          if (booking.status == BookingStatus.pending ||
                              booking.status == BookingStatus.confirmed) ...[
                            Row(
                              children: [
                                // Edit button
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _editBooking(booking),
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Edit'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Cancel button
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _cancelBooking(booking.id),
                                    icon: const Icon(Icons.cancel),
                                    label: const Text('Cancel'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
          );
        },
      ),
    );
  }

  /// Navigate to edit booking screen
  void _editBooking(Booking booking) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BookingFormScreen(
              bookingId: booking.id,
              serviceId: booking.serviceId,
              serviceType: booking.serviceType,
              serviceName: booking.serviceName,
              basePrice: booking.totalPrice / booking.duration,
              eventId: booking.eventId,
              eventName: booking.eventName,
            ),
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }

  /// Show success message
  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking cancelled successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Cancel a booking
  Future<void> _cancelBooking(String bookingId) async {
    // Get the provider before any async operations
    final BookingProvider bookingProvider;
    try {
      bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    } catch (e) {
      setState(() {
        _error = 'Failed to access booking provider: $e';
      });
      return;
    }

    // Now show the dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => const ConfirmationDialog(
            title: 'Cancel Booking',
            content:
                'Are you sure you want to cancel this booking? This action cannot be undone.',
            confirmText: 'Cancel Booking',
            confirmColor: Colors.red,
          ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final success = await bookingProvider.cancelBooking(bookingId);

      if (!success) {
        throw Exception(bookingProvider.error ?? 'Failed to cancel booking');
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showSuccessMessage();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }
}
