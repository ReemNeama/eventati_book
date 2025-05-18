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
import 'package:eventati_book/styles/text_styles.dart';

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
    final cardColor =
        isDarkMode
            ? Color.fromRGBO(
              AppColors.disabled.r.toInt(),
              AppColors.disabled.g.toInt(),
              AppColors.disabled.b.toInt(),
              0.8,
            )
            : Colors.white;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text('Planning Tools', style: TextStyles.title),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          color:
              isDarkMode
                  ? Color.fromRGBO(
                    AppColors.disabled.r.toInt(),
                    AppColors.disabled.g.toInt(),
                    AppColors.disabled.b.toInt(),
                    0.9,
                  )
                  : Color.fromRGBO(
                    AppColors.disabled.r.toInt(),
                    AppColors.disabled.g.toInt(),
                    AppColors.disabled.b.toInt(),
                    0.1,
                  ),
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
                    color: Color.fromRGBO(
                      Colors.black.r.toInt(),
                      Colors.black.g.toInt(),
                      Colors.black.b.toInt(),
                      0.10,
                    ), // 0.1 * 255 = 25.5 ≈ 26
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(eventName, style: TextStyles.subtitle),
                  const SizedBox(height: AppConstants.smallPadding),
                  Row(
                    children: [
                      Icon(
                        Icons.event,
                        size: 16,
                        color:
                            isDarkMode
                                ? Color.fromRGBO(
                                  AppColors.disabled.r.toInt(),
                                  AppColors.disabled.g.toInt(),
                                  AppColors.disabled.b.toInt(),
                                  0.4,
                                )
                                : Color.fromRGBO(
                                  AppColors.disabled.r.toInt(),
                                  AppColors.disabled.g.toInt(),
                                  AppColors.disabled.b.toInt(),
                                  0.6,
                                ),
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Text(
                        DateTimeUtils.formatDate(eventDate),
                        style: TextStyles.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.smallPadding / 2),
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        size: 16,
                        color:
                            isDarkMode
                                ? Color.fromRGBO(
                                  AppColors.disabled.r.toInt(),
                                  AppColors.disabled.g.toInt(),
                                  AppColors.disabled.b.toInt(),
                                  0.4,
                                )
                                : Color.fromRGBO(
                                  AppColors.disabled.r.toInt(),
                                  AppColors.disabled.g.toInt(),
                                  AppColors.disabled.b.toInt(),
                                  0.6,
                                ),
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Text(eventType, style: TextStyles.bodySmall),
                    ],
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                  LinearProgressIndicator(
                    value:
                        0.35, // This would be calculated based on completed tasks
                    backgroundColor:
                        isDarkMode
                            ? Color.fromRGBO(
                              AppColors.disabled.r.toInt(),
                              AppColors.disabled.g.toInt(),
                              AppColors.disabled.b.toInt(),
                              0.7,
                            )
                            : Color.fromRGBO(
                              AppColors.disabled.r.toInt(),
                              AppColors.disabled.g.toInt(),
                              AppColors.disabled.b.toInt(),
                              0.3,
                            ),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('35% Complete', style: TextStyles.bodySmall),
                      Text(
                        '${_getDaysUntil(eventDate)} days left',
                        style: TextStyles.bodySmall,
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
        'color': AppColors.success,
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
        'color': AppColors.primary,
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
        'color': AppColors.warning,
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
        'title': 'Task Dependencies',
        'icon': Icons.account_tree,
        'color': AppColors.info,
        'onTap': (BuildContext context) {
          NavigationUtils.navigateToNamed(
            context,
            RouteNames.taskDependency,
            arguments: TaskDependencyArguments(
              eventId: eventId,
              eventName: eventName,
            ),
          );
        },
      },
      {
        'title': 'Task Templates',
        'icon': Icons.library_books,
        'color': Colors.indigo,
        'onTap': (BuildContext context) {
          NavigationUtils.navigateToNamed(
            context,
            RouteNames.taskTemplates,
            arguments: TaskTemplatesArguments(
              eventId: eventId,
              eventType: eventType,
            ),
          );
        },
      },
      {
        'title': 'Vendor Communication',
        'icon': Icons.message,
        'color': AppColors.primary,
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
        'color': AppColors.ratingStarColor,
        'onTap': (BuildContext context) {
          NavigationUtils.navigateToNamed(
            context,
            RouteNames.personalizedRecommendations,
          );
        },
      },
      {
        'title': 'Vendor Recommendations',
        'icon': Icons.recommend,
        'color': Colors.deepOrange,
        'onTap': (BuildContext context) {
          NavigationUtils.navigateToNamed(
            context,
            RouteNames.vendorRecommendations,
            arguments: VendorRecommendationsArguments(
              eventId: eventId,
              eventName: eventName,
            ),
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
