import 'package:flutter/material.dart';
import 'package:eventati_book/screens/homepage/homepage_screen.dart';
import 'package:eventati_book/screens/services/services_screen.dart';
import 'package:eventati_book/screens/events/user_events_screen.dart';
import 'package:eventati_book/screens/profile/profile_screen.dart';

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
      ProfileScreen(toggleTheme: widget.toggleTheme),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
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
