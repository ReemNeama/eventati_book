import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/budget_provider.dart';
import 'package:eventati_book/models/budget_item.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/screens/event_planning/budget/budget_item_form_screen.dart';

class BudgetDetailsScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  final String? initialCategoryId;

  const BudgetDetailsScreen({
    super.key,
    required this.eventId,
    required this.eventName,
    this.initialCategoryId,
  });

  @override
  State<BudgetDetailsScreen> createState() => _BudgetDetailsScreenState();
}

class _BudgetDetailsScreenState extends State<BudgetDetailsScreen> {
  String? _selectedCategoryId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return ChangeNotifierProvider(
      create: (_) => BudgetProvider(eventId: widget.eventId),
      child: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, _) {
          if (budgetProvider.isLoading) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Budget for ${widget.eventName}'),
                backgroundColor: primaryColor,
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          final filteredItems = _getFilteredItems(budgetProvider);

          return Scaffold(
            appBar: AppBar(
              title: Text('Budget for ${widget.eventName}'),
              backgroundColor: primaryColor,
            ),
            body: Column(
              children: [
                _buildFilterBar(context, budgetProvider),
                Expanded(
                  child:
                      filteredItems.isEmpty
                          ? Center(
                            child: Text(
                              'No budget items found',
                              style: TextStyle(
                                color:
                                    isDarkMode
                                        ? Colors.white70
                                        : Colors.black54,
                              ),
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              return _buildBudgetItemCard(
                                context,
                                filteredItems[index],
                                budgetProvider,
                              );
                            },
                          ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: primaryColor,
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => BudgetItemFormScreen(
                          eventId: widget.eventId,
                          budgetProvider: budgetProvider,
                          initialCategoryId: _selectedCategoryId,
                        ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  List<BudgetItem> _getFilteredItems(BudgetProvider budgetProvider) {
    var items = budgetProvider.items;

    // Filter by category if selected
    if (_selectedCategoryId != null) {
      items =
          items
              .where((item) => item.categoryId == _selectedCategoryId)
              .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      items =
          items
              .where(
                (item) => item.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();
    }

    return items;
  }

  Widget _buildFilterBar(BuildContext context, BudgetProvider budgetProvider) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final backgroundColor = isDarkMode ? Colors.grey[800] : Colors.grey[200];

    return Container(
      padding: const EdgeInsets.all(16),
      color: backgroundColor,
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search budget items...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDarkMode ? Colors.grey[700] : Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          // Category filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip(
                  context,
                  null,
                  'All',
                  Icons.list,
                  primaryColor,
                ),
                ...budgetProvider.categories.map((category) {
                  return _buildCategoryChip(
                    context,
                    category.id,
                    category.name,
                    category.icon,
                    primaryColor,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String? categoryId,
    String label,
    IconData icon,
    Color primaryColor,
  ) {
    final isSelected = _selectedCategoryId == categoryId;
    final isDarkMode = UIUtils.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        avatar: Icon(
          icon,
          size: 18,
          color:
              isSelected
                  ? Colors.white
                  : isDarkMode
                  ? Colors.white
                  : primaryColor,
        ),
        backgroundColor: isDarkMode ? Colors.grey[700] : Colors.white,
        selectedColor: primaryColor,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color:
              isSelected
                  ? Colors.white
                  : isDarkMode
                  ? Colors.white
                  : Colors.black,
        ),
        onSelected: (selected) {
          setState(() {
            _selectedCategoryId = selected ? categoryId : null;
          });
        },
      ),
    );
  }

  Widget _buildBudgetItemCard(
    BuildContext context,
    BudgetItem item,
    BudgetProvider budgetProvider,
  ) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final category = budgetProvider.categories.firstWhere(
      (c) => c.id == item.categoryId,
      orElse:
          () =>
              BudgetCategory(id: '', name: 'Unknown', icon: Icons.help_outline),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryColor,
                  radius: 16,
                  child: Icon(category.icon, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (item.isPaid)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(51), // 0.2 * 255 = 51
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Paid',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.description,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    Text(
                      ServiceUtils.formatPrice(
                        item.estimatedCost,
                        decimalPlaces: 0,
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                if (item.actualCost != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Actual',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      Text(
                        ServiceUtils.formatPrice(
                          item.actualCost!,
                          decimalPlaces: 0,
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (item.notes != null && item.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Notes:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Text(
                item.notes!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => BudgetItemFormScreen(
                              eventId: widget.eventId,
                              budgetProvider: budgetProvider,
                              item: item,
                            ),
                      ),
                    );
                  },
                  child: Text('Edit', style: TextStyle(color: primaryColor)),
                ),
                TextButton(
                  onPressed: () {
                    _showDeleteConfirmation(context, item, budgetProvider);
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    BudgetItem item,
    BudgetProvider budgetProvider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Budget Item'),
            content: Text(
              'Are you sure you want to delete "${item.description}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  budgetProvider.deleteBudgetItem(item.id);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
