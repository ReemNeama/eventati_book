import 'package:flutter/material.dart';
import 'package:eventati_book/models/event_models/event_template.dart';

/// Detailed templates for common event types
class DetailedEventTemplates {
  /// Get all detailed templates
  static List<EventTemplate> getAllTemplates() {
    return [
      ...getWeddingTemplates(),
      ...getBusinessTemplates(),
      ...getCelebrationTemplates(),
    ];
  }

  /// Get detailed templates for weddings
  static List<EventTemplate> getWeddingTemplates() {
    return [
      // Traditional Wedding
      const EventTemplate(
        id: 'wedding_traditional',
        name: 'Traditional Wedding',
        description: 'A classic wedding with traditional elements',
        detailedDescription:
            'A timeless celebration with traditional ceremony, '
            'formal reception, and classic decor. Perfect for couples who want '
            'a traditional wedding experience with all the classic elements.',
        icon: Icons.church,
        subtypes: ['Traditional', 'Formal', 'Classic'],
        defaultServices: {
          'venue': true,
          'catering': true,
          'photography': true,
          'videography': true,
          'florist': true,
          'music': true,
          'cake': true,
          'transportation': true,
          'attire': true,
        },
        suggestedTasks: [
          'Book ceremony venue',
          'Book reception venue',
          'Hire photographer',
          'Hire videographer',
          'Book catering',
          'Order wedding cake',
          'Book florist',
          'Book music/DJ',
          'Arrange transportation',
          'Shop for wedding attire',
          'Send invitations',
          'Book honeymoon',
        ],
        imageUrl: 'assets/images/templates/wedding_traditional.jpg',
        isDetailedTemplate: true,
        parentTemplateId: 'wedding',
        defaultValues: {
          'guestCount': 150,
          'budgetEstimate': 35000,
          'timelineMonths': 12,
          'formality': 'Formal',
        },
      ),

      // Destination Wedding
      const EventTemplate(
        id: 'wedding_destination',
        name: 'Destination Wedding',
        description: 'A wedding in a beautiful destination',
        detailedDescription:
            'Exchange vows in a stunning location away from home. '
            'Perfect for couples who want a unique wedding experience in a '
            'beautiful setting with a smaller guest list.',
        icon: Icons.flight,
        subtypes: ['Beach', 'Resort', 'International'],
        defaultServices: {
          'venue': true,
          'catering': true,
          'photography': true,
          'videography': true,
          'florist': true,
          'music': true,
          'cake': true,
          'transportation': true,
          'travel_arrangements': true,
        },
        suggestedTasks: [
          'Research destination options',
          'Book venue package',
          'Arrange travel for wedding party',
          'Send save-the-dates early',
          'Create wedding website with travel info',
          'Research local marriage requirements',
          'Book photographer familiar with location',
          'Arrange welcome party for guests',
          'Book group accommodations',
          'Plan activities for guests',
        ],
        imageUrl: 'assets/images/templates/wedding_destination.jpg',
        isDetailedTemplate: true,
        parentTemplateId: 'wedding',
        defaultValues: {
          'guestCount': 50,
          'budgetEstimate': 30000,
          'timelineMonths': 15,
          'formality': 'Semi-formal',
        },
      ),

      // Intimate Wedding
      const EventTemplate(
        id: 'wedding_intimate',
        name: 'Intimate Wedding',
        description:
            'A small, intimate celebration with close family and friends',
        detailedDescription:
            'A cozy, personal celebration focused on quality time '
            'with your closest loved ones. Perfect for couples who prefer a '
            'smaller, more intimate gathering with personalized touches.',
        icon: Icons.favorite,
        subtypes: ['Small', 'Intimate', 'Family'],
        defaultServices: {
          'venue': true,
          'catering': true,
          'photography': true,
          'florist': true,
          'cake': true,
        },
        suggestedTasks: [
          'Find intimate venue',
          'Create guest list (under 50)',
          'Book photographer',
          'Plan personalized menu',
          'Order small wedding cake',
          'Arrange simple floral decorations',
          'Plan personalized ceremony',
          'Book intimate dinner reception',
          'Send handwritten invitations',
          'Plan special touches for each guest',
        ],
        imageUrl: 'assets/images/templates/wedding_intimate.jpg',
        isDetailedTemplate: true,
        parentTemplateId: 'wedding',
        defaultValues: {
          'guestCount': 30,
          'budgetEstimate': 15000,
          'timelineMonths': 6,
          'formality': 'Semi-formal',
        },
      ),
    ];
  }

