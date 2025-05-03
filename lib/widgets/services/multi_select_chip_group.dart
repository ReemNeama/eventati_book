import 'package:flutter/material.dart';

class MultiSelectChipGroup extends StatelessWidget {
  final String title;
  final List<String> options;
  final List<String> selectedOptions;
  final Function(String, bool) onOptionSelected;

  const MultiSelectChipGroup({
    super.key,
    required this.title,
    required this.options,
    required this.selectedOptions,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              options.map((option) {
                final isSelected = selectedOptions.contains(option);
                return FilterChip(
                  label: Text(
                    option,
                    style: TextStyle(
                      color:
                          isSelected
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Theme.of(context).primaryColor,
                  backgroundColor: Colors.white,
                  checkmarkColor: Colors.white,
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  onSelected: (bool selected) {
                    onOptionSelected(option, selected);
                  },
                );
              }).toList(),
        ),
      ],
    );
  }
}
