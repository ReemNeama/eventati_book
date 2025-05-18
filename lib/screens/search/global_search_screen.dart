import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/routing/routing.dart';
import 'package:eventati_book/services/search/search_service.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:eventati_book/widgets/search/search_result_card.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// A screen for global search across all features
class GlobalSearchScreen extends StatefulWidget {
  final String? initialQuery;
  final String? initialCategory;

  const GlobalSearchScreen({
    super.key,
    this.initialQuery,
    this.initialCategory,
  });

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late TabController _tabController;
  late SearchService _searchService;
  String _currentQuery = '';
  bool _isSearching = false;

  // Search results
  List<Event> _eventResults = [];
  List<Service> _serviceResults = [];
  List<Task> _taskResults = [];
  List<BudgetItem> _budgetResults = [];
  List<Guest> _guestResults = [];
  List<Booking> _bookingResults = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _tabController = TabController(length: 6, vsync: this);
    _searchService = SearchService();

    // Set initial category tab if provided
    if (widget.initialCategory != null) {
      _setInitialTab(widget.initialCategory!);
    }

    // Perform initial search if query is provided
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _currentQuery = widget.initialQuery!;
      _performSearch();
    }
  }

  void _setInitialTab(String category) {
    switch (category.toLowerCase()) {
      case 'events':
        _tabController.index = 0;
        break;
      case 'services':
        _tabController.index = 1;
        break;
      case 'tasks':
        _tabController.index = 2;
        break;
      case 'budget':
        _tabController.index = 3;
        break;
      case 'guests':
        _tabController.index = 4;
        break;
      case 'bookings':
        _tabController.index = 5;
        break;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_currentQuery.isEmpty) {
      setState(() {
        _eventResults = [];
        _serviceResults = [];
        _taskResults = [];
        _budgetResults = [];
        _guestResults = [];
        _bookingResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.uid;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final results = await _searchService.search(_currentQuery, userId);

      setState(() {
        _eventResults = results.events;
        _serviceResults = results.services;
        _taskResults = results.tasks;
        _budgetResults = results.budgetItems;
        _guestResults = results.guests;
        _bookingResults = results.bookings;
        _isSearching = false;
      });

      // Log search event
      AnalyticsUtils.logSearch(searchTerm: _currentQuery);
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      Logger.e('Search error: $e', tag: 'GlobalSearchScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = UIUtils.isDarkMode(context);
    final Color primaryColor =
        isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final Color textPrimary =
        isDarkMode ? AppColorsDark.textPrimary : AppColors.textPrimary;
    final Color textSecondary =
        isDarkMode ? AppColorsDark.textSecondary : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search across all features...',
            hintStyle: TextStyle(color: textSecondary.withAlpha(179)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
          style: TextStyle(color: textPrimary),
          onSubmitted: (value) {
            setState(() {
              _currentQuery = value.trim();
            });
            _performSearch();
          },
          textInputAction: TextInputAction.search,
          autofocus: _currentQuery.isEmpty,
        ),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _currentQuery = '';
              });
              _performSearch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _currentQuery = _searchController.text.trim();
              });
              _performSearch();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Events'),
            Tab(text: 'Services'),
            Tab(text: 'Tasks'),
            Tab(text: 'Budget'),
            Tab(text: 'Guests'),
            Tab(text: 'Bookings'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Color.fromRGBO(Colors.white.r.toInt(), Colors.white.g.toInt(), Colors.white.b.toInt(), 0.7),
        ),
      ),
      body:
          _isSearching
              ? const Center(child: LoadingIndicator())
              : _currentQuery.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      size: 80,
                      color: textSecondary.withAlpha(128),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Search across all features',
                      style: TextStyle(fontSize: 18, color: textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter a search term to find events, services, tasks, and more',
                      style: TextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildEventResults(),
                  _buildServiceResults(),
                  _buildTaskResults(),
                  _buildBudgetResults(),
                  _buildGuestResults(),
                  _buildBookingResults(),
                ],
              ),
    );
  }

  Widget _buildEventResults() {
    return _buildResultsList(
      _eventResults,
      'events',
      (event) => SearchResultCard.event(
        event: event,
        onTap: () => _navigateToEventDetails(event.id),
      ),
    );
  }

  Widget _buildServiceResults() {
    return _buildResultsList(
      _serviceResults,
      'services',
      (service) => SearchResultCard.service(
        service: service,
        onTap: () => _navigateToServiceDetails(service),
      ),
    );
  }

  Widget _buildTaskResults() {
    return _buildResultsList(
      _taskResults,
      'tasks',
      (task) => SearchResultCard.task(
        task: task,
        onTap: () => _navigateToTaskDetails(task),
      ),
    );
  }

  Widget _buildBudgetResults() {
    return _buildResultsList(
      _budgetResults,
      'budget items',
      (budgetItem) => SearchResultCard.budgetItem(
        budgetItem: budgetItem,
        onTap: () => _navigateToBudgetDetails(budgetItem),
      ),
    );
  }

  Widget _buildGuestResults() {
    return _buildResultsList(
      _guestResults,
      'guests',
      (guest) => SearchResultCard.guest(
        guest: guest,
        onTap: () => _navigateToGuestDetails(guest),
      ),
    );
  }

  Widget _buildBookingResults() {
    return _buildResultsList(
      _bookingResults,
      'bookings',
      (booking) => SearchResultCard.booking(
        booking: booking,
        onTap: () => _navigateToBookingDetails(booking.id),
      ),
    );
  }

  Widget _buildResultsList<T>(
    List<T> results,
    String itemType,
    Widget Function(T) itemBuilder,
  ) {
    if (results.isEmpty) {
      return Center(
        child: EmptyState.search(
          title: 'No $itemType found',
          message: 'Try a different search term or category',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return itemBuilder(item);
      },
    );
  }

  void _navigateToEventDetails(String eventId) {
    NavigationUtils.navigateToNamed(
      context,
      RouteNames.eventDetails,
      arguments: EventDetailsArguments(eventId: eventId),
    );
  }

  void _navigateToServiceDetails(Service service) {
    // Determine service type from categoryId
    // This is a simplified approach - in a real app, you would have a proper mapping
    String serviceType = '';

    // In a real app, you would get the service type from a category service or similar
    if (service.categoryId.contains('venue')) {
      serviceType = 'venue';
    } else if (service.categoryId.contains('catering')) {
      serviceType = 'catering';
    } else if (service.categoryId.contains('photo')) {
      serviceType = 'photography';
    } else if (service.categoryId.contains('planner')) {
      serviceType = 'planner';
    }

    // Navigate based on service type
    switch (serviceType) {
      case 'venue':
        NavigationUtils.navigateToNamed(
          context,
          RouteNames.venueDetails,
          arguments: VenueDetailsArguments(venueId: service.id),
        );
        break;
      case 'catering':
        NavigationUtils.navigateToNamed(
          context,
          RouteNames.cateringDetails,
          arguments: CateringDetailsArguments(cateringId: service.id),
        );
        break;
      case 'photography':
        NavigationUtils.navigateToNamed(
          context,
          RouteNames.photographerDetails,
          arguments: PhotographerDetailsArguments(photographerId: service.id),
        );
        break;
      case 'planner':
        NavigationUtils.navigateToNamed(
          context,
          RouteNames.plannerDetails,
          arguments: PlannerDetailsArguments(plannerId: service.id),
        );
        break;
      default:
        // Default to services screen
        NavigationUtils.navigateToNamed(context, RouteNames.services);
        break;
    }
  }

  void _navigateToTaskDetails(Task task) {
    // In a real app, you would get the eventId from the task
    // For now, we'll use a default value
    final String eventId = task.eventId ?? 'default_event_id';

    NavigationUtils.navigateToNamed(
      context,
      RouteNames.timeline,
      arguments: TimelineArguments(
        eventId: eventId,
        eventName: 'Event', // This will be replaced with actual event name
      ),
    );
  }

  void _navigateToBudgetDetails(BudgetItem budgetItem) {
    // In a real app, you would get the eventId from the budget item
    // For now, we'll use a default value or extract it from another property
    const String eventId = 'default_event_id';

    NavigationUtils.navigateToNamed(
      context,
      RouteNames.budgetOverview,
      arguments: const BudgetOverviewArguments(eventId: eventId),
    );
  }

  void _navigateToGuestDetails(Guest guest) {
    // In a real app, you would get the eventId from the guest
    // For now, we'll use a default value or extract it from another property
    const String eventId = 'default_event_id';

    NavigationUtils.navigateToNamed(
      context,
      RouteNames.guestList,
      arguments: const GuestListArguments(
        eventId: eventId,
        eventName: 'Event', // This will be replaced with actual event name
      ),
    );
  }

  void _navigateToBookingDetails(String bookingId) {
    NavigationUtils.navigateToNamed(
      context,
      RouteNames.bookingDetails,
      arguments: BookingDetailsArguments(bookingId: bookingId),
    );
  }
}
