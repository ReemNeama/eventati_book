import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

/// A form for writing reviews
class ReviewForm extends StatefulWidget {
  /// The ID of the service being reviewed
  final String serviceId;

  /// The type of service being reviewed
  final String serviceType;

  /// Callback when the review is submitted
  final Function(ServiceReview)? onReviewSubmitted;

  /// Callback when the form is cancelled
  final VoidCallback? onCancel;

  /// Existing review to edit (null for new reviews)
  final ServiceReview? existingReview;

  /// Constructor
  const ReviewForm({
    super.key,
    required this.serviceId,
    required this.serviceType,
    this.onReviewSubmitted,
    this.onCancel,
    this.existingReview,
  });

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  double _rating = 0;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // If editing an existing review, populate the form
    if (widget.existingReview != null) {
      _rating = widget.existingReview!.rating;
      _commentController.text = widget.existingReview!.comment;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  /// Submit the review
  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_rating == 0) {
      setState(() {
        _errorMessage = 'Please select a rating';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.user == null) {
        setState(() {
          _errorMessage = 'You must be logged in to submit a review';
          _isSubmitting = false;
        });
        return;
      }

      // Create the review
      final review = ServiceReview(
        id: widget.existingReview?.id ?? const Uuid().v4(),
        serviceId: widget.serviceId,
        userId: authProvider.user!.id,
        userName: authProvider.user!.name,
        rating: _rating,
        comment: _commentController.text.trim(),
        imageUrls: widget.existingReview?.imageUrls ?? [],
        isVerified: widget.existingReview?.isVerified ?? false,
        createdAt: widget.existingReview?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Call the onReviewSubmitted callback
      if (widget.onReviewSubmitted != null) {
        widget.onReviewSubmitted!(review);
      }

      // Close the form
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error submitting review: ${e.toString()}';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                widget.existingReview != null
                    ? 'Edit Review'
                    : 'Write a Review',
                style: TextStyles.title,
              ),
              const SizedBox(height: 16),

              // Rating
              Text('Rating', style: TextStyles.bodyLarge),
              const SizedBox(height: 8),
              _buildRatingSelector(),
              if (_errorMessage != null && _rating == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              const SizedBox(height: 16),

              // Comment
              Text('Review', style: TextStyles.bodyLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _commentController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a review';
                  }
                  if (value.trim().length < 10) {
                    return 'Review must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Error message
              if (_errorMessage != null && _rating > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel button
                  TextButton(
                    onPressed:
                        _isSubmitting
                            ? null
                            : () {
                              if (widget.onCancel != null) {
                                widget.onCancel!();
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),

                  // Submit button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child:
                        _isSubmitting
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              widget.existingReview != null
                                  ? 'Update Review'
                                  : 'Submit Review',
                              style: TextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the rating selector
  Widget _buildRatingSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        final rating = index + 1;
        return InkWell(
          onTap: () {
            AccessibilityUtils.buttonPressHapticFeedback();
            setState(() {
              _rating = rating.toDouble();
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Icon(
                  rating <= _rating ? Icons.star : Icons.star_border,
                  color:
                      rating <= _rating
                          ? AppColors.warning
                          : AppColors.disabled,
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(rating.toString()),
              ],
            ),
          ),
        );
      }),
    );
  }
}
