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
  static const String personalizedRecommendations =
      '/recommendations/personalized';
  static const String vendorRecommendations = '/recommendations/vendors';

  // Booking routes
  static const String bookings = '/bookings';
  static const String bookingDetails = '/bookings/details';
  static const String bookingForm = '/bookings/form';
  static const String preCheckoutComparison =
      '/bookings/pre-checkout-comparison';
  static const String payment = '/bookings/payment';
  static const String paymentHistory = '/bookings/payment-history';

  // Comparison routes
  static const String savedComparisons = '/services/comparison/saved';

  // Service routes
  static const String services = '/services';
  static const String venues = '/services/venues';
  static const String venueList = '/services/venues/list';
  static const String venueDetails = '/services/venues/details';
  static const String catering = '/services/catering';
  static const String cateringList = '/services/catering/list';
  static const String cateringDetails = '/services/catering/details';
  static const String photographers = '/services/photographers';
  static const String photographerList = '/services/photographers/list';
  static const String photographerDetails = '/services/photographers/details';
  static const String planners = '/services/planners';
  static const String plannerList = '/services/planners/list';
  static const String plannerDetails = '/services/planners/details';
  static const String serviceComparison = '/services/comparison';
  static const String recentlyViewedServices = '/services/recently-viewed';

  // Event routes
  static const String userEvents = '/events';
  static const String eventDetails = '/events/details';
  static const String eventDashboard = '/events/dashboard';

  // Event planning routes
  static const String eventPlanning = '/event-planning';
  static const String budget = '/event-planning/budget';
  static const String budgetOverview = '/event-planning/budget/overview';
  static const String guestList = '/event-planning/guest-list';
  static const String timeline = '/event-planning/timeline';
  static const String taskDependency = '/event-planning/task-dependency';
  static const String taskTemplates = '/event-planning/task-templates';
  static const String taskTemplateForm = '/event-planning/task-templates/form';
  static const String vendors = '/event-planning/vendors';
  static const String vendorCommunication =
      '/event-planning/vendor-communication';

  // Profile routes
  static const String profile = '/profile';

  // Notification routes
  static const String notifications = '/notifications';

  // Settings routes
  static const String notificationPreferences =
      '/settings/notification-preferences';
  static const String biometricSettings = '/settings/biometric';

  // Search routes
  static const String globalSearch = '/search';
  static const String searchResults = '/search/results';
  static const String advancedSearch = '/search/advanced';

  // Activity routes
  static const String activityHistory = '/activity/history';

  // Dashboard routes
  static const String mainDashboard = '/dashboard';

  // Testing routes - All removed
}
