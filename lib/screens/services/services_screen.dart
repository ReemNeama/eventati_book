import 'package:flutter/material.dart';
import 'package:eventati_book/screens/services/venue_list_screen.dart';
import 'package:eventati_book/screens/services/catering_list_screen.dart';
import 'package:eventati_book/screens/services/photographer_list_screen.dart';
import 'package:eventati_book/screens/services/planner_list_screen.dart';

/// Services screen that provides access to all service categories
/// (venues, catering, photographers, planners)
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.primaryColor,
          labelColor:
              theme.brightness == Brightness.dark
                  ? Colors
                      .white // Use white for dark mode
                  : theme.primaryColor, // Use primary color for light mode
          unselectedLabelColor:
              theme.brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54,
          tabs: const [
            Tab(text: 'Venues'),
            Tab(text: 'Catering'),
            Tab(text: 'Photos'),
            Tab(text: 'Planners'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          VenueListScreen(),
          CateringListScreen(),
          PhotographerListScreen(),
          PlannerListScreen(),
        ],
      ),
    );
  }
}
