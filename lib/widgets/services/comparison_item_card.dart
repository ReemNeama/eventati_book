import 'package:flutter/material.dart';
import 'package:eventati_book/models/venue.dart';
import 'package:eventati_book/models/catering_service.dart';
import 'package:eventati_book/models/photographer.dart';
import 'package:eventati_book/models/planner.dart';
import 'package:eventati_book/screens/services/venue_details_screen.dart';
import 'package:eventati_book/screens/services/catering_details_screen.dart';
import 'package:eventati_book/screens/services/photographer_details_screen.dart';
import 'package:eventati_book/screens/services/planner_details_screen.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';

/// Card widget for displaying a service in the comparison view
class ComparisonItemCard extends StatelessWidget {
  /// The service to display
  final dynamic service;

  /// The type of service (Venue, Catering, Photographer, Planner)
  final String serviceType;

  /// Whether this service is highlighted as the best option
  final bool isHighlighted;

  /// Constructor
  const ComparisonItemCard({
    super.key,
    required this.service,
    required this.serviceType,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final backgroundColor = isDarkMode ? Colors.grey[800] : Colors.grey[300];
    final iconColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    // Get service details based on service type
    String name = '';
    double rating = 0;
    String price = '';

    if (serviceType == 'Venue' && service is Venue) {
      name = service.name;
      rating = service.rating;
      price = '\$${service.pricePerEvent.toStringAsFixed(2)}';
    } else if (serviceType == 'Catering' && service is CateringService) {
      name = service.name;
      rating = service.rating;
      price = '\$${service.pricePerPerson.toStringAsFixed(2)} per person';
    } else if (serviceType == 'Photographer' && service is Photographer) {
      name = service.name;
      rating = service.rating;
      price = '\$${service.pricePerEvent.toStringAsFixed(2)}';
    } else if (serviceType == 'Planner' && service is Planner) {
      name = service.name;
      rating = service.rating;
      price = '\$${service.pricePerEvent.toStringAsFixed(2)}';
    }

    return Card(
      elevation: AppConstants.mediumElevation,
      margin: const EdgeInsets.all(AppConstants.smallPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius),
        side:
            isHighlighted
                ? BorderSide(color: primaryColor, width: 2)
                : BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppConstants.mediumBorderRadius),
              topRight: Radius.circular(AppConstants.mediumBorderRadius),
            ),
            child: Container(
              height: 120,
              width: double.infinity,
              color: backgroundColor,
              child: Center(
                child: Icon(Icons.image, size: 40, color: iconColor),
              ),
            ),
          ),

          // Service details
          Padding(
            padding: const EdgeInsets.all(AppConstants.mediumPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppConstants.smallPadding),

                // Rating
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: AppColors.ratingStarColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ServiceUtils.formatRating(rating),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.smallPadding),

                // Price
                Text(
                  price,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // View details button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to service details screen
                      _navigateToDetailsScreen(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.smallPadding,
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
                ),

                // Highlight badge if this is the best option
                if (isHighlighted) ...[
                  const SizedBox(height: AppConstants.smallPadding),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.smallPadding,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(
                        AppConstants.smallBorderRadius,
                      ),
                    ),
                    child: const Text(
                      'Best Option',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Navigate to the appropriate details screen based on service type
  void _navigateToDetailsScreen(BuildContext context) {
    if (serviceType == 'Venue' && service is Venue) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VenueDetailsScreen(venue: service),
        ),
      );
    } else if (serviceType == 'Catering' && service is CateringService) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CateringDetailsScreen(cateringService: service),
        ),
      );
    } else if (serviceType == 'Photographer' && service is Photographer) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => PhotographerDetailsScreen(photographer: service),
        ),
      );
    } else if (serviceType == 'Planner' && service is Planner) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlannerDetailsScreen(planner: service),
        ),
      );
    }
  }
}
