import 'package:flutter/material.dart';
import 'package:eventati_book/routing/route_names.dart';
import 'package:eventati_book/routing/route_arguments.dart';
// Route guards are applied in the UI layer, not here
// import 'package:eventati_book/routing/route_guards.dart';
import 'package:eventati_book/routing/route_analytics.dart';
import 'package:eventati_book/routing/route_performance.dart';
import 'package:eventati_book/screens/screens.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/tempDB/venues.dart';
import 'package:eventati_book/tempDB/services.dart';
import 'package:eventati_book/screens/planning/task_dependency_screen.dart';
import 'package:eventati_book/screens/testing/task_firestore_test_screen.dart';
import 'package:eventati_book/screens/recommendations/personalized_recommendations_screen.dart';

/// Router class for handling all navigation in the app
class AppRouter {
  /// Define static routes that don't require parameters
  static Map<String, WidgetBuilder> get routes => {
    RouteNames.splash: (context) => const AuthScreen(),
    RouteNames.login: (context) => const LoginScreen(),
    RouteNames.register: (context) => const RegisterScreen(),
    RouteNames.forgotPassword: (context) => const ForgetpasswordScreen(),

    // Guard-related routes
    RouteNames.unauthorized: (context) => const UnauthorizedScreen(),
    RouteNames.subscription: (context) => const SubscriptionScreen(),
    RouteNames.featureUnavailable:
        (context) => const FeatureUnavailableScreen(),

    // Demo routes
    RouteNames.featureGuardDemo: (context) => const FeatureGuardDemoScreen(),
    RouteNames.routePerformance: (context) => const RoutePerformanceScreen(),

    // Add more static routes as needed
  };

  /// Handle routes that require parameters
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Start tracking navigation time
    RoutePerformance.instance.startNavigationTimer(settings.name ?? 'unknown');

    // Track navigation event
    RouteAnalytics.instance.trackNavigation(
      settings.name ?? 'unknown',
      parameters:
          settings.arguments is Map<String, dynamic>
              ? settings.arguments as Map<String, dynamic>
              : settings.arguments != null
              ? {'arguments': settings.arguments.toString()}
              : null,
    );

    switch (settings.name) {
      case RouteNames.verification:
        final args = settings.arguments as VerificationArguments;
        final route = MaterialPageRoute(
          builder: (context) => VerificationScreen(email: args.email),
        );

        // End tracking navigation time when the route is built
        RoutePerformance.instance.endNavigationTimer(
          settings.name ?? 'unknown',
        );

        return route;

      case RouteNames.resetPassword:
        // Check if we have a reset code from deep link
        final args = settings.arguments;
        String? oobCode;

        if (args is ResetPasswordArguments) {
          oobCode = args.oobCode;
        }

        return MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(oobCode: oobCode),
        );

      case RouteNames.mainNavigation:
        final args = settings.arguments as MainNavigationArguments;
        return MaterialPageRoute(
          builder:
              (context) => MainNavigationScreen(toggleTheme: args.toggleTheme),
        );

      case RouteNames.bookingDetails:
        final args = settings.arguments as BookingDetailsArguments;
        return MaterialPageRoute(
          builder: (context) => BookingDetailsScreen(bookingId: args.bookingId),
        );

      case RouteNames.bookingForm:
        final args = settings.arguments as BookingFormArguments;
        return MaterialPageRoute(
          builder:
              (context) => BookingFormScreen(
                serviceId: args.serviceId,
                serviceType: args.serviceType,
                serviceName: args.serviceName,
                basePrice: args.basePrice,
                bookingId: args.bookingId,
                eventId: args.eventId,
                eventName: args.eventName,
              ),
        );

      case RouteNames.venueDetails:
        final args = settings.arguments as VenueDetailsArguments;
        final venue = getVenueById(args.venueId);
        if (venue != null) {
          return MaterialPageRoute(
            builder: (context) => VenueDetailsScreen(venue: venue),
          );
        }
        return _buildErrorRoute('Venue not found');

      case RouteNames.cateringDetails:
        final args = settings.arguments as CateringDetailsArguments;
        final cateringService = getCateringById(args.cateringId);
        if (cateringService != null) {
          return MaterialPageRoute(
            builder:
                (context) =>
                    CateringDetailsScreen(cateringService: cateringService),
          );
        }
        return _buildErrorRoute('Catering service not found');

      case RouteNames.photographerDetails:
        final args = settings.arguments as PhotographerDetailsArguments;
        final photographer = getPhotographerById(args.photographerId);
        if (photographer != null) {
          return MaterialPageRoute(
            builder:
                (context) =>
                    PhotographerDetailsScreen(photographer: photographer),
          );
        }
        return _buildErrorRoute('Photographer not found');

      case RouteNames.plannerDetails:
        final args = settings.arguments as PlannerDetailsArguments;
        final planner = getPlannerById(args.plannerId);
        if (planner != null) {
          return MaterialPageRoute(
            builder: (context) => PlannerDetailsScreen(planner: planner),
          );
        }
        return _buildErrorRoute('Planner not found');

      case RouteNames.serviceComparison:
        final args = settings.arguments as ServiceComparisonArguments;
        return MaterialPageRoute(
          builder:
              (context) =>
                  ServiceComparisonScreen(serviceType: args.serviceType),
        );

      case RouteNames.savedComparisons:
        return MaterialPageRoute(
          builder: (context) => const SavedComparisonsScreen(),
        );

