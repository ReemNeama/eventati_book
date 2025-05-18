import 'package:url_launcher/url_launcher.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:eventati_book/config/deep_link_config.dart';
import 'package:eventati_book/services/analytics_service.dart';

/// Service for sharing content to specific platforms
class PlatformSharingService {
  /// Analytics service for tracking shares
  final AnalyticsService _analyticsService;

  /// Constructor
  PlatformSharingService({AnalyticsService? analyticsService})
    : _analyticsService = analyticsService ?? AnalyticsService();

  /// Share content to Facebook
  ///
  /// [text] The text to share
  /// [url] The URL to share (optional)
  /// [hashtag] The hashtag to include (optional, without the # symbol)
  Future<bool> shareToFacebook({
    required String text,
    String? url,
    String? hashtag,
  }) async {
    try {
      // Prepare the Facebook share URL
      String fbUrl = 'https://www.facebook.com/sharer/sharer.php?';

      // Add the quote parameter (text)
      fbUrl += 'quote=${Uri.encodeComponent(text)}';

      // Add the URL parameter if provided
      if (url != null && url.isNotEmpty) {
        fbUrl += '&u=${Uri.encodeComponent(url)}';
      }

      // Add the hashtag parameter if provided
      if (hashtag != null && hashtag.isNotEmpty) {
        fbUrl += '&hashtag=${Uri.encodeComponent('#$hashtag')}';
      }

      // Launch the Facebook share dialog
      final uri = Uri.parse(fbUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Track the share
        await _analyticsService.trackShare(
          contentType: 'text',
          itemId: 'facebook_share',
          method: 'facebook',
        );

        Logger.i(
          'Content shared to Facebook successfully',
          tag: 'PlatformSharingService',
        );
        return true;
      } else {
        throw Exception('Could not launch Facebook share dialog');
      }
    } catch (e) {
      Logger.e('Error sharing to Facebook: $e', tag: 'PlatformSharingService');
      return false;
    }
  }

  /// Share content to Twitter
  ///
  /// [text] The text to share
  /// [url] The URL to share (optional)
  /// [hashtags] The hashtags to include (optional, without the # symbol)
  Future<bool> shareToTwitter({
    required String text,
    String? url,
    List<String>? hashtags,
  }) async {
    try {
      // Prepare the tweet text
      String tweetText = text;
      if (url != null && url.isNotEmpty) {
        tweetText += ' $url';
      }
      if (hashtags != null && hashtags.isNotEmpty) {
        tweetText += ' ${hashtags.map((tag) => '#$tag').join(' ')}';
      }

      // Encode the tweet text for the URL
      final encodedText = Uri.encodeComponent(tweetText);
      final twitterUrl = 'https://twitter.com/intent/tweet?text=$encodedText';

      // Launch the Twitter intent
      final uri = Uri.parse(twitterUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Track the share
        await _analyticsService.trackShare(
          contentType: 'text',
          itemId: 'twitter_share',
          method: 'twitter',
        );

        Logger.i(
          'Content shared to Twitter successfully',
          tag: 'PlatformSharingService',
        );
        return true;
      } else {
        throw Exception('Could not launch Twitter');
      }
    } catch (e) {
      Logger.e('Error sharing to Twitter: $e', tag: 'PlatformSharingService');
      return false;
    }
  }

  /// Share content to WhatsApp
  ///
  /// [text] The text to share
  /// [phone] The phone number to share to (optional)
  Future<bool> shareToWhatsApp({required String text, String? phone}) async {
    try {
      // Prepare the WhatsApp URL
      String whatsappUrl = 'https://wa.me/';

      // Add the phone number if provided
      if (phone != null && phone.isNotEmpty) {
        // Remove any non-numeric characters from the phone number
        final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
        whatsappUrl += cleanPhone;
      }

      // Add the text parameter
      whatsappUrl += '?text=${Uri.encodeComponent(text)}';

      // Launch WhatsApp
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Track the share
        await _analyticsService.trackShare(
          contentType: 'text',
          itemId: 'whatsapp_share',
          method: 'whatsapp',
        );

        Logger.i(
          'Content shared to WhatsApp successfully',
          tag: 'PlatformSharingService',
        );
        return true;
      } else {
        throw Exception('Could not launch WhatsApp');
      }
    } catch (e) {
      Logger.e('Error sharing to WhatsApp: $e', tag: 'PlatformSharingService');
      return false;
    }
  }

  /// Share an event to a specific platform
  ///
  /// [event] The event to share
  /// [platform] The platform to share to
  /// [includeDetails] Whether to include detailed event information
  Future<bool> shareEvent(
    Event event,
    SharingPlatform platform, {
    bool includeDetails = true,
  }) async {
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
        if (event.description != null && event.description!.isNotEmpty) {
          shareText += '\n\n${event.description}';
        }
      }

      shareText += '\n\nView in Eventati Book: $deepLink';

      // Share to the specified platform
      bool success = false;
      switch (platform) {
        case SharingPlatform.facebook:
          success = await shareToFacebook(
            text: shareText,
            url: deepLink,
            hashtag: 'EventatiBook',
          );
          break;
        case SharingPlatform.twitter:
          success = await shareToTwitter(
            text: 'Check out this event: ${event.name}',
            url: deepLink,
            hashtags: ['EventatiBook', 'Event'],
          );
          break;
        case SharingPlatform.whatsapp:
          success = await shareToWhatsApp(text: shareText);
          break;
        // No default case needed as we've covered all enum values
      }

      // Track the share
      await _analyticsService.trackShare(
        contentType: 'event',
        itemId: event.id,
        method: platform.toString().split('.').last,
      );

      return success;
    } catch (e) {
      Logger.e('Error sharing event: $e', tag: 'PlatformSharingService');
      return false;
    }
  }

  /// Share a booking to a specific platform
  ///
  /// [booking] The booking to share
  /// [platform] The platform to share to
  Future<bool> shareBooking(Booking booking, SharingPlatform platform) async {
    try {
      // Create the share text
      String shareText = 'I\'ve booked ${booking.serviceName}';
      shareText += '\nDate: ${_formatDate(booking.bookingDateTime)}';
      shareText += '\nDuration: ${booking.duration} hours';

      if (booking.specialRequests.isNotEmpty) {
        shareText += '\nSpecial requests: ${booking.specialRequests}';
      }

      shareText += '\n\nBook your own services on Eventati Book!';

      // Share to the specified platform
      bool success = false;
      switch (platform) {
        case SharingPlatform.facebook:
          success = await shareToFacebook(
            text: shareText,
            hashtag: 'EventatiBook',
          );
          break;
        case SharingPlatform.twitter:
          success = await shareToTwitter(
            text: 'I\'ve booked ${booking.serviceName} on Eventati Book!',
            hashtags: ['EventatiBook', 'Booking'],
          );
          break;
        case SharingPlatform.whatsapp:
          success = await shareToWhatsApp(text: shareText);
          break;
        // No default case needed as we've covered all enum values
      }

      // Track the share
      await _analyticsService.trackShare(
        contentType: 'booking',
        itemId: booking.id,
        method: platform.toString().split('.').last,
      );

      return success;
    } catch (e) {
      Logger.e('Error sharing booking: $e', tag: 'PlatformSharingService');
      return false;
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

/// Enum for the platforms that can be shared to
enum SharingPlatform {
  /// Facebook
  facebook,

  /// Twitter
  twitter,

  /// WhatsApp
  whatsapp,
}
