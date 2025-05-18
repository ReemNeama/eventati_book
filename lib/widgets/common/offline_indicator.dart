import 'package:flutter/material.dart';
import 'package:eventati_book/services/utils/network_connectivity_service.dart';
import 'package:eventati_book/styles/app_colors.dart';


/// Widget that shows an indicator when the device is offline
class OfflineIndicator extends StatefulWidget {
  /// Child widget to display
  final Widget child;

  /// Whether to show a banner when offline
  final bool showBanner;

  /// Whether to show an icon when offline
  final bool showIcon;

  /// Banner color
  final Color bannerColor;

  /// Banner text color
  final Color bannerTextColor;

  /// Banner text
  final String bannerText;

  /// Icon color
  final Color iconColor;

  /// Icon size
  final double iconSize;

  /// Constructor
  const OfflineIndicator({
    super.key,
    required this.child,
    this.showBanner = true,
    this.showIcon = true,
    this.bannerColor = AppColors.error,
    this.bannerTextColor = Colors.white,
    this.bannerText = 'You are offline. Some features may be unavailable.',
    this.iconColor = AppColors.error,
    this.iconSize = 16,
  });

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  final NetworkConnectivityService _connectivityService =
      NetworkConnectivityService();
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivityService.connectionStream.listen(_updateConnectionStatus);
  }

  Future<void> _checkConnectivity() async {
    final isConnected = await _connectivityService.isConnected();
    setState(() {
      _isOffline = !isConnected;
    });
  }

  void _updateConnectionStatus(bool isConnected) {
    setState(() {
      _isOffline = !isConnected;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffline) {
      return widget.child;
    }

    return Column(
      children: [
        if (widget.showBanner && _isOffline)
          Container(
            width: double.infinity,
            color: widget.bannerColor,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Row(
              children: [
                if (widget.showIcon)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.cloud_off,
                      color: widget.bannerTextColor,
                      size: widget.iconSize,
                    ),
                  ),
                Expanded(
                  child: Text(
                    widget.bannerText,
                    style: TextStyle(
                      color: widget.bannerTextColor,
                      fontSize: 12,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _checkConnectivity,
                  style: TextButton.styleFrom(
                    foregroundColor: widget.bannerTextColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(60, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
