import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/feature_providers/calendar_provider.dart';
import 'package:eventati_book/providers/feature_providers/email_preferences_provider.dart';
import 'package:eventati_book/providers/feature_providers/service_recommendation_provider.dart';
import 'package:eventati_book/providers/feature_providers/social_sharing_provider.dart';
import 'package:eventati_book/providers/planning_providers/booking_provider.dart';

/// Manager for all providers in the application
///
/// This class is responsible for creating and managing all providers
/// in the application. It provides a single point of access for all
/// providers and ensures they are created in the correct order.
class ProvidersManager {
  /// Get all providers for the application
  ///
  /// Returns a list of providers wrapped in a [MultiProvider]
  static Widget getProviders({required Widget child}) {
    return MultiProvider(
      providers: [
        // Feature providers
        ChangeNotifierProvider<ServiceRecommendationProvider>(
          create: (_) => ServiceRecommendationProvider(),
        ),

        // New providers for Services & Booking Enhancements
        ChangeNotifierProvider<CalendarProvider>(
          create: (_) => CalendarProvider(),
        ),
        ChangeNotifierProvider<EmailPreferencesProvider>(
          create: (_) => EmailPreferencesProvider(),
        ),
        ChangeNotifierProvider<BookingProvider>(
          create: (_) => BookingProvider(),
        ),
        ChangeNotifierProvider<SocialSharingProvider>(
          create: (_) => SocialSharingProvider(),
        ),
      ],
      child: child,
    );
  }
}
