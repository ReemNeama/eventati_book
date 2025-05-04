import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/booking_provider.dart';
import 'package:eventati_book/screens/booking/booking_details_screen.dart';
import 'package:eventati_book/utils/ui_utils.dart';
import 'package:eventati_book/utils/date_utils.dart' as date_utils;
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:eventati_book/widgets/common/error_message.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// Screen to display booking history
class BookingHistoryScreen extends StatefulWidget {
  /// Constructor
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize booking provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Initialize bookings
  Future<void> _initializeBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookingProvider = Provider.of<BookingProvider>(
        context,
        listen: false,
      );
      await bookingProvider.initialize();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
        title: const Text('My Bookings'),
        backgroundColor: primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past')],
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: LoadingIndicator(message: 'Loading bookings...'),
              )
              : Consumer<BookingProvider>(
                builder: (context, bookingProvider, child) {
                  if (bookingProvider.error != null) {
                    return Center(
                      child: ErrorMessage(
                        message: bookingProvider.error!,
                        onRetry: _initializeBookings,
                      ),
                    );
                  }

                  return Container(
                    color: backgroundColor,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Upcoming bookings tab
                        _buildBookingsList(
                          bookingProvider.upcomingBookings,
                          'No upcoming bookings',
                          'You don\'t have any upcoming bookings. Book a service to get started!',
                          cardBackground,
                          textColor,
                          primaryColor,
                        ),

                        // Past bookings tab
                        _buildBookingsList(
                          bookingProvider.pastBookings,
                          'No past bookings',
                          'You don\'t have any past bookings yet.',
                          cardBackground,
                          textColor,
                          primaryColor,
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  /// Build a list of bookings
  Widget _buildBookingsList(
    List<Booking> bookings,
    String emptyTitle,
    String emptyMessage,
    Color cardBackground,
    Color textColor,
    Color primaryColor,
  ) {
    if (bookings.isEmpty) {
      return EmptyState(
        title: emptyTitle,
        message: emptyMessage,
        icon: Icons.calendar_today,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(
          booking,
          cardBackground,
          textColor,
          primaryColor,
        );
      },
    );
  }

  /// Build a booking card
  Widget _buildBookingCard(
    Booking booking,
    Color cardBackground,
    Color textColor,
    Color primaryColor,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: cardBackground,
      child: InkWell(
        onTap: () => _navigateToBookingDetails(booking.id),
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
                    date_utils.DateTimeUtils.formatDate(
                      booking.bookingDateTime,
                    ),
                    style: TextStyles.bodyMedium.copyWith(color: textColor),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    date_utils.DateTimeUtils.formatTime(
                      booking.bookingDateTime,
                    ),
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
              if (booking.eventId != null) ...[
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

  /// Navigate to booking details screen
  void _navigateToBookingDetails(String bookingId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailsScreen(bookingId: bookingId),
      ),
    ).then((_) {
      // Refresh the list when returning from details
      setState(() {});
    });
  }
}
