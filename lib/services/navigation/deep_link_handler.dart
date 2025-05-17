import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:eventati_book/config/deep_link_config.dart';
import 'package:eventati_book/services/analytics_service.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:eventati_book/services/navigation/navigation_service.dart';

/// Handler for deep links in the application
class DeepLinkHandler {
  /// The app links instance for handling deep links
  final AppLinks _appLinks = AppLinks();

  /// The navigation service for navigating to routes
  final NavigationService _navigationService;

  /// The analytics service for tracking deep link events
  final AnalyticsService _analyticsService;

  /// Stream subscription for initial link
  StreamSubscription<Uri>? _initialLinkSubscription;

  /// Stream subscription for link changes
  StreamSubscription<Uri>? _linkSubscription;

  /// Constructor
  DeepLinkHandler({
    NavigationService? navigationService,
    AnalyticsService? analyticsService,
  }) : _navigationService = navigationService ?? NavigationService(),
       _analyticsService = analyticsService ?? AnalyticsService();

  /// Initialize the deep link handler
  Future<void> initialize() async {
    try {
      // Handle initial link if the app was opened from a deep link
      _initialLinkSubscription = _appLinks.uriLinkStream.listen(
        (uri) {
          Logger.i('Initial deep link received: $uri', tag: 'DeepLinkHandler');
          _handleDeepLink(uri);
        },
        onError: (error) {
          Logger.e(
            'Error getting initial deep link: $error',
            tag: 'DeepLinkHandler',
          );
        },
      );

      // Handle links when the app is already running
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (uri) {
          Logger.i('Deep link received: $uri', tag: 'DeepLinkHandler');
          _handleDeepLink(uri);
        },
        onError: (error) {
          Logger.e('Error getting deep link: $error', tag: 'DeepLinkHandler');
        },
      );

      // Check for any initial link
      final initialLink = await _appLinks.getInitialAppLink();
      if (initialLink != null) {
        Logger.i('Initial deep link: $initialLink', tag: 'DeepLinkHandler');
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      Logger.e(
        'Error initializing deep link handler: $e',
        tag: 'DeepLinkHandler',
      );
    }
  }

  /// Dispose of the deep link handler
  void dispose() {
    _initialLinkSubscription?.cancel();
    _linkSubscription?.cancel();
  }

  /// Handle a deep link
  void _handleDeepLink(Uri uri) {
    try {
      // Check if the URI scheme matches our app's scheme
      if (uri.scheme != DeepLinkConfig.urlScheme) {
        Logger.w(
          'Invalid deep link scheme: ${uri.scheme}',
          tag: 'DeepLinkHandler',
        );
        return;
      }

      // Check if the URI host matches our app's host
      if (uri.host != DeepLinkConfig.host) {
        Logger.w('Invalid deep link host: ${uri.host}', tag: 'DeepLinkHandler');
        return;
      }

      // Track the deep link event
      _analyticsService.trackDeepLink(uri.toString());

      // Handle the deep link based on the path segments
      final pathSegments = uri.pathSegments;
      if (pathSegments.isEmpty) {
        // If no path segments, navigate to the home screen
        _navigationService.navigateTo('/');
        return;
      }

      // Handle different types of deep links
      switch (pathSegments[0]) {
        case 'auth':
          _handleAuthDeepLink(pathSegments, uri.queryParameters);
          break;
        case 'events':
          _handleEventDeepLink(pathSegments, uri.queryParameters);
          break;
        case 'services':
          _handleServiceDeepLink(pathSegments, uri.queryParameters);
          break;
        case 'bookings':
          _handleBookingDeepLink(pathSegments, uri.queryParameters);
          break;
        case 'profile':
          _handleProfileDeepLink(pathSegments, uri.queryParameters);
          break;
        case 'notifications':
          _handleNotificationDeepLink(pathSegments, uri.queryParameters);
          break;
        case 'settings':
          _handleSettingsDeepLink(pathSegments, uri.queryParameters);
          break;
        case 'comparisons':
          _handleComparisonDeepLink(pathSegments, uri.queryParameters);
          break;
        case 'planning':
          _handlePlanningDeepLink(pathSegments, uri.queryParameters);
          break;
        case 'search':
          _handleSearchDeepLink(pathSegments, uri.queryParameters);
          break;
        case 'dashboard':
          _handleDashboardDeepLink(pathSegments, uri.queryParameters);
          break;
        default:
          Logger.w(
            'Unknown deep link path: ${pathSegments[0]}',
            tag: 'DeepLinkHandler',
          );
          _navigationService.navigateTo('/');
          break;
      }
    } catch (e) {
      Logger.e('Error handling deep link: $e', tag: 'DeepLinkHandler');
      _navigationService.navigateTo('/');
    }
  }

