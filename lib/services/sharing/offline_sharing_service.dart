import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/sharing/social_sharing_service.dart';
import 'package:eventati_book/services/sharing/platform_sharing_service.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model for pending shares
class PendingShare {
  /// The type of content to share
  final String contentType;

  /// The content to share (serialized as JSON)
  final String contentJson;

  /// The platform to share to (null for generic share)
  final SharingPlatform? platform;

  /// The timestamp when the share was queued
  final DateTime timestamp;

  /// Whether to include details in the share
  final bool includeDetails;

  /// Constructor
  PendingShare({
    required this.contentType,
    required this.contentJson,
    this.platform,
    required this.timestamp,
    this.includeDetails = true,
  });

  /// Create a PendingShare from a map
  factory PendingShare.fromMap(Map<String, dynamic> map) {
    return PendingShare(
      contentType: map['contentType'],
      contentJson: map['contentJson'],
      platform: map['platform'] != null
          ? SharingPlatform.values.firstWhere(
              (e) => e.toString() == map['platform'],
              orElse: () => SharingPlatform.values.first,
            )
          : null,
      timestamp: DateTime.parse(map['timestamp']),
      includeDetails: map['includeDetails'] ?? true,
    );
  }

  /// Convert PendingShare to a map
  Map<String, dynamic> toMap() {
    return {
      'contentType': contentType,
      'contentJson': contentJson,
      'platform': platform?.toString(),
      'timestamp': timestamp.toIso8601String(),
      'includeDetails': includeDetails,
    };
  }
}

/// Service for handling offline sharing functionality
class OfflineSharingService {
  /// Key for storing pending shares in SharedPreferences
  static const String _pendingSharesKey = 'pending_shares';

  /// Social sharing service for sharing content
  final SocialSharingService _socialSharingService;

  /// Platform sharing service for platform-specific sharing
  final PlatformSharingService _platformSharingService;

  /// Connectivity instance for checking network status
  final Connectivity _connectivity = Connectivity();

  /// Stream subscription for connectivity changes
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  /// Whether the device is currently online
  bool _isOnline = false;

  /// Constructor
  OfflineSharingService({
    SocialSharingService? socialSharingService,
    PlatformSharingService? platformSharingService,
  })  : _socialSharingService = socialSharingService ?? SocialSharingService(),
        _platformSharingService =
            platformSharingService ?? PlatformSharingService();

