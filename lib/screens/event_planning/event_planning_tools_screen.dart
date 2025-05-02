import 'package:flutter/material.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/screens/event_planning/budget/budget_overview_screen.dart';
import 'package:eventati_book/screens/event_planning/guest_list/guest_list_screen.dart';
import 'package:eventati_book/screens/event_planning/timeline/timeline_screen.dart';
import 'package:eventati_book/screens/event_planning/messaging/vendor_list_screen.dart';
import 'package:eventati_book/widgets/event_planning/tool_card.dart';

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

            // Planning tools grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(AppConstants.mediumPadding),
                mainAxisSpacing: AppConstants.mediumPadding,
                crossAxisSpacing: AppConstants.mediumPadding,
                children: [
                  ToolCard(
                    title: 'Budget Calculator',
                    icon: Icons.calculate,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BudgetOverviewScreen(
                                eventId: eventId,
                                eventName: eventName,
                              ),
                        ),
                      );
                    },
                  ),
                  ToolCard(
                    title: 'Guest List',
                    icon: Icons.people,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => GuestListScreen(
                                eventId: eventId,
                                eventName: eventName,
                              ),
                        ),
                      );
                    },
                  ),
                  ToolCard(
                    title: 'Timeline & Checklist',
                    icon: Icons.checklist,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => TimelineScreen(
                                eventId: eventId,
                                eventName: eventName,
                              ),
                        ),
                      );
                    },
                  ),
                  ToolCard(
                    title: 'Vendor Communication',
                    icon: Icons.message,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => VendorListScreen(
                                eventId: eventId,
                                eventName: eventName,
                              ),
                        ),
                      );
                    },
                  ),
                ],
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
}
