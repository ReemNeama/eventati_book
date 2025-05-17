import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/feature_providers/social_sharing_provider.dart';
import 'package:eventati_book/services/sharing/offline_sharing_service.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Widget to display and manage pending shares
class PendingSharesWidget extends StatefulWidget {
  /// Whether to show a header
  final bool showHeader;

  /// Whether to show a clear all button
  final bool showClearAll;

  /// Maximum number of shares to display
  final int? maxShares;

  /// Callback when a share is processed
  final VoidCallback? onShareProcessed;

  /// Constructor
  const PendingSharesWidget({
    Key? key,
    this.showHeader = true,
    this.showClearAll = true,
    this.maxShares,
    this.onShareProcessed,
  }) : super(key: key);

  @override
  State<PendingSharesWidget> createState() => _PendingSharesWidgetState();
}

class _PendingSharesWidgetState extends State<PendingSharesWidget> {
  List<PendingShare> _pendingShares = [];
  bool _isLoading = true;
  String? _errorMessage;
  late OfflineSharingService _offlineSharingService;

  @override
  void initState() {
    super.initState();
    _offlineSharingService = OfflineSharingService();
    _loadPendingShares();
  }

  Future<void> _loadPendingShares() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final shares = await _offlineSharingService.getPendingShares();
      
      setState(() {
        _pendingShares = shares;
        _isLoading = false;
      });
    } catch (e) {
      Logger.e('Error loading pending shares: $e', tag: 'PendingSharesWidget');
      setState(() {
        _errorMessage = 'Failed to load pending shares';
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAllShares() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final success = await _offlineSharingService.clearPendingShares();
      
      if (success) {
        setState(() {
          _pendingShares = [];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to clear pending shares');
      }
    } catch (e) {
      Logger.e('Error clearing pending shares: $e', tag: 'PendingSharesWidget');
      setState(() {
        _errorMessage = 'Failed to clear pending shares';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColorsDark()
        : AppColors();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: TextStyle(color: colors.error),
        ),
      );
    }

    if (_pendingShares.isEmpty) {
      return const Center(
        child: Text('No pending shares'),
      );
    }

    final sharesToDisplay = widget.maxShares != null && widget.maxShares! < _pendingShares.length
        ? _pendingShares.sublist(0, widget.maxShares!)
        : _pendingShares;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showHeader) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pending Shares (${_pendingShares.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (widget.showClearAll)
                TextButton(
                  onPressed: _clearAllShares,
                  child: const Text('Clear All'),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        ...sharesToDisplay.map((share) => _buildShareItem(share, colors)),
        if (widget.maxShares != null && widget.maxShares! < _pendingShares.length) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {
                // Show all pending shares in a dialog or navigate to a new screen
                _showAllPendingShares(context);
              },
              child: Text('View All (${_pendingShares.length})'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildShareItem(PendingShare share, AppColors colors) {
    String title;
    String subtitle;
    IconData icon;

    switch (share.contentType) {
      case 'event':
        title = 'Event Share';
        subtitle = 'Pending event share';
        icon = Icons.event;
        break;
      case 'booking':
        title = 'Booking Share';
        subtitle = 'Pending booking share';
        icon = Icons.calendar_today;
        break;
      case 'comparison':
        title = 'Comparison Share';
        subtitle = 'Pending comparison share';
        icon = Icons.compare_arrows;
        break;
      default:
        title = 'Pending Share';
        subtitle = 'Pending content share';
        icon = Icons.share;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colors.primary.withOpacity(0.1),
          child: Icon(icon, color: colors.primary),
        ),
        title: Text(title),
        subtitle: Text(
          '${subtitle} • ${timeago.format(share.timestamp)}',
        ),
        trailing: share.platform != null
            ? _buildPlatformIcon(share.platform!, colors)
            : const Icon(Icons.share),
      ),
    );
  }

  Widget _buildPlatformIcon(SharingPlatform platform, AppColors colors) {
    IconData icon;
    Color color;

    switch (platform) {
      case SharingPlatform.facebook:
        icon = Icons.facebook;
        color = const Color(0xFF1877F2);
        break;
      case SharingPlatform.twitter:
        icon = Icons.flutter_dash; // Using a placeholder icon
        color = const Color(0xFF1DA1F2);
        break;
      case SharingPlatform.whatsapp:
        icon = Icons.whatsapp;
        color = const Color(0xFF25D366);
        break;
    }

    return CircleAvatar(
      radius: 16,
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 16),
    );
  }

  void _showAllPendingShares(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Pending Shares'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _pendingShares.length,
            itemBuilder: (context, index) {
              final share = _pendingShares[index];
              final colors = Theme.of(context).brightness == Brightness.dark
                  ? AppColorsDark()
                  : AppColors();
              return _buildShareItem(share, colors);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              _clearAllShares();
              Navigator.of(context).pop();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