  /// Initialize the service
  Future<void> initialize() async {
    // Check initial connectivity status
    final connectivityResult = await _connectivity.checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        _isOnline = result != ConnectivityResult.none;

        // If we're back online, process pending shares
        if (_isOnline) {
          _processPendingShares();
        }
      },
    );

    // Process any pending shares if we're online
    if (_isOnline) {
      _processPendingShares();
    }
  }

  /// Dispose of the service
  void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// Queue an event for sharing when online
  Future<bool> queueEventShare(
    Event event, {
    SharingPlatform? platform,
    bool includeDetails = true,
  }) async {
    try {
      final pendingShare = PendingShare(
        contentType: 'event',
        contentJson: jsonEncode(event.toMap()),
        platform: platform,
        timestamp: DateTime.now(),
        includeDetails: includeDetails,
      );

      await _addPendingShare(pendingShare);

      // If we're online, process pending shares immediately
      if (_isOnline) {
        _processPendingShares();
      }

      return true;
    } catch (e) {
      Logger.e('Error queueing event share: $e', tag: 'OfflineSharingService');
      return false;
    }
  }

  /// Queue a booking for sharing when online
  Future<bool> queueBookingShare(
    Booking booking, {
    SharingPlatform? platform,
  }) async {
    try {
      final pendingShare = PendingShare(
        contentType: 'booking',
        contentJson: jsonEncode(booking.toMap()),
        platform: platform,
        timestamp: DateTime.now(),
      );

      await _addPendingShare(pendingShare);

      // If we're online, process pending shares immediately
      if (_isOnline) {
        _processPendingShares();
      }

      return true;
    } catch (e) {
      Logger.e('Error queueing booking share: $e', tag: 'OfflineSharingService');
      return false;
    }
  }

  /// Queue a comparison for sharing when online
  Future<bool> queueComparisonShare(SavedComparison comparison) async {
    try {
      final pendingShare = PendingShare(
        contentType: 'comparison',
        contentJson: jsonEncode(comparison.toMap()),
        timestamp: DateTime.now(),
      );

      await _addPendingShare(pendingShare);

      // If we're online, process pending shares immediately
      if (_isOnline) {
        _processPendingShares();
      }

      return true;
    } catch (e) {
      Logger.e(
        'Error queueing comparison share: $e',
        tag: 'OfflineSharingService',
      );
      return false;
    }
  }

  /// Get all pending shares
  Future<List<PendingShare>> getPendingShares() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sharesJson = prefs.getStringList(_pendingSharesKey) ?? [];

      return sharesJson
          .map((json) => PendingShare.fromMap(jsonDecode(json)))
          .toList();
    } catch (e) {
      Logger.e('Error getting pending shares: $e', tag: 'OfflineSharingService');
      return [];
    }
  }

  /// Clear all pending shares
  Future<bool> clearPendingShares() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_pendingSharesKey, []);
      return true;
    } catch (e) {
      Logger.e('Error clearing pending shares: $e', tag: 'OfflineSharingService');
      return false;
    }
  }

  /// Add a pending share to the queue
  Future<void> _addPendingShare(PendingShare share) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sharesJson = prefs.getStringList(_pendingSharesKey) ?? [];

      sharesJson.add(jsonEncode(share.toMap()));

      await prefs.setStringList(_pendingSharesKey, sharesJson);

      Logger.i('Pending share added to queue', tag: 'OfflineSharingService');
    } catch (e) {
      Logger.e('Error adding pending share: $e', tag: 'OfflineSharingService');
    }
  }

  /// Remove a pending share from the queue
  Future<void> _removePendingShare(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sharesJson = prefs.getStringList(_pendingSharesKey) ?? [];

      if (index >= 0 && index < sharesJson.length) {
        sharesJson.removeAt(index);
        await prefs.setStringList(_pendingSharesKey, sharesJson);
      }
    } catch (e) {
      Logger.e('Error removing pending share: $e', tag: 'OfflineSharingService');
    }
  }

  /// Process all pending shares
  Future<void> _processPendingShares() async {
    try {
      final shares = await getPendingShares();
      if (shares.isEmpty) return;

      Logger.i(
        'Processing ${shares.length} pending shares',
        tag: 'OfflineSharingService',
      );

      for (int i = 0; i < shares.length; i++) {
        final share = shares[i];
        bool success = false;

        switch (share.contentType) {
          case 'event':
            success = await _processEventShare(share);
            break;
          case 'booking':
            success = await _processBookingShare(share);
            break;
          case 'comparison':
            success = await _processComparisonShare(share);
            break;
        }

        if (success) {
          await _removePendingShare(i);
          // Adjust index since we removed an item
          i--;
        }
      }
    } catch (e) {
      Logger.e('Error processing pending shares: $e', tag: 'OfflineSharingService');
    }
  }

  /// Process an event share
  Future<bool> _processEventShare(PendingShare share) async {
    try {
      final eventMap = jsonDecode(share.contentJson);
      final event = Event.fromMap(eventMap);

      if (share.platform != null) {
        return await _platformSharingService.shareEvent(
          event,
          share.platform!,
          includeDetails: share.includeDetails,
        );
      } else {
        await _socialSharingService.shareEvent(
          event,
          includeDetails: share.includeDetails,
        );
        return true;
      }
    } catch (e) {
      Logger.e('Error processing event share: $e', tag: 'OfflineSharingService');
      return false;
    }
  }

  /// Process a booking share
  Future<bool> _processBookingShare(PendingShare share) async {
    try {
      final bookingMap = jsonDecode(share.contentJson);
      final booking = Booking.fromMap(bookingMap);

      if (share.platform != null) {
        return await _platformSharingService.shareBooking(
          booking,
          share.platform!,
        );
      } else {
        await _socialSharingService.shareBooking(booking);
        return true;
      }
    } catch (e) {
      Logger.e('Error processing booking share: $e', tag: 'OfflineSharingService');
      return false;
    }
  }

  /// Process a comparison share
  Future<bool> _processComparisonShare(PendingShare share) async {
    try {
      final comparisonMap = jsonDecode(share.contentJson);
      final comparison = SavedComparison.fromMap(comparisonMap);

      await _socialSharingService.shareComparison(comparison);
      return true;
    } catch (e) {
      Logger.e(
        'Error processing comparison share: $e',
        tag: 'OfflineSharingService',
      );
      return false;
    }
  }
}
