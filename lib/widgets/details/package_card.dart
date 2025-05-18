import 'package:flutter/material.dart';
import 'package:eventati_book/utils/utils.dart';

import 'package:eventati_book/styles/text_styles.dart';


class PackageCard extends StatelessWidget {
  final String name;
  final String description;
  final double price;
  final List<String> includedItems;
  final List<String> additionalFeatures;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? additionalInfo;

  const PackageCard({
    super.key,
    required this.name,
    required this.description,
    required this.price,
    required this.includedItems,
    required this.additionalFeatures,
    required this.isSelected,
    required this.onTap,
    this.additionalInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(name, style: TextStyles.sectionTitle)),
                  Text(
                    NumberUtils.formatCurrency(price, decimalPlaces: 0),
                    style: TextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(description),
              if (additionalInfo != null) ...[
                const SizedBox(height: 8),
                // Use the non-null additionalInfo directly
                additionalInfo!,
              ],
              const SizedBox(height: 16),
              const Text(
                'Included Services:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...includedItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Additional Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...additionalFeatures.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.add_circle, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(feature)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (isSelected)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Selected',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
