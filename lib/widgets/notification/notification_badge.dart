import 'package:eventati_book/providers/notification_provider.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/widgets/notification/notification_center.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


/// Widget for displaying a notification badge with unread count
class NotificationBadge extends StatefulWidget {
  /// Icon to display
  final IconData icon;

  /// Icon size
  final double iconSize;

  /// Icon color
  final Color? iconColor;

  /// Badge color
  final Color? badgeColor;

  /// Constructor
  const NotificationBadge({
    super.key,
    this.icon = Icons.notifications,
    this.iconSize = 24.0,
    this.iconColor,
    this.badgeColor,
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  final GlobalKey _iconKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOverlayVisible = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  /// Show the notification center overlay
  void _showNotificationCenter() {
    if (_isOverlayVisible) {
      _removeOverlay();
      return;
    }

    final RenderBox? renderBox =
        _iconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Stack(
            children: [
              // Transparent background for dismissing
              GestureDetector(
                onTap: _removeOverlay,
                child: Container(
                  color: Colors.transparent,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
              // Notification center
              Positioned(
                top: position.dy + size.height + 8,
                right:
                    MediaQuery.of(context).size.width -
                    (position.dx + size.width),
                child: const Material(
                  elevation: 0,
                  color: Colors.transparent,
                  child: NotificationCenter(),
                ),
              ),
            ],
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isOverlayVisible = true;
  }

  /// Remove the notification center overlay
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOverlayVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor =
        widget.iconColor ?? (isDarkMode ? Colors.white : Colors.black);
    final badgeColor =
        widget.badgeColor ??
        (isDarkMode ? AppColorsDark.primary : AppColors.primary);

    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        final unreadCount = notificationProvider.unreadCount;

        return InkWell(
          key: _iconKey,
          onTap: _showNotificationCenter,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(widget.icon, size: widget.iconSize, color: iconColor),
                if (unreadCount > 0)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 9 ? '9+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
