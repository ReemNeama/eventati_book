import 'package:flutter/material.dart';
import 'package:eventati_book/models/milestone.dart';

/// Factory class for creating milestone templates and instances
class MilestoneFactory {
  /// Get all predefined milestone templates
  static List<Milestone> getAllTemplates() {
    return [
      ...getWeddingTemplates(),
      ...getBusinessEventTemplates(),
      ...getCelebrationTemplates(),
      ...getCommonTemplates(),
    ];
  }

  /// Get templates for a specific event type
  static List<Milestone> getTemplatesForEventType(String eventType) {
    final commonTemplates = getCommonTemplates();

    switch (eventType) {
      case 'wedding':
        return [...commonTemplates, ...getWeddingTemplates()];
      case 'business':
        return [...commonTemplates, ...getBusinessEventTemplates()];
      case 'celebration':
        return [...commonTemplates, ...getCelebrationTemplates()];
      default:
        return commonTemplates;
    }
  }

  /// Create milestone instances for an event
  static List<Milestone> createMilestonesForEvent(
    String eventId,
    String eventType,
  ) {
    final templates = getTemplatesForEventType(eventType);
    return templates
        .map((template) => Milestone.fromTemplate(template, eventId))
        .toList();
  }

  /// Get common milestone templates applicable to all event types
  static List<Milestone> getCommonTemplates() {
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
        isTemplate: true,
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
        isTemplate: true,
      ),

      // Budget Master
      Milestone(
        id: 'budget_master',
        title: 'Budget Master',
        description: 'Create a budget for your event',
        category: MilestoneCategory.budget,
        icon: Icons.attach_money,
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
        rewardText: 'You\'ve created a budget for your event!',
        isTemplate: true,
      ),

      // Guest List Creator
      Milestone(
        id: 'guest_list_creator',
        title: 'Guest List Creator',
        description: 'Create a guest list for your event',
        category: MilestoneCategory.guests,
        icon: Icons.people,
        points: 15,
        applicableEventTypes: ['all'],
        criteria: const MilestoneCriteria(
          completionConditions: [
            MilestoneCondition(
              field: 'guestCount',
              operator: MilestoneConditionOperator.greaterThan,
              value: 0,
            ),
          ],
        ),
        rewardText: 'You\'ve created a guest list for your event!',
        isTemplate: true,
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
        isTemplate: true,
      ),
    ];
  }

  /// Get wedding-specific milestone templates
  static List<Milestone> getWeddingTemplates() {
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
        isTemplate: true,
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
        isTemplate: true,
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
            'You\'ve selected catering for your wedding! Delicious food for your special day!',
        isTemplate: true,
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
        isTemplate: true,
      ),
    ];
  }

  /// Get business event-specific milestone templates
  static List<Milestone> getBusinessEventTemplates() {
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
        isTemplate: true,
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
        isTemplate: true,
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
        isTemplate: true,
      ),
    ];
  }

  /// Get celebration-specific milestone templates
  static List<Milestone> getCelebrationTemplates() {
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
        isTemplate: true,
      ),

      // Party Venue
      Milestone(
        id: 'celebration_venue',
        title: 'Party Venue',
        description: 'Select a venue for your celebration',
        category: MilestoneCategory.services,
        icon: Icons.location_on,
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
              field: 'selectedServices',
              operator: MilestoneConditionOperator.contains,
              value: 'Venue',
            ),
          ],
        ),
        rewardText:
            'You\'ve selected a venue for your celebration! The perfect party spot!',
        isTemplate: true,
      ),

      // Entertainment Expert
      Milestone(
        id: 'celebration_entertainment',
        title: 'Entertainment Expert',
        description: 'Select entertainment for your celebration',
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
        isTemplate: true,
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
        isTemplate: true,
      ),
    ];
  }
}
