import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/feature_providers/social_sharing_provider.dart';
import 'package:eventati_book/services/sharing/platform_sharing_service.dart';
import 'package:eventati_book/utils/logger.dart';

/// A widget that displays buttons for sharing to specific platforms
class PlatformShareButtons extends StatelessWidget {
  /// The type of content to share
  final ShareContentType contentType;

  /// The content to share (Event, Booking, SavedComparison, etc.)
  final dynamic content;

  /// The platforms to show buttons for
  final List<SharingPlatform> platforms;

  /// The size of the buttons
  final double buttonSize;

  /// The spacing between buttons
  final double spacing;

  /// The direction of the buttons (horizontal or vertical)
  final Axis direction;

  /// Callback when sharing is successful
  final VoidCallback? onSuccess;

  /// Callback when sharing fails
  final Function(String)? onError;

  /// Constructor
  const PlatformShareButtons({
    Key? key,
    required this.contentType,
    required this.content,
    this.platforms = const [
      SharingPlatform.facebook,
      SharingPlatform.twitter,
      SharingPlatform.whatsapp,
    ],
    this.buttonSize = 40.0,
    this.spacing = 8.0,
    this.direction = Axis.horizontal,
    this.onSuccess,
    this.onError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = platforms.map((platform) {
      return _buildPlatformButton(context, platform);
    }).toList();

    return direction == Axis.horizontal
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: _addSpacing(children, spacing),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: _addSpacing(children, spacing),
          );
  }

  /// Build a button for a specific platform
  Widget _buildPlatformButton(BuildContext context, SharingPlatform platform) {
    IconData icon;
    Color color;
    String tooltip;

    switch (platform) {
      case SharingPlatform.facebook:
        icon = Icons.facebook;
        color = const Color(0xFF1877F2);
        tooltip = 'Share on Facebook';
        break;
      case SharingPlatform.twitter:
        icon = Icons.flutter_dash; // Using a placeholder icon
        color = const Color(0xFF1DA1F2);
        tooltip = 'Share on Twitter';
        break;
      case SharingPlatform.whatsapp:
        icon = Icons.whatsapp;
        color = const Color(0xFF25D366);
        tooltip = 'Share on WhatsApp';
        break;
    }

    return InkWell(
      onTap: () => _shareToPlatform(context, platform),
      borderRadius: BorderRadius.circular(buttonSize / 2),
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1),
          ),
          child: Icon(
            icon,
            color: color,
            size: buttonSize * 0.6,
          ),
        ),
      ),
    );
  }

  /// Add spacing between widgets
  List<Widget> _addSpacing(List<Widget> widgets, double spacing) {
    if (widgets.isEmpty) return [];
    if (widgets.length == 1) return widgets;

    final result = <Widget>[];
    for (int i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i < widgets.length - 1) {
        if (direction == Axis.horizontal) {
          result.add(SizedBox(width: spacing));
        } else {
          result.add(SizedBox(height: spacing));
        }
      }
    }
    return result;
  }

  /// Share to a specific platform
  Future<void> _shareToPlatform(
    BuildContext context,
    SharingPlatform platform,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final socialSharingProvider = Provider.of<SocialSharingProvider>(
      context,
      listen: false,
    );

    try {
      bool success = false;

      switch (contentType) {
        case ShareContentType.event:
          if (content is Event) {
            success = await socialSharingProvider.shareEventToPlatform(
              content,
              platform,
            );
          } else {
            throw Exception('Content must be an Event');
          }
          break;
        case ShareContentType.booking:
          if (content is Booking) {
            success = await socialSharingProvider.shareBookingToPlatform(
              content,
              platform,
            );
          } else {
            throw Exception('Content must be a Booking');
          }
          break;
        case ShareContentType.comparison:
          // For comparisons, we'll use the generic share for now
          if (content is SavedComparison) {
            success = await socialSharingProvider.shareComparison(content);
          } else {
            throw Exception('Content must be a SavedComparison');
          }
          break;
        default:
          throw Exception('Unsupported content type');
      }

      if (success) {
        // Call success callback if provided
        if (onSuccess != null) {
          onSuccess!();
        } else {
          // Show default success message
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                'Shared successfully to ${platform.toString().split('.').last}',
              ),
            ),
          );
        }
      } else {
        throw Exception('Failed to share');
      }
    } catch (e) {
      Logger.e('Error sharing content: $e', tag: 'PlatformShareButtons');

      // Call error callback if provided
      if (onError != null) {
        onError!(e.toString());
      } else {
        // Show default error message
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    }
  }
}
