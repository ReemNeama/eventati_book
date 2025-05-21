import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/feature_providers/social_sharing_provider.dart';
import 'package:eventati_book/utils/logger.dart';

/// A reusable share button widget that can be used across the app
class ShareButton extends StatelessWidget {
  /// The type of content to share
  final ShareContentType contentType;

  /// The content to share (Event, Booking, SavedComparison, etc.)
  final dynamic content;

  /// The icon to use for the button
  final IconData icon;

  /// The color of the icon
  final Color? iconColor;

  /// The size of the icon
  final double iconSize;

  /// The tooltip text
  final String tooltip;

  /// Callback when sharing is successful
  final VoidCallback? onSuccess;

  /// Callback when sharing fails
  final Function(String)? onError;

  /// Constructor
  const ShareButton({
    super.key,
    required this.contentType,
    required this.content,
    this.icon = Icons.share,
    this.iconColor,
    this.iconSize = 24.0,
    this.tooltip = 'Share',
    this.onSuccess,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      iconSize: iconSize,
      color: iconColor,
      tooltip: tooltip,
      onPressed: () => _share(context),
    );
  }

  /// Share the content
  Future<void> _share(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final socialSharingProvider = Provider.of<SocialSharingProvider>(
      context,
      listen: false,
    );

    try {
      switch (contentType) {
        case ShareContentType.event:
          if (content is Event) {
            await socialSharingProvider.shareEvent(content);
          } else {
            throw Exception('Content must be an Event');
          }
          break;
        case ShareContentType.booking:
          if (content is Booking) {
            await socialSharingProvider.shareBooking(content);
          } else {
            throw Exception('Content must be a Booking');
          }
          break;
        case ShareContentType.comparison:
          if (content is SavedComparison) {
            await socialSharingProvider.shareComparison(content);
          } else {
            throw Exception('Content must be a SavedComparison');
          }
          break;
        case ShareContentType.text:
          if (content is String) {
            await socialSharingProvider.shareContent(
              text: content,
              subject: 'Shared from Eventati Book',
            );
          } else {
            throw Exception('Content must be a String');
          }
          break;
        case ShareContentType.file:
          if (content is Map<String, dynamic> &&
              content.containsKey('filePath')) {
            await socialSharingProvider.shareFile(
              filePath: content['filePath'],
              text: content['text'],
              subject: content['subject'],
              mimeType: content['mimeType'],
            );
          } else {
            throw Exception(
              'Content must be a Map with at least a filePath key',
            );
          }
          break;
        case ShareContentType.service:
          if (content is Service) {
            await socialSharingProvider.shareService(content);
          } else {
            throw Exception('Content must be a Service');
          }
          break;
        case ShareContentType.venue:
          if (content is Venue) {
            await socialSharingProvider.shareService(content);
          } else {
            throw Exception('Content must be a Venue');
          }
          break;
        case ShareContentType.photographer:
          if (content is Photographer) {
            await socialSharingProvider.shareService(content);
          } else {
            throw Exception('Content must be a Photographer');
          }
          break;
        case ShareContentType.planner:
          if (content is Planner) {
            await socialSharingProvider.shareService(content);
          } else {
            throw Exception('Content must be a Planner');
          }
          break;
        case ShareContentType.catering:
          if (content is CateringService) {
            await socialSharingProvider.shareService(content);
          } else {
            throw Exception('Content must be a CateringService');
          }
          break;
      }

      // Call success callback if provided
      if (onSuccess != null) {
        onSuccess!();
      } else {
        // Show default success message
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Shared successfully')),
        );
      }
    } catch (e) {
      Logger.e('Error sharing content: $e', tag: 'ShareButton');

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

/// Enum for the type of content to share
enum ShareContentType {
  /// Share an event
  event,

  /// Share a booking
  booking,

  /// Share a comparison
  comparison,

  /// Share text
  text,

  /// Share a file
  file,

  /// Share a service
  service,

  /// Share a venue
  venue,

  /// Share a photographer
  photographer,

  /// Share a planner
  planner,

  /// Share a catering service
  catering,
}
