/// Configuration for deep links in the application
class DeepLinkConfig {
  /// The URL scheme for deep links
  static const String urlScheme = 'eventati';

  /// The host for deep links
  static const String host = 'app';

  /// The web URL for sharing
  static const String webUrl = 'https://eventatibook.com';

  /// The dynamic link domain for Firebase Dynamic Links
  static const String dynamicLinkDomain = 'eventati.page.link';

  /// Generate a deep link URL for authentication
  static String generateAuthUrl(String action, {Map<String, String>? params}) {
    return _generateUrl(['auth', action], params);
  }

  /// Generate a deep link URL for events
  static String generateEventUrl(
    String eventId, {
    Map<String, String>? params,
  }) {
    return _generateUrl(['events', eventId], params);
  }

  /// Generate a deep link URL for event creation
  static String generateEventCreationUrl({Map<String, String>? params}) {
    return _generateUrl(['events', 'create'], params);
  }

  /// Generate a deep link URL for event dashboard
  static String generateEventDashboardUrl(
    String eventId, {
    Map<String, String>? params,
  }) {
    return _generateUrl(['events', eventId, 'dashboard'], params);
  }

  /// Generate a deep link URL for event budget
  static String generateEventBudgetUrl(
    String eventId, {
    Map<String, String>? params,
  }) {
    return _generateUrl(['events', eventId, 'budget'], params);
  }

  /// Generate a deep link URL for event guest list
  static String generateEventGuestListUrl(
    String eventId, {
    Map<String, String>? params,
  }) {
    return _generateUrl(['events', eventId, 'guests'], params);
  }

  /// Generate a deep link URL for event timeline
  static String generateEventTimelineUrl(
    String eventId, {
    Map<String, String>? params,
  }) {
    return _generateUrl(['events', eventId, 'timeline'], params);
  }

  /// Generate a deep link URL for services
  static String generateServicesUrl({Map<String, String>? params}) {
    return _generateUrl(['services'], params);
  }

  /// Generate a deep link URL for a specific service type
  static String generateServiceTypeUrl(
    String serviceType, {
    Map<String, String>? params,
  }) {
    return _generateUrl(['services', serviceType], params);
  }

  /// Generate a deep link URL for a specific service
  static String generateServiceUrl(
    String serviceType,
    String serviceId, {
    Map<String, String>? params,
  }) {
    return _generateUrl(['services', serviceType, serviceId], params);
  }

  /// Generate a deep link URL for search
  static String generateSearchUrl({
    String? query,
    String? category,
    Map<String, String>? additionalParams,
  }) {
    final params = <String, String>{};
    if (query != null) params['q'] = query;
    if (category != null) params['category'] = category;
    if (additionalParams != null) params.addAll(additionalParams);

    return _generateUrl(['search'], params);
  }

  /// Generate a deep link URL for the dashboard
  static String generateDashboardUrl({Map<String, String>? params}) {
    return _generateUrl(['dashboard'], params);
  }

  /// Generate a deep link URL for bookings
  static String generateBookingsUrl({Map<String, String>? params}) {
    return _generateUrl(['bookings'], params);
  }

  /// Generate a deep link URL for a specific booking
  static String generateBookingUrl(
    String bookingId, {
    Map<String, String>? params,
  }) {
    return _generateUrl(['bookings', bookingId], params);
  }

  /// Generate a deep link URL for the user profile
  static String generateProfileUrl({Map<String, String>? params}) {
    return _generateUrl(['profile'], params);
  }

  /// Generate a deep link URL for the notification center
  static String generateNotificationsUrl({Map<String, String>? params}) {
    return _generateUrl(['notifications'], params);
  }

  /// Generate a deep link URL for the settings page
  static String generateSettingsUrl({Map<String, String>? params}) {
    return _generateUrl(['settings'], params);
  }

  /// Generate a deep link URL for a specific settings section
  static String generateSettingsSectionUrl(
    String section, {
    Map<String, String>? params,
  }) {
    return _generateUrl(['settings', section], params);
  }

