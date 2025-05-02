import 'package:flutter/material.dart';
import 'package:eventati_book/models/milestone.dart';

/// Predefined milestone templates
class MilestoneTemplates {
  /// Get all predefined milestones
  static List<Milestone> getAllMilestones() {
    return [
      ...getWeddingMilestones(),
      ...getBusinessEventMilestones(),
      ...getCelebrationMilestones(),
      ...getCommonMilestones(),
    ];
  }

  /// Get milestones for a specific event type
  static List<Milestone> getMilestonesForEventType(String eventType) {
    final commonMilestones = getCommonMilestones();

    switch (eventType) {
      case 'wedding':
        return [...commonMilestones, ...getWeddingMilestones()];
      case 'business':
        return [...commonMilestones, ...getBusinessEventMilestones()];
      case 'celebration':
        return [...commonMilestones, ...getCelebrationMilestones()];
      default:
        return commonMilestones;
    }
  }

  /// Get common milestones applicable to all event types
  static List<Milestone> getCommonMilestones() {
    return [
      // Getting Started
      Milestone(
        id: 'event_planner',
        title: 'Event Planner',
        description: 'Start planning your first event',
        category: MilestoneCategory.planning,
        icon: Icons.celebration,
        points: 10,
        applicableEventTypes: ['all'],
        criteria: const MilestoneCriteria(
          completionConditions: [
            MilestoneCondition(
              field: 'eventName',
              operator: MilestoneConditionOperator.isNotNull,
            ),
            MilestoneCondition(
              field: 'eventName',
              operator: MilestoneConditionOperator.notEquals,
              value: '',
            ),
          ],
        ),
        rewardText: 'You\'ve taken the first step in planning your event!',
      ),

      // Complete Wizard
      Milestone(
        id: 'planning_complete',
        title: 'Planning Complete',
        description: 'Complete all steps in the event wizard',
        category: MilestoneCategory.planning,
        icon: Icons.check_circle,
        points: 25,
        applicableEventTypes: ['all'],
        criteria: const MilestoneCriteria(
          completionConditions: [
            MilestoneCondition(
              field: 'isCompleted',
              operator: MilestoneConditionOperator.isTrue,
            ),
          ],
        ),
        rewardText:
            'Congratulations! You\'ve completed the event planning wizard!',
      ),

      // Date Setter
      Milestone(
        id: 'date_setter',
        title: 'Date Setter',
        description: 'Set a date for your event',
        category: MilestoneCategory.planning,
        icon: Icons.calendar_today,
        points: 15,
        applicableEventTypes: ['all'],
        criteria: const MilestoneCriteria(
          completionConditions: [
            MilestoneCondition(
              field: 'eventDate',
              operator: MilestoneConditionOperator.isNotNull,
            ),
          ],
        ),
        rewardText: 'You\'ve set a date for your event! Mark your calendar!',
      ),

      // Guest List Creator
      Milestone(
        id: 'guest_list_creator',
        title: 'Guest List Creator',
        description: 'Set the number of guests for your event',
        category: MilestoneCategory.guests,
        icon: Icons.people,
        points: 15,
        applicableEventTypes: ['all'],
        criteria: const MilestoneCriteria(
          completionConditions: [
            MilestoneCondition(
              field: 'guestCount',
              operator: MilestoneConditionOperator.isNotNull,
            ),
            MilestoneCondition(
              field: 'guestCount',
              operator: MilestoneConditionOperator.greaterThan,
              value: 0,
            ),
          ],
        ),
        rewardText:
            'You\'ve started your guest list! Who else should you invite?',
      ),

      // Service Selector
      Milestone(
        id: 'service_selector',
        title: 'Service Selector',
        description: 'Select at least one service for your event',
        category: MilestoneCategory.services,
        icon: Icons.room_service,
        points: 15,
        applicableEventTypes: ['all'],
        criteria: const MilestoneCriteria(
          completionConditions: [
            MilestoneCondition(
              field: 'selectedServices',
              operator: MilestoneConditionOperator.contains,
              value: true,
            ),
          ],
        ),
        rewardText: 'You\'ve selected your first service! Great choice!',
      ),

      // Service Expert
      Milestone(
        id: 'service_expert',
        title: 'Service Expert',
        description: 'Select at least 5 services for your event',
        category: MilestoneCategory.services,
        icon: Icons.star,
        points: 25,
        applicableEventTypes: ['all'],
        criteria: const MilestoneCriteria(
          unlockConditions: [
            MilestoneCondition(
              field: 'selectedServices',
              operator: MilestoneConditionOperator.contains,
              value: true,
            ),
          ],
          completionConditions: [
            MilestoneCondition(
              field: 'selectedServices',
              operator: MilestoneConditionOperator.contains,
              value: 'FIVE_OR_MORE_SERVICES',
            ),
          ],
        ),
        rewardText:
            'You\'re a service expert! Your event is going to be amazing!',
      ),
    ];
  }

