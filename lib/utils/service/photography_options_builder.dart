import 'package:flutter/material.dart';
import 'package:eventati_book/models/service_options/photography_options.dart';

/// Builder class for photography options form fields
class PhotographyOptionsBuilder {
  /// Build all photography options form fields
  static List<Widget> buildPhotographyOptionsFields({
    required BuildContext context,
    required PhotographyOptions initialOptions,
    required Function(PhotographyOptions) onOptionsChanged,
  }) {
    // Controllers for text fields
    final customSessionTypeController = TextEditingController(
      text: initialOptions.customSessionTypeDescription ?? '',
    );
    final specificLocationController = TextEditingController(
      text: initialOptions.specificLocationDescription ?? '',
    );

    // Local state
    List<PhotoSessionType> selectedSessionTypes = List.from(
      initialOptions.sessionTypes,
    );
    PhotoLocationPreference selectedLocationPreference =
        initialOptions.locationPreference;
    List<String> selectedEquipment = List.from(
      initialOptions.equipmentRequests,
    );
    bool includeSecondPhotographer = initialOptions.includeSecondPhotographer;
    bool includeVideography = initialOptions.includeVideography;

    // Update the options whenever a field changes
    void updateOptions() {
      onOptionsChanged(
        initialOptions.copyWith(
          sessionTypes: selectedSessionTypes,
          customSessionTypeDescription:
              selectedSessionTypes.contains(PhotoSessionType.custom)
                  ? customSessionTypeController.text
                  : null,
          locationPreference: selectedLocationPreference,
          specificLocationDescription:
              (selectedLocationPreference ==
                          PhotoLocationPreference.specificLocation ||
                      selectedLocationPreference ==
                          PhotoLocationPreference.custom)
                  ? specificLocationController.text
                  : null,
          equipmentRequests: selectedEquipment,
          includeSecondPhotographer: includeSecondPhotographer,
          includeVideography: includeVideography,
        ),
      );
    }

    return [
      const SizedBox(height: 16),
      const Text(
        'Photography Service Options',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),

      // Build each section of the form
      ...buildSessionTypesSection(
        selectedSessionTypes: selectedSessionTypes,
        customSessionTypeController: customSessionTypeController,
        onSessionTypesChanged: (types) {
          selectedSessionTypes = types;
          updateOptions();
        },
        onCustomDescriptionChanged: (_) => updateOptions(),
      ),

      ...buildLocationPreferenceSection(
        selectedLocationPreference: selectedLocationPreference,
        specificLocationController: specificLocationController,
        onLocationPreferenceChanged: (preference) {
          selectedLocationPreference = preference;
          updateOptions();
        },
        onSpecificLocationChanged: (_) => updateOptions(),
      ),

      ...buildEquipmentRequestsSection(
        selectedEquipment: selectedEquipment,
        onEquipmentChanged: (equipment) {
          selectedEquipment = equipment;
          updateOptions();
        },
      ),

      ...buildAdditionalServicesSection(
        includeSecondPhotographer: includeSecondPhotographer,
        includeVideography: includeVideography,
        onIncludeSecondPhotographerChanged: (include) {
          includeSecondPhotographer = include;
          updateOptions();
        },
        onIncludeVideographyChanged: (include) {
          includeVideography = include;
          updateOptions();
        },
      ),
    ];
  }

  /// Build the session types section
  static List<Widget> buildSessionTypesSection({
    required List<PhotoSessionType> selectedSessionTypes,
    required TextEditingController customSessionTypeController,
    required Function(List<PhotoSessionType>) onSessionTypesChanged,
    required Function(String) onCustomDescriptionChanged,
  }) {
    return [
      const Text(
        'Session Types',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),

      // Session type options
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              ...PhotoSessionType.values.map((type) {
                return CheckboxListTile(
                  title: Text(type.displayName),
                  value: selectedSessionTypes.contains(type),
                  onChanged: (value) {
                    setState(() {
                      final newTypes = List<PhotoSessionType>.from(
                        selectedSessionTypes,
                      );
                      if (value == true) {
                        if (!newTypes.contains(type)) {
                          newTypes.add(type);
                        }
                      } else {
                        newTypes.remove(type);
                      }
                      onSessionTypesChanged(newTypes);
                    });
                  },
                );
              }),

              // Custom session type description
              if (selectedSessionTypes.contains(PhotoSessionType.custom))
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: customSessionTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Custom Session Type Description',
                      hintText: 'Describe your custom session type',
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

  /// Build the location preference section
  static List<Widget> buildLocationPreferenceSection({
    required PhotoLocationPreference selectedLocationPreference,
    required TextEditingController specificLocationController,
    required Function(PhotoLocationPreference) onLocationPreferenceChanged,
    required Function(String) onSpecificLocationChanged,
  }) {
    return [
      const Text(
        'Location Preference',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),

      // Location preference options
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              ...PhotoLocationPreference.values.map((preference) {
                return RadioListTile<PhotoLocationPreference>(
                  title: Text(preference.displayName),
                  value: preference,
                  groupValue: selectedLocationPreference,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        onLocationPreferenceChanged(value);
                      });
                    }
                  },
                );
              }),

              // Specific location description
              if (selectedLocationPreference ==
                      PhotoLocationPreference.specificLocation ||
                  selectedLocationPreference == PhotoLocationPreference.custom)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: specificLocationController,
                    decoration: const InputDecoration(
                      labelText: 'Location Details',
                      hintText: 'Describe your preferred location',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: onSpecificLocationChanged,
                  ),
                ),
            ],
          );
        },
      ),
      const SizedBox(height: 16),
    ];
  }

  /// Build the equipment requests section
  static List<Widget> buildEquipmentRequestsSection({
    required List<String> selectedEquipment,
    required Function(List<String>) onEquipmentChanged,
  }) {
    // Equipment options
    final equipmentOptions = [
      'Professional Lighting',
      'Drone Photography',
      'Green Screen',
      'Photo Booth',
      'Specialty Lenses',
      'Underwater Camera',
    ];

    return [
      const Text(
        'Equipment Requests',
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
      const SizedBox(height: 16),
    ];
  }

  /// Build the additional services section
  static List<Widget> buildAdditionalServicesSection({
    required bool includeSecondPhotographer,
    required bool includeVideography,
    required Function(bool) onIncludeSecondPhotographerChanged,
    required Function(bool) onIncludeVideographyChanged,
  }) {
    return [
      const Text(
        'Additional Services',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),

      // Additional services options
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              SwitchListTile(
                title: const Text('Include Second Photographer'),
                value: includeSecondPhotographer,
                onChanged: (value) {
                  setState(() {
                    onIncludeSecondPhotographerChanged(value);
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Include Videography'),
                value: includeVideography,
                onChanged: (value) {
                  setState(() {
                    onIncludeVideographyChanged(value);
                  });
                },
              ),
            ],
          );
        },
      ),
    ];
  }
}
