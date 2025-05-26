import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:eventati_book/widgets/common/error_message.dart';
import 'package:eventati_book/widgets/common/rating_display.dart';
import 'package:eventati_book/widgets/reviews/review_form.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

/// A widget for displaying a list of reviews
class ReviewsList extends StatefulWidget {
  /// The ID of the service being reviewed
  final String serviceId;

  /// The type of service being reviewed
  final String serviceType;

  /// The maximum number of reviews to show (null for all)
  final int? maxReviews;

  /// Whether to show the "Write a Review" button
  final bool showWriteReviewButton;

  /// Whether to show the "View All Reviews" button
  final bool showViewAllButton;

  /// Callback when the "View All Reviews" button is pressed
  final VoidCallback? onViewAllPressed;

  /// Constructor
  const ReviewsList({
    super.key,
    required this.serviceId,
    required this.serviceType,
    this.maxReviews,
    this.showWriteReviewButton = true,
    this.showViewAllButton = true,
    this.onViewAllPressed,
  });

  @override
  State<ReviewsList> createState() => _ReviewsListState();
}

class _ReviewsListState extends State<ReviewsList> {
  bool _isLoading = false;
  String? _error;
  List<ServiceReview> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  /// Load reviews for the service
  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get the service database provider
      final serviceDatabaseProvider = Provider.of<ServiceDatabaseProvider>(
        context,
        listen: false,
      );

      // Load reviews
      final reviews = await serviceDatabaseProvider.getServiceReviews(
        widget.serviceId,
      );

      // Sort by date (newest first)
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Limit the number of reviews if maxReviews is specified
      final limitedReviews =
          widget.maxReviews != null && widget.maxReviews! > 0
              ? reviews.take(widget.maxReviews!).toList()
              : reviews;

      setState(() {
        _reviews = limitedReviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load reviews: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Show the review form dialog
  void _showReviewForm({ServiceReview? existingReview}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => ReviewForm(
            serviceId: widget.serviceId,
            serviceType: widget.serviceType,
            existingReview: existingReview,
            onReviewSubmitted: _handleReviewSubmitted,
          ),
    );
  }

  /// Handle a submitted review
  Future<void> _handleReviewSubmitted(ServiceReview review) async {
    try {
      // Get the service database provider
      final serviceDatabaseProvider = Provider.of<ServiceDatabaseProvider>(
        context,
        listen: false,
      );

      // Add or update the review
      await serviceDatabaseProvider.addServiceReview(widget.serviceId, review);

      // Reload reviews
      await _loadReviews();

      if (mounted) {
        UIUtils.showSnackBar(
          context,
          review.id == review.id
              ? 'Review updated successfully'
              : 'Review submitted successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showSnackBar(context, 'Error: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (_error != null) {
      return Center(child: ErrorMessage(message: _error!));
    }

    if (_reviews.isEmpty) {
      return Column(
        children: [
          EmptyState(
            title: 'No Reviews Yet',
            message: 'Be the first to review this ${widget.serviceType}!',
            icon: Icons.rate_review,
            actionText: 'Write a Review',
            onAction:
                widget.showWriteReviewButton ? () => _showReviewForm() : null,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and write review button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Reviews', style: TextStyles.sectionTitle),
            if (widget.showWriteReviewButton)
              TextButton(
                onPressed: () => _showReviewForm(),
                child: const Text('Write a Review'),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Reviews list
        ..._reviews.map((review) => _buildReviewItem(review)),

        // View all button
        if (widget.showViewAllButton &&
            widget.maxReviews != null &&
            _reviews.length >= widget.maxReviews!)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextButton(
                onPressed: widget.onViewAllPressed,
                child: const Text('View All Reviews'),
              ),
            ),
          ),
      ],
    );
  }

  /// Build a single review item
  Widget _buildReviewItem(ServiceReview review) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isCurrentUserReview = authProvider.user?.id == review.userId;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user name, rating, and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            isDarkMode
                                ? AppColorsDark.primary.withValues(
                                  alpha: 51,
                                ) // 0.2 * 255
                                : AppColors.primary.withValues(
                                  alpha: 51,
                                ), // 0.2 * 255
                        child: Text(
                          review.userName.isNotEmpty
                              ? review.userName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color:
                                isDarkMode
                                    ? AppColorsDark.primary
                                    : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.userName,
                              style: TextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              timeago.format(review.createdAt),
                              style: TextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                RatingDisplay(rating: review.rating, showAllStars: true),
              ],
            ),

            // Review text
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(review.comment),
            ),

            // Actions for current user's review
            if (isCurrentUserReview)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _showReviewForm(existingReview: review),
                    child: const Text('Edit'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Show delete confirmation
                      UIUtils.showConfirmationDialog(
                        context,
                        title: 'Delete Review',
                        message: 'Are you sure you want to delete your review?',
                        confirmText: 'Delete',
                        cancelText: 'Cancel',
                      ).then((confirmed) async {
                        if (confirmed && mounted) {
                          try {
                            // Get the service database provider
                            final serviceDatabaseProvider =
                                Provider.of<ServiceDatabaseProvider>(
                                  context,
                                  listen: false,
                                );

                            // Delete the review
                            final success = await serviceDatabaseProvider
                                .deleteServiceReview(review.id);

                            if (success && mounted) {
                              // Reload reviews
                              _loadReviews();

                              // Show success message
                              UIUtils.showSnackBar(
                                context,
                                'Review deleted successfully',
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              UIUtils.showSnackBar(
                                context,
                                'Error deleting review: ${e.toString()}',
                              );
                            }
                          }
                        }
                      });
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
