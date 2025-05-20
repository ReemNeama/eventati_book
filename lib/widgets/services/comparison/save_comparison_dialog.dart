import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// Dialog for saving a comparison
class SaveComparisonDialog extends StatefulWidget {
  /// The type of service being compared
  final String serviceType;

  /// The list of service IDs being compared
  final List<String> serviceIds;

  /// The list of service names being compared
  final List<String> serviceNames;

  /// Optional event ID to associate with the comparison
  final String? eventId;

  /// Optional event name to associate with the comparison
  final String? eventName;

  /// Callback when the comparison is saved
  final Function(SavedComparison)? onSaved;

  /// Constructor
  const SaveComparisonDialog({
    super.key,
    required this.serviceType,
    required this.serviceIds,
    required this.serviceNames,
    this.eventId,
    this.eventName,
    this.onSaved,
  });

  @override
  State<SaveComparisonDialog> createState() => _SaveComparisonDialogState();
}

class _SaveComparisonDialogState extends State<SaveComparisonDialog> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Set default title based on service type
    _titleController.text = '${widget.serviceType} Comparison';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveComparison() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final provider = Provider.of<ComparisonSavingProvider>(
        context,
        listen: false,
      );

      final success = await provider.saveComparison(
        serviceType: widget.serviceType,
        serviceIds: widget.serviceIds,
        serviceNames: widget.serviceNames,
        title: _titleController.text.trim(),
        notes: _notesController.text.trim(),
        eventId: widget.eventId,
        eventName: widget.eventName,
      );

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();

          // Get the saved comparison and call the onSaved callback
          if (widget.onSaved != null) {
            final comparisons = provider.savedComparisons;
            if (comparisons.isNotEmpty) {
              widget.onSaved!(comparisons.first);
            }
          }

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comparison saved successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = provider.error ?? 'Failed to save comparison';
          _isSaving = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor =
        isDarkMode
            ? Color.fromRGBO(
              AppColors.primary.r.toInt(),
              AppColors.primary.g.toInt(),
              AppColors.primary.b.toInt(),
              0.8,
            )
            : AppColors.primary;

    return AlertDialog(
      title: const Text(
        'Save Comparison',
        style: TextStyle(fontWeight: FontWeight.bold),
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
                  hintText: 'Enter a title for this comparison',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes field
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Add any notes about this comparison',
                ),
                maxLines: 3,
              ),

              // Services being compared
              const SizedBox(height: 16),
              Text('Services being compared:', style: TextStyles.bodyMedium),
              const SizedBox(height: 8),
              ...widget.serviceNames.map(
                (name) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• $name', style: TextStyles.bodySmall),
                ),
              ),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: primaryColor)),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveComparison,
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          child:
              _isSaving
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Text('Save'),
        ),
      ],
    );
  }
}