  /// Handle authentication deep links
  void _handleAuthDeepLink(
    List<String> pathSegments,
    Map<String, String> queryParams,
  ) {
    if (pathSegments.length < 2) {
      _navigationService.navigateTo('/auth');
      return;
    }

    final action = pathSegments[1];
    switch (action) {
      case 'login':
        _navigationService.navigateTo('/auth/login');
        break;
      case 'register':
        _navigationService.navigateTo('/auth/register');
        break;
      case 'reset-password':
        _navigationService.navigateTo('/auth/reset-password');
        break;
      case 'verify-email':
        final token = queryParams['token'];
        if (token != null) {
          _navigationService.navigateTo(
            '/auth/verify-email',
            arguments: {'token': token},
          );
        } else {
          _navigationService.navigateTo('/auth/verify-email');
        }
        break;
      default:
        _navigationService.navigateTo('/auth');
        break;
    }
  }

  /// Handle event deep links
  void _handleEventDeepLink(
    List<String> pathSegments,
    Map<String, String> queryParams,
  ) {
    if (pathSegments.length < 2) {
      _navigationService.navigateTo('/events');
      return;
    }

    if (pathSegments[1] == 'create') {
      _navigationService.navigateTo('/events/create');
      return;
    }

    final eventId = pathSegments[1];
    if (pathSegments.length == 2) {
      _navigationService.navigateTo('/events/$eventId');
      return;
    }

    final section = pathSegments[2];
    switch (section) {
      case 'dashboard':
        _navigationService.navigateTo('/events/$eventId/dashboard');
        break;
      case 'budget':
        _navigationService.navigateTo('/events/$eventId/budget');
        break;
      case 'guests':
        _navigationService.navigateTo('/events/$eventId/guests');
        break;
      case 'timeline':
        _navigationService.navigateTo('/events/$eventId/timeline');
        break;
      default:
        _navigationService.navigateTo('/events/$eventId');
        break;
    }
  }

  /// Handle service deep links
  void _handleServiceDeepLink(
    List<String> pathSegments,
    Map<String, String> queryParams,
  ) {
    if (pathSegments.length < 2) {
      _navigationService.navigateTo('/services');
      return;
    }

    final serviceType = pathSegments[1];
    if (pathSegments.length == 2) {
      _navigationService.navigateTo('/services/$serviceType');
      return;
    }

    final serviceId = pathSegments[2];
    _navigationService.navigateTo('/services/$serviceType/$serviceId');
  }

  /// Handle booking deep links
  void _handleBookingDeepLink(
    List<String> pathSegments,
    Map<String, String> queryParams,
  ) {
    if (pathSegments.length < 2) {
      _navigationService.navigateTo('/bookings');
      return;
    }

    final bookingId = pathSegments[1];
    _navigationService.navigateTo('/bookings/$bookingId');
  }

  /// Handle profile deep links
  void _handleProfileDeepLink(
    List<String> pathSegments,
    Map<String, String> queryParams,
  ) {
    _navigationService.navigateTo('/profile');
  }

  /// Handle notification deep links
  void _handleNotificationDeepLink(
    List<String> pathSegments,
    Map<String, String> queryParams,
  ) {
    _navigationService.navigateTo('/notifications');
  }

  /// Handle settings deep links
  void _handleSettingsDeepLink(
    List<String> pathSegments,
    Map<String, String> queryParams,
  ) {
    if (pathSegments.length < 2) {
      _navigationService.navigateTo('/settings');
      return;
    }

    final section = pathSegments[1];
    _navigationService.navigateTo('/settings/$section');
  }

  /// Handle comparison deep links
  void _handleComparisonDeepLink(
    List<String> pathSegments,
    Map<String, String> queryParams,
  ) {
    if (pathSegments.length < 2) {
      _navigationService.navigateTo('/comparisons');
      return;
    }

    final comparisonId = pathSegments[1];
    _navigationService.navigateTo('/comparisons/$comparisonId');
  }

  /// Handle planning deep links
  void _handlePlanningDeepLink(
    List<String> pathSegments,
    Map<String, String> queryParams,
  ) {
    if (pathSegments.length < 2) {
      _navigationService.navigateTo('/planning');
      return;
    }

    final toolType = pathSegments[1];
    _navigationService.navigateTo('/planning/$toolType');
  }

  /// Handle search deep links
  void _handleSearchDeepLink(
    List<String> pathSegments,
    Map<String, String> queryParams,
  ) {
    final query = queryParams['q'];
    final category = queryParams['category'];

    if (query != null || category != null) {
      _navigationService.navigateTo(
        '/search',
        arguments: {
          if (query != null) 'query': query,
          if (category != null) 'category': category,
        },
      );
    } else {
      _navigationService.navigateTo('/search');
    }
  }

  /// Handle dashboard deep links
  void _handleDashboardDeepLink(
    List<String> pathSegments,
    Map<String, String> queryParams,
  ) {
    _navigationService.navigateTo('/dashboard');
  }
}
