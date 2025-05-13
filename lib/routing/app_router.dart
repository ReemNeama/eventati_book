import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/routing/route_names.dart';
import 'package:eventati_book/routing/route_arguments.dart';
// Route guards are applied in the UI layer, not here
// import 'package:eventati_book/routing/route_guards.dart';
import 'package:eventati_book/routing/route_analytics.dart';
import 'package:eventati_book/routing/route_performance.dart';
import 'package:eventati_book/screens/screens.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/supabase/database/service_database_service.dart';
import 'package:eventati_book/services/supabase/database/booking_database_service.dart';
import 'package:eventati_book/di/service_locator.dart';
import 'package:eventati_book/providers/planning_providers/task_template_provider.dart';
import 'package:eventati_book/screens/testing/task_database_test_screen.dart';
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
        // Return a FutureBuilder route to handle the async venue fetch
        return MaterialPageRoute(
          builder:
              (context) => FutureBuilder<Venue?>(
                future: getVenueById(args.venueId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return Scaffold(
                      appBar: AppBar(title: const Text('Error')),
                      body: Center(child: Text('Error: ${snapshot.error}')),
                    );
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return VenueDetailsScreen(venue: snapshot.data!);
                  } else {
                    return Scaffold(
                      appBar: AppBar(title: const Text('Venue Not Found')),
                      body: const Center(child: Text('Venue not found')),
                    );
                  }
                },
              ),
        );

      case RouteNames.cateringDetails:
        final args = settings.arguments as CateringDetailsArguments;
        // Return a FutureBuilder route to handle the async catering service fetch
        return MaterialPageRoute(
          builder:
              (context) => FutureBuilder<CateringService?>(
                future: getCateringById(args.cateringId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return Scaffold(
                      appBar: AppBar(title: const Text('Error')),
                      body: Center(child: Text('Error: ${snapshot.error}')),
                    );
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return CateringDetailsScreen(
                      cateringService: snapshot.data!,
                    );
                  } else {
                    return Scaffold(
                      appBar: AppBar(
                        title: const Text('Catering Service Not Found'),
                      ),
                      body: const Center(
                        child: Text('Catering service not found'),
                      ),
                    );
                  }
                },
              ),
        );

      case RouteNames.photographerDetails:
        final args = settings.arguments as PhotographerDetailsArguments;
        // Return a FutureBuilder route to handle the async photographer fetch
        return MaterialPageRoute(
          builder:
              (context) => FutureBuilder<Photographer?>(
                future: getPhotographerById(args.photographerId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return Scaffold(
                      appBar: AppBar(title: const Text('Error')),
                      body: Center(child: Text('Error: ${snapshot.error}')),
                    );
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return PhotographerDetailsScreen(
                      photographer: snapshot.data!,
                    );
                  } else {
                    return Scaffold(
                      appBar: AppBar(
                        title: const Text('Photographer Not Found'),
                      ),
                      body: const Center(child: Text('Photographer not found')),
                    );
                  }
                },
              ),
        );

      case RouteNames.plannerDetails:
        final args = settings.arguments as PlannerDetailsArguments;
        // Return a FutureBuilder route to handle the async planner fetch
        return MaterialPageRoute(
          builder:
              (context) => FutureBuilder<Planner?>(
                future: getPlannerById(args.plannerId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return Scaffold(
                      appBar: AppBar(title: const Text('Error')),
                      body: Center(child: Text('Error: ${snapshot.error}')),
                    );
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return PlannerDetailsScreen(planner: snapshot.data!);
                  } else {
                    return Scaffold(
                      appBar: AppBar(title: const Text('Planner Not Found')),
                      body: const Center(child: Text('Planner not found')),
                    );
                  }
                },
              ),
        );

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

      case RouteNames.taskDatabaseTest:
        final args = settings.arguments as TaskDatabaseTestArguments;
        return MaterialPageRoute(
          builder: (context) => TaskDatabaseTestScreen(eventId: args.eventId),
        );

      case RouteNames.taskTemplates:
        // We're not using the arguments yet, but they're available for future use
        // final args = settings.arguments as TaskTemplatesArguments?;
        return MaterialPageRoute(
          builder: (context) => const TaskTemplateScreen(),
        );

      case RouteNames.taskTemplateForm:
        final args = settings.arguments as TaskTemplateFormArguments?;
        return MaterialPageRoute(
          builder:
              (context) => TaskTemplateFormScreen(
                template:
                    args?.templateId != null
                        ? Provider.of<TaskTemplateProvider>(
                          context,
                          listen: false,
                        ).templates.firstWhere((t) => t.id == args!.templateId)
                        : null,
              ),
        );

      case RouteNames.personalizedRecommendations:
        return MaterialPageRoute(
          builder: (context) => const PersonalizedRecommendationsScreen(),
        );

      case RouteNames.payment:
        final args = settings.arguments as PaymentArguments;
        // Return a FutureBuilder route to handle the async booking fetch
        return MaterialPageRoute(
          builder:
              (context) => FutureBuilder<Booking?>(
                future: getBookingById(args.bookingId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return Scaffold(
                      appBar: AppBar(title: const Text('Error')),
                      body: Center(child: Text('Error: ${snapshot.error}')),
                    );
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return PaymentScreen(booking: snapshot.data!);
                  } else {
                    return Scaffold(
                      appBar: AppBar(title: const Text('Booking Not Found')),
                      body: const Center(child: Text('Booking not found')),
                    );
                  }
                },
              ),
        );

      case RouteNames.paymentHistory:
        return MaterialPageRoute(
          builder: (context) => const PaymentHistoryScreen(),
        );

      case RouteNames.notifications:
        return MaterialPageRoute(
          builder: (context) => const NotificationListScreen(),
        );

      case RouteNames.notificationPreferences:
        return MaterialPageRoute(
          builder: (context) => const NotificationPreferencesScreen(),
        );

      case RouteNames.eventDetails:
        // In a real app, you would fetch the event from the database using the eventId
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

  /// Get a Venue by ID
  static Future<Venue?> getVenueById(String id) async {
    try {
      final serviceDatabase = serviceLocator.get<ServiceDatabaseService>();
      final service = await serviceDatabase.getService(id);
      if (service == null) return null;

      return Venue(
        name: service.name,
        description: service.description,
        rating: service.averageRating,
        venueTypes: service.tags,
        minCapacity: 50, // Default value
        maxCapacity: service.maximumCapacity ?? 200,
        pricePerEvent: service.price,
        imageUrl:
            service.imageUrls.isNotEmpty
                ? service.imageUrls.first
                : 'assets/images/venue_placeholder.jpg',
        features: service.tags,
      );
    } catch (e) {
      // Return a placeholder venue for now
      return Venue(
        name: 'Venue $id',
        description: 'A beautiful venue for your event',
        rating: 4.5,
        venueTypes: ['Wedding', 'Corporate', 'Party'],
        minCapacity: 50,
        maxCapacity: 200,
        pricePerEvent: 1000,
        imageUrl: 'assets/images/venue_placeholder.jpg',
        features: ['Parking', 'Catering', 'Sound System'],
      );
    }
  }

  /// Get a CateringService by ID
  static Future<CateringService?> getCateringById(String id) async {
    try {
      final serviceDatabase = serviceLocator.get<ServiceDatabaseService>();
      final service = await serviceDatabase.getService(id);
      if (service == null) return null;

      return CateringService(
        name: service.name,
        description: service.description,
        rating: service.averageRating,
        cuisineTypes: service.tags,
        minCapacity: 20, // Default value
        maxCapacity: service.maximumCapacity ?? 500,
        pricePerPerson: service.price / 10, // Assuming price is for 10 people
        imageUrl:
            service.imageUrls.isNotEmpty
                ? service.imageUrls.first
                : 'assets/images/catering_placeholder.jpg',
      );
    } catch (e) {
      // Return a placeholder catering service for now
      return CateringService(
        name: 'Catering Service $id',
        description: 'Delicious food for your event',
        rating: 4.5,
        cuisineTypes: ['Italian', 'Mediterranean', 'International'],
        minCapacity: 20,
        maxCapacity: 500,
        pricePerPerson: 50,
        imageUrl: 'assets/images/catering_placeholder.jpg',
      );
    }
  }

  /// Get a Photographer by ID
  static Future<Photographer?> getPhotographerById(String id) async {
    try {
      final serviceDatabase = serviceLocator.get<ServiceDatabaseService>();
      final service = await serviceDatabase.getService(id);
      if (service == null) return null;

      return Photographer(
        name: service.name,
        description: service.description,
        rating: service.averageRating,
        styles: service.tags,
        pricePerEvent: service.price,
        imageUrl:
            service.imageUrls.isNotEmpty
                ? service.imageUrls.first
                : 'assets/images/photographer_placeholder.jpg',
        equipment: [
          'Professional Camera',
          'Lighting Equipment',
        ], // Default value
        packages: ['Basic Package', 'Premium Package'], // Default value
      );
    } catch (e) {
      // Return a placeholder photographer for now
      return Photographer(
        name: 'Photographer $id',
        description: 'Professional photographer for your event',
        rating: 4.5,
        styles: ['Portrait', 'Candid', 'Documentary'],
        pricePerEvent: 1500,
        imageUrl: 'assets/images/photographer_placeholder.jpg',
        equipment: ['Professional Camera', 'Lighting Equipment'],
        packages: ['Basic Package', 'Premium Package'],
      );
    }
  }

  /// Get a Booking by ID
  static Future<Booking?> getBookingById(String id) async {
    try {
      final bookingDatabase = serviceLocator.get<BookingDatabaseService>();
      return await bookingDatabase.getBooking(id);
    } catch (e) {
      debugPrint('Error getting booking: $e');
      return null;
    }
  }

  /// Get a Planner by ID
  static Future<Planner?> getPlannerById(String id) async {
    try {
      final serviceDatabase = serviceLocator.get<ServiceDatabaseService>();
      final service = await serviceDatabase.getService(id);
      if (service == null) return null;

      return Planner(
        name: service.name,
        description: service.description,
        rating: service.averageRating,
        specialties: service.tags,
        yearsExperience: 5, // Default value
        pricePerEvent: service.price,
        imageUrl:
            service.imageUrls.isNotEmpty
                ? service.imageUrls.first
                : 'assets/images/planner_placeholder.jpg',
        services: [
          'Full Planning',
          'Day-of Coordination',
          'Vendor Management',
        ], // Default value
      );
    } catch (e) {
      // Return a placeholder planner for now
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
}
