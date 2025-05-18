import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/screens/event_planning/budget/budget_details_screen.dart';
import 'package:eventati_book/screens/event_planning/budget/budget_item_form_screen.dart';
import 'package:eventati_book/styles/text_styles.dart';

class BudgetOverviewScreen extends StatelessWidget {
  final String eventId;
  final String eventName;

  const BudgetOverviewScreen({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return ChangeNotifierProvider(
      create: (_) => BudgetProvider(eventId: eventId),
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          title: Text('Budget for $eventName', style: TextStyles.subtitle),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Consumer<BudgetProvider>(
          builder: (context, budgetProvider, _) {
            if (budgetProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (budgetProvider.error != null) {
              return Center(
                child: Text(
                  'Error: ${budgetProvider.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? Color.fromRGBO(
                          AppColors.disabled.r.toInt(),
                          AppColors.disabled.g.toInt(),
                          AppColors.disabled.b.toInt(),
                          0.9,
                        )
                        : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  _buildBudgetSummary(context, budgetProvider),
                  _buildCategoryList(context, budgetProvider),
                ],
              ),
            );
          },
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
                      eventId: eventId,
                      budgetProvider: Provider.of<BudgetProvider>(
                        context,
                        listen: false,
                      ),
                    ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBudgetSummary(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryCard(
                context,
                'Estimated',
                ServiceUtils.formatPrice(
                  budgetProvider.totalEstimated,
                  decimalPlaces: 0,
                ),
                Icons.calculate,
                primaryColor,
              ),
              _buildSummaryCard(
                context,
                'Actual',
                ServiceUtils.formatPrice(
                  budgetProvider.totalActual,
                  decimalPlaces: 0,
                ),
                Icons.receipt_long,
                AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryCard(
                context,
                'Paid',
                ServiceUtils.formatPrice(
                  budgetProvider.totalPaid,
                  decimalPlaces: 0,
                ),
                Icons.check_circle,
                AppColors.success,
              ),
              _buildSummaryCard(
                context,
                'Remaining',
                ServiceUtils.formatPrice(
                  budgetProvider.totalRemaining,
                  decimalPlaces: 0,
                ),
                Icons.pending,
                AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Categories', style: TextStyles.sectionTitle),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => BudgetDetailsScreen(
                            eventId: eventId,
                            eventName: eventName,
                          ),
                    ),
                  );
                },
                child: Text(
                  'View All Items',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String amount,
    IconData icon,
    Color color,
  ) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final cardColor =
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
              0.1,
            );

    return Container(
      width: MediaQuery.of(context).size.width * 0.43,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyles.bodyMedium),
            ],
          ),
          const SizedBox(height: 8),
          Text(amount, style: TextStyles.sectionTitle),
        ],
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final categoryTotals = budgetProvider.getCategoryTotals();

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: budgetProvider.categories.length,
        itemBuilder: (context, index) {
          final category = budgetProvider.categories[index];
          final categoryItems = budgetProvider.getItemsByCategory(category.id);
          final categoryTotal = categoryTotals[category.id] ?? 0;

          if (categoryItems.isEmpty) {
            return const SizedBox.shrink();
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor:
                    isDarkMode ? AppColorsDark.primary : AppColors.primary,
                child: Icon(category.icon, color: Colors.white, size: 20),
              ),
              title: Text(
                category.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${categoryItems.length} items',
                style: TextStyles.bodySmall,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    ServiceUtils.formatPrice(categoryTotal, decimalPlaces: 0),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${((categoryTotal / budgetProvider.totalEstimated) * 100).toStringAsFixed(0)}%',
                    style: TextStyles.bodySmall,
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => BudgetDetailsScreen(
                          eventId: eventId,
                          eventName: eventName,
                          initialCategoryId: category.id,
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
}
