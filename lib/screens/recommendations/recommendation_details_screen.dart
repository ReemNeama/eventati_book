import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:eventati_book/widgets/common/error_message.dart';
import 'package:eventati_book/widgets/recommendations/recommendation_badge.dart';
import 'package:eventati_book/routing/routing.dart';

/// Screen for displaying detailed information about a vendor recommendation
class RecommendationDetailsScreen extends StatefulWidget {
  /// The recommendation to display
  final Suggestion recommendation;

  /// The event ID
  final String eventId;

  /// Creates a new recommendation details screen
  const RecommendationDetailsScreen({
    super.key,
    required this.recommendation,
    required this.eventId,
  });

  @override
  State<RecommendationDetailsScreen> createState() =>
      _RecommendationDetailsScreenState();
}

class _RecommendationDetailsScreenState
    extends State<RecommendationDetailsScreen> {
  /// Whether the recommendation is saved
  bool _isSaved = false;

  /// Whether the recommendation is being contacted
  bool _isContacting = false;

  /// Whether the recommendation is being booked
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  /// Check if the recommendation is saved
  Future<void> _checkIfSaved() async {
    // TODO: Implement checking if recommendation is saved
    setState(() {
      _isSaved = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final backgroundColor =
        isDarkMode ? AppColorsDark.background : AppColors.background;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeaderImage(),
            ),
            actions: [
              // Save button
              IconButton(
                icon: Icon(
                  _isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: _isSaved ? primaryColor : null,
                ),
                onPressed: _toggleSave,
                tooltip: _isSaved ? 'Remove from saved' : 'Save',
              ),
              // Share button
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareRecommendation,
                tooltip: 'Share',
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and category
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.recommendation.category.icon,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.recommendation.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                            ),
                            Text(
                              widget.recommendation.category.label,
                              style: TextStyle(
                                color: textColor.withAlpha(179),
                              ),
                            ),
                          ],
                        ),
                      ),
                      RecommendationBadge(
                        reason: widget.recommendation.description,
                        relevanceScore:
                            widget.recommendation.baseRelevanceScore,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.recommendation.description,
                    style: TextStyle(
                      color: textColor.withAlpha(230),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tags
                  if (widget.recommendation.tags.isNotEmpty) ...[
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.recommendation.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: primaryColor.withAlpha(26),
                          labelStyle: TextStyle(color: primaryColor),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isContacting ? null : _contactVendor,
                          icon: _isContacting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.email),
                          label: Text(
                            _isContacting ? 'Contacting...' : 'Contact',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isBooking ? null : _bookVendor,
                          icon: _isBooking
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.calendar_today),
                          label: Text(_isBooking ? 'Booking...' : 'Book Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Similar recommendations
                  _buildSimilarRecommendations(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the header image
  Widget _buildHeaderImage() {
    return widget.recommendation.imageUrl != null
        ? Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.recommendation.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              ),
              // Gradient overlay for better text visibility
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(0),
                      Colors.black.withAlpha(150),
                    ],
                  ),
                ),
              ),
            ],
          )
        : _buildPlaceholderImage();
  }

  /// Build a placeholder image
  Widget _buildPlaceholderImage() {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Container(
      color: primaryColor.withAlpha(26),
      child: Center(
        child: Icon(
          widget.recommendation.category.icon,
          size: 80,
          color: primaryColor.withAlpha(128),
        ),
      ),
    );
  }

  /// Build similar recommendations section
  Widget _buildSimilarRecommendations() {
    return Consumer<ServiceRecommendationProvider>(
      builder: (context, provider, _) {
        // Get similar recommendations
        final similarRecommendations = provider.getSimilarRecommendations(
          widget.recommendation,
          maxCount: 3,
        );

        if (similarRecommendations.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Similar Recommendations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: similarRecommendations.length,
                itemBuilder: (context, index) {
                  final recommendation = similarRecommendations[index];
                  return _buildSimilarRecommendationCard(recommendation);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build a card for a similar recommendation
  Widget _buildSimilarRecommendationCard(Suggestion recommendation) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return GestureDetector(
      onTap: () => _navigateToRecommendation(recommendation),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: primaryColor.withAlpha(51),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: recommendation.imageUrl != null
                  ? Image.network(
                      recommendation.imageUrl!,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          color: primaryColor.withAlpha(26),
                          child: Center(
                            child: Icon(
                              recommendation.category.icon,
                              color: primaryColor.withAlpha(128),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 100,
                      color: primaryColor.withAlpha(26),
                      child: Center(
                        child: Icon(
                          recommendation.category.icon,
                          color: primaryColor.withAlpha(128),
                        ),
                      ),
                    ),
            ),
            // Title and category
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recommendation.category.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recommendation.baseRelevanceScore}% match',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Toggle saving the recommendation
  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
    // TODO: Implement saving recommendation
  }

  /// Share the recommendation
  void _shareRecommendation() {
    // TODO: Implement sharing recommendation
  }

  /// Contact the vendor
  Future<void> _contactVendor() async {
    setState(() {
      _isContacting = true;
    });

    // TODO: Implement contacting vendor

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isContacting = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact request sent!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Book the vendor
  Future<void> _bookVendor() async {
    setState(() {
      _isBooking = true;
    });

    // TODO: Implement booking vendor

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isBooking = false;
    });

    if (mounted) {
      // Navigate to booking form
      NavigationUtils.navigateToNamed(
        context,
        RouteNames.bookingForm,
        arguments: BookingFormArguments(
          eventId: widget.eventId,
          serviceId: widget.recommendation.id,
          serviceType: widget.recommendation.category.name,
        ),
      );
    }
  }

  /// Navigate to another recommendation
  void _navigateToRecommendation(Suggestion recommendation) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RecommendationDetailsScreen(
          recommendation: recommendation,
          eventId: widget.eventId,
        ),
      ),
    );
  }
}
