import 'package:flutter/material.dart';
import 'package:eventati_book/screens/events/user_events_screen.dart';
import 'package:eventati_book/screens/booking/booking_history_screen.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/ui/ui_utils.dart';

/// A screen that combines user events and bookings into a single screen with tabs
class CombinedEventsScreen extends StatefulWidget {
  /// Constructor
  const CombinedEventsScreen({super.key});

  @override
  State<CombinedEventsScreen> createState() => _CombinedEventsScreenState();
}

class _CombinedEventsScreenState extends State<CombinedEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
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
          tabs: const [Tab(text: 'Events'), Tab(text: 'Bookings')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          UserEventsScreen(showAppBar: false),
          BookingHistoryScreen(showAppBar: false),
        ],
      ),
    );
  }
}
