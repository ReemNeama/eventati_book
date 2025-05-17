import 'package:flutter/material.dart';
import 'package:eventati_book/screens/homepage/homepage_screen.dart';
import 'package:eventati_book/screens/services/common/services_screen.dart';
import 'package:eventati_book/screens/events/user_events_screen.dart';
import 'package:eventati_book/screens/profile/profile_screen.dart';
import 'package:eventati_book/screens/event_wizard/suggestion_screen.dart';
import 'package:eventati_book/screens/booking/booking_history_screen.dart';
import 'package:eventati_book/widgets/notification/notification_badge.dart';
import 'package:eventati_book/routing/route_names.dart';

/// Main navigation screen that hosts the bottom navigation bar
/// and manages switching between the main app sections
class MainNavigationScreen extends StatefulWidget {
  final Function toggleTheme;

  const MainNavigationScreen({super.key, required this.toggleTheme});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomepageScreen(),
      const ServicesScreen(),
      const UserEventsScreen(),
      const BookingHistoryScreen(),
      const SuggestionScreen(),
      ProfileScreen(toggleTheme: widget.toggleTheme),
    ];
  }

  /// Get the app bar title based on the current index
  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Services';
      case 2:
        return 'My Events';
      case 3:
        return 'Bookings';
      case 4:
        return 'Suggestions';
      default:
        return 'Eventati Book';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar:
          _currentIndex != 5
              ? AppBar(
                title: Text(_getAppBarTitle()),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      Navigator.pushNamed(context, RouteNames.globalSearch);
                    },
                    tooltip: 'Global Search',
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, RouteNames.notifications);
                    },
                    child: const NotificationBadge(),
                  ),
                  const SizedBox(width: 16),
                ],
              )
              : null,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x19000000), // Colors.black.withAlpha(25)
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          selectedItemColor: theme.primaryColor,
          unselectedItemColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Services',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined),
              activeIcon: Icon(Icons.event),
              label: 'My Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outline),
              activeIcon: Icon(Icons.lightbulb),
              label: 'Suggestions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