  /// Generate a deep link URL for saved comparisons
  static String generateComparisonsUrl({Map<String, String>? params}) {
    return _generateUrl(['comparisons'], params);
  }

  /// Generate a deep link URL for a specific comparison
  static String generateComparisonUrl(
    String comparisonId, {
    Map<String, String>? params,
  }) {
    return _generateUrl(['comparisons', comparisonId], params);
  }

  /// Generate a deep link URL for the planning tools
  static String generatePlanningToolsUrl({Map<String, String>? params}) {
    return _generateUrl(['planning'], params);
  }

  /// Generate a deep link URL for a specific planning tool
  static String generatePlanningToolUrl(
    String toolType, {
    Map<String, String>? params,
  }) {
    return _generateUrl(['planning', toolType], params);
  }

  /// Generate a web URL for sharing
  static String generateWebUrl(
    List<String> pathSegments, {
    Map<String, String>? queryParameters,
  }) {
    final uri = Uri(
      scheme: 'https',
      host: webUrl.replaceAll('https://', ''),
      pathSegments: pathSegments,
      queryParameters: queryParameters,
    );

    return uri.toString();
  }

  /// Generate a web URL for sharing an event
  static String generateEventWebUrl(
    String eventId, {
    Map<String, String>? params,
  }) {
    return generateWebUrl(['events', eventId], queryParameters: params);
  }

  /// Generate a web URL for sharing a service
  static String generateServiceWebUrl(
    String serviceType,
    String serviceId, {
    Map<String, String>? params,
  }) {
    return generateWebUrl([
      'services',
      serviceType,
      serviceId,
    ], queryParameters: params);
  }

  /// Generate a web URL for sharing a comparison
  static String generateComparisonWebUrl(
    String comparisonId, {
    Map<String, String>? params,
  }) {
    return generateWebUrl([
      'comparisons',
      comparisonId,
    ], queryParameters: params);
  }

  /// Generate a dynamic link for sharing
  static String generateDynamicLink(
    String deepLink,
    String title,
    String description, {
    String? imageUrl,
  }) {
    final params = <String, String>{
      'link': deepLink,
      'apn': 'com.eventatibook.app',
      'ibi': 'com.eventatibook.app',
      'st': title,
      'sd': description,
    };

    if (imageUrl != null) {
      params['si'] = imageUrl;
    }

    final uri = Uri(
      scheme: 'https',
      host: dynamicLinkDomain,
      queryParameters: params,
    );

    return uri.toString();
  }

  /// Generate a dynamic link for sharing an event
  static String generateEventDynamicLink(
    String eventId,
    String eventName,
    String eventDescription, {
    String? imageUrl,
  }) {
    final deepLink = generateEventUrl(eventId);
    return generateDynamicLink(
      deepLink,
      'Event: $eventName',
      eventDescription,
      imageUrl: imageUrl,
    );
  }

  /// Generate a dynamic link for sharing a service
  static String generateServiceDynamicLink(
    String serviceType,
    String serviceId,
    String serviceName,
    String serviceDescription, {
    String? imageUrl,
  }) {
    final deepLink = generateServiceUrl(serviceType, serviceId);
    return generateDynamicLink(
      deepLink,
      'Service: $serviceName',
      serviceDescription,
      imageUrl: imageUrl,
    );
  }

  /// Generate a dynamic link for sharing a booking
  static String generateBookingDynamicLink(
    String bookingId,
    String serviceName,
    String bookingDetails, {
    String? imageUrl,
  }) {
    final deepLink = generateBookingUrl(bookingId);
    return generateDynamicLink(
      deepLink,
      'Booking: $serviceName',
      bookingDetails,
      imageUrl: imageUrl,
    );
  }

  /// Generate a deep link URL with the given path segments and query parameters
  static String _generateUrl(
    List<String> pathSegments, [
    Map<String, String>? queryParameters,
  ]) {
    final uri = Uri(
      scheme: urlScheme,
      host: host,
      pathSegments: pathSegments,
      queryParameters: queryParameters,
    );

    return uri.toString();
  }
}
