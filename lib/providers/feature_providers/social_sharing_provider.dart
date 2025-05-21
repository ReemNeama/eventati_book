import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/sharing/social_sharing_service.dart';
import 'package:eventati_book/services/sharing/platform_sharing_service.dart';
import 'package:eventati_book/services/sharing/offline_sharing_service.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Provider for managing social sharing functionality
class SocialSharingProvider extends ChangeNotifier {
  /// Social sharing service
  final SocialSharingService _sharingService;

  /// Offline sharing service
  final OfflineSharingService _offlineSharingService;

  /// Connectivity instance for checking network status
  final Connectivity _connectivity = Connectivity();

  /// Flag indicating if the provider is currently loading
  bool _isLoading = false;

  /// Error message if an operation fails
  String? _errorMessage;

  /// Whether the device is currently online
  bool _isOnline = true;

  /// Whether to automatically queue shares when offline
  final bool _autoQueueWhenOffline = true;

  /// Constructor
  SocialSharingProvider({
    SocialSharingService? sharingService,
    OfflineSharingService? offlineSharingService,
  }) : _sharingService = sharingService ?? SocialSharingService(),
       _offlineSharingService =
           offlineSharingService ?? OfflineSharingService() {
    _initConnectivity();
    _offlineSharingService.initialize();
  }

  /// Initialize connectivity monitoring
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isOnline = result != ConnectivityResult.none;

