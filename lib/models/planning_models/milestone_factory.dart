import 'package:flutter/material.dart';
import 'milestone.dart';

/// Factory class for creating milestone templates and instances
///
/// This class provides methods to generate predefined milestone templates for different event types
/// and create milestone instances for specific events. It serves as a central repository for all
/// milestone definitions in the application.
///
/// The factory follows a template pattern where milestone templates are defined with specific
/// criteria for completion, and these templates can be instantiated for specific events.
///
/// Key features:
/// - Provides milestone templates for different event types (wedding, business, celebration)
/// - Offers common milestones applicable to all event types
/// - Creates milestone instances for specific events based on templates
/// - Defines completion criteria for each milestone
class MilestoneFactory {
  /// Get all predefined milestone templates
  ///
  /// Returns a combined list of all milestone templates from all categories:
  /// - Wedding-specific templates
  /// - Business event-specific templates
  /// - Celebration-specific templates
  /// - Common templates applicable to all event types
  ///
  /// This method is useful when you need to access all available templates
  /// regardless of event type, such as for administrative purposes or
  /// displaying a complete catalog of possible achievements.
  static List<Milestone> getAllTemplates() {
    return [
      ...getWeddingTemplates(),
      ...getBusinessEventTemplates(),
      ...getCelebrationTemplates(),
      ...getCommonTemplates(),
    ];
  }

  /// Get templates for a specific event type
  ///
  /// Returns a filtered list of milestone templates applicable to the specified event type.
  /// The returned list includes both event-specific templates and common templates that
  /// apply to all event types.
  ///
  /// Parameters:
  /// - [eventType]: The type of event ('wedding', 'business', 'celebration', or any other type)
  ///
  /// Returns:
  /// - For 'wedding': Wedding-specific templates + common templates
  /// - For 'business': Business event-specific templates + common templates
  /// - For 'celebration': Celebration-specific templates + common templates
  /// - For any other type: Only common templates
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
  ///
  /// Instantiates milestone objects for a specific event based on the appropriate
  /// templates for the event type. This method converts template milestones into
  /// actual milestone instances that can be tracked for a specific event.
  ///
  /// Parameters:
  /// - [eventId]: The unique identifier of the event
  /// - [eventType]: The type of event ('wedding', 'business', 'celebration', etc.)
  ///
  /// Returns:
  /// A list of Milestone objects that are instances (not templates) associated with
  /// the specified event. These instances can be tracked, completed, and rewarded.
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
  ///
  /// Returns a list of milestone templates that are relevant for all event types.
  /// These common milestones represent achievements that are universal to the event
  /// planning process, regardless of the specific event type.
  ///
  /// Common milestones include:
  /// - Event Planner: Starting to plan an event
  /// - Planning Complete: Completing all steps in the event wizard
  /// - Budget Master: Creating a budget for the event
  /// - Guest List Creator: Creating a guest list
  /// - Service Expert: Selecting multiple services
  ///
  /// These milestones use the 'all' applicableEventTypes value to indicate they
  /// apply universally.
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
  ///
  /// Returns a list of milestone templates that are specifically designed for wedding events.
  /// These milestones represent achievements related to wedding planning and services.
  ///
  /// Wedding-specific milestones include:
  /// - Wedding Planner: Starting to plan a wedding
  /// - Venue Selector: Selecting a venue for the wedding
  /// - Catering Connoisseur: Selecting catering services
  /// - Memory Maker: Selecting photography/videography services
  ///
  /// All wedding milestones use the 'wedding' applicableEventTypes value and include
  /// criteria that check if the event template is a wedding.
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
  ///
  /// Returns a list of milestone templates that are specifically designed for business events.
  /// These milestones represent achievements related to business event planning and services.
  ///
  /// Business event-specific milestones include:
  /// - Business Event Planner: Starting to plan a business event
  /// - Schedule Master: Setting duration and times for the business event
  /// - Tech Savvy: Selecting audio/visual equipment
  ///
  /// All business event milestones use the 'business' applicableEventTypes value and include
  /// criteria that check if the event template is a business event.
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
  ///
  /// Returns a list of milestone templates that are specifically designed for celebration events.
  /// These milestones represent achievements related to celebration planning and services.
  ///
  /// Celebration-specific milestones include:
  /// - Celebration Planner: Starting to plan a celebration
  /// - Party Venue: Selecting a venue for the celebration
  /// - Entertainment Expert: Selecting entertainment services
  /// - Sweet Tooth: Selecting cake & desserts
  ///
  /// All celebration milestones use the 'celebration' applicableEventTypes value and include
  /// criteria that check if the event template is a celebration event.
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
