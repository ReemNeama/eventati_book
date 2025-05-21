import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/event_models/event.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/services/sharing/platform_sharing_service.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/widgets/details/info_card.dart';
import 'package:eventati_book/widgets/details/feature_item.dart';
import 'package:eventati_book/widgets/details/image_placeholder.dart';
import 'package:eventati_book/widgets/common/image_gallery.dart';
import 'package:eventati_book/routing/routing.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// Screen to display event details
class EventDetailsScreen extends StatefulWidget {
  /// The event to display
  final Event event;

  /// Creates an EventDetailsScreen
  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  List<String> _eventImages = [];
  bool _isLoadingImages = false;

  @override
  void initState() {
    super.initState();
    _loadEventImages();
  }

  /// Load event images from storage
  Future<void> _loadEventImages() async {
    setState(() {
      _isLoadingImages = true;
    });

    try {
      // Add any images from the imageUrls list
      if (widget.event.imageUrls.isNotEmpty) {
        _eventImages = List.from(widget.event.imageUrls);
      }
    } catch (e) {
      Logger.e('Error loading event images: $e', tag: 'EventDetailsScreen');
    } finally {
      setState(() {
        _isLoadingImages = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = UIUtils.isDarkMode(context);
    final Color primaryColor =
        isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.name),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Event',
            onPressed: () => _showShareOptions(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEventImages(),
            const SizedBox(height: 16),
            _buildEventInfo(),
            const SizedBox(height: 16),
            _buildEventDetails(),
            const SizedBox(height: 16),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  /// Builds the event image gallery
  Widget _buildEventImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Event Photos', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (_isLoadingImages)
          const Center(child: CircularProgressIndicator())
        else if (_eventImages.isEmpty)
          const ImagePlaceholder(
            height: 200,
            width: double.infinity,
            borderRadius: 8,
            icon: Icons.image,
            iconSize: 50,
          )
        else
          ImageGallery(
            imageUrls: _eventImages,
            height: 250,
            width: double.infinity,
            borderRadius: 8,
            enableFullScreen: true,
            emptyText: 'No photos available for this event',
          ),
      ],
    );
  }

  /// Builds the event basic information section
  Widget _buildEventInfo() {
    return InfoCard(
      title: 'Event Information',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FeatureItem(
            text: 'Event Type: ${widget.event.type.displayName}',
            icon: Icons.event,
          ),
          const SizedBox(height: 8),
          FeatureItem(
            text: 'Date: ${DateTimeUtils.formatDate(widget.event.date)}',
            icon: Icons.calendar_today,
          ),
          const SizedBox(height: 8),
          FeatureItem(
            text: 'Location: ${widget.event.location}',
            icon: Icons.location_on,
          ),
          const SizedBox(height: 8),
          FeatureItem(
            text:
                'Guest Count: ${NumberUtils.formatWithCommas(widget.event.guestCount)}',
            icon: Icons.people,
          ),
          const SizedBox(height: 8),
          FeatureItem(
            text: 'Budget: ${NumberUtils.formatCurrency(widget.event.budget)}',
            icon: Icons.attach_money,
          ),
        ],
      ),
    );
  }

  /// Builds the event details section
  Widget _buildEventDetails() {
    return InfoCard(
      title: 'Event Details',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.event.description != null &&
              widget.event.description!.isNotEmpty)
            Text(widget.event.description!),
          if (widget.event.description == null ||
              widget.event.description!.isEmpty)
            const Text('No additional details available for this event.'),
        ],
      ),
    );
  }

  /// Builds the action buttons for the event
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          'Planning Tools',
          Icons.checklist,
          () => _navigateToEventPlanning(),
        ),
        _buildActionButton(
          context,
          'Guest List',
          Icons.people,
          () => _navigateToGuestList(),
        ),
        _buildActionButton(
          context,
          'Budget',
          Icons.account_balance_wallet,
          () => _navigateToBudget(),
        ),
      ],
    );
  }

  /// Builds an individual action button
  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyles.bodySmall),
      ],
    );
  }

  /// Navigate to event planning screen
  void _navigateToEventPlanning() {
    NavigationUtils.navigateToNamed(
      context,
      RouteNames.eventPlanning,
      arguments: EventPlanningArguments(
        eventId: widget.event.id,
        eventName: widget.event.name,
        eventType: widget.event.type.displayName,
        eventDate: widget.event.date,
      ),
    );
  }

  /// Navigate to guest list screen
  void _navigateToGuestList() {
    NavigationUtils.navigateToNamed(
      context,
      RouteNames.guestList,
      arguments: GuestListArguments(
        eventId: widget.event.id,
        eventName: widget.event.name,
      ),
    );
  }

  /// Navigate to budget screen
  void _navigateToBudget() {
    NavigationUtils.navigateToNamed(
      context,
      RouteNames.budget,
      arguments: BudgetArguments(
        eventId: widget.event.id,
        eventName: widget.event.name,
      ),
    );
  }

  /// Show share options dialog
  void _showShareOptions(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Share Event'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Share via System'),
                  subtitle: const Text('Share using your device\'s share menu'),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    _shareEvent();
                  },
                ),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Share to social media:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Facebook share button
                    _buildSocialShareButton(
                      dialogContext,
                      SharingPlatform.facebook,
                      Icons.facebook,
                      'Facebook',
                    ),
                    // Twitter share button
                    _buildSocialShareButton(
                      dialogContext,
                      SharingPlatform.twitter,
                      Icons.flutter_dash,
                      'Twitter',
                    ),
                    // WhatsApp share button
                    _buildSocialShareButton(
                      dialogContext,
                      SharingPlatform.whatsapp,
                      Icons.message,
                      'WhatsApp',
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  /// Build a social media share button
  Widget _buildSocialShareButton(
    BuildContext dialogContext,
    SharingPlatform platform,
    IconData icon,
    String label,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: () async {
            Navigator.of(dialogContext).pop();

            // Show loading indicator
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sharing to $label...'),
                duration: const Duration(seconds: 1),
              ),
            );

            try {
              // Share to the platform
              final success = await Provider.of<SocialSharingProvider>(
                context,
                listen: false,
              ).shareEventToPlatform(widget.event, platform);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Shared to $label successfully')),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to share to $label')),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error sharing to $label: $e')),
                );
              }
            }
          },
          tooltip: 'Share to $label',
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  /// Share event using the system share dialog
  Future<void> _shareEvent() async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preparing to share...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Share the event
      await Provider.of<SocialSharingProvider>(
        context,
        listen: false,
      ).shareEvent(widget.event);
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share event: $e')));
      }
    }
  }
}
