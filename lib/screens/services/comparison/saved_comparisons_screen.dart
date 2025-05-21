import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/models/feature_models/comparison_annotation.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/services/sharing/platform_sharing_service.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/utils/service/pdf_export_utils.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';
import 'package:eventati_book/widgets/common/error_message.dart';
import 'package:eventati_book/widgets/services/comparison/annotation_dialog.dart';
import 'package:eventati_book/styles/text_styles.dart';

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
              onAction: () => NavigationUtils.pop(context),
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
                      style: TextStyles.sectionTitle,
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
                      style: TextStyles.bodySmall,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.smallPadding),

              // Services being compared
              Text(
                'Comparing: ${comparison.serviceNames.join(', ')}',
                style: TextStyles.bodyMedium,
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
                    style: TextStyles.bodySmall,
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
                        style: TextStyles.bodySmall,
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
                  // Annotations button
                  TextButton.icon(
                    icon: const Icon(Icons.note_add),
                    label: const Text('Notes'),
                    onPressed: () => _manageAnnotations(comparison),
                  ),
                  // Share button
                  TextButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    onPressed: () => _shareComparison(comparison),
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
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
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
                onPressed: () => NavigationUtils.pop(context),
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

  /// Manage annotations for a saved comparison
  void _manageAnnotations(SavedComparison comparison) {
    // Get the list of annotations (or empty list if null)
    final annotations = comparison.annotations ?? [];

    // Show a dialog with the list of annotations
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('Annotations for ${comparison.title}'),
            content: SizedBox(
              width: double.maxFinite,
              child:
                  annotations.isEmpty
                      ? const Center(
                        child: Text(
                          'No annotations yet. Add notes and highlights to help you remember important details.',
                          textAlign: TextAlign.center,
                        ),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: annotations.length,
                        itemBuilder: (context, index) {
                          final annotation = annotations[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(annotation.title),
                              subtitle: Text(
                                annotation.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: annotation.color,
                                child: const Icon(
                                  Icons.note,
                                  color: Colors.white,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  // Remove the annotation
                                  final updatedAnnotations =
                                      List<ComparisonAnnotation>.from(
                                        annotations,
                                      );
                                  updatedAnnotations.removeAt(index);

                                  // Store the dialog context navigator
                                  final navigator = Navigator.of(dialogContext);

                                  // Update the comparison
                                  _updateComparisonAnnotations(
                                    comparison,
                                    updatedAnnotations,
                                    navigator,
                                  );
                                },
                              ),
                              onTap: () {
                                // Edit the annotation
                                _editAnnotation(
                                  comparison,
                                  annotation,
                                  annotations,
                                  dialogContext,
                                );
                              },
                            ),
                          );
                        },
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  // Add a new annotation
                  _addAnnotation(comparison, annotations, dialogContext);
                },
                child: const Text('Add Annotation'),
              ),
            ],
          ),
    );
  }

  /// Add a new annotation to a comparison
  void _addAnnotation(
    SavedComparison comparison,
    List<ComparisonAnnotation> existingAnnotations,
    BuildContext dialogContext,
  ) {
    // Create lists of service IDs and names for the dropdown
    final serviceIds = comparison.serviceIds;
    final serviceNames = comparison.serviceNames;

    // Create a list of common features for the dropdown
    final features = [
      'Price',
      'Quality',
      'Availability',
      'Location',
      'Amenities',
      'Reviews',
      'Packages',
      'Staff',
    ];

    // Show the annotation dialog
    // Store the navigator before the async operation
    final navigator = Navigator.of(dialogContext);

    showDialog(
      context: dialogContext,
      builder:
          (context) => AnnotationDialog(
            serviceIds: serviceIds,
            serviceNames: serviceNames,
            features: features,
          ),
    ).then((result) {
      if (result != null && result is ComparisonAnnotation) {
        // Add the new annotation to the list
        final updatedAnnotations = List<ComparisonAnnotation>.from(
          existingAnnotations,
        );
        updatedAnnotations.add(result);

        // Update the comparison
        if (mounted) {
          _updateComparisonAnnotations(
            comparison,
            updatedAnnotations,
            navigator,
          );
        }
      }
    });
  }

  /// Edit an existing annotation
  void _editAnnotation(
    SavedComparison comparison,
    ComparisonAnnotation annotation,
    List<ComparisonAnnotation> existingAnnotations,
    BuildContext dialogContext,
  ) {
    // Create lists of service IDs and names for the dropdown
    final serviceIds = comparison.serviceIds;
    final serviceNames = comparison.serviceNames;

    // Create a list of common features for the dropdown
    final features = [
      'Price',
      'Quality',
      'Availability',
      'Location',
      'Amenities',
      'Reviews',
      'Packages',
      'Staff',
    ];

    // Show the annotation dialog
    // Store the navigator before the async operation
    final navigator = Navigator.of(dialogContext);

    showDialog(
      context: dialogContext,
      builder:
          (context) => AnnotationDialog(
            annotation: annotation,
            serviceIds: serviceIds,
            serviceNames: serviceNames,
            features: features,
          ),
    ).then((result) {
      if (result != null && result is ComparisonAnnotation) {
        // Replace the edited annotation in the list
        final updatedAnnotations = List<ComparisonAnnotation>.from(
          existingAnnotations,
        );
        final index = updatedAnnotations.indexWhere(
          (a) => a.id == annotation.id,
        );
        if (index != -1) {
          updatedAnnotations[index] = result;

          // Update the comparison
          if (mounted) {
            _updateComparisonAnnotations(
              comparison,
              updatedAnnotations,
              navigator,
            );
          }
        }
      }
    });
  }

  /// Update the annotations for a comparison
  void _updateComparisonAnnotations(
    SavedComparison comparison,
    List<ComparisonAnnotation> annotations,
    NavigatorState navigator,
  ) {
    // Create an updated comparison with the new annotations
    final updatedComparison = comparison.copyWith(annotations: annotations);

    // Store a reference to the provider and scaffold messenger
    final provider = Provider.of<ComparisonSavingProvider>(
      context,
      listen: false,
    );
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Update the comparison
    provider.updateSavedComparison(updatedComparison).then((success) {
      if (success && mounted) {
        // Show success message
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Annotations updated successfully')),
        );

        // Refresh the list
        provider.refreshData();

        // Close the dialog if it's still open and we're still mounted
        if (mounted && navigator.canPop()) {
          navigator.pop();
        }

        // Show the annotations dialog again with the updated list
        if (mounted) {
          _manageAnnotations(updatedComparison);
        }
      } else if (mounted) {
        // Show error message
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed to update annotations: ${provider.error}'),
          ),
        );
      }
    });
  }

  /// Share a comparison as a PDF
  void _shareComparison(SavedComparison comparison) {
    // Show a dialog with sharing options
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Share Comparison'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: const Text('Export as PDF'),
                  subtitle: const Text(
                    'Create a PDF document of this comparison',
                  ),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    _exportToPDF(comparison);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.print),
                  title: const Text('Print'),
                  subtitle: const Text('Print this comparison'),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    _printComparison(comparison);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: const Text('Send this comparison via email'),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    _emailComparison(comparison);
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
                      comparison,
                      SharingPlatform.facebook,
                      Icons.facebook,
                      'Facebook',
                    ),
                    // Twitter share button
                    _buildSocialShareButton(
                      dialogContext,
                      comparison,
                      SharingPlatform.twitter,
                      Icons.flutter_dash,
                      'Twitter',
                    ),
                    // WhatsApp share button
                    _buildSocialShareButton(
                      dialogContext,
                      comparison,
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
    SavedComparison comparison,
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
              ).shareComparisonToPlatform(comparison, platform);

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

  /// Export a comparison to PDF
  Future<void> _exportToPDF(SavedComparison comparison) async {
    try {
      // Show a loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating PDF...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Generate the PDF
      final pdfBytes = await PDFExportUtils.generateComparisonPDF(
        comparison,
        includeNotes: true,
        includeHighlights: true,
      );

      // Create a filename
      final fileName =
          '${comparison.title.replaceAll(' ', '_')}_comparison.pdf';

      // Share the PDF
      await PDFExportUtils.sharePDF(
        pdfBytes,
        fileName,
        subject: 'Eventati Book Comparison: ${comparison.title}',
        text:
            'Here is your comparison of ${comparison.serviceNames.join(', ')}.',
      );
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to export PDF: $e')));
      }
    }
  }

  /// Print a comparison
  Future<void> _printComparison(SavedComparison comparison) async {
    try {
      // Show a loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preparing document for printing...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Generate the PDF
      final pdfBytes = await PDFExportUtils.generateComparisonPDF(
        comparison,
        includeNotes: true,
        includeHighlights: true,
      );

      // Print the PDF
      await PDFExportUtils.printPDF(
        pdfBytes,
        'Eventati Book Comparison: ${comparison.title}',
      );
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to print comparison: $e')),
        );
      }
    }
  }

  /// Email a comparison
  Future<void> _emailComparison(SavedComparison comparison) async {
    try {
      // Show a loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preparing email...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Generate the PDF
      final pdfBytes = await PDFExportUtils.generateComparisonPDF(
        comparison,
        includeNotes: true,
        includeHighlights: true,
      );

      // Create a filename
      final fileName =
          '${comparison.title.replaceAll(' ', '_')}_comparison.pdf';

      // Save the PDF to a file
      final filePath = await PDFExportUtils.savePDF(pdfBytes, fileName);

      // Share the PDF via email
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Eventati Book Comparison: ${comparison.title}',
        text:
            'Here is your comparison of ${comparison.serviceNames.join(', ')}.',
      );
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to email comparison: $e')),
        );
      }
    }
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
                onPressed: () => NavigationUtils.pop(dialogContext),
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
                  NavigationUtils.pop(dialogContext);

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
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
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
          onPressed: () => NavigationUtils.pop(context),
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
            NavigationUtils.pop(context);

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
