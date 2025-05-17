import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:eventati_book/config/deep_link_config.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:eventati_book/services/analytics_service.dart';
import 'package:eventati_book/utils/service/pdf_export_utils.dart';
import 'package:eventati_book/services/sharing/platform_sharing_service.dart';

/// Service for handling social sharing functionality
class SocialSharingService {
  /// Analytics service for tracking shares
  final AnalyticsService _analyticsService;

  /// Platform-specific sharing service
  final PlatformSharingService _platformSharingService;

  /// Constructor
  SocialSharingService({
    AnalyticsService? analyticsService,
    PlatformSharingService? platformSharingService,
  }) : _analyticsService = analyticsService ?? AnalyticsService(),
       _platformSharingService =
           platformSharingService ?? PlatformSharingService();

  /// Share content via the platform's share dialog
  ///
  /// [text] The text to share
  /// [subject] The subject for the share (used in emails)
  /// [sharePositionOrigin] The position where the share UI should appear (optional)
  Future<void> shareContent({
    required String text,
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    try {
      await Share.share(
        text,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      );

      // Track the share
      await _analyticsService.trackShare(
        contentType: 'text',
        itemId: 'generic_share',
        method: 'platform_share',
      );

      Logger.i('Content shared successfully', tag: 'SocialSharingService');
    } catch (e) {
      Logger.e('Error sharing content: $e', tag: 'SocialSharingService');
      throw Exception('Failed to share content: $e');
    }
  }

  /// Share a file via the platform's share dialog
  ///
  /// [filePath] The path to the file to share
  /// [text] Additional text to include with the share
  /// [subject] The subject for the share (used in emails)
  Future<void> shareFile({
    required String filePath,
    String? text,
    String? subject,
    String? mimeType,
  }) async {
    try {
      final file = XFile(filePath, mimeType: mimeType);
      await Share.shareXFiles([file], text: text, subject: subject);

      // Track the share
      await _analyticsService.trackShare(
        contentType: 'file',
        itemId: filePath.split('/').last,
        method: 'platform_share',
      );

      Logger.i(
        'File shared successfully: $filePath',
        tag: 'SocialSharingService',
      );
    } catch (e) {
      Logger.e('Error sharing file: $e', tag: 'SocialSharingService');
      throw Exception('Failed to share file: $e');
    }
  }

  /// Share an event via the platform's share dialog
  ///
  /// [event] The event to share
  /// [includeDetails] Whether to include detailed event information
  Future<void> shareEvent(Event event, {bool includeDetails = true}) async {
    try {
      // Generate a deep link to the event
      final deepLink = DeepLinkConfig.generateEventUrl(event.id);

      // Create the share text
      String shareText = 'Check out this event: ${event.name}';

      if (includeDetails) {
        shareText += '\n\nDate: ${_formatDate(event.date)}';
        if (event.location.isNotEmpty) {
          shareText += '\nLocation: ${event.location}';
        }
        if (event.description?.isNotEmpty ?? false) {
          shareText += '\n\n${event.description}';
        }
      }

      shareText += '\n\nView in Eventati Book: $deepLink';

      // Share the event
      await shareContent(
        text: shareText,
        subject: 'Eventati Book - ${event.name}',
      );

      // Track the share
      await _analyticsService.trackShare(
        contentType: 'event',
        itemId: event.id,
        method: 'platform_share',
      );

      Logger.i(
        'Event shared successfully: ${event.id}',
        tag: 'SocialSharingService',
      );
    } catch (e) {
      Logger.e('Error sharing event: $e', tag: 'SocialSharingService');
      throw Exception('Failed to share event: $e');
    }
  }

  /// Share an event to a specific platform
  ///
  /// [event] The event to share
  /// [platform] The platform to share to
  /// [includeDetails] Whether to include detailed event information
  Future<bool> shareEventToPlatform(
    Event event,
    SharingPlatform platform, {
    bool includeDetails = true,
  }) async {
    try {
      final success = await _platformSharingService.shareEvent(
        event,
        platform,
        includeDetails: includeDetails,
      );

      if (success) {
        Logger.i(
          'Event shared successfully to ${platform.toString().split('.').last}: ${event.id}',
          tag: 'SocialSharingService',
        );
      } else {
        Logger.w(
          'Failed to share event to ${platform.toString().split('.').last}: ${event.id}',
          tag: 'SocialSharingService',
        );
      }

      return success;
    } catch (e) {
      Logger.e(
        'Error sharing event to ${platform.toString().split('.').last}: $e',
        tag: 'SocialSharingService',
      );
      return false;
    }
  }

  /// Share a booking via the platform's share dialog
  ///
  /// [booking] The booking to share
  Future<void> shareBooking(Booking booking) async {
    try {
      // Create the share text
      String shareText = 'I\'ve booked ${booking.serviceName}';
      shareText += '\nDate: ${_formatDate(booking.bookingDateTime)}';
      shareText += '\nDuration: ${booking.duration} hours';

      if (booking.specialRequests.isNotEmpty) {
        shareText += '\nSpecial requests: ${booking.specialRequests}';
      }

      shareText += '\n\nBook your own services on Eventati Book!';

      // Share the booking
      await shareContent(
        text: shareText,
        subject: 'Eventati Book - ${booking.serviceName} Booking',
      );

      // Track the share
      await _analyticsService.trackShare(
        contentType: 'booking',
        itemId: booking.id,
        method: 'platform_share',
      );

      Logger.i(
        'Booking shared successfully: ${booking.id}',
        tag: 'SocialSharingService',
      );
    } catch (e) {
      Logger.e('Error sharing booking: $e', tag: 'SocialSharingService');
      throw Exception('Failed to share booking: $e');
    }
  }

  /// Share a booking to a specific platform
  ///
  /// [booking] The booking to share
  /// [platform] The platform to share to
  Future<bool> shareBookingToPlatform(
    Booking booking,
    SharingPlatform platform,
  ) async {
    try {
      final success = await _platformSharingService.shareBooking(
        booking,
        platform,
      );

      if (success) {
        Logger.i(
          'Booking shared successfully to ${platform.toString().split('.').last}: ${booking.id}',
          tag: 'SocialSharingService',
        );
      } else {
        Logger.w(
          'Failed to share booking to ${platform.toString().split('.').last}: ${booking.id}',
          tag: 'SocialSharingService',
        );
      }

      return success;
    } catch (e) {
      Logger.e(
        'Error sharing booking to ${platform.toString().split('.').last}: $e',
        tag: 'SocialSharingService',
      );
      return false;
    }
  }

  /// Share a comparison as a PDF
  ///
  /// [comparison] The comparison to share
  Future<void> shareComparison(SavedComparison comparison) async {
    try {
      // Generate the PDF
      final pdfBytes = await PDFExportUtils.generateComparisonPDF(
        comparison,
        includeNotes: true,
        includeHighlights: true,
      );

      // Create a filename
      final fileName =
          '${comparison.title.replaceAll(' ', '_')}_comparison.pdf';

      // Share the PDF
      await PDFExportUtils.sharePDF(
        pdfBytes,
        fileName,
        subject: 'Eventati Book Comparison: ${comparison.title}',
        text:
            'Here is your comparison of ${comparison.serviceNames.join(', ')}.',
      );

      // Track the share
      await _analyticsService.trackShare(
        contentType: 'comparison',
        itemId: comparison.id,
        method: 'pdf_share',
      );

      Logger.i(
        'Comparison shared successfully: ${comparison.id}',
        tag: 'SocialSharingService',
      );
    } catch (e) {
      Logger.e('Error sharing comparison: $e', tag: 'SocialSharingService');
      throw Exception('Failed to share comparison: $e');
    }
  }

  /// Format a date for display in shares
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }
}
