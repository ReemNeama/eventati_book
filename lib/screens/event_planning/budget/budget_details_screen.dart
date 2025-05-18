import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';
import 'package:eventati_book/widgets/common/responsive_layout.dart';
import 'package:eventati_book/screens/event_planning/budget/budget_item_form_screen.dart';
import 'package:eventati_book/styles/text_styles.dart';

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
            body: ResponsiveLayout(
              // Mobile layout (portrait phones)
              mobileLayout: Column(
                children: [
                  _buildFilterBar(context, budgetProvider),
                  Expanded(
                    child: _buildBudgetItemsList(filteredItems, budgetProvider),
                  ),
                ],
              ),
              // Tablet layout (landscape phones and tablets)
              tabletLayout: _buildTabletLayout(filteredItems, budgetProvider),
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

  /// Builds the tablet layout with a side panel for budget summary
  Widget _buildTabletLayout(
    List<BudgetItem> filteredItems,
    BudgetProvider budgetProvider,
  ) {
    return Row(
      children: [
        // Left panel: Filter bar and budget items list (70% width)
        Expanded(
          flex: 70,
          child: Column(
            children: [
              _buildFilterBar(context, budgetProvider),
              Expanded(
                child: _buildBudgetItemsList(filteredItems, budgetProvider),
              ),
            ],
          ),
        ),
        // Vertical divider
        VerticalDivider(
          width: 1,
          thickness: 1,
          color:
              UIUtils.isDarkMode(context)
                  ? Color.fromRGBO(
                    AppColors.disabled.r.toInt(),
                    AppColors.disabled.g.toInt(),
                    AppColors.disabled.b.toInt(),
                    0.8,
                  )
                  : Color.fromRGBO(
                    AppColors.disabled.r.toInt(),
                    AppColors.disabled.g.toInt(),
                    AppColors.disabled.b.toInt(),
                    0.3,
                  ),
        ),
        // Right panel: Budget summary (30% width)
        Expanded(flex: 30, child: _buildBudgetSummary(budgetProvider)),
      ],
    );
  }

  /// Builds the list of budget items or empty state
  Widget _buildBudgetItemsList(
    List<BudgetItem> filteredItems,
    BudgetProvider budgetProvider,
  ) {
    return filteredItems.isEmpty
        ? Center(
          child:
              budgetProvider.items.isEmpty
                  ? EmptyStateUtils.getEmptyBudgetState(
                    actionText: 'Add Item',
                    onAction: () {
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
                  )
                  : EmptyState(
                    title: 'No Matching Items',
                    message: 'No budget items match your current filters',
                    icon: Icons.filter_alt_off,
                    actionText: 'Clear Filters',
                    onAction: () {
                      setState(() {
                        _selectedCategoryId = null;
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
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
        );
  }

  /// Builds a summary of the budget with totals and category breakdown
  Widget _buildBudgetSummary(BudgetProvider budgetProvider) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    // Calculate budget totals
    double totalEstimated = 0;
    double totalActual = 0;
    double totalRemaining = 0;

    for (final item in budgetProvider.items) {
      totalEstimated += item.estimatedCost;
      if (item.actualCost != null) {
        totalActual += item.actualCost!;
      }
    }

    totalRemaining = totalEstimated - totalActual;

    // Group items by category
    final Map<String, double> categoryTotals = {};

    for (final item in budgetProvider.items) {
      final categoryId = item.categoryId;
      if (!categoryTotals.containsKey(categoryId)) {
        categoryTotals[categoryId] = 0;
      }
      categoryTotals[categoryId] =
          categoryTotals[categoryId]! + item.estimatedCost;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Budget Summary', style: TextStyles.subtitle.copyWith()),
          const SizedBox(height: 24),

          // Budget totals
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Totals',
                    style: TextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBudgetSummaryRow(
                    'Estimated',
                    totalEstimated,
                    primaryColor,
                  ),
                  const SizedBox(height: 8),
                  _buildBudgetSummaryRow(
                    'Actual',
                    totalActual,
                    AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  _buildBudgetSummaryRow(
                    'Remaining',
                    totalRemaining,
                    totalRemaining >= 0 ? AppColors.success : AppColors.error,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Category breakdown
          Text(
            'Category Breakdown',
            style: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...categoryTotals.entries.map((entry) {
            final category = budgetProvider.categories.firstWhere(
              (c) => c.id == entry.key,
              orElse:
                  () => BudgetCategory(
                    id: '',
                    name: 'Unknown',
                    icon: Icons.help_outline,
                  ),
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        isDarkMode
                            ? Color.fromRGBO(
                              AppColors.disabled.r.toInt(),
                              AppColors.disabled.g.toInt(),
                              AppColors.disabled.b.toInt(),
                              0.8,
                            )
                            : Color.fromRGBO(
                              AppColors.disabled.r.toInt(),
                              AppColors.disabled.g.toInt(),
                              AppColors.disabled.b.toInt(),
                              0.2,
                            ),
                    radius: 16,
                    child: Icon(category.icon, color: primaryColor, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(category.name, style: TextStyles.bodyMedium),
                  ),
                  Text(
                    ServiceUtils.formatPrice(entry.value, decimalPlaces: 0),
                    style: TextStyles.bodyMedium,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Builds a row for the budget summary
  Widget _buildBudgetSummaryRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyles.bodyMedium),
        Text(
          ServiceUtils.formatPrice(amount, decimalPlaces: 0),
          style: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context, BudgetProvider budgetProvider) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final backgroundColor =
        isDarkMode
            ? Color.fromRGBO(
              AppColors.disabled.r.toInt(),
              AppColors.disabled.g.toInt(),
              AppColors.disabled.b.toInt(),
              0.8,
            )
            : Color.fromRGBO(
              AppColors.disabled.r.toInt(),
              AppColors.disabled.g.toInt(),
              AppColors.disabled.b.toInt(),
              0.2,
            );

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
              fillColor:
                  isDarkMode
                      ? Color.fromRGBO(
                        AppColors.disabled.r.toInt(),
                        AppColors.disabled.g.toInt(),
                        AppColors.disabled.b.toInt(),
                        0.7,
                      )
                      : Colors.white,
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
        backgroundColor:
            isDarkMode
                ? Color.fromRGBO(
                  AppColors.disabled.r.toInt(),
                  AppColors.disabled.g.toInt(),
                  AppColors.disabled.b.toInt(),
                  0.7,
                )
                : Colors.white,
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
                Text(category.name, style: TextStyles.bodyMedium),
                const Spacer(),
                if (item.isPaid)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(
                        AppColors.success.r.toInt(),
                        AppColors.success.g.toInt(),
                        AppColors.success.b.toInt(),
                        0.20,
                      ), // 0.2 * 255 = 51
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text('Paid', style: TextStyles.bodySmall),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.description,
              style: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estimated', style: TextStyles.bodySmall),
                    Text(
                      ServiceUtils.formatPrice(
                        item.estimatedCost,
                        decimalPlaces: 0,
                      ),
                      style: TextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (item.actualCost != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Actual', style: TextStyles.bodySmall),
                      Text(
                        ServiceUtils.formatPrice(
                          item.actualCost!,
                          decimalPlaces: 0,
                        ),
                        style: TextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (item.notes != null && item.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Notes:', style: TextStyles.bodySmall),
              Text(item.notes!, style: TextStyles.bodyMedium),
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
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }
}
