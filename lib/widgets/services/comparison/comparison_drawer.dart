import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/services/comparison/feature_comparison_table.dart';
import 'package:eventati_book/widgets/services/comparison/comparison_item_card.dart';
import 'package:eventati_book/widgets/services/comparison/save_comparison_dialog.dart';

/// A drawer for quick comparison of services
class ComparisonDrawer extends StatelessWidget {
  /// The services to compare
  final List<dynamic> services;

  /// The type of service being compared
  final String serviceType;

  /// Callback when the full comparison button is pressed
  final VoidCallback? onFullComparisonPressed;

  /// Callback when the save comparison button is pressed
  final VoidCallback? onSaveComparisonPressed;

  /// Callback when the share comparison button is pressed
  final VoidCallback? onShareComparisonPressed;

  /// Callback when a service is removed from comparison
  final Function(dynamic)? onRemoveService;

  /// Constructor
  const ComparisonDrawer({
    super.key,
    required this.services,
    required this.serviceType,
    this.onFullComparisonPressed,
    this.onSaveComparisonPressed,
    this.onShareComparisonPressed,
    this.onRemoveService,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = UIUtils.isDarkMode(context);
    final Color primaryColor =
        isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: primaryColor,
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quick Comparison',
                    style: TextStyles.subtitle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
          ),

          // Service cards
          Container(
            height: 160,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return SizedBox(
                  width: 200,
                  child: Stack(
                    children: [
                      ComparisonItemCard(
                        service: service,
                        serviceType: serviceType,
                      ),
                      if (onRemoveService != null)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 12,
                                color: Colors.white,
                              ),
                              onPressed: () => onRemoveService!(service),
                              padding: EdgeInsets.zero,
                              tooltip: 'Remove from comparison',
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          const Divider(),

          // Feature comparison
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Feature Comparison', style: TextStyles.sectionTitle),
                  const SizedBox(height: 8),
                  FeatureComparisonTable(
                    services: services,
                    serviceType: serviceType,
                  ),
                ],
              ),
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black12 : Colors.grey[100],
              border: Border(
                top: BorderSide(
                  color: isDarkMode ? Colors.white24 : Colors.black12,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (onFullComparisonPressed != null)
                    ElevatedButton.icon(
                      onPressed: onFullComparisonPressed,
                      icon: const Icon(Icons.compare_arrows),
                      label: const Text('Full Comparison'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () {
                      // Get service IDs and names
                      final List<String> serviceIds = [];
                      final List<String> serviceNames = [];

                      for (var service in services) {
                        String id = '';
                        String name = '';

                        if (service is Venue) {
                          id = service.name;
                          name = service.name;
                        } else if (service is CateringService) {
                          id = service.name;
                          name = service.name;
                        } else if (service is Photographer) {
                          id = service.name;
                          name = service.name;
                        } else if (service is Planner) {
                          id = service.name;
                          name = service.name;
                        }

                        if (id.isNotEmpty && name.isNotEmpty) {
                          serviceIds.add(id);
                          serviceNames.add(name);
                        }
                      }

                      // Show the save dialog
                      showDialog(
                        context: context,
                        builder:
                            (context) => SaveComparisonDialog(
                              serviceType: serviceType,
                              serviceIds: serviceIds,
                              serviceNames: serviceNames,
                            ),
                      );
                    },
                    tooltip: 'Save comparison',
                  ),
                  if (onShareComparisonPressed != null)
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: onShareComparisonPressed,
                      tooltip: 'Share comparison',
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
