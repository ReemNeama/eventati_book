import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/planning_providers/booking_provider.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:eventati_book/widgets/common/error_message.dart';

import 'package:eventati_book/widgets/common/share_button.dart' as share_button;
import 'package:eventati_book/widgets/common/platform_share_buttons.dart'
    as platform_buttons;

/// Screen for displaying booking details
class BookingDetailsScreen extends StatefulWidget {
  /// The ID of the booking to display
  final String bookingId;

  /// Constructor
  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  late Future<Booking?> _bookingFuture;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  void _loadBooking() {
    // Get the provider before the async gap
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );

    _bookingFuture = Future.delayed(Duration.zero, () {
      return bookingProvider.getBookingById(widget.bookingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colors = isDarkMode ? AppColorsDark() : AppColors();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        actions: [
          Consumer<BookingProvider>(
            builder: (context, bookingProvider, _) {
              final booking = bookingProvider.getBookingById(widget.bookingId);
              if (booking == null) return const SizedBox.shrink();

              return share_button.ShareButton(
                contentType: share_button.ShareContentType.booking,
                content: booking,
                tooltip: 'Share Booking',
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Booking?>(
        future: _bookingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: ErrorMessage(
                message: 'Error loading booking: ${snapshot.error}',
                onRetry: _loadBooking,
              ),
            );
          }

          final booking = snapshot.data;
          if (booking == null) {
            return Center(
              child: ErrorMessage(
                message: 'Booking not found',
                onRetry: _loadBooking,
              ),
            );
          }

          return _buildBookingDetails(booking, colors);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addToCalendar,
        tooltip: 'Add to Calendar',
        child: const Icon(Icons.calendar_today),
      ),
    );
  }

  Widget _buildBookingDetails(Booking booking, dynamic colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.serviceName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Date & Time',
                    DateTimeUtils.formatDateTime(booking.bookingDateTime),
                    Icons.access_time,
                    colors,
                  ),
                  _buildInfoRow(
                    'Duration',
                    '${booking.duration} hours',
                    Icons.hourglass_bottom,
                    colors,
                  ),
                  _buildInfoRow(
                    'Status',
                    booking.status.toString().split('.').last,
                    Icons.info_outline,
                    colors,
                  ),
                  if (booking.specialRequests.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Special Requests:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(booking.specialRequests),
                  ],
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Share with:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      platform_buttons.PlatformShareButtons(
                        contentType: platform_buttons.ShareContentType.booking,
                        content: booking,
                        buttonSize: 36,
                        spacing: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButtons(booking),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    AppColors colors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color:
                colors is AppColorsDark
                    ? AppColorsDark.primary
                    : AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Booking booking) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (booking.isUpcoming)
          ElevatedButton.icon(
            onPressed: () => _updateBooking(booking),
            icon: const Icon(Icons.edit),
            label: const Text('Update'),
          ),
        if (booking.isUpcoming)
          ElevatedButton.icon(
            onPressed: () => _cancelBooking(booking.id),
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }

  void _addToCalendar() async {
    // Implementation for adding to calendar
  }

  void _updateBooking(Booking booking) {
    // Implementation for updating booking
  }

  void _cancelBooking(String bookingId) {
    // Implementation for cancelling booking
  }
}
