import 'package:eventati_book/models/service_models/payment.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling payment-related database operations with Supabase
class PaymentDatabaseService {
  /// Supabase client
  final SupabaseClient _supabase;

  /// Table name for payments
  static const String _paymentsTable = 'payments';

  /// Constructor
  PaymentDatabaseService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  /// Get all payments for a user
  Future<List<Payment>> getPayments(String userId) async {
    try {
      final response = await _supabase
          .from(_paymentsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map<Payment>((data) => Payment.fromJson(data)).toList();
    } catch (e) {
      Logger.e('Error getting payments: $e', tag: 'PaymentDatabaseService');
      return [];
    }
  }

  /// Get payments for a specific booking
  Future<List<Payment>> getPaymentsForBooking(String bookingId) async {
    try {
      final response = await _supabase
          .from(_paymentsTable)
          .select()
          .eq('booking_id', bookingId)
          .order('created_at', ascending: false);

      return response.map<Payment>((data) => Payment.fromJson(data)).toList();
    } catch (e) {
      Logger.e(
        'Error getting payments for booking: $e',
        tag: 'PaymentDatabaseService',
      );
      return [];
    }
  }

  /// Get a specific payment by ID
  Future<Payment?> getPayment(String paymentId) async {
    try {
      final response =
          await _supabase
              .from(_paymentsTable)
              .select()
              .eq('id', paymentId)
              .single();

      return Payment.fromJson(response);
    } catch (e) {
      Logger.e('Error getting payment: $e', tag: 'PaymentDatabaseService');
      return null;
    }
  }

  /// Create a new payment
  Future<String> createPayment(Payment payment) async {
    try {
      final response =
          await _supabase
              .from(_paymentsTable)
              .insert(payment.toJson())
              .select()
              .single();

      return response['id'];
    } catch (e) {
      Logger.e('Error creating payment: $e', tag: 'PaymentDatabaseService');
      throw Exception('Failed to create payment: $e');
    }
  }

  /// Update payment status
  Future<void> updatePaymentStatus(
    String paymentId,
    PaymentStatus status,
  ) async {
    try {
      await _supabase
          .from(_paymentsTable)
          .update({
            'status': status.toString().split('.').last,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId);
    } catch (e) {
      Logger.e(
        'Error updating payment status: $e',
        tag: 'PaymentDatabaseService',
      );
      throw Exception('Failed to update payment status: $e');
    }
  }

  /// Update payment with Stripe payment intent details
  Future<void> updatePaymentWithStripeDetails(
    String paymentId,
    String paymentIntentId,
    String? paymentMethodId,
  ) async {
    try {
      await _supabase
          .from(_paymentsTable)
          .update({
            'payment_intent_id': paymentIntentId,
            'payment_method_id': paymentMethodId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId);
    } catch (e) {
      Logger.e(
        'Error updating payment with Stripe details: $e',
        tag: 'PaymentDatabaseService',
      );
      throw Exception('Failed to update payment with Stripe details: $e');
    }
  }

  /// Update booking with payment information
  Future<void> updateBookingWithPayment(
    String bookingId,
    String paymentId,
    PaymentStatus status,
  ) async {
    try {
      await _supabase
          .from('bookings')
          .update({
            'payment_id': paymentId,
            'payment_status': status.toString().split('.').last,
          })
          .eq('id', bookingId);
    } catch (e) {
      Logger.e(
        'Error updating booking with payment: $e',
        tag: 'PaymentDatabaseService',
      );
      throw Exception('Failed to update booking with payment: $e');
    }
  }
}
