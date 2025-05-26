import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:eventati_book/widgets/common/error_message.dart';
import 'package:eventati_book/widgets/reviews/review_form.dart';

/// Screen to display all reviews for a service
class ReviewsScreen extends StatefulWidget {
  /// The ID of the service
  final String serviceId;

  /// The type of service
  final String serviceType;

  /// The name of the service
  final String serviceName;

  /// Constructor
  const ReviewsScreen({
    super.key,
    required this.serviceId,
    required this.serviceType,
    required this.serviceName,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
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

      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load reviews: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews for ${widget.serviceName}'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReviews,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: LoadingIndicator())
              : _error != null
              ? Center(child: ErrorMessage(message: _error!))
              : _buildReviewsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show review form
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
                  onReviewSubmitted: (review) async {
                    // Add the review
                    final serviceDatabaseProvider =
                        Provider.of<ServiceDatabaseProvider>(
                          context,
                          listen: false,
                        );

                    final success = await serviceDatabaseProvider
                        .addServiceReview(widget.serviceId, review);

                    if (success && mounted) {
                      // Reload reviews
                      _loadReviews();

                      // Show success message
                      UIUtils.showSnackBar(
                        context,
                        'Review submitted successfully',
                      );
                    }
                  },
                ),
          );
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.rate_review),
      ),
    );
  }

  /// Build the reviews list
  Widget _buildReviewsList() {
    if (_reviews.isEmpty) {
      return EmptyState(
        title: 'No Reviews Yet',
        message: 'Be the first to review this ${widget.serviceType}!',
        icon: Icons.rate_review,
        actionText: 'Write a Review',
        onAction: () {
          // Show review form
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
                  onReviewSubmitted: (review) async {
                    // Add the review
                    final serviceDatabaseProvider =
                        Provider.of<ServiceDatabaseProvider>(
                          context,
                          listen: false,
                        );

                    final success = await serviceDatabaseProvider
                        .addServiceReview(widget.serviceId, review);

                    if (success && mounted) {
                      // Reload reviews
                      _loadReviews();

                      // Show success message
                      UIUtils.showSnackBar(
                        context,
                        'Review submitted successfully',
                      );
                    }
                  },
                ),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        return _buildReviewItem(review);
      },
    );
  }

  /// Format a timestamp into a human-readable string
  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
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
                                  alpha: 51, // 0.2 * 255
                                )
                                : AppColors.primary.withValues(
                                  alpha: 51, // 0.2 * 255
                                ),
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
                              _formatTimeAgo(review.createdAt),
                              style: TextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: AppColors.warning,
                      size: 16,
                    );
                  }),
                ),
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
                    onPressed: () {
                      // Show review form for editing
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        builder:
                            (context) => ReviewForm(
                              serviceId: widget.serviceId,
                              serviceType: widget.serviceType,
                              existingReview: review,
                              onReviewSubmitted: (updatedReview) async {
                                // Update the review
                                final serviceDatabaseProvider =
                                    Provider.of<ServiceDatabaseProvider>(
                                      context,
                                      listen: false,
                                    );

                                final success = await serviceDatabaseProvider
                                    .addServiceReview(
                                      widget.serviceId,
                                      updatedReview,
                                    );

                                if (success && mounted) {
                                  // Reload reviews
                                  _loadReviews();

                                  // Show success message
                                  UIUtils.showSnackBar(
                                    context,
                                    'Review updated successfully',
                                  );
                                }
                              },
                            ),
                      );
                    },
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
                          // Delete the review
                          final serviceDatabaseProvider =
                              Provider.of<ServiceDatabaseProvider>(
                                context,
                                listen: false,
                              );

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
