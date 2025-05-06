/// Class containing all route names used in the application
class RouteNames {
  // Main routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verification = '/verification';
  static const String resetPassword = '/reset-password';
  static const String eventSelection = '/event-selection';
  static const String home = '/home';
  static const String mainNavigation = '/main-navigation';
  static const String onboarding = '/onboarding';

  // Guard-related routes
  static const String unauthorized = '/unauthorized';
  static const String subscription = '/subscription';
  static const String featureUnavailable = '/feature-unavailable';
  static const String bookingSelection = '/booking-selection';
  static const String comparisonSelection = '/comparison-selection';
  static const String wizard = '/wizard';

  // Demo routes
  static const String featureGuardDemo = '/demo/feature-guard';
  static const String routePerformance = '/demo/route-performance';

  // Event wizard routes
  static const String eventWizardSuggestions = '/event-wizard/suggestions';
  static const String eventWizardCreateSuggestion =
      '/event-wizard/create-suggestion';

  // Booking routes
  static const String bookings = '/bookings';
  static const String bookingDetails = '/bookings/details';
  static const String bookingForm = '/bookings/form';

  // Comparison routes
  static const String savedComparisons = '/services/comparison/saved';

  // Service routes
  static const String services = '/services';
  static const String venues = '/services/venues';
  static const String venueDetails = '/services/venues/details';
  static const String catering = '/services/catering';
  static const String cateringDetails = '/services/catering/details';
  static const String photographers = '/services/photographers';
  static const String photographerDetails = '/services/photographers/details';
  static const String planners = '/services/planners';
  static const String plannerDetails = '/services/planners/details';
  static const String serviceComparison = '/services/comparison';

  // Event planning routes
  static const String eventPlanning = '/event-planning';
  static const String budget = '/event-planning/budget';
  static const String guestList = '/event-planning/guest-list';
  static const String timeline = '/event-planning/timeline';
  static const String vendors = '/event-planning/vendors';
  static const String vendorCommunication =
      '/event-planning/vendor-communication';

  // Profile routes
  static const String profile = '/profile';
}
