/// Application-wide constants
class AppConstants {
  // App information
  static const String appName = 'Eventati Book';
  static const String appVersion = '1.0.0';

  // API endpoints
  static const String baseApiUrl = 'https://api.example.com';
  static const String authEndpoint = '$baseApiUrl/auth';
  static const String usersEndpoint = '$baseApiUrl/users';
  static const String eventsEndpoint = '$baseApiUrl/events';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'app_theme';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);

  // Event types
  static const List<String> eventTypes = [
    'Wedding',
    'Birthday',
    'Corporate Event',
    'Conference',
    'Anniversary',
    'Graduation',
    'Baby Shower',
    'Engagement',
    'Reunion',
    'Holiday Party',
  ];

  // Service categories
  static const List<String> serviceCategories = [
    'Venue',
    'Catering',
    'Photography',
    'Event Planning',
    'Decoration',
    'Entertainment',
    'Transportation',
    'Accommodation',
  ];

  // Default padding values
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;

  // Default border radius values
  static const double smallBorderRadius = 4.0;
  static const double mediumBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Default elevation values
  static const double smallElevation = 1.0;
  static const double mediumElevation = 2.0;
  static const double largeElevation = 4.0;
}
