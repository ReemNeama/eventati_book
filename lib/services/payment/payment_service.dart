import 'package:eventati_book/models/service_models/payment.dart';
import 'package:eventati_book/services/supabase/database/payment_database_service.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Service for handling payment operations
class PaymentService {
  final SupabaseClient _supabase;
  final PaymentDatabaseService _paymentDatabaseService;

  /// Constructor
  PaymentService({
    SupabaseClient? supabase,
    PaymentDatabaseService? paymentDatabaseService,
  }) : _supabase = supabase ?? Supabase.instance.client,
       _paymentDatabaseService =
           paymentDatabaseService ?? PaymentDatabaseService();

  /// Create a payment intent with Stripe
  Future<String> createPaymentIntent({
    required String bookingId,
    required double amount,
    required String currency,
  }) async {
    try {
      // Get current user ID
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Create a payment record in the database
      final payment = Payment(
        id: const Uuid().v4(),
        bookingId: bookingId,
        userId: userId,
        amount: amount,
        currency: currency,
        status: PaymentStatus.pending,
        createdAt: DateTime.now(),
      );

      final paymentId = await _paymentDatabaseService.createPayment(payment);

      // Call Supabase Edge Function to create payment intent
      final response = await _supabase.functions.invoke(
        'payment-intent',
        body: {
          'amount': amount,
          'currency': currency,
          'booking_id': bookingId,
          'payment_id': paymentId,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to create payment intent: ${response.data}');
      }

      // Update booking with payment ID
      await _paymentDatabaseService.updateBookingWithPayment(
        bookingId,
        paymentId,
        PaymentStatus.processing,
      );

      // Update payment with payment intent ID
      await _paymentDatabaseService.updatePaymentWithStripeDetails(
        paymentId,
        response.data['paymentIntentId'],
        null,
      );

      return response.data['clientSecret'];
    } catch (e) {
      Logger.e('Error creating payment intent: $e', tag: 'PaymentService');
      throw Exception('Failed to create payment intent: $e');
    }
  }

  /// Process a payment for a booking
  Future<void> processPayment({
    required String bookingId,
    required double amount,
    required String currency,
    required String merchantDisplayName,
  }) async {
    try {
      // Create payment intent
      final clientSecret = await createPaymentIntent(
        bookingId: bookingId,
        amount: amount,
        currency: currency,
      );

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantDisplayName,
          style: ThemeMode.system,
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Payment successful, update booking status
      // Note: In production, this would typically be handled by a webhook
      await _paymentDatabaseService.updatePaymentStatus(
        clientSecret.split('_secret_')[0],
        PaymentStatus.succeeded,
      );

      await _paymentDatabaseService.updateBookingWithPayment(
        bookingId,
        clientSecret.split('_secret_')[0],
        PaymentStatus.succeeded,
      );

      Logger.i('Payment processed successfully', tag: 'PaymentService');
    } catch (e) {
      if (e is StripeException) {
        Logger.e(
          'Stripe error: ${e.error.localizedMessage}',
          tag: 'PaymentService',
        );
        throw Exception('Payment failed: ${e.error.localizedMessage}');
      } else {
        Logger.e('Payment error: $e', tag: 'PaymentService');
        throw Exception('Payment failed: $e');
      }
    }
  }

  /// Get payment history for a user
  Future<List<Payment>> getPaymentHistory() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      return await _paymentDatabaseService.getPayments(userId);
    } catch (e) {
      Logger.e('Error getting payment history: $e', tag: 'PaymentService');
      return [];
    }
  }

  /// Get payment details for a booking
  Future<Payment?> getPaymentForBooking(String bookingId) async {
    try {
      final payments = await _paymentDatabaseService.getPaymentsForBooking(
        bookingId,
      );
      if (payments.isEmpty) {
        return null;
      }

      // Return the most recent payment
      return payments.first;
    } catch (e) {
      Logger.e('Error getting payment for booking: $e', tag: 'PaymentService');
      return null;
    }
  }
}
