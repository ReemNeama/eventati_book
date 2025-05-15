import 'package:flutter/material.dart';
import 'package:eventati_book/models/feedback_models/user_feedback.dart';
import 'package:eventati_book/services/supabase/database/feedback_database_service.dart';
import 'package:eventati_book/providers/core_providers/auth_provider.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:eventati_book/utils/ui/accessibility_utils.dart';
import 'package:eventati_book/utils/service/validation_utils.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// A form for collecting user feedback
class FeedbackForm extends StatefulWidget {
  /// The context of the feedback (e.g., screen name)
  final String? context;

  /// The initial feedback type
  final FeedbackType initialType;

  /// The callback when feedback is submitted
  final Function(UserFeedback feedback)? onFeedbackSubmitted;

  /// Creates a FeedbackForm
  const FeedbackForm({
    super.key,
    this.context,
    this.initialType = FeedbackType.general,
    this.onFeedbackSubmitted,
  });

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  FeedbackType _selectedType = FeedbackType.general;
  int _rating = 3;
  bool _isSubmitting = false;
  String? _errorMessage;

  final FeedbackDatabaseService _feedbackService = FeedbackDatabaseService();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;

    // Track screen view
    Posthog().screen(
      screenName: 'Feedback Form',
      properties: {
        'context': widget.context ?? 'unknown',
        'initial_type': widget.initialType.name,
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get the current user
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      setState(() {
        _errorMessage = 'You must be logged in to submit feedback.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // Create the feedback object
      final feedback = UserFeedback(
        userId: authProvider.currentUser!.id,
        type: _selectedType,
        rating: _selectedType == FeedbackType.general ? _rating : null,
        message: _messageController.text.trim(),
        context: widget.context,
      );

      // Add the feedback to the database
      final feedbackId = await _feedbackService.addFeedback(feedback);

      if (feedbackId != null) {
        // Track the feedback submission
        Posthog().capture(
          eventName: 'feedback_submitted',
          properties: {
            'feedback_type': _selectedType.name,
            'rating': _rating,
            'context': widget.context ?? 'unknown',
          },
        );

        // Call the callback if provided
        if (widget.onFeedbackSubmitted != null) {
          widget.onFeedbackSubmitted!(feedback.copyWith(id: feedbackId));
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thank you for your feedback!'),
              backgroundColor: Colors.green,
            ),
          );

          // Clear the form
          _messageController.clear();
          setState(() {
            _rating = 3;
            _selectedType = widget.initialType;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to submit feedback. Please try again.';
        });
      }
    } catch (e) {
      Logger.e('Error submitting feedback: $e', tag: 'FeedbackForm');
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Feedback type selector
          Text('Feedback Type', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildFeedbackTypeSelector(),
          const SizedBox(height: 16),

          // Rating (only for general feedback)
          if (_selectedType == FeedbackType.general) ...[
            Text('Rating', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildRatingSelector(),
            const SizedBox(height: 16),
          ],

          // Message
          Text('Message', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _messageController,
            decoration: const InputDecoration(
              hintText: 'Enter your feedback here...',
              prefixIcon: Icon(Icons.message),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            maxLines: 5,
            validator: ValidationUtils.validateRequired,
          ),
          const SizedBox(height: 16),

          // Error message
          if (_errorMessage != null) ...[
            Text(
              _errorMessage!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            const SizedBox(height: 16),
          ],

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              child:
                  _isSubmitting
                      ? const LoadingIndicator(size: 24)
                      : const Text('Submit Feedback'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackTypeSelector() {
    return DropdownButtonFormField<FeedbackType>(
      value: _selectedType,
      decoration: const InputDecoration(
        hintText: 'Select feedback type',
        prefixIcon: Icon(Icons.category),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      items:
          FeedbackType.values.map((type) {
            return DropdownMenuItem<FeedbackType>(
              value: type,
              child: Text(type.displayName),
            );
          }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedType = value;
          });
        }
      },
    );
  }

  Widget _buildRatingSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        final rating = index + 1;
        return InkWell(
          onTap: () {
            AccessibilityUtils.buttonPressHapticFeedback();
            setState(() {
              _rating = rating;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Icon(
                  rating <= _rating ? Icons.star : Icons.star_border,
                  color: rating <= _rating ? Colors.amber : Colors.grey,
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
