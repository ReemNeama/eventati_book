import 'package:flutter/material.dart';
import 'package:eventati_book/screens/services/venue/venue_list_screen.dart';
import 'package:eventati_book/screens/services/catering/catering_list_screen.dart';
import 'package:eventati_book/screens/services/photographer/photographer_list_screen.dart';
import 'package:eventati_book/screens/services/planner/planner_list_screen.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/widgets/services/recently_viewed/recently_viewed_section.dart';

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
    final bool isDarkMode = UIUtils.isDarkMode(context);
    final Color primaryColor =
        isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: isDarkMode ? Colors.white : primaryColor,
          unselectedLabelColor:
              isDarkMode
                  ? Color.fromRGBO(
                    Colors.white.r.toInt(),
                    Colors.white.g.toInt(),
                    Colors.white.b.toInt(),
                    0.7,
                  )
                  : AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Venues'),
            Tab(text: 'Catering'),
            Tab(text: 'Photos'),
            Tab(text: 'Planners'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Recently viewed services section
          const RecentlyViewedSection(
            title: 'Recently Viewed Services',
            maxServices: 5,
            showSeeAllButton: true,
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                VenueListScreen(),
                CateringListScreen(),
                PhotographerListScreen(),
                PlannerListScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
