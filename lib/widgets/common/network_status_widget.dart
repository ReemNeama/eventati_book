import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/feature_providers/social_sharing_provider.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/widgets/common/pending_shares_widget.dart';

/// Widget to display the network status and pending shares
class NetworkStatusWidget extends StatelessWidget {
  /// Whether to show the pending shares
  final bool showPendingShares;

  /// Whether to show the network status
  final bool showNetworkStatus;

  /// Maximum number of pending shares to display
  final int? maxPendingShares;

  /// Constructor
  const NetworkStatusWidget({
    Key? key,
    this.showPendingShares = true,
    this.showNetworkStatus = true,
    this.maxPendingShares,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socialSharingProvider = Provider.of<SocialSharingProvider>(context);
    final isOnline = socialSharingProvider.isOnline;
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColorsDark()
        : AppColors();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showNetworkStatus) ...[
          _buildNetworkStatusIndicator(context, isOnline, colors),
          const SizedBox(height: 16),
        ],
        if (showPendingShares && !isOnline) ...[
          PendingSharesWidget(
            maxShares: maxPendingShares,
            onShareProcessed: () {
              // Refresh the widget when a share is processed
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Share processed successfully'),
                  ),
                );
              }
            },
          ),
        ],
      ],
    );
  }

  /// Build the network status indicator
  Widget _buildNetworkStatusIndicator(
    BuildContext context,
    bool isOnline,
    AppColors colors,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isOnline ? colors.success.withOpacity(0.1) : colors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOnline ? colors.success : colors.error,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Icons.wifi : Icons.wifi_off,
            color: isOnline ? colors.success : colors.error,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              color: isOnline ? colors.success : colors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