  /// Get wedding-specific milestones
  static List<Milestone> getWeddingMilestones() {
    return [
      // Wedding Planner
      Milestone(
        id: 'wedding_planner',
        title: 'Wedding Planner',
        description: 'Start planning your wedding',
        category: MilestoneCategory.planning,
        icon: Icons.favorite,
        points: 20,
        applicableEventTypes: ['wedding'],
        criteria: const MilestoneCriteria(
          completionConditions: [
            MilestoneCondition(
              field: 'templateId',
              operator: MilestoneConditionOperator.equals,
              value: 'wedding',
            ),
            MilestoneCondition(
              field: 'currentStep',
              operator: MilestoneConditionOperator.greaterThan,
              value: 0,
            ),
          ],
        ),
        rewardText:
            'You\'ve started planning your wedding! Exciting times ahead!',
      ),

      // Venue Selector
      Milestone(
        id: 'wedding_venue',
        title: 'Venue Selector',
        description: 'Select a venue for your wedding',
        category: MilestoneCategory.services,
        icon: Icons.location_on,
        points: 20,
        applicableEventTypes: ['wedding'],
        criteria: const MilestoneCriteria(
          completionConditions: [
            MilestoneCondition(
              field: 'templateId',
              operator: MilestoneConditionOperator.equals,
              value: 'wedding',
            ),
            MilestoneCondition(
              field: 'selectedServices',
              operator: MilestoneConditionOperator.contains,
              value: 'Venue',
            ),
          ],
        ),
        rewardText:
            'You\'ve selected a venue for your wedding! A perfect place to say "I do"!',
      ),

      // Catering Connoisseur
      Milestone(
        id: 'wedding_catering',
        title: 'Catering Connoisseur',
        description: 'Select catering for your wedding',
        category: MilestoneCategory.services,
        icon: Icons.restaurant,
        points: 15,
        applicableEventTypes: ['wedding'],
        criteria: const MilestoneCriteria(
          completionConditions: [
            MilestoneCondition(
              field: 'templateId',
              operator: MilestoneConditionOperator.equals,
              value: 'wedding',
            ),
            MilestoneCondition(
              field: 'selectedServices',
              operator: MilestoneConditionOperator.contains,
              value: 'Catering',
            ),
          ],
        ),
        rewardText:
            'You\'ve selected catering for your wedding! Your guests will be delighted!',
      ),

      // Memory Maker
      Milestone(
        id: 'wedding_photography',
        title: 'Memory Maker',
        description: 'Select photography/videography for your wedding',
        category: MilestoneCategory.services,
        icon: Icons.camera_alt,
        points: 15,
        applicableEventTypes: ['wedding'],
        criteria: const MilestoneCriteria(
          completionConditions: [
            MilestoneCondition(
              field: 'templateId',
              operator: MilestoneConditionOperator.equals,
              value: 'wedding',
            ),
            MilestoneCondition(
              field: 'selectedServices',
              operator: MilestoneConditionOperator.contains,
              value: 'Photography/Videography',
            ),
          ],
        ),
        rewardText:
            'You\'ve selected photography for your wedding! Capturing memories that last a lifetime!',
      ),
    ];
  }