  /// Get detailed templates for business events
  static List<EventTemplate> getBusinessTemplates() {
    return [
      // Corporate Conference
      const EventTemplate(
        id: 'business_conference',
        name: 'Corporate Conference',
        description: 'A professional conference for your organization',
        detailedDescription:
            'A comprehensive professional event featuring keynote '
            'speakers, breakout sessions, networking opportunities, and '
            'professional development. Perfect for companies looking to bring '
            'together employees, partners, or industry professionals.',
        icon: Icons.business_center,
        subtypes: ['Conference', 'Corporate', 'Professional'],
        defaultServices: {
          'venue': true,
          'catering': true,
          'av_equipment': true,
          'photography': true,
          'transportation': true,
          'accommodations': true,
          'speakers': true,
        },
        suggestedTasks: [
          'Book conference venue',
          'Arrange accommodations for attendees',
          'Book keynote speakers',
          'Plan breakout sessions',
          'Arrange catering for all days',
          'Set up registration system',
          'Organize AV equipment',
          'Create conference materials',
          'Plan networking events',
          'Arrange transportation',
        ],
        imageUrl: 'assets/images/templates/business_conference.jpg',
        isDetailedTemplate: true,
        parentTemplateId: 'business',
        defaultValues: {
          'guestCount': 200,
          'budgetEstimate': 50000,
          'timelineMonths': 8,
          'formality': 'Professional',
        },
      ),

      // Team Building Event
      const EventTemplate(
        id: 'business_team_building',
        name: 'Team Building Event',
        description: 'An event focused on team bonding and development',
        detailedDescription:
            'A fun and engaging event designed to strengthen team '
            'bonds, improve communication, and boost morale. Perfect for companies '
            'looking to invest in their team dynamics and company culture.',
        icon: Icons.groups,
        subtypes: ['Team Building', 'Retreat', 'Workshop'],
        defaultServices: {
          'venue': true,
          'catering': true,
          'activities': true,
          'facilitator': true,
          'transportation': true,
        },
        suggestedTasks: [
          'Research team building activities',
          'Book venue suitable for activities',
          'Hire professional facilitator',
          'Arrange transportation',
          'Plan meals and refreshments',
          'Create schedule of activities',
          'Prepare team building materials',
          'Set clear objectives for the event',
          'Plan follow-up assessment',
          'Book accommodations if overnight',
        ],
        imageUrl: 'assets/images/templates/business_team_building.jpg',
        isDetailedTemplate: true,
        parentTemplateId: 'business',
        defaultValues: {
          'guestCount': 30,
          'budgetEstimate': 15000,
          'timelineMonths': 3,
          'formality': 'Casual',
        },
      ),
    ];
  }

  /// Get detailed templates for celebrations
  static List<EventTemplate> getCelebrationTemplates() {
    return [
      // Birthday Party
      const EventTemplate(
        id: 'celebration_birthday',
        name: 'Birthday Party',
        description: 'A fun celebration for a birthday milestone',
        detailedDescription:
            'A joyful celebration to mark a special birthday. '
            'Whether it\'s a milestone birthday or just a reason to gather, '
            'this template helps you plan a memorable party with all the essentials.',
        icon: Icons.cake,
        subtypes: ['Birthday', 'Milestone', 'Party'],
        defaultServices: {
          'venue': true,
          'catering': true,
          'cake': true,
          'decorations': true,
          'entertainment': true,
        },
        suggestedTasks: [
          'Choose party theme',
          'Book venue or prepare home',
          'Create guest list',
          'Send invitations',
          'Order birthday cake',
          'Plan food and drinks',
          'Arrange decorations',
          'Plan entertainment or activities',
          'Organize music playlist',
          'Arrange photography',
        ],
        imageUrl: 'assets/images/templates/celebration_birthday.jpg',
        isDetailedTemplate: true,
        parentTemplateId: 'celebration',
        defaultValues: {
          'guestCount': 40,
          'budgetEstimate': 2000,
          'timelineMonths': 2,
          'formality': 'Casual',
        },
      ),

      // Anniversary Celebration
      const EventTemplate(
        id: 'celebration_anniversary',
        name: 'Anniversary Celebration',
        description: 'A special event to celebrate a relationship milestone',
        detailedDescription:
            'A meaningful celebration to honor a significant '
            'relationship milestone. Perfect for couples celebrating a wedding '
            'anniversary or organizations marking a company anniversary.',
        icon: Icons.favorite_border,
        subtypes: ['Anniversary', 'Milestone', 'Celebration'],
        defaultServices: {
          'venue': true,
          'catering': true,
          'cake': true,
          'photography': true,
          'music': true,
          'decorations': true,
        },
        suggestedTasks: [
          'Select anniversary theme',
          'Book venue for celebration',
          'Create guest list',
          'Send formal invitations',
          'Arrange special menu',
          'Order anniversary cake',
          'Book photographer',
          'Plan music or entertainment',
          'Prepare speech or toast',
          'Select meaningful decorations',
        ],
        imageUrl: 'assets/images/templates/celebration_anniversary.jpg',
        isDetailedTemplate: true,
        parentTemplateId: 'celebration',
        defaultValues: {
          'guestCount': 60,
          'budgetEstimate': 5000,
          'timelineMonths': 3,
          'formality': 'Semi-formal',
        },
      ),
    ];
  }
}
