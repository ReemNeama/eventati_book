/// Configuration for deep links in the application
class DeepLinkConfig {
  /// The URL scheme for deep links
  static const String urlScheme = 'eventati';

  /// The host for deep links
  static const String host = 'app';

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