      _connectivity.onConnectivityChanged.listen((result) {
        _isOnline = result != ConnectivityResult.none;
        notifyListeners();
      });
    } catch (e) {
      Logger.e(
        'Error initializing connectivity: $e',
        tag: 'SocialSharingProvider',
      );
      _isOnline = true; // Assume online if we can't check
    }
  }

  /// Returns whether the provider is currently loading
  bool get isLoading => _isLoading;

  /// Returns the error message if an operation has failed, null otherwise
  String? get errorMessage => _errorMessage;

  /// Returns whether the device is currently online
  bool get isOnline => _isOnline;

  /// Returns whether to automatically queue shares when offline
  bool get autoQueueWhenOffline => _autoQueueWhenOffline;

  /// Returns the offline sharing service
  OfflineSharingService get offlineSharingService => _offlineSharingService;

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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _sharingService.shareContent(
        text: text,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to share content: $e';
      Logger.e(_errorMessage!, tag: 'SocialSharingProvider');
      notifyListeners();
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _sharingService.shareFile(
        filePath: filePath,
        text: text,
        subject: subject,
        mimeType: mimeType,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to share file: $e';
      Logger.e(_errorMessage!, tag: 'SocialSharingProvider');
      notifyListeners();
    }
  }

  /// Share an event via the platform's share dialog
  ///
  /// [event] The event to share
  /// [includeDetails] Whether to include detailed event information
  /// [queueIfOffline] Whether to queue the share if offline
  Future<void> shareEvent(
    Event event, {
    bool includeDetails = true,
    bool? queueIfOffline,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if we're online
      if (!_isOnline && (queueIfOffline ?? _autoQueueWhenOffline)) {
        // Queue the share for later
        final success = await _offlineSharingService.queueEventShare(
          event,
          includeDetails: includeDetails,
        );

        if (success) {
          _isLoading = false;
          notifyListeners();
        } else {
          throw Exception('Failed to queue event share');
        }
      } else {
        // Share immediately
        await _sharingService.shareEvent(event, includeDetails: includeDetails);

        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to share event: $e';
      Logger.e(_errorMessage!, tag: 'SocialSharingProvider');
      notifyListeners();
    }
  }

  /// Share an event to a specific platform
  ///
  /// [event] The event to share
  /// [platform] The platform to share to
  /// [includeDetails] Whether to include detailed event information
  /// [queueIfOffline] Whether to queue the share if offline
  Future<bool> shareEventToPlatform(
    Event event,
    SharingPlatform platform, {
    bool includeDetails = true,
    bool? queueIfOffline,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if we're online
      if (!_isOnline && (queueIfOffline ?? _autoQueueWhenOffline)) {
        // Queue the share for later
        final success = await _offlineSharingService.queueEventShare(
          event,
          platform: platform,
          includeDetails: includeDetails,
        );

        _isLoading = false;
        notifyListeners();

        return success;
      } else {
        // Share immediately
        final success = await _sharingService.shareEventToPlatform(
          event,
          platform,
          includeDetails: includeDetails,
        );

        _isLoading = false;
        notifyListeners();

        return success;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage =
          'Failed to share event to ${platform.toString().split('.').last}: $e';
      Logger.e(_errorMessage!, tag: 'SocialSharingProvider');
      notifyListeners();

      return false;
    }
  }

  /// Share a booking via the platform's share dialog
  ///
  /// [booking] The booking to share
  /// [queueIfOffline] Whether to queue the share if offline
  Future<void> shareBooking(Booking booking, {bool? queueIfOffline}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if we're online
      if (!_isOnline && (queueIfOffline ?? _autoQueueWhenOffline)) {
        // Queue the share for later
        final success = await _offlineSharingService.queueBookingShare(booking);

        if (success) {
          _isLoading = false;
          notifyListeners();
        } else {
          throw Exception('Failed to queue booking share');
        }
      } else {
        // Share immediately
        await _sharingService.shareBooking(booking);

        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to share booking: $e';
      Logger.e(_errorMessage!, tag: 'SocialSharingProvider');
      notifyListeners();
    }
  }

  /// Share a booking to a specific platform
  ///
  /// [booking] The booking to share
  /// [platform] The platform to share to
  /// [queueIfOffline] Whether to queue the share if offline
  Future<bool> shareBookingToPlatform(
    Booking booking,
    SharingPlatform platform, {
    bool? queueIfOffline,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if we're online
      if (!_isOnline && (queueIfOffline ?? _autoQueueWhenOffline)) {
        // Queue the share for later
        final success = await _offlineSharingService.queueBookingShare(
          booking,
          platform: platform,
        );

        _isLoading = false;
        notifyListeners();

        return success;
      } else {
        // Share immediately
        final success = await _sharingService.shareBookingToPlatform(
          booking,
          platform,
        );

        _isLoading = false;
        notifyListeners();

        return success;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage =
          'Failed to share booking to ${platform.toString().split('.').last}: $e';
      Logger.e(_errorMessage!, tag: 'SocialSharingProvider');
      notifyListeners();

      return false;
    }
  }

  /// Share a comparison as a PDF
  ///
  /// [comparison] The comparison to share
  /// [queueIfOffline] Whether to queue the share if offline
  Future<bool> shareComparison(
    SavedComparison comparison, {
    bool? queueIfOffline,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if we're online
      if (!_isOnline && (queueIfOffline ?? _autoQueueWhenOffline)) {
        // Queue the share for later
        final success = await _offlineSharingService.queueComparisonShare(
          comparison,
        );

        _isLoading = false;
        notifyListeners();

        return success;
      } else {
        // Share immediately
        await _sharingService.shareComparison(comparison);

        _isLoading = false;
        notifyListeners();

        return true;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to share comparison: $e';
      Logger.e(_errorMessage!, tag: 'SocialSharingProvider');
      notifyListeners();

      return false;
    }
  }

  /// Share a comparison to a specific platform
  ///
  /// [comparison] The comparison to share
  /// [platform] The platform to share to
  /// [queueIfOffline] Whether to queue the share if offline
  Future<bool> shareComparisonToPlatform(
    SavedComparison comparison,
    SharingPlatform platform, {
    bool? queueIfOffline,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if we're online
      if (!_isOnline && (queueIfOffline ?? _autoQueueWhenOffline)) {
        // Queue the share for later
        final success = await _offlineSharingService.queueComparisonShare(
          comparison,
          platform: platform,
        );

        _isLoading = false;
        notifyListeners();

        return success;
      } else {
        // Share immediately
        final success = await _sharingService.shareComparisonToPlatform(
          comparison,
          platform,
        );

        _isLoading = false;
        notifyListeners();

        return success;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage =
          'Failed to share comparison to ${platform.toString().split('.').last}: $e';
      Logger.e(_errorMessage!, tag: 'SocialSharingProvider');
      notifyListeners();

      return false;
    }
  }

  /// Share a service via the platform's share dialog
  ///
  /// [service] The service to share
  /// [includeDetails] Whether to include detailed service information
  /// [queueIfOffline] Whether to queue the share if offline
  Future<void> shareService(
    Service service, {
    bool includeDetails = true,
    bool? queueIfOffline,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if we're online
      if (!_isOnline && (queueIfOffline ?? _autoQueueWhenOffline)) {
        // Queue the share for later
        final success = await _offlineSharingService.queueServiceShare(
          service,
          includeDetails: includeDetails,
        );

        if (success) {
          _isLoading = false;
          notifyListeners();
        } else {
          throw Exception('Failed to queue service share');
        }
      } else {
        // Share immediately
        await _sharingService.shareService(
          service,
          includeDetails: includeDetails,
        );

        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to share service: $e';
      Logger.e(_errorMessage!, tag: 'SocialSharingProvider');
      notifyListeners();
    }
  }

  /// Share a service to a specific platform
  ///
  /// [service] The service to share
  /// [platform] The platform to share to
  /// [includeDetails] Whether to include detailed service information
  /// [queueIfOffline] Whether to queue the share if offline
  Future<bool> shareServiceToPlatform(
    Service service,
    SharingPlatform platform, {
    bool includeDetails = true,
    bool? queueIfOffline,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if we're online
      if (!_isOnline && (queueIfOffline ?? _autoQueueWhenOffline)) {
        // Queue the share for later
        final success = await _offlineSharingService.queueServiceShare(
          service,
          platform: platform,
          includeDetails: includeDetails,
        );

        _isLoading = false;
        notifyListeners();

        return success;
      } else {
        // Share immediately
        final success = await _sharingService.shareServiceToPlatform(
          service,
          platform,
          includeDetails: includeDetails,
        );

        _isLoading = false;
        notifyListeners();

        return success;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage =
          'Failed to share service to ${platform.toString().split('.').last}: $e';
      Logger.e(_errorMessage!, tag: 'SocialSharingProvider');
      notifyListeners();

      return false;
    }
  }
}
