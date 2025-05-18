import 'package:flutter/material.dart';
import 'package:eventati_book/models/feature_models/comparison_annotation.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/ui/ui_utils.dart';
import 'package:eventati_book/utils/utils.dart';

// Constants for padding and border radius
const double smallPadding = 8.0;
const double mediumPadding = 16.0;
const double smallBorderRadius = 8.0;

/// Dialog for adding or editing an annotation
class AnnotationDialog extends StatefulWidget {
  /// The annotation to edit (null for creating a new annotation)
  final ComparisonAnnotation? annotation;

  /// List of service IDs for the dropdown
  final List<String> serviceIds;

  /// List of service names for the dropdown (should match serviceIds)
  final List<String> serviceNames;

  /// List of features for the dropdown
  final List<String> features;

  /// Constructor
  const AnnotationDialog({
    super.key,
    this.annotation,
    required this.serviceIds,
    required this.serviceNames,
    required this.features,
  });

  @override
  State<AnnotationDialog> createState() => _AnnotationDialogState();
}

class _AnnotationDialogState extends State<AnnotationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedServiceId;
  String? _selectedFeature;
  Color _selectedColor = Colors.yellow;

  // Predefined colors for highlights
  final List<Color> _highlightColors = [
    Colors.yellow,
    Color.fromRGBO(AppColors.success.r.toInt(), AppColors.success.g.toInt(), AppColors.success.b.toInt(), 0.2),
    Color.fromRGBO(AppColors.primary.r.toInt(), AppColors.primary.g.toInt(), AppColors.primary.b.toInt(), 0.2),
    Color.fromRGBO(AppColors.error.r.toInt(), AppColors.error.g.toInt(), AppColors.error.b.toInt(), 0.2),
    Colors.purple.shade200,
    Color.fromRGBO(AppColors.warning.r.toInt(), AppColors.warning.g.toInt(), AppColors.warning.b.toInt(), 0.2),
    Colors.pink.shade200,
    Colors.teal.shade200,
  ];

  @override
  void initState() {
    super.initState();

    // If editing an existing annotation, populate the form
    if (widget.annotation != null) {
      _titleController.text = widget.annotation!.title;
      _contentController.text = widget.annotation!.content;
      _selectedServiceId = widget.annotation!.serviceId;
      _selectedFeature = widget.annotation!.feature;
      _selectedColor = widget.annotation!.color;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return AlertDialog(
      title: Text(
        widget.annotation == null ? 'Add Annotation' : 'Edit Annotation',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter a title for this annotation',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: mediumPadding),

              // Content field
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Enter the annotation content',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: mediumPadding),

              // Service dropdown
              if (widget.serviceIds.isNotEmpty)
                DropdownButtonFormField<String?>(
                  decoration: const InputDecoration(
                    labelText: 'Service',
                    hintText: 'Select a service (optional)',
                  ),
                  value: _selectedServiceId,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All Services'),
                    ),
                    ...List.generate(
                      widget.serviceIds.length,
                      (index) => DropdownMenuItem<String?>(
                        value: widget.serviceIds[index],
                        child: Text(widget.serviceNames[index]),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedServiceId = value;
                    });
                  },
                ),
              const SizedBox(height: mediumPadding),

              // Feature dropdown
              if (widget.features.isNotEmpty)
                DropdownButtonFormField<String?>(
                  decoration: const InputDecoration(
                    labelText: 'Feature',
                    hintText: 'Select a feature (optional)',
                  ),
                  value: _selectedFeature,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('General'),
                    ),
                    ...widget.features.map(
                      (feature) => DropdownMenuItem<String?>(
                        value: feature,
                        child: Text(feature),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedFeature = value;
                    });
                  },
                ),
              const SizedBox(height: mediumPadding),

              // Color selection
              Text(
                'Highlight Color',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: smallPadding),
              Wrap(
                spacing: smallPadding,
                runSpacing: smallPadding,
                children:
                    _highlightColors.map((color) {
                      final isSelected =
                          _selectedColor.toARGB32() == color.toARGB32();
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            border: Border.all(
                              color: isSelected ? primaryColor : AppColors.disabled,
                              width: isSelected ? 3 : 1,
                            ),
                            borderRadius: BorderRadius.circular(
                              smallBorderRadius,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              // Create the annotation
              final annotation = ComparisonAnnotation(
                id: widget.annotation?.id,
                title: _titleController.text.trim(),
                content: _contentController.text.trim(),
                serviceId: _selectedServiceId,
                feature: _selectedFeature,
                color: _selectedColor,
                createdAt: widget.annotation?.createdAt,
              );

              // Return the annotation
              Navigator.of(context).pop(annotation);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
