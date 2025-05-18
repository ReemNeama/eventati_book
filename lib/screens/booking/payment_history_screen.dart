import 'package:eventati_book/models/service_models/payment.dart';
import 'package:eventati_book/services/payment/payment_service.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:posthog_flutter/posthog_flutter.dart';


/// Screen for viewing payment history
class PaymentHistoryScreen extends StatefulWidget {
  /// Constructor
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = true;
  List<Payment> _payments = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPayments();

    // Track screen view
    Posthog().screen(screenName: 'Payment History Screen');
  }

  /// Load payment history
  Future<void> _loadPayments() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final payments = await _paymentService.getPaymentHistory();

      setState(() {
        _payments = payments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load payment history: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        backgroundColor: primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPayments,
        child:
            _isLoading
                ? const LoadingIndicator(message: 'Loading payment history...')
                : _errorMessage != null
                ? Center(child: Text(_errorMessage!, style: TextStyles.error))
                : _payments.isEmpty
                ? const EmptyState(
                  icon: Icons.payment,
                  title: 'No Payments',
                  message: 'You haven\'t made any payments yet.',
                )
                : _buildPaymentList(),
      ),
    );
  }

  /// Build the payment list
  Widget _buildPaymentList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _payments.length,
      itemBuilder: (context, index) {
        final payment = _payments[index];
        return _buildPaymentCard(payment);
      },
    );
  }

  /// Build a payment card
  Widget _buildPaymentCard(Payment payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showPaymentDetails(payment),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(payment.formattedAmount, style: TextStyles.price),
                  _buildStatusChip(payment.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Date: ${DateFormat('MMM d, yyyy').format(payment.createdAt)}',
                style: TextStyles.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Time: ${DateFormat('h:mm a').format(payment.createdAt)}',
                style: TextStyles.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Booking ID: ${payment.bookingId}',
                style: TextStyles.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a status chip
  Widget _buildStatusChip(PaymentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withAlpha(51), // 0.2 * 255 = 51
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 16, color: status.color),
          const SizedBox(width: 4),
          Text(status.displayName, style: TextStyles.bodySmall),
        ],
      ),
    );
  }

  /// Show payment details
  void _showPaymentDetails(Payment payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment Details', style: TextStyles.title),
              const SizedBox(height: 16),
              _buildDetailRow('Amount', payment.formattedAmount),
              _buildDetailRow('Status', payment.status.displayName),
              _buildDetailRow(
                'Date',
                DateFormat('MMM d, yyyy').format(payment.createdAt),
              ),
              _buildDetailRow(
                'Time',
                DateFormat('h:mm a').format(payment.createdAt),
              ),
              _buildDetailRow('Payment ID', payment.id),
              _buildDetailRow('Booking ID', payment.bookingId),
              if (payment.paymentIntentId != null)
                _buildDetailRow('Payment Intent ID', payment.paymentIntentId!),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build a detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Text(value, style: TextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
