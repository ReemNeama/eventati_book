import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/milestones/milestone_grid.dart';
import 'package:eventati_book/widgets/milestones/milestone_detail_dialog.dart';
import 'package:eventati_book/widgets/milestones/milestone_celebration_overlay.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// A screen to display all milestones
class MilestoneScreen extends StatefulWidget {
  /// The event ID
  final String eventId;

  const MilestoneScreen({super.key, required this.eventId});

  @override
  State<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends State<MilestoneScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
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

    return Consumer<MilestoneProvider>(
      builder: (context, milestoneProvider, _) {
        if (milestoneProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Check for newly completed milestones
        final newlyCompleted = milestoneProvider.newlyCompletedMilestones;
        if (newlyCompleted.isNotEmpty) {
          // Show celebration overlay for the first newly completed milestone
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showMilestoneCelebration(
              context,
              newlyCompleted.first,
              milestoneProvider,
            );
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Milestones & Achievements'),
            backgroundColor: primaryColor,
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Planning'),
                Tab(text: 'Budget'),
                Tab(text: 'Guests'),
                Tab(text: 'Services'),
                Tab(text: 'Timeline'),
              ],
            ),
          ),
          body: Column(
            children: [
              // Points summary
              Container(
                padding: const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    // Total points
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Points', style: TextStyles.bodyMedium),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star, color: primaryColor, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                '${milestoneProvider.totalPoints}',
                                style: TextStyles.subtitle,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Completion progress
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Milestones Completed',
                            style: TextStyles.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${milestoneProvider.completedMilestones.length} / ${milestoneProvider.milestones.length}',
                            style: TextStyles.subtitle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Milestone tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // All milestones
                    MilestoneGrid(
                      milestones: milestoneProvider.milestones,
                      onMilestoneTap:
                          (milestone) =>
                              _showMilestoneDetails(context, milestone),
                    ),

                    // Planning milestones
                    MilestoneGrid(
                      milestones: milestoneProvider.getMilestonesByCategory(
                        MilestoneCategory.planning,
                      ),
                      onMilestoneTap:
                          (milestone) =>
                              _showMilestoneDetails(context, milestone),
                    ),

                    // Budget milestones
                    MilestoneGrid(
                      milestones: milestoneProvider.getMilestonesByCategory(
                        MilestoneCategory.budget,
                      ),
                      onMilestoneTap:
                          (milestone) =>
                              _showMilestoneDetails(context, milestone),
                    ),

                    // Guest milestones
                    MilestoneGrid(
                      milestones: milestoneProvider.getMilestonesByCategory(
                        MilestoneCategory.guests,
                      ),
                      onMilestoneTap:
                          (milestone) =>
                              _showMilestoneDetails(context, milestone),
                    ),

                    // Services milestones
                    MilestoneGrid(
                      milestones: milestoneProvider.getMilestonesByCategory(
                        MilestoneCategory.services,
                      ),
                      onMilestoneTap:
                          (milestone) =>
                              _showMilestoneDetails(context, milestone),
                    ),

                    // Timeline milestones
                    MilestoneGrid(
                      milestones: milestoneProvider.getMilestonesByCategory(
                        MilestoneCategory.timeline,
                      ),
                      onMilestoneTap:
                          (milestone) =>
                              _showMilestoneDetails(context, milestone),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Show milestone details dialog
  void _showMilestoneDetails(BuildContext context, Milestone milestone) {
    showDialog(
      context: context,
      builder: (context) => MilestoneDetailDialog(milestone: milestone),
    );
  }

  /// Show milestone celebration overlay
  void _showMilestoneCelebration(
    BuildContext context,
    Milestone milestone,
    MilestoneProvider provider,
  ) {
    // Show the celebration overlay
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return MilestoneCelebrationOverlay(
          milestone: milestone,
          onDismiss: () {
            // Acknowledge the milestone and dismiss the overlay
            provider.acknowledgeNewlyCompletedMilestone(milestone.id);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
