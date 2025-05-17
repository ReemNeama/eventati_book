import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:eventati_book/routing/route_names.dart';
import 'package:eventati_book/routing/route_arguments.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:eventati_book/utils/ui/navigation_utils.dart';

/// Handler for deep links in the application
class DeepLinkHandler {
  static final DeepLinkHandler _instance = DeepLinkHandler._internal();
  factory DeepLinkHandler() => _instance;
  DeepLinkHandler._internal();

  static DeepLinkHandler get instance => _instance;

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  /// Initialize deep link handling
  Future<void> initialize() async {
    // Get initial link if app was opened with one
    try {
      final initialLink = await _appLinks.getInitialAppLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      Logger.e('Error getting initial deep link: $e', tag: 'DeepLinkHandler');
    }

    // Listen for deep links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
      onError: (error) {
        Logger.e('Error handling deep link: $error', tag: 'DeepLinkHandler');
      },
    );
  }

  /// Dispose of resources
  void dispose() {
    _linkSubscription?.cancel();
  }

  /// Handle incoming deep link
  void _handleDeepLink(Uri uri) {
    Logger.i('Received deep link: $uri', tag: 'DeepLinkHandler');

    // Parse the path segments
    final pathSegments = uri.pathSegments;
    if (pathSegments.isEmpty) {
      return;
    }

    // Handle different deep link paths
    switch (pathSegments[0]) {
      case 'auth':
        _handleAuthDeepLink(pathSegments, uri);
        break;
      case 'events':
        _handleEventsDeepLink(pathSegments, uri);
        break;
      case 'services':
        _handleServicesDeepLink(pathSegments, uri);
        break;
      case 'planning':
        _handlePlanningDeepLink(pathSegments, uri);
        break;
      case 'search':
        _handleSearchDeepLink(pathSegments, uri);
        break;
      case 'dashboard':
        _handleDashboardDeepLink(pathSegments, uri);
        break;
      default:
        // Default to home screen
        NavigationUtils.navigateWithoutContext(RouteNames.splash);
        break;
    }
  }

  /// Handle authentication-related deep links
  void _handleAuthDeepLink(List<String> pathSegments, Uri uri) {
    if (pathSegments.length < 2) return;

    switch (pathSegments[1]) {
      case 'reset-password':
        final oobCode = uri.queryParameters['oobCode'];
        if (oobCode != null) {
          NavigationUtils.navigateWithoutContext(
            RouteNames.resetPassword,
            arguments: ResetPasswordArguments(oobCode: oobCode),
          );
        }
        break;
      case 'verify-email':
        final email = uri.queryParameters['email'];
        if (email != null) {
          NavigationUtils.navigateWithoutContext(
            RouteNames.verification,
            arguments: VerificationArguments(email: email),
          );
        }
        break;
      default:
        NavigationUtils.navigateWithoutContext(RouteNames.login);
        break;
    }
  }

  /// Handle event-related deep links
  void _handleEventsDeepLink(List<String> pathSegments, Uri uri) {
    if (pathSegments.length < 2) {
      // Navigate to events list
      NavigationUtils.navigateWithoutContext(RouteNames.userEvents);
      return;
    }

    if (pathSegments[1] == 'create') {
      // Navigate to event creation
      NavigationUtils.navigateWithoutContext(RouteNames.eventSelection);
    } else {
      // Assume it's an event ID
      final eventId = pathSegments[1];
      NavigationUtils.navigateWithoutContext(
        RouteNames.eventDetails,
        arguments: EventDetailsArguments(eventId: eventId),
      );

      // Check for additional path segments for sub-features
      if (pathSegments.length >= 3) {
        _handleEventSubFeature(eventId, pathSegments.sublist(2), uri);
      }
    }
  }

  /// Handle sub-features of an event
  void _handleEventSubFeature(
    String eventId,
    List<String> subPathSegments,
    Uri uri,
  ) {
    if (subPathSegments.isEmpty) return;

    switch (subPathSegments[0]) {
      case 'budget':
        NavigationUtils.navigateWithoutContext(
          RouteNames.budgetOverview,
          arguments: BudgetOverviewArguments(eventId: eventId),
        );
        break;
      case 'guests':
        NavigationUtils.navigateWithoutContext(
          RouteNames.guestList,
          arguments: GuestListArguments(eventId: eventId, eventName: 'Event'),
        );
        break;
      case 'timeline':
        NavigationUtils.navigateWithoutContext(
          RouteNames.timeline,
          arguments: TimelineArguments(eventId: eventId, eventName: 'Event'),
        );
        break;
      case 'dashboard':
        NavigationUtils.navigateWithoutContext(
          RouteNames.eventDashboard,
          arguments: EventDashboardArguments(eventId: eventId),
        );
        break;
    }
  }

  /// Handle service-related deep links
  void _handleServicesDeepLink(List<String> pathSegments, Uri uri) {
    if (pathSegments.length < 2) {
      // Navigate to services list
      NavigationUtils.navigateWithoutContext(RouteNames.services);
      return;
    }

    switch (pathSegments[1]) {
      case 'venue':
        if (pathSegments.length >= 3) {
          // Navigate to specific venue
          NavigationUtils.navigateWithoutContext(
            RouteNames.venueDetails,
            arguments: VenueDetailsArguments(venueId: pathSegments[2]),
          );
        } else {
          // Navigate to venue list
          NavigationUtils.navigateWithoutContext(RouteNames.venueList);
        }
        break;
      case 'catering':
        if (pathSegments.length >= 3) {
          // Navigate to specific catering service
          NavigationUtils.navigateWithoutContext(
            RouteNames.cateringDetails,
            arguments: CateringDetailsArguments(cateringId: pathSegments[2]),
          );
        } else {
          // Navigate to catering list
          NavigationUtils.navigateWithoutContext(RouteNames.cateringList);
        }
        break;
      case 'photography':
        if (pathSegments.length >= 3) {
          // Navigate to specific photographer
          NavigationUtils.navigateWithoutContext(
            RouteNames.photographerDetails,
            arguments: PhotographerDetailsArguments(
              photographerId: pathSegments[2],
            ),
          );
        } else {
          // Navigate to photographer list
          NavigationUtils.navigateWithoutContext(RouteNames.photographerList);
        }
        break;
      default:
        // Navigate to services list
        NavigationUtils.navigateWithoutContext(RouteNames.services);
        break;
    }
  }

  /// Handle planning-related deep links
  void _handlePlanningDeepLink(List<String> pathSegments, Uri uri) {
    // Implementation for planning tools deep links
  }

  /// Handle search-related deep links
  void _handleSearchDeepLink(List<String> pathSegments, Uri uri) {
    final query = uri.queryParameters['q'];
    final category = uri.queryParameters['category'];

    NavigationUtils.navigateWithoutContext(
      RouteNames.globalSearch,
      arguments: GlobalSearchArguments(
        initialQuery: query,
        initialCategory: category,
      ),
    );
  }

  /// Handle dashboard-related deep links
  void _handleDashboardDeepLink(List<String> pathSegments, Uri uri) {
    NavigationUtils.navigateWithoutContext(RouteNames.eventDashboard);
  }
}
