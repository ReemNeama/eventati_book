import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/saved_comparison.dart';
import 'package:eventati_book/providers/comparison_saving_provider.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/constants.dart';
import 'package:eventati_book/utils/responsive_constants.dart';
import 'package:eventati_book/utils/responsive_utils.dart';
import 'package:eventati_book/utils/ui_utils.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';
import 'package:eventati_book/widgets/common/error_message.dart';

/// Screen to display and manage saved comparisons
class SavedComparisonsScreen extends StatefulWidget {
  /// Constructor
  const SavedComparisonsScreen({super.key});

  @override
  State<SavedComparisonsScreen> createState() => _SavedComparisonsScreenState();
}

class _SavedComparisonsScreenState extends State<SavedComparisonsScreen> {
  /// Selected service type filter (null means all types)
  String? _selectedServiceType;

  /// Sort order (true = newest first, false = oldest first)
  bool _sortNewestFirst = true;

  @override
  void initState() {
    super.initState();
    // Load saved comparisons when the screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if the widget is still mounted before accessing context
      if (mounted) {
        // Use the public method to load saved comparisons
        Provider.of<ComparisonSavingProvider>(
          context,
          listen: false,
        ).refreshData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    // We don't need backgroundColor since we're using the Scaffold's default background
    final cardColor = isDarkMode ? AppColorsDark.card : AppColors.card;
    final textColor =
        isDarkMode ? AppColorsDark.textPrimary : AppColors.textPrimary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Comparisons'),
        actions: [
          // Sort button
          IconButton(
            icon: Icon(
              _sortNewestFirst ? Icons.arrow_downward : Icons.arrow_upward,
            ),
            tooltip: _sortNewestFirst ? 'Newest first' : 'Oldest first',
            onPressed: () {
              setState(() {
                _sortNewestFirst = !_sortNewestFirst;
              });
            },
          ),
          // Filter button
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by service type',
            onSelected: (value) {
              setState(() {
                _selectedServiceType = value;
              });
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem<String?>(
                    value: null,
                    child: Text('All Types'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Venue',
                    child: Text('Venues'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Catering',
                    child: Text('Catering'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Photographer',
                    child: Text('Photographers'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Planner',
                    child: Text('Planners'),
                  ),
                ],
          ),
        ],
      ),
      body: Consumer<ComparisonSavingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: ErrorMessage(
                message: provider.error!,
                onRetry: () => provider.refreshData(),
              ),
            );
          }

          // Filter comparisons by service type if selected
          final comparisons =
              _selectedServiceType == null
                  ? provider.savedComparisons
                  : provider.getSavedComparisonsByType(_selectedServiceType!);

          // Sort comparisons by date
          if (_sortNewestFirst) {
            comparisons.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          } else {
            comparisons.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          }

          if (comparisons.isEmpty) {
            return EmptyState(
              icon: Icons.compare_arrows,
              title: 'No Saved Comparisons',
              message:
                  _selectedServiceType == null
                      ? 'You haven\'t saved any comparisons yet.'
                      : 'You haven\'t saved any $_selectedServiceType comparisons yet.',
              actionText: 'Browse Services',
              onAction: () => Navigator.of(context).pop(),
            );
          }

          // Use a responsive layout based on screen size
          return ResponsiveUtils.isTabletOrLarger(context)
              ? _buildTabletLayout(
                comparisons,
                cardColor,
                textColor,
                primaryColor,
              )
              : _buildMobileLayout(
                comparisons,
                cardColor,
                textColor,
                primaryColor,
              );
        },
      ),
    );
  }

  /// Build the mobile layout (list view)
  Widget _buildMobileLayout(
    List<SavedComparison> comparisons,
    Color cardColor,
    Color textColor,
    Color primaryColor,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      itemCount: comparisons.length,
      itemBuilder: (context, index) {
        final comparison = comparisons[index];
        return _buildComparisonCard(
          comparison,
          cardColor,
          textColor,
          primaryColor,
        );
      },
    );
  }

  /// Build the tablet layout (grid view)
  Widget _buildTabletLayout(
    List<SavedComparison> comparisons,
    Color cardColor,
    Color textColor,
    Color primaryColor,
  ) {
    final columns = ResponsiveConstants.getGridColumns(context);

    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 1.5,
        crossAxisSpacing: AppConstants.mediumPadding,
        mainAxisSpacing: AppConstants.mediumPadding,
      ),
      itemCount: comparisons.length,
      itemBuilder: (context, index) {
        final comparison = comparisons[index];
        return _buildComparisonCard(
          comparison,
          cardColor,
          textColor,
          primaryColor,
        );
      },
    );
  }

  /// Build a card for a saved comparison
  Widget _buildComparisonCard(
    SavedComparison comparison,
    Color cardColor,
    Color textColor,
    Color primaryColor,
  ) {
    return Card(
      elevation: AppConstants.mediumElevation,
      margin: const EdgeInsets.only(bottom: AppConstants.mediumPadding),
      child: InkWell(
        onTap: () => _viewComparison(comparison),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.mediumPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and service type
              Row(
                children: [
                  Expanded(
                    child: Text(
                      comparison.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.smallPadding,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withAlpha(50),
                      borderRadius: BorderRadius.circular(
                        AppConstants.smallBorderRadius,
                      ),
                    ),
                    child: Text(
                      comparison.serviceType,
                      style: TextStyle(
                        fontSize: 12,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.smallPadding),

              // Services being compared
              Text(
                'Comparing: ${comparison.serviceNames.join(', ')}',
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppConstants.smallPadding),

              // Date and event info
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: textColor.withAlpha(150),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(comparison.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withAlpha(150),
                    ),
                  ),
                  if (comparison.eventName != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.event,
                      size: 14,
                      color: textColor.withAlpha(150),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        comparison.eventName!,
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withAlpha(150),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: AppConstants.mediumPadding),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // View button
                  TextButton.icon(
                    icon: const Icon(Icons.visibility),
                    label: const Text('View'),
                    onPressed: () => _viewComparison(comparison),
                  ),
                  // Edit button
                  TextButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    onPressed: () => _editComparison(comparison),
                  ),
                  // Delete button
                  TextButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    onPressed: () => _deleteComparison(comparison),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Format a date for display
  String _formatDate(DateTime date) {
    // Format as DD/MM/YYYY with leading zeros
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// View a saved comparison
  void _viewComparison(SavedComparison comparison) {
    // Show a dialog with the comparison details for now
    // In the future, this will navigate to the comparison screen with the saved services
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(comparison.title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service type
                  Text(
                    'Service Type: ${comparison.serviceType}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Services being compared
                  const Text(
                    'Services:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...comparison.serviceNames.map(
                    (name) => Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Text('• $name'),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Date
                  Text(
                    'Saved on: ${_formatDate(comparison.createdAt)}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 8),

                  // Notes
                  if (comparison.notes.isNotEmpty) ...[
                    const Text(
                      'Notes:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Text(comparison.notes),
                    ),
                  ],

                  // Event info
                  if (comparison.eventName != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Event: ${comparison.eventName}',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  /// Edit a saved comparison
  void _editComparison(SavedComparison comparison) {
    // Show a dialog to edit the comparison title and notes
    showDialog(
      context: context,
      builder:
          (context) => _EditComparisonDialog(
            comparison: comparison,
            onSave: (updatedComparison) {
              // Refresh the list after saving
              Provider.of<ComparisonSavingProvider>(
                context,
                listen: false,
              ).refreshData();
            },
          ),
    );
  }

  /// Delete a saved comparison
  void _deleteComparison(SavedComparison comparison) {
    // Show a confirmation dialog
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Delete Comparison'),
            content: Text(
              'Are you sure you want to delete "${comparison.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Store a reference to the provider
                  final provider = Provider.of<ComparisonSavingProvider>(
                    context,
                    listen: false,
                  );

                  // Close the dialog
                  Navigator.of(dialogContext).pop();

                  // Delete the comparison
                  provider.deleteSavedComparison(comparison.id).then((success) {
                    if (success && mounted) {
                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Comparison deleted successfully'),
                        ),
                      );

                      // Refresh the list
                      provider.refreshData();
                    } else if (mounted) {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to delete comparison: ${provider.error}',
                          ),
                        ),
                      );
                    }
                  });
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}

/// Dialog to edit a saved comparison
class _EditComparisonDialog extends StatefulWidget {
  /// The comparison to edit
  final SavedComparison comparison;

  /// Callback when the comparison is saved
  final Function(SavedComparison)? onSave;

  /// Constructor
  const _EditComparisonDialog({required this.comparison, this.onSave});

  @override
  State<_EditComparisonDialog> createState() => _EditComparisonDialogState();
}

class _EditComparisonDialogState extends State<_EditComparisonDialog> {
  /// Controller for the title field
  late TextEditingController _titleController;

  /// Controller for the notes field
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.comparison.title);
    _notesController = TextEditingController(text: widget.comparison.notes);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Comparison'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title field with validation
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter a title for this comparison',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            // Notes field
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Enter any notes about this comparison',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Validate title is not empty
            if (_titleController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a title for the comparison'),
                ),
              );
              return;
            }

            // Update the comparison
            final updatedComparison = widget.comparison.copyWith(
              title: _titleController.text.trim(),
              notes: _notesController.text.trim(),
            );

            // Store a reference to the provider
            final provider = Provider.of<ComparisonSavingProvider>(
              context,
              listen: false,
            );

            // Close the dialog
            Navigator.of(context).pop();

            // Store a reference to the scaffold messenger
            final scaffoldMessenger = ScaffoldMessenger.of(context);

            // Update the comparison using the provider
            provider.updateSavedComparison(updatedComparison).then((success) {
              if (mounted) {
                if (success) {
                  // Show success message
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Comparison updated successfully'),
                    ),
                  );

                  // Call the onSave callback if provided
                  if (widget.onSave != null) {
                    widget.onSave!(updatedComparison);
                  }
                } else {
                  // Show error message
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to update comparison: ${provider.error}',
                      ),
                    ),
                  );
                }
              }
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
