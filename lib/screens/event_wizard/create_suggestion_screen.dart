import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/suggestion.dart';
import 'package:eventati_book/providers/suggestion_provider.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';

/// Screen for creating a custom suggestion
class CreateSuggestionScreen extends StatefulWidget {
  const CreateSuggestionScreen({super.key});

  @override
  State<CreateSuggestionScreen> createState() => _CreateSuggestionScreenState();
}

class _CreateSuggestionScreenState extends State<CreateSuggestionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String _title = '';
  String _description = '';
  SuggestionCategory _category = SuggestionCategory.other;
  SuggestionPriority _priority = SuggestionPriority.medium;
  String? _actionUrl;
  String? _imageUrl;

  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final textColor =
        isDarkMode ? AppColorsDark.textPrimary : AppColors.textPrimary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Custom Suggestion'),
        backgroundColor: primaryColor,
      ),
      body:
          _isSaving
              ? const Center(
                child: LoadingIndicator(message: 'Saving suggestion...'),
              )
              : Container(
                color:
                    isDarkMode
                        ? AppColorsDark.background
                        : AppColors.background,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title field
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            hintText: 'Enter a title for your suggestion',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                          onSaved: (value) => _title = value!,
                        ),
                        const SizedBox(height: 16),

                        // Description field
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Enter a detailed description',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                          onSaved: (value) => _description = value!,
                        ),
                        const SizedBox(height: 16),

                        // Category dropdown
                        DropdownButtonFormField<SuggestionCategory>(
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          value: _category,
                          items:
                              SuggestionCategory.values.map((category) {
                                return DropdownMenuItem<SuggestionCategory>(
                                  value: category,
                                  child: Row(
                                    children: [
                                      Icon(category.icon, size: 20),
                                      const SizedBox(width: 8),
                                      Text(category.label),
                                    ],
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _category = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Priority dropdown
                        DropdownButtonFormField<SuggestionPriority>(
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                            border: OutlineInputBorder(),
                          ),
                          value: _priority,
                          items:
                              SuggestionPriority.values.map((priority) {
                                return DropdownMenuItem<SuggestionPriority>(
                                  value: priority,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.flag,
                                        color: priority.color,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(priority.label),
                                    ],
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _priority = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Optional fields section
                        Text(
                          'Optional Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Action URL field
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Action URL',
                            hintText: 'e.g., /event-planning/budget',
                            border: OutlineInputBorder(),
                            helperText:
                                'Internal app route to navigate to when taking action',
                          ),
                          onSaved:
                              (value) =>
                                  _actionUrl =
                                      value?.isNotEmpty == true ? value : null,
                        ),
                        const SizedBox(height: 16),

                        // Image URL field
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Image URL',
                            hintText: 'Enter an image URL (optional)',
                            border: OutlineInputBorder(),
                          ),
                          onSaved:
                              (value) =>
                                  _imageUrl =
                                      value?.isNotEmpty == true ? value : null,
                        ),
                        const SizedBox(height: 32),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveSuggestion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Save Suggestion',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  /// Save the suggestion
  Future<void> _saveSuggestion() async {
    // Validate the form
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    // Save the form fields
    _formKey.currentState?.save();

    setState(() {
      _isSaving = true;
    });

    try {
      // Create a new suggestion
      final suggestion = Suggestion(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        title: _title,
        description: _description,
        category: _category,
        priority: _priority,
        baseRelevanceScore: 70, // Default score for custom suggestions
        conditions: [], // No conditions for custom suggestions
        applicableEventTypes: [
          'wedding',
          'business',
          'celebration',
        ], // Apply to all event types
        imageUrl: _imageUrl,
        actionUrl: _actionUrl,
        isCustom: true,
      );

      // Get the provider
      final suggestionProvider = Provider.of<SuggestionProvider>(
        context,
        listen: false,
      );

      // Add the suggestion to the provider
      final success = await suggestionProvider.addCustomSuggestion(suggestion);

      // Force a refresh of the filtered suggestions
      if (success) {
        suggestionProvider.applyCurrentCategoryFilter();
      }

      if (success) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Suggestion added successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back
          Navigator.pop(context, true);
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add suggestion. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
