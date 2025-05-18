import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/navigation/breadcrumb_provider.dart';
import 'package:eventati_book/routing/route_names.dart';

/// Utility functions for breadcrumb navigation
class BreadcrumbUtils {
  /// Set the breadcrumb path for a specific route
  static void setBreadcrumbsForRoute(
    BuildContext context,
    String routeName,
    List<BreadcrumbItem> breadcrumbs,
  ) {
    // Get the breadcrumb provider
    final provider = Provider.of<BreadcrumbProvider>(context, listen: false);

    // Set the breadcrumbs
    provider.setBreadcrumbs(breadcrumbs);
  }

  /// Add a breadcrumb to the current path
  static void addBreadcrumb(
    BuildContext context,
    String label,
    String routeName, {
    Object? arguments,
  }) {
    // Get the breadcrumb provider
    final provider = Provider.of<BreadcrumbProvider>(context, listen: false);

    // Add the breadcrumb
    provider.addBreadcrumb(
      BreadcrumbItem(label: label, routeName: routeName, arguments: arguments),
    );
  }

  /// Clear the breadcrumb path
  static void clearBreadcrumbs(BuildContext context) {
    // Get the breadcrumb provider
    final provider = Provider.of<BreadcrumbProvider>(context, listen: false);

    // Clear the breadcrumbs
    provider.clearBreadcrumbs();
  }

  /// Get a standard breadcrumb path for a service detail screen
  static List<BreadcrumbItem> getServiceDetailBreadcrumbs(
    String serviceType,
    String serviceId,
    String serviceName,
  ) {
    return [
      const BreadcrumbItem(label: 'Home', routeName: RouteNames.home),
      const BreadcrumbItem(label: 'Services', routeName: RouteNames.services),
      BreadcrumbItem(
        label: serviceType,
        routeName: _getServiceListRouteForType(serviceType),
      ),
      BreadcrumbItem(
        label: serviceName,
        routeName: _getServiceDetailRouteForType(serviceType),
        arguments: {'id': serviceId},
      ),
    ];
  }

  /// Get a standard breadcrumb path for an event planning tool
  static List<BreadcrumbItem> getEventPlanningToolBreadcrumbs(
    String eventId,
    String eventName,
    String toolName,
    String toolRouteName,
  ) {
    return [
      const BreadcrumbItem(label: 'Home', routeName: RouteNames.home),
      const BreadcrumbItem(
        label: 'My Events',
        routeName: RouteNames.userEvents,
      ),
      BreadcrumbItem(
        label: eventName,
        routeName: RouteNames.eventDetails,
        arguments: {'id': eventId},
      ),
      BreadcrumbItem(
        label: toolName,
        routeName: toolRouteName,
        arguments: {'eventId': eventId},
      ),
    ];
  }

  /// Helper method to get the route name for a service list based on type
  static String _getServiceListRouteForType(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'venues':
        return RouteNames.venueList;
      case 'catering':
        return RouteNames.cateringList;
      case 'photography':
        return RouteNames.photographerList;
      case 'planners':
        return RouteNames.plannerList;
      default:
        return RouteNames.services;
    }
  }

  /// Helper method to get the route name for a service detail based on type
  static String _getServiceDetailRouteForType(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'venues':
        return RouteNames.venueDetails;
      case 'catering':
        return RouteNames.cateringDetails;
      case 'photography':
        return RouteNames.photographerDetails;
      case 'planners':
        return RouteNames.plannerDetails;
      default:
        return RouteNames.services;
    }
  }
}