  /// Get business event-specific milestones
  static List<Milestone> getBusinessEventMilestones() {
    return [
      // Business Event Planner
      Milestone(
        id: 'business_planner',
        title: 'Business Event Planner',
        description: 'Start planning your business event',
        category: MilestoneCategory.planning,
        icon: Icons.business,
        points: 20,
        applicableEventTypes: ['business'],
        criteria: const MilestoneCriteria(
          completionConditions: [
            MilestoneCondition(
              field: 'templateId',
              operator: MilestoneConditionOperator.equals,
              value: 'business',
            ),
            MilestoneCondition(
              field: 'currentStep',
              operator: MilestoneConditionOperator.greaterThan,
              value: 0,
            ),
          ],
        ),
        rewardText:
            'You\'ve started planning your business event! Professional and organized!',
      ),

      // Schedule Master
      Milestone(
        id: 'business_schedule',
        title: 'Schedule Master',
        description: 'Set the duration and times for your business event',
        category: MilestoneCategory.planning,
        icon: Icons.schedule,
        points: 15,
        applicableEventTypes: ['business'],
        criteria: const MilestoneCriteria(
          completionConditions: [
            MilestoneCondition(
              field: 'templateId',
              operator: MilestoneConditionOperator.equals,
              value: 'business',
            ),
            MilestoneCondition(
              field: 'eventDuration',
              operator: MilestoneConditionOperator.isNotNull,
            ),
            MilestoneCondition(
              field: 'dailyStartTime',
              operator: MilestoneConditionOperator.isNotNull,
            ),
            MilestoneCondition(
              field: 'dailyEndTime',
              operator: MilestoneConditionOperator.isNotNull,
            ),
          ],
        ),
        rewardText:
            'You\'ve set the schedule for your business event! Time management at its best!',
      ),

      // Tech Savvy
      Milestone(
        id: 'business_av',
        title: 'Tech Savvy',
        description: 'Select audio/visual equipment for your business event',
        category: MilestoneCategory.services,
        icon: Icons.speaker,
        points: 15,
        applicableEventTypes: ['business'],
        criteria: const MilestoneCriteria(
          completionConditions: [
            MilestoneCondition(
              field: 'templateId',
              operator: MilestoneConditionOperator.equals,
              value: 'business',
            ),
            MilestoneCondition(
              field: 'selectedServices',
              operator: MilestoneConditionOperator.contains,
              value: 'Audio/Visual Equipment',
            ),
          ],
        ),
        rewardText:
            'You\'ve selected audio/visual equipment for your business event! Professional presentation guaranteed!',
      ),
    ];
  }

  /// Get celebration-specific milestones
  static List<Milestone> getCelebrationMilestones() {
    return [
      // Celebration Planner
      Milestone(
        id: 'celebration_planner',
        title: 'Celebration Planner',
        description: 'Start planning your celebration',
        category: MilestoneCategory.planning,
        icon: Icons.cake,
        points: 20,
        applicableEventTypes: ['celebration'],
        criteria: const MilestoneCriteria(
          completionConditions: [
            MilestoneCondition(
              field: 'templateId',
              operator: MilestoneConditionOperator.equals,
              value: 'celebration',
            ),
            MilestoneCondition(
              field: 'currentStep',
              operator: MilestoneConditionOperator.greaterThan,
              value: 0,
            ),
          ],
        ),
        rewardText:
            'You\'ve started planning your celebration! Let\'s make it memorable!',
      ),

      // Party Planner
      Milestone(
        id: 'celebration_entertainment',
        title: 'Party Planner',
        description: 'Select music & entertainment for your celebration',
        category: MilestoneCategory.services,
        icon: Icons.music_note,
        points: 15,
        applicableEventTypes: ['celebration'],
        criteria: const MilestoneCriteria(
          completionConditions: [
            MilestoneCondition(
              field: 'templateId',
              operator: MilestoneConditionOperator.equals,
              value: 'celebration',
            ),
            MilestoneCondition(
              field: 'selectedServices',
              operator: MilestoneConditionOperator.contains,
              value: 'Music & Entertainment',
            ),
          ],
        ),
        rewardText:
            'You\'ve selected entertainment for your celebration! Let the good times roll!',
      ),

      // Sweet Tooth
      Milestone(
        id: 'celebration_cake',
        title: 'Sweet Tooth',
        description: 'Select cake & desserts for your celebration',
        category: MilestoneCategory.services,
        icon: Icons.cake,
        points: 15,
        applicableEventTypes: ['celebration'],
        criteria: const MilestoneCriteria(
          completionConditions: [
            MilestoneCondition(
              field: 'templateId',
              operator: MilestoneConditionOperator.equals,
              value: 'celebration',
            ),
            MilestoneCondition(
              field: 'selectedServices',
              operator: MilestoneConditionOperator.contains,
              value: 'Cake & Desserts',
            ),
          ],
        ),
        rewardText:
            'You\'ve selected cake & desserts for your celebration! Sweet treats for everyone!',
      ),
    ];
  }
}
