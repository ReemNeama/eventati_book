/// Constants used throughout the app
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // Padding constants
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  // Border radius constants
  static const double smallBorderRadius = 4.0;
  static const double mediumBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  static const double extraLargeBorderRadius = 24.0;

  // Elevation constants
  static const double noElevation = 0.0;
  static const double smallElevation = 2.0;
  static const double mediumElevation = 4.0;
  static const double largeElevation = 8.0;

  // Animation duration constants
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Shared preferences keys
  static const String tokenKey = 'token';
  static const String userDataKey = 'userData';
  static const String onboardingCompletedKey = 'onboardingCompleted';
  static const String eventsKey = 'events';
  static const String activeEventKey = 'activeEvent';
  static const String bookingsKey = 'bookings';
  static const String savedComparisonsKey = 'savedComparisons';
  static const String themePreferenceKey = 'themePreference';
  static const String suggestionsKey = 'suggestions';
  static const String featuresKey = 'features';

  // API endpoints
  static const String baseUrl = 'https://api.eventati.com';
  static const String authEndpoint = '/auth';
  static const String venuesEndpoint = '/venues';
  static const String cateringEndpoint = '/catering';
  static const String photographersEndpoint = '/photographers';
  static const String plannersEndpoint = '/planners';
  static const String bookingsEndpoint = '/bookings';
  static const String eventsEndpoint = '/events';

  // Default values
  static const int defaultPageSize = 10;
  static const int maxGuestCount = 1000;
  static const double maxBudget = 100000.0;
  static const int maxImageCount = 10;
  static const int maxReviewCount = 5;
  static const int maxFeaturesCount = 10;
  static const int maxAmenitiesCount = 10;
  static const int maxCuisineTypesCount = 10;
  static const int maxStylesCount = 10;
  static const int maxSpecialtiesCount = 10;
  static const int maxServicesCount = 10;
  static const int maxPackagesCount = 5;
  static const int maxEquipmentCount = 10;
  static const int maxVenueTypesCount = 10;
  static const int maxFavoriteVenuesCount = 20;
  static const int maxFavoriteServicesCount = 20;
  static const int maxSavedComparisonsCount = 10;
  static const int maxSuggestionsCount = 10;
  static const int maxEventsCount = 10;
  static const int maxBookingsCount = 20;
  static const int maxTasksCount = 50;
  static const int maxGuestsCount = 200;
  static const int maxVendorsCount = 20;
  static const int maxMessagesCount = 100;
  static const int maxMilestonesCount = 30;
  static const int maxBudgetItemsCount = 50;
  static const int maxTimelineItemsCount = 50;
  static const int maxNotificationsCount = 20;
  static const int maxSearchResultsCount = 50;
  static const int maxFilterOptionsCount = 10;
  static const int maxSortOptionsCount = 5;
  static const int maxComparisonItemsCount = 5;
  static const int maxComparisonFeaturesCount = 10;
  static const int maxComparisonPricingCount = 5;
  static const int maxComparisonRatingsCount = 5;
  static const int maxComparisonAmenitiesCount = 10;
  static const int maxComparisonServicesCount = 10;
  static const int maxComparisonPackagesCount = 5;
  static const int maxComparisonEquipmentCount = 10;
  static const int maxComparisonVenueTypesCount = 10;
  static const int maxComparisonCuisineTypesCount = 10;
  static const int maxComparisonStylesCount = 10;
  static const int maxComparisonSpecialtiesCount = 10;
  static const int maxComparisonFeaturesPerItemCount = 10;
  static const int maxComparisonPricingPerItemCount = 5;
  static const int maxComparisonRatingsPerItemCount = 5;
  static const int maxComparisonAmenitiesPerItemCount = 10;
  static const int maxComparisonServicesPerItemCount = 10;
  static const int maxComparisonPackagesPerItemCount = 5;
  static const int maxComparisonEquipmentPerItemCount = 10;
  static const int maxComparisonVenueTypesPerItemCount = 10;
  static const int maxComparisonCuisineTypesPerItemCount = 10;
  static const int maxComparisonStylesPerItemCount = 10;
  static const int maxComparisonSpecialtiesPerItemCount = 10;
}
