import 'package:flutter/material.dart';
import 'package:eventati_book/models/service_options/catering_options.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// Builder class for catering options form fields
class CateringOptionsBuilder {
  /// Build all catering options form fields
  static List<Widget> buildCateringOptionsFields({
    required BuildContext context,
    required CateringOptions initialOptions,
    required Function(CateringOptions) onOptionsChanged,
  }) {
    // Controllers for text fields
    final customMealServiceController = TextEditingController(
      text: initialOptions.customMealServiceDescription ?? '',
    );
    final customBeverageController = TextEditingController(
      text: initialOptions.customBeverageDescription ?? '',
    );
    final staffCountController = TextEditingController(
      text: initialOptions.staffCount?.toString() ?? '2',
    );

    // Local state
    MealServiceStyle selectedMealStyle = initialOptions.mealServiceStyle;
    BeverageOption selectedBeverageOption = initialOptions.beverageOption;
    List<String> selectedDietaryRestrictions = List.from(
      initialOptions.dietaryRestrictions,
    );
    bool includeStaffService = initialOptions.includeStaffService;

    // Update the options whenever a field changes
    void updateOptions() {
      onOptionsChanged(
        initialOptions.copyWith(
          mealServiceStyle: selectedMealStyle,
          customMealServiceDescription:
              selectedMealStyle == MealServiceStyle.custom
                  ? customMealServiceController.text
                  : null,
          dietaryRestrictions: selectedDietaryRestrictions,
          beverageOption: selectedBeverageOption,
          customBeverageDescription:
              selectedBeverageOption == BeverageOption.custom
                  ? customBeverageController.text
                  : null,
          includeStaffService: includeStaffService,
          staffCount:
              includeStaffService
                  ? int.tryParse(staffCountController.text) ?? 2
                  : null,
        ),
      );
    }

    return [
      const SizedBox(height: 16),
      Text('Catering Service Options', style: TextStyles.sectionTitle),
      const SizedBox(height: 16),

      // Build each section of the form
      ...buildMealServiceSection(
        selectedMealStyle: selectedMealStyle,
        customMealServiceController: customMealServiceController,
        onMealStyleChanged: (style) {
          selectedMealStyle = style;
          updateOptions();
        },
        onCustomDescriptionChanged: (_) => updateOptions(),
      ),

      ...buildDietaryRestrictionsSection(
        selectedDietaryRestrictions: selectedDietaryRestrictions,
        onDietaryRestrictionsChanged: (restrictions) {
          selectedDietaryRestrictions = restrictions;
          updateOptions();
        },
      ),

      ...buildBeverageServiceSection(
        selectedBeverageOption: selectedBeverageOption,
        customBeverageController: customBeverageController,
        onBeverageOptionChanged: (option) {
          selectedBeverageOption = option;
          updateOptions();
        },
        onCustomDescriptionChanged: (_) => updateOptions(),
      ),

      ...buildStaffServiceSection(
        includeStaffService: includeStaffService,
        staffCountController: staffCountController,
        onIncludeStaffServiceChanged: (include) {
          includeStaffService = include;
          updateOptions();
        },
        onStaffCountChanged: (_) => updateOptions(),
      ),
    ];
  }

  /// Build the meal service style section
  static List<Widget> buildMealServiceSection({
    required MealServiceStyle selectedMealStyle,
    required TextEditingController customMealServiceController,
    required Function(MealServiceStyle) onMealStyleChanged,
    required Function(String) onCustomDescriptionChanged,
  }) {
    return [
      Text(
        'Meal Service Style',
        style: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),

      // Meal service options
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              ...MealServiceStyle.values.map((style) {
                return RadioListTile<MealServiceStyle>(
                  title: Text(style.displayName),
                  value: style,
                  groupValue: selectedMealStyle,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        onMealStyleChanged(value);
                      });
                    }
                  },
                );
              }),

              // Custom meal service description
              if (selectedMealStyle == MealServiceStyle.custom)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: customMealServiceController,
                    decoration: const InputDecoration(
                      labelText: 'Custom Meal Service Description',
                      hintText: 'Describe your custom meal service',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: onCustomDescriptionChanged,
                  ),
                ),
            ],
          );
        },
      ),
      const SizedBox(height: 16),
    ];
  }

  /// Build the dietary restrictions section
  static List<Widget> buildDietaryRestrictionsSection({
    required List<String> selectedDietaryRestrictions,
    required Function(List<String>) onDietaryRestrictionsChanged,
  }) {
    // Dietary restriction options
    final dietaryOptions = [
      'Vegetarian',
      'Vegan',
      'Gluten-Free',
      'Dairy-Free',
      'Nut-Free',
      'Kosher',
      'Halal',
      'Low-Carb',
      'Low-Sugar',
      'Pescatarian',
    ];

    return [
      Text(
        'Dietary Restrictions to Accommodate',
        style: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),

      // Dietary restriction options
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children:
                dietaryOptions.map((restriction) {
                  return CheckboxListTile(
                    title: Text(restriction),
                    value: selectedDietaryRestrictions.contains(restriction),
                    onChanged: (value) {
                      setState(() {
                        final newRestrictions = List<String>.from(
                          selectedDietaryRestrictions,
                        );
                        if (value == true) {
                          if (!newRestrictions.contains(restriction)) {
                            newRestrictions.add(restriction);
                          }
                        } else {
                          newRestrictions.remove(restriction);
                        }
                        onDietaryRestrictionsChanged(newRestrictions);
                      });
                    },
                  );
                }).toList(),
          );
        },
      ),
      const SizedBox(height: 16),
    ];
  }

  /// Build the beverage service section
  static List<Widget> buildBeverageServiceSection({
    required BeverageOption selectedBeverageOption,
    required TextEditingController customBeverageController,
    required Function(BeverageOption) onBeverageOptionChanged,
    required Function(String) onCustomDescriptionChanged,
  }) {
    return [
      Text(
        'Beverage Service',
        style: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),

      // Beverage service options
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              ...BeverageOption.values.map((option) {
                return RadioListTile<BeverageOption>(
                  title: Text(option.displayName),
                  value: option,
                  groupValue: selectedBeverageOption,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        onBeverageOptionChanged(value);
                      });
                    }
                  },
                );
              }),

              // Custom beverage description
              if (selectedBeverageOption == BeverageOption.custom)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: customBeverageController,
                    decoration: const InputDecoration(
                      labelText: 'Custom Beverage Service Description',
                      hintText: 'Describe your custom beverage service',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: onCustomDescriptionChanged,
                  ),
                ),
            ],
          );
        },
      ),
      const SizedBox(height: 16),
    ];
  }

  /// Build the staff service section
  static List<Widget> buildStaffServiceSection({
    required bool includeStaffService,
    required TextEditingController staffCountController,
    required Function(bool) onIncludeStaffServiceChanged,
    required Function(String) onStaffCountChanged,
  }) {
    return [
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              SwitchListTile(
                title: const Text('Include Staff Service'),
                value: includeStaffService,
                onChanged: (value) {
                  setState(() {
                    onIncludeStaffServiceChanged(value);
                  });
                },
              ),

              // Staff count
              if (includeStaffService)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: staffCountController,
                    decoration: const InputDecoration(
                      labelText: 'Number of Staff',
                      hintText: 'Enter number of staff needed',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: onStaffCountChanged,
                  ),
                ),
            ],
          );
        },
      ),
    ];
  }
}
