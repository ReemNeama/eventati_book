import 'package:flutter/material.dart';
import 'package:eventati_book/providers/budget_provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:intl/intl.dart';

class BudgetItemFormScreen extends StatefulWidget {
  final String eventId;
  final BudgetProvider budgetProvider;
  final BudgetItem? item;
  final String? initialCategoryId;

  const BudgetItemFormScreen({
    super.key,
    required this.eventId,
    required this.budgetProvider,
    this.item,
    this.initialCategoryId,
  });

  @override
  State<BudgetItemFormScreen> createState() => _BudgetItemFormScreenState();
}

class _BudgetItemFormScreenState extends State<BudgetItemFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _categoryId;
  final _descriptionController = TextEditingController();
  final _estimatedCostController = TextEditingController();
  final _actualCostController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isPaid = false;
  DateTime? _paymentDate;

  @override
  void initState() {
    super.initState();

    if (widget.item != null) {
      // Edit mode - populate form with existing data
      _categoryId = widget.item!.categoryId;
      _descriptionController.text = widget.item!.description;
      _estimatedCostController.text = widget.item!.estimatedCost.toString();
      _actualCostController.text = widget.item!.actualCost?.toString() ?? '';
      _isPaid = widget.item!.isPaid;
      _paymentDate = widget.item!.paymentDate;
      _notesController.text = widget.item!.notes ?? '';
    } else {
      // Create mode - initialize with defaults
      _categoryId =
          widget.initialCategoryId ?? widget.budgetProvider.categories.first.id;
      _isPaid = false;
      _paymentDate = null;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _estimatedCostController.dispose();
    _actualCostController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final isEditing = widget.item != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Budget Item' : 'Add Budget Item'),
        backgroundColor: primaryColor,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Category dropdown
            DropdownButtonFormField<String>(
              value: _categoryId,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items:
                  widget.budgetProvider.categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.id,
                      child: Row(
                        children: [
                          Icon(category.icon, size: 20),
                          const SizedBox(width: 8),
                          Text(category.name),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _categoryId = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Estimated cost
            TextFormField(
              controller: _estimatedCostController,
              decoration: const InputDecoration(
                labelText: 'Estimated Cost',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an estimated cost';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Actual cost
            TextFormField(
              controller: _actualCostController,
              decoration: const InputDecoration(
                labelText: 'Actual Cost (optional)',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Paid status
            SwitchListTile(
              title: const Text('Paid'),
              value: _isPaid,
              activeColor: primaryColor,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  _isPaid = value;
                  if (!value) {
                    _paymentDate = null;
                  } else {
                    _paymentDate ??= DateTime.now();
                  }
                });
              },
            ),

            // Payment date (only shown if paid)
            if (_isPaid) ...[
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Payment Date'),
                subtitle: Text(
                  _paymentDate != null
                      ? DateFormat('MMM d, yyyy').format(_paymentDate!)
                      : 'Select date',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _paymentDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _paymentDate = date;
                    });
                  }
                },
              ),
              const Divider(),
            ],

            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _saveItem,
              child: Text(
                isEditing ? 'Update Item' : 'Add Item',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      // Create or update budget item
      final description = _descriptionController.text;
      final estimatedCost = double.parse(_estimatedCostController.text);
      final actualCostText = _actualCostController.text;
      final actualCost =
          actualCostText.isNotEmpty ? double.parse(actualCostText) : null;
      final notes =
          _notesController.text.isNotEmpty ? _notesController.text : null;

      if (widget.item != null) {
        // Update existing item
        final updatedItem = widget.item!.copyWith(
          categoryId: _categoryId,
          description: description,
          estimatedCost: estimatedCost,
          actualCost: actualCost,
          isPaid: _isPaid,
          paymentDate: _isPaid ? _paymentDate : null,
          notes: notes,
        );

        await widget.budgetProvider.updateBudgetItem(updatedItem);
      } else {
        // Create new item
        final newItem = BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: _categoryId,
          description: description,
          estimatedCost: estimatedCost,
          actualCost: actualCost,
          isPaid: _isPaid,
          paymentDate: _isPaid ? _paymentDate : null,
          notes: notes,
        );

        await widget.budgetProvider.addBudgetItem(newItem);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
