import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';

/// Enum representing the status of a payment
enum PaymentStatus {
  pending,
  processing,
  succeeded,
  failed,
  refunded,
  cancelled,
}

/// Extension to add helper methods to PaymentStatus
extension PaymentStatusExtension on PaymentStatus {
  /// Get the display name of the payment status
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.succeeded:
        return 'Succeeded';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Get the color associated with the payment status
  Color get color {
    switch (this) {
      case PaymentStatus.pending:
        return AppColors.warning;
      case PaymentStatus.processing:
        return AppColors.primary;
      case PaymentStatus.succeeded:
        return AppColors.success;
      case PaymentStatus.failed:
        return AppColors.error;
      case PaymentStatus.refunded:
        return Colors.purple;
      case PaymentStatus.cancelled:
        return AppColors.disabled;
    }
  }

  /// Get the icon associated with the payment status
  IconData get icon {
    switch (this) {
      case PaymentStatus.pending:
        return Icons.hourglass_empty;
      case PaymentStatus.processing:
        return Icons.sync;
      case PaymentStatus.succeeded:
        return Icons.check_circle;
      case PaymentStatus.failed:
        return Icons.error;
      case PaymentStatus.refunded:
        return Icons.undo;
      case PaymentStatus.cancelled:
        return Icons.cancel;
    }
  }
}

/// Model representing a payment
class Payment {
  /// Unique identifier for the payment
  final String id;

  /// ID of the booking this payment is for
  final String bookingId;

  /// ID of the user who made the payment
  final String userId;

  /// Amount of the payment
  final double amount;

  /// Currency of the payment (e.g., 'usd')
  final String currency;

  /// Status of the payment
  final PaymentStatus status;

  /// Stripe payment intent ID
  final String? paymentIntentId;

  /// Stripe payment method ID
  final String? paymentMethodId;

  /// When the payment was created
  final DateTime createdAt;

  /// When the payment was last updated
  final DateTime? updatedAt;

  /// Constructor
  Payment({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.status,
    this.paymentIntentId,
    this.paymentMethodId,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create a copy of this payment with modified fields
  Payment copyWith({
    String? id,
    String? bookingId,
    String? userId,
    double? amount,
    String? currency,
    PaymentStatus? status,
    String? paymentIntentId,
    String? paymentMethodId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create from JSON
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      bookingId: json['booking_id'],
      userId: json['user_id'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${json['status']}',
        orElse: () => PaymentStatus.pending,
      ),
      paymentIntentId: json['payment_intent_id'],
      paymentMethodId: json['payment_method_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'user_id': userId,
      'amount': amount,
      'currency': currency,
      'status': status.toString().split('.').last,
      'payment_intent_id': paymentIntentId,
      'payment_method_id': paymentMethodId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Get the formatted amount with currency
  String get formattedAmount {
    final currencySymbol = _getCurrencySymbol(currency);
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  /// Get the currency symbol for a currency code
  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toLowerCase()) {
      case 'usd':
        return '\$';
      case 'eur':
        return '€';
      case 'gbp':
        return '£';
      default:
        return currencyCode.toUpperCase();
    }
  }
}
