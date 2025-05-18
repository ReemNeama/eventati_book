import 'package:eventati_book/models/service_models/booking.dart';
import 'package:eventati_book/models/service_models/payment.dart';
import 'package:eventati_book/services/payment/payment_service.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:posthog_flutter/posthog_flutter.dart';


/// Screen for processing payments
class PaymentScreen extends StatefulWidget {
  /// The booking to process payment for
  final Booking booking;

  /// Constructor
  const PaymentScreen({super.key, required this.booking});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = false;
  String? _errorMessage;
  Payment? _payment;

  @override
  void initState() {
    super.initState();
    _checkExistingPayment();

    // Track screen view
    Posthog().screen(
      screenName: 'Payment Screen',
      properties: {
        'booking_id': widget.booking.id,
        'service_name': widget.booking.serviceName,
        'total_price': widget.booking.totalPrice,
      },
    );
  }

  /// Check if there's an existing payment for this booking
  Future<void> _checkExistingPayment() async {
    try {
      final payment = await _paymentService.getPaymentForBooking(
        widget.booking.id,
      );
      if (payment != null) {
        setState(() {
          _payment = payment;
        });
      }
    } catch (e) {
      Logger.e('Error checking existing payment: $e', tag: 'PaymentScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: primaryColor,
      ),
      body:
          _isLoading
              ? const LoadingIndicator(message: 'Processing payment...')
              : _errorMessage != null
              ? _buildErrorView()
              : _payment != null && _payment!.status == PaymentStatus.succeeded
              ? _buildPaymentSuccessView()
              : _buildPaymentForm(),
    );
  }

  /// Build the error view
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 64),
            const SizedBox(height: 16),
            Text('Payment Error', style: TextStyles.title),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the payment success view
  Widget _buildPaymentSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 64),
            const SizedBox(height: 16),
            Text('Payment Successful', style: TextStyles.title),
            const SizedBox(height: 16),
            Text(
              'Your payment has been processed successfully.',
              style: TextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: ${_payment!.formattedAmount}',
              style: TextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back to Booking'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the payment form
  Widget _buildPaymentForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Booking details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service: ${widget.booking.serviceName}',
                      style: TextStyles.subtitle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${DateFormat('MMM d, yyyy').format(widget.booking.bookingDateTime)}',
                      style: TextStyles.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Time: ${DateFormat('h:mm a').format(widget.booking.bookingDateTime)}',
                      style: TextStyles.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Duration: ${widget.booking.formattedDuration}',
                      style: TextStyles.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total: ${widget.booking.formattedPrice}',
                      style: TextStyles.price,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment information
            Text('Payment Information', style: TextStyles.subtitle),
            const SizedBox(height: 8),
            Text(
              'You will be redirected to a secure payment page to complete your payment.',
              style: TextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'We accept all major credit cards including Visa, Mastercard, American Express, and Discover.',
              style: TextStyles.bodyMedium,
            ),
            const SizedBox(height: 32),

            // Payment button
            ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Pay ${widget.booking.formattedPrice}',
                style: TextStyles.buttonText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Process the payment
  Future<void> _processPayment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Track payment attempt
      Posthog().capture(
        eventName: 'payment_attempt',
        properties: {
          'booking_id': widget.booking.id,
          'service_name': widget.booking.serviceName,
          'amount': widget.booking.totalPrice,
        },
      );

      await _paymentService.processPayment(
        bookingId: widget.booking.id,
        amount: widget.booking.totalPrice,
        currency: 'usd', // Default currency
        merchantDisplayName: 'Eventati Book',
      );

      // Track successful payment
      Posthog().capture(
        eventName: 'payment_success',
        properties: {
          'booking_id': widget.booking.id,
          'service_name': widget.booking.serviceName,
          'amount': widget.booking.totalPrice,
        },
      );

      // Refresh payment data
      await _checkExistingPayment();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // Track payment failure
      Posthog().capture(
        eventName: 'payment_failure',
        properties: {
          'booking_id': widget.booking.id,
          'service_name': widget.booking.serviceName,
          'amount': widget.booking.totalPrice,
          'error': e.toString(),
        },
      );

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }
}
