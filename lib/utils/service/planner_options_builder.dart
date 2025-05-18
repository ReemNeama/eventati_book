import 'package:flutter/material.dart';
import 'package:eventati_book/models/service_options/planner_options.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// Builder class for planner options form fields
class PlannerOptionsBuilder {
  /// Build all planner options form fields
  static List<Widget> buildPlannerOptionsFields({
    required BuildContext context,
    required PlannerOptions initialOptions,
    required Function(PlannerOptions) onOptionsChanged,
  }) {
    // Controllers for text fields
    final customConsultationController = TextEditingController(
      text: initialOptions.customConsultationDescription ?? '',
    );
    final customPackageController = TextEditingController(
      text: initialOptions.customPackageDescription ?? '',
    );

    // Local state
    ConsultationPreference selectedConsultationPreference =
        initialOptions.consultationPreference;
    PlanningPackageType selectedPackageType = initialOptions.packageType;
    List<String> selectedPlanningNeeds = List.from(
      initialOptions.specificPlanningNeeds,
    );
    bool includeVendorCoordination = initialOptions.includeVendorCoordination;
    bool includeBudgetManagement = initialOptions.includeBudgetManagement;

    // Update the options whenever a field changes
    void updateOptions() {
      onOptionsChanged(
        initialOptions.copyWith(
          consultationPreference: selectedConsultationPreference,
          customConsultationDescription:
              selectedConsultationPreference == ConsultationPreference.custom
                  ? customConsultationController.text
                  : null,
          packageType: selectedPackageType,
          customPackageDescription:
              selectedPackageType == PlanningPackageType.custom
                  ? customPackageController.text
                  : null,
          specificPlanningNeeds: selectedPlanningNeeds,
          includeVendorCoordination: includeVendorCoordination,
          includeBudgetManagement: includeBudgetManagement,
        ),
      );
    }

    return [
      const SizedBox(height: 16),
      Text('Planner Service Options', style: TextStyles.sectionTitle),
      const SizedBox(height: 16),

      // Build each section of the form
      ...buildConsultationSection(
        selectedConsultationPreference: selectedConsultationPreference,
        customConsultationController: customConsultationController,
        onConsultationPreferenceChanged: (preference) {
          selectedConsultationPreference = preference;
          updateOptions();
        },
        onCustomDescriptionChanged: (_) => updateOptions(),
      ),

      ...buildPackageTypeSection(
        selectedPackageType: selectedPackageType,
        customPackageController: customPackageController,
        onPackageTypeChanged: (type) {
          selectedPackageType = type;
          updateOptions();
        },
        onCustomDescriptionChanged: (_) => updateOptions(),
      ),

      ...buildPlanningNeedsSection(
        selectedPlanningNeeds: selectedPlanningNeeds,
        onPlanningNeedsChanged: (needs) {
          selectedPlanningNeeds = needs;
          updateOptions();
        },
      ),

      ...buildAdditionalServicesSection(
        includeVendorCoordination: includeVendorCoordination,
        includeBudgetManagement: includeBudgetManagement,
        onIncludeVendorCoordinationChanged: (include) {
          includeVendorCoordination = include;
          updateOptions();
        },
        onIncludeBudgetManagementChanged: (include) {
          includeBudgetManagement = include;
          updateOptions();
        },
      ),
    ];
  }

  /// Build the consultation preference section
  static List<Widget> buildConsultationSection({
    required ConsultationPreference selectedConsultationPreference,
    required TextEditingController customConsultationController,
    required Function(ConsultationPreference) onConsultationPreferenceChanged,
    required Function(String) onCustomDescriptionChanged,
  }) {
    return [
      Text(
        'Consultation Preference',
        style: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),

      // Consultation preference options
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              ...ConsultationPreference.values.map((preference) {
                return RadioListTile<ConsultationPreference>(
                  title: Text(preference.displayName),
                  value: preference,
                  groupValue: selectedConsultationPreference,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        onConsultationPreferenceChanged(value);
                      });
                    }
                  },
                );
              }),

              // Custom consultation description
              if (selectedConsultationPreference ==
                  ConsultationPreference.custom)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: customConsultationController,
                    decoration: const InputDecoration(
                      labelText: 'Custom Consultation Description',
                      hintText: 'Describe your custom consultation preference',
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

  /// Build the package type section
  static List<Widget> buildPackageTypeSection({
    required PlanningPackageType selectedPackageType,
    required TextEditingController customPackageController,
    required Function(PlanningPackageType) onPackageTypeChanged,
    required Function(String) onCustomDescriptionChanged,
  }) {
    return [
      Text(
        'Package Type',
        style: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),

      // Package type options
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              ...PlanningPackageType.values.map((type) {
                return RadioListTile<PlanningPackageType>(
                  title: Text(type.displayName),
                  value: type,
                  groupValue: selectedPackageType,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        onPackageTypeChanged(value);
                      });
                    }
                  },
                );
              }),

              // Custom package description
              if (selectedPackageType == PlanningPackageType.custom)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: customPackageController,
                    decoration: const InputDecoration(
                      labelText: 'Custom Package Description',
                      hintText: 'Describe your custom package',
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

  /// Build the planning needs section
  static List<Widget> buildPlanningNeedsSection({
    required List<String> selectedPlanningNeeds,
    required Function(List<String>) onPlanningNeedsChanged,
  }) {
    // Planning needs options
    final planningNeedsOptions = [
      'Venue Selection',
      'Vendor Coordination',
      'Budget Management',
      'Timeline Creation',
      'Guest List Management',
      'Seating Arrangement',
      'Decor Planning',
      'Menu Planning',
      'Transportation Coordination',
      'Accommodation Coordination',
    ];

    return [
      Text(
        'Specific Planning Needs',
        style: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),

      // Planning needs options
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children:
                planningNeedsOptions.map((need) {
                  return CheckboxListTile(
                    title: Text(need),
                    value: selectedPlanningNeeds.contains(need),
                    onChanged: (value) {
                      setState(() {
                        final newNeeds = List<String>.from(
                          selectedPlanningNeeds,
                        );
                        if (value == true) {
                          if (!newNeeds.contains(need)) {
                            newNeeds.add(need);
                          }
                        } else {
                          newNeeds.remove(need);
                        }
                        onPlanningNeedsChanged(newNeeds);
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
    required bool includeVendorCoordination,
    required bool includeBudgetManagement,
    required Function(bool) onIncludeVendorCoordinationChanged,
    required Function(bool) onIncludeBudgetManagementChanged,
  }) {
    return [
      Text(
        'Additional Services',
        style: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),

      // Additional services options
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              SwitchListTile(
                title: const Text('Include Vendor Coordination'),
                value: includeVendorCoordination,
                onChanged: (value) {
                  setState(() {
                    onIncludeVendorCoordinationChanged(value);
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Include Budget Management'),
                value: includeBudgetManagement,
                onChanged: (value) {
                  setState(() {
                    onIncludeBudgetManagementChanged(value);
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
