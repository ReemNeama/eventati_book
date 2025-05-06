import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/widgets/milestones/milestone_card.dart';

/// A grid of milestones
class MilestoneGrid extends StatelessWidget {
  /// The milestones to display
  final List<Milestone> milestones;

  /// Callback when a milestone is tapped
  final Function(Milestone)? onMilestoneTap;

  /// Whether to show locked milestones
  final bool showLocked;

  const MilestoneGrid({
    super.key,
    required this.milestones,
    this.onMilestoneTap,
    this.showLocked = true,
  });

  /// Get filtered milestones based on showLocked setting
  List<Milestone> _getFilteredMilestones() {
    if (showLocked) {
      // If showLocked is true, return all milestones
      return milestones;
    } else {
      // If showLocked is false, filter out locked and hidden milestones
      return milestones
          .where((m) => m.status != MilestoneStatus.locked || !m.isHidden)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter milestones based on showLocked
    final filteredMilestones = _getFilteredMilestones();

    if (filteredMilestones.isEmpty) {
      return Center(
        child: Text(
          'No milestones available',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filteredMilestones.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final milestone = filteredMilestones[index];

        return MilestoneCard(
          milestone: milestone,
          onTap: () {
            // Use null-aware method invocation operator
            onMilestoneTap?.call(milestone);
          },
        );
      },
    );
  }
}
