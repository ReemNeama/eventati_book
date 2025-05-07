import 'package:flutter/material.dart';

// Import utilities using barrel file
import 'package:eventati_book/utils/utils.dart';

// Import styles
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';

// Import routing
import 'package:eventati_book/routing/routing.dart';

// Import widgets using barrel file
import 'package:eventati_book/widgets/widgets.dart';

class EventPlanningToolsScreen extends StatelessWidget {
  final String eventId;
  final String eventName;
  final String eventType;
  final DateTime eventDate;

  const EventPlanningToolsScreen({
    super.key,
    required this.eventId,
    required this.eventName,
    required this.eventType,
    required this.eventDate,
  });

  @override
  Widget build(BuildContext context) {
    // Wrap the screen with RouteGuardWrapper to apply route guards
    return RouteGuardWrapper(
      // Require authentication
      authGuard: true,
      // Require onboarding completion
      onboardingGuard: true,
      // Require an active event
      eventGuard: true,
      child: _buildScreen(context),
    );
  }

  Widget _buildScreen(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Planning Tools',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppConstants.largeBorderRadius * 2),
            topRight: Radius.circular(AppConstants.largeBorderRadius * 2),
          ),
        ),
        child: Column(
          children: [
            // Event info card
            Container(
              margin: const EdgeInsets.all(AppConstants.mediumPadding),
              padding: const EdgeInsets.all(AppConstants.mediumPadding),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(
                  AppConstants.largeBorderRadius,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26), // 0.1 * 255 = 25.5 ≈ 26
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Row(
                    children: [
                      Icon(
                        Icons.event,
                        size: 16,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Text(
                        DateTimeUtils.formatDate(eventDate),
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.smallPadding / 2),
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        size: 16,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Text(
                        eventType,
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                  LinearProgressIndicator(
                    value:
                        0.35, // This would be calculated based on completed tasks
                    backgroundColor:
                        isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '35% Complete',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${_getDaysUntil(eventDate)} days left',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Planning tools grid - responsive
            Expanded(
              child: OrientationResponsiveBuilder(
                portraitBuilder: (context, constraints) {
                  // Portrait mode: 2 columns for phones, 3 for tablets
                  return _buildToolsGrid(
                    context,
                    UIUtils.isTablet(context) ? 3 : 2,
                  );
                },
                landscapeBuilder: (context, constraints) {
                  // Landscape mode: 3 columns for phones, 4 for tablets
                  return _buildToolsGrid(
                    context,
                    UIUtils.isTablet(context) ? 4 : 3,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getDaysUntil(DateTime date) {
    final now = DateTime.now();

    return date.difference(now).inDays;
  }

  Widget _buildToolsGrid(BuildContext context, int crossAxisCount) {
    final List<Map<String, dynamic>> tools = [
      {
        'title': 'Budget Calculator',
        'icon': Icons.calculate,
        'color': Colors.green,
        'onTap': (BuildContext context) {
          NavigationUtils.navigateToNamed(
            context,
            RouteNames.budget,
            arguments: BudgetArguments(eventId: eventId, eventName: eventName),
          );
        },
      },
      {
        'title': 'Guest List',
        'icon': Icons.people,
        'color': Colors.blue,
        'onTap': (BuildContext context) {
          NavigationUtils.navigateToNamed(
            context,
            RouteNames.guestList,
            arguments: GuestListArguments(
              eventId: eventId,
              eventName: eventName,
            ),
          );
        },
      },
      {
        'title': 'Timeline & Checklist',
        'icon': Icons.checklist,
        'color': Colors.orange,
        'onTap': (BuildContext context) {
          NavigationUtils.navigateToNamed(
            context,
            RouteNames.timeline,
            arguments: TimelineArguments(
              eventId: eventId,
              eventName: eventName,
            ),
          );
        },
      },
      {
        'title': 'Vendor Communication',
        'icon': Icons.message,
        'color': Colors.purple,
        'onTap': (BuildContext context) {
          NavigationUtils.navigateToNamed(
            context,
            RouteNames.vendorCommunication,
            arguments: VendorCommunicationArguments(
              eventId: eventId,
              eventName: eventName,
            ),
          );
        },
      },
      {
        'title': 'Personalized Recommendations',
        'icon': Icons.lightbulb,
        'color': Colors.amber,
        'onTap': (BuildContext context) {
          NavigationUtils.navigateToNamed(
            context,
            RouteNames.personalizedRecommendations,
          );
        },
      },
    ];

    // Use ResponsiveGridView for more flexibility
    return ResponsiveGridView(
      minItemWidth: 150, // Minimum width for each tool card
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      crossAxisSpacing: AppConstants.mediumPadding,
      mainAxisSpacing: AppConstants.mediumPadding,
      children:
          tools.map((tool) {
            return ToolCard(
              title: tool['title'],
              icon: tool['icon'],
              color: tool['color'],
              onTap: () => tool['onTap'](context),
            );
          }).toList(),
    );
  }
}
