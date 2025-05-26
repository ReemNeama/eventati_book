import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';

import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';

import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:eventati_book/widgets/common/error_message.dart';
import 'package:eventati_book/widgets/services/card/service_card.dart';
import 'package:eventati_book/routing/routing.dart';

/// Screen to display all favorited services
class FavoritesScreen extends StatefulWidget {
  /// Constructor
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _error;
  List<Service> _favoriteServices = [];
  List<Service> _favoriteVenues = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load favorite services and venues
  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        setState(() {
          _error = 'You must be logged in to view favorites';
          _isLoading = false;
        });
        return;
      }

      // Get service database provider
      final serviceDatabaseProvider = Provider.of<ServiceDatabaseProvider>(
        context,
        listen: false,
      );

      // Load favorite services
      final List<Service> services = [];
      for (final serviceId in user.favoriteServices) {
        final service = await serviceDatabaseProvider.getService(serviceId);
        if (service != null) {
          services.add(service);
        }
      }

      // Load favorite venues
      final List<Service> venues = [];
      for (final venueId in user.favoriteVenues) {
        final venue = await serviceDatabaseProvider.getVenue(venueId);
        if (venue != null) {
          venues.add(venue);
        }
      }

      setState(() {
        _favoriteServices = services;
        _favoriteVenues = venues;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load favorites: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Remove a service from favorites
  Future<void> _removeServiceFromFavorites(String serviceId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.removeFavoriteService(serviceId);

      if (success) {
        setState(() {
          _favoriteServices.removeWhere((service) => service.id == serviceId);
        });
        if (mounted) {
          UIUtils.showSnackBar(context, 'Service removed from favorites');
        }
      } else {
        if (mounted) {
          UIUtils.showSnackBar(
            context,
            'Failed to remove service from favorites',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showSnackBar(context, 'Error: ${e.toString()}');
      }
    }
  }

  /// Remove a venue from favorites
  Future<void> _removeVenueFromFavorites(String venueId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.removeFavoriteVenue(venueId);

      if (success) {
        setState(() {
          _favoriteVenues.removeWhere((venue) => venue.id == venueId);
        });
        if (mounted) {
          UIUtils.showSnackBar(context, 'Venue removed from favorites');
        }
      } else {
        if (mounted) {
          UIUtils.showSnackBar(
            context,
            'Failed to remove venue from favorites',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showSnackBar(context, 'Error: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Services'), Tab(text: 'Venues')],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: LoadingIndicator())
              : _error != null
              ? Center(child: ErrorMessage(message: _error!))
              : TabBarView(
                controller: _tabController,
                children: [_buildServicesTab(), _buildVenuesTab()],
              ),
    );
  }

  /// Build the services tab
  Widget _buildServicesTab() {
    if (_favoriteServices.isEmpty) {
      return EmptyState.favorites(
        title: 'No favorite services',
        message: 'Services you mark as favorites will appear here',
        actionText: 'Browse Services',
        onAction: () {
          NavigationUtils.navigateToNamed(context, RouteNames.services);
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: _favoriteServices.length,
      itemBuilder: (context, index) {
        final service = _favoriteServices[index];
        return ServiceCard(
          name: service.name,
          description: service.description,
          rating: service.averageRating,
          imageUrl: service.imageUrls.isNotEmpty ? service.imageUrls.first : '',
          price: service.price,
          priceType:
              service.isPricePerHour ? PriceType.perHour : PriceType.perEvent,
          currency: service.currency,
          maxCapacity: service.maximumCapacity,
          tags: service.tags,
          isAvailable: service.isAvailable,
          isFeatured: service.isFeatured,
          isSaved: true,
          onSave: () => _removeServiceFromFavorites(service.id),
          onTap: () {
            // Navigate to service details based on service type
            NavigationUtils.navigateToNamed(
              context,
              RouteNames.venueDetails,
              arguments: VenueDetailsArguments(venueId: service.id),
            );
          },
        );
      },
    );
  }

  /// Build the venues tab
  Widget _buildVenuesTab() {
    if (_favoriteVenues.isEmpty) {
      return EmptyState.favorites(
        title: 'No favorite venues',
        message: 'Venues you mark as favorites will appear here',
        actionText: 'Browse Venues',
        onAction: () {
          NavigationUtils.navigateToNamed(context, RouteNames.venues);
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: _favoriteVenues.length,
      itemBuilder: (context, index) {
        final venue = _favoriteVenues[index];
        return ServiceCard(
          name: venue.name,
          description: venue.description,
          rating: venue.averageRating,
          imageUrl: venue.imageUrls.isNotEmpty ? venue.imageUrls.first : '',
          price: venue.price,
          priceType: PriceType.perEvent,
          currency: venue.currency,

          maxCapacity: venue.maximumCapacity,
          tags: venue.tags,
          isAvailable: venue.isAvailable,
          isFeatured: venue.isFeatured,
          isSaved: true,
          onSave: () => _removeVenueFromFavorites(venue.id),
          onTap: () {
            // Navigate to venue details
            NavigationUtils.navigateToNamed(
              context,
              RouteNames.venueDetails,
              arguments: VenueDetailsArguments(venueId: venue.id),
            );
          },
        );
      },
    );
  }
}
