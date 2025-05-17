import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/feature_providers/social_sharing_provider.dart';
import 'package:eventati_book/services/sharing/offline_sharing_service.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/widgets/common/network_status_widget.dart';
import 'package:eventati_book/widgets/common/pending_shares_widget.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:eventati_book/widgets/common/error_message.dart';

/// Screen to manage pending shares
class PendingSharesScreen extends StatefulWidget {
  /// Constructor
  const PendingSharesScreen({Key? key}) : super(key: key);

  @override
  State<PendingSharesScreen> createState() => _PendingSharesScreenState();
}

class _PendingSharesScreenState extends State<PendingSharesScreen> {
  List<PendingShare> _pendingShares = [];
  bool _isLoading = true;
  String? _errorMessage;
  late OfflineSharingService _offlineSharingService;

  @override
  void initState() {
    super.initState();
    _offlineSharingService = Provider.of<SocialSharingProvider>(
      context,
      listen: false,
    ).offlineSharingService;
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
      setState(() {
        _errorMessage = 'Failed to load pending shares: $e';
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
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All pending shares cleared'),
            ),
          );
        }
      } else {
        throw Exception('Failed to clear pending shares');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to clear pending shares: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColorsDark()
        : AppColors();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Shares'),
        actions: [
          if (_pendingShares.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear All',
              onPressed: _clearAllShares,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadPendingShares,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPendingShares,
        child: _buildContent(colors),
      ),
    );
  }

  Widget _buildContent(AppColors colors) {
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: ErrorMessage(
          message: _errorMessage!,
          onRetry: _loadPendingShares,
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NetworkStatusWidget(
            showPendingShares: false,
          ),
          const SizedBox(height: 24),
          if (_pendingShares.isEmpty) ...[
            const Center(
              child: Text(
                'No pending shares',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ] else ...[
            Text(
              'Pending Shares (${_pendingShares.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const PendingSharesWidget(
              showHeader: false,
              showClearAll: false,
            ),
          ],
        ],
      ),
    );
  }
}
