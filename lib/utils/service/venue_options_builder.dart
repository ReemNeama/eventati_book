import 'package:flutter/material.dart';
import 'package:eventati_book/models/service_options/venue_options.dart';

/// Builder class for venue options form fields
class VenueOptionsBuilder {
  /// Build all venue options form fields
  static List<Widget> buildVenueOptionsFields({
    required BuildContext context,
    required VenueOptions initialOptions,
    required Function(VenueOptions) onOptionsChanged,
  }) {
    // Controllers for text fields
    final setupTimeController = TextEditingController(
      text: initialOptions.setupTimeMinutes.toString(),
    );
    final teardownTimeController = TextEditingController(
      text: initialOptions.teardownTimeMinutes.toString(),
    );
    final customLayoutController = TextEditingController(
      text: initialOptions.customLayoutDescription ?? '',
    );

    // Local state
    VenueLayout selectedLayout = initialOptions.layout;
    List<String> selectedEquipment = List.from(initialOptions.equipmentNeeds);

    // Update the options whenever a field changes
    void updateOptions() {
      onOptionsChanged(
        initialOptions.copyWith(
          setupTimeMinutes: int.tryParse(setupTimeController.text) ?? 60,
          teardownTimeMinutes: int.tryParse(teardownTimeController.text) ?? 60,
          layout: selectedLayout,
          customLayoutDescription:
              selectedLayout == VenueLayout.custom
                  ? customLayoutController.text
                  : null,
          equipmentNeeds: selectedEquipment,
        ),
      );
    }

    return [
      const SizedBox(height: 16),
      const Text(
        'Venue Service Options',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),

      // Build each section of the form
      ...buildSetupTeardownSection(
        setupTimeController: setupTimeController,
        teardownTimeController: teardownTimeController,
        onSetupTimeChanged: (_) => updateOptions(),
        onTeardownTimeChanged: (_) => updateOptions(),
      ),

      ...buildLayoutSection(
        selectedLayout: selectedLayout,
        customLayoutController: customLayoutController,
        onLayoutChanged: (layout) {
          selectedLayout = layout;
          updateOptions();
        },
        onCustomDescriptionChanged: (_) => updateOptions(),
      ),

      ...buildEquipmentSection(
        selectedEquipment: selectedEquipment,
        onEquipmentChanged: (equipment) {
          selectedEquipment = equipment;
          updateOptions();
        },
      ),
    ];
  }

  /// Build the setup and teardown section
  static List<Widget> buildSetupTeardownSection({
    required TextEditingController setupTimeController,
    required TextEditingController teardownTimeController,
    required Function(String) onSetupTimeChanged,
    required Function(String) onTeardownTimeChanged,
  }) {
    return [
      const Text(
        'Setup and Teardown',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),

      // Setup time
      TextField(
        controller: setupTimeController,
        decoration: const InputDecoration(
          labelText: 'Setup Time (minutes)',
          hintText: 'Enter setup time in minutes',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: onSetupTimeChanged,
      ),
      const SizedBox(height: 8),

      // Teardown time
      TextField(
        controller: teardownTimeController,
        decoration: const InputDecoration(
          labelText: 'Teardown Time (minutes)',
          hintText: 'Enter teardown time in minutes',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: onTeardownTimeChanged,
      ),
      const SizedBox(height: 16),
    ];
  }

  /// Build the layout section
  static List<Widget> buildLayoutSection({
    required VenueLayout selectedLayout,
    required TextEditingController customLayoutController,
    required Function(VenueLayout) onLayoutChanged,
    required Function(String) onCustomDescriptionChanged,
  }) {
    return [
      const Text(
        'Venue Layout',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),

      // Layout options
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              ...VenueLayout.values.map((layout) {
                return RadioListTile<VenueLayout>(
                  title: Text(layout.displayName),
                  value: layout,
                  groupValue: selectedLayout,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        onLayoutChanged(value);
                      });
                    }
                  },
                );
              }),

              // Custom layout description
              if (selectedLayout == VenueLayout.custom)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: customLayoutController,
                    decoration: const InputDecoration(
                      labelText: 'Custom Layout Description',
                      hintText: 'Describe your custom layout',
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

  /// Build the equipment section
  static List<Widget> buildEquipmentSection({
    required List<String> selectedEquipment,
    required Function(List<String>) onEquipmentChanged,
  }) {
    // Equipment options
    final equipmentOptions = [
      'Tables',
      'Chairs',
      'Linens',
      'Sound System',
      'Projector',
      'Microphone',
      'Lighting',
      'Stage',
      'Dance Floor',
      'Podium',
    ];

    return [
      const Text(
        'Equipment Needs',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),

      // Equipment options
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children:
                equipmentOptions.map((equipment) {
                  return CheckboxListTile(
                    title: Text(equipment),
                    value: selectedEquipment.contains(equipment),
                    onChanged: (value) {
                      setState(() {
                        final newEquipment = List<String>.from(
                          selectedEquipment,
                        );
                        if (value == true) {
                          if (!newEquipment.contains(equipment)) {
                            newEquipment.add(equipment);
                          }
                        } else {
                          newEquipment.remove(equipment);
                        }
                        onEquipmentChanged(newEquipment);
                      });
                    },
                  );
                }).toList(),
          );
        },
      ),
    ];
  }
}