      case RouteNames.eventPlanning:
        // Route guards should be applied in the UI layer, not here
        // We'll just process the arguments
        final args = settings.arguments as EventPlanningArguments;
        return MaterialPageRoute(
          builder:
              (context) => EventPlanningToolsScreen(
                eventId: args.eventId,
                eventName: args.eventName,
                eventType: args.eventType,
                eventDate: args.eventDate,
              ),
        );

      case RouteNames.budget:
        final args = settings.arguments as BudgetArguments;
        return MaterialPageRoute(
          builder:
              (context) => BudgetOverviewScreen(
                eventId: args.eventId,
                eventName: args.eventName,
              ),
        );

      case RouteNames.guestList:
        final args = settings.arguments as GuestListArguments;
        return MaterialPageRoute(
          builder:
              (context) => GuestListScreen(
                eventId: args.eventId,
                eventName: args.eventName,
              ),
        );

      case RouteNames.timeline:
        final args = settings.arguments as TimelineArguments;
        return MaterialPageRoute(
          builder:
              (context) => TimelineScreen(
                eventId: args.eventId,
                eventName: args.eventName,
              ),
        );

      case RouteNames.taskDependency:
        final args = settings.arguments as TaskDependencyArguments;
        return MaterialPageRoute(
          builder:
              (context) => TaskDependencyScreen(
                eventId: args.eventId,
                focusedTaskId: args.focusedTaskId,
              ),
        );

      case RouteNames.vendorCommunication:
        final args = settings.arguments as VendorCommunicationArguments;
        return MaterialPageRoute(
          builder:
              (context) => VendorListScreen(
                eventId: args.eventId,
                eventName: args.eventName,
              ),
        );

      case RouteNames.taskFirestoreTest:
        final args = settings.arguments as TaskFirestoreTestArguments;
        return MaterialPageRoute(
          builder: (context) => TaskFirestoreTestScreen(eventId: args.eventId),
        );

      case RouteNames.personalizedRecommendations:
        return MaterialPageRoute(
          builder: (context) => const PersonalizedRecommendationsScreen(),
        );

      case RouteNames.eventDetails:
        // In a real app, you would fetch the event from Firestore using the eventId
        // For now, we'll redirect to the UserEventsScreen
        return MaterialPageRoute(
          builder: (context) => const UserEventsScreen(),
        );

      default:
        return null;
    }
  }

  /// Handle unknown routes
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder:
          (context) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
    );
  }

  /// Build an error route
  static Route<dynamic> _buildErrorRoute(String message) {
    return MaterialPageRoute(
      builder:
          (context) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text(message)),
          ),
    );
  }

  /// Get a Venue by ID
  static Venue? getVenueById(String id) {
    final venueData = VenueDB.getVenueById(id);
    if (venueData == null) return null;

    return Venue(
      name: venueData['name'],
      description: venueData['description'],
      rating: venueData['rating'],
      venueTypes: List<String>.from(venueData['features']),
      minCapacity: 50, // Default value, adjust as needed
      maxCapacity: venueData['capacity'],
      pricePerEvent: 1000, // Default value, adjust as needed
      imageUrl:
          venueData['imageUrls']?.isNotEmpty == true
              ? venueData['imageUrls'][0]
              : 'assets/images/venue_placeholder.jpg',
      features: List<String>.from(venueData['features']),
    );
  }

  /// Get a CateringService by ID
  static CateringService? getCateringById(String id) {
    final cateringData = ServiceDB.getServiceById(id, 'catering');
    if (cateringData == null) return null;

    return CateringService(
      name: cateringData['name'],
      description: cateringData['description'],
      rating: cateringData['rating'],
      cuisineTypes: List<String>.from(cateringData['features']),
      minCapacity: 20, // Default value, adjust as needed
      maxCapacity: 500, // Default value, adjust as needed
      pricePerPerson: 50, // Default value, adjust as needed
      imageUrl:
          cateringData['imageUrls']?.isNotEmpty == true
              ? cateringData['imageUrls'][0]
              : 'assets/images/catering_placeholder.jpg',
    );
  }

  /// Get a Photographer by ID
  static Photographer? getPhotographerById(String id) {
    final photographerData = ServiceDB.getServiceById(id, 'photography');
    if (photographerData == null) return null;

    return Photographer(
      name: photographerData['name'],
      description: photographerData['description'],
      rating: photographerData['rating'],
      styles: List<String>.from(photographerData['features']),
      pricePerEvent: 1500, // Default value, adjust as needed
      imageUrl:
          photographerData['imageUrls']?.isNotEmpty == true
              ? photographerData['imageUrls'][0]
              : 'assets/images/photographer_placeholder.jpg',
      equipment: ['Professional Camera', 'Lighting Equipment'], // Default value
      packages: ['Basic Package', 'Premium Package'], // Default value
    );
  }

  /// Get a Planner by ID
  static Planner? getPlannerById(String id) {
    // Note: This is a placeholder. In a real implementation, you would fetch from a database
    // For now, we'll return a mock planner
    return Planner(
      name: 'Event Planner $id',
      description: 'Professional event planner with years of experience',
      rating: 4.8,
      specialties: ['Weddings', 'Corporate Events', 'Celebrations'],
      yearsExperience: 5,
      pricePerEvent: 2000,
      imageUrl: 'assets/images/planner_placeholder.jpg',
      services: ['Full Planning', 'Day-of Coordination', 'Vendor Management'],
    );
  }
}
