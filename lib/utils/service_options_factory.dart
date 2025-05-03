import 'package:flutter/material.dart';
import 'package:eventati_book/models/service_options/service_options.dart';

/// Factory class for generating service-specific form fields
class ServiceOptionsFactory {
  /// Generate form fields for venue options
  static List<Widget> generateVenueOptionsFields({
    required BuildContext context,
    required VenueOptions initialOptions,
    required Function(VenueOptions) onOptionsChanged,
  }) {
    // No theme variables needed for this widget

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

    // Local state - variables can't be final because they're modified in setState
    // ignore: prefer_final_locals
    VenueLayout selectedLayout = initialOptions.layout;
    // ignore: prefer_final_locals
    List<String> selectedEquipment = List.from(initialOptions.equipmentNeeds);

    // Equipment options
    final equipmentOptions = [
      'Projector',
      'Microphone',
      'Sound System',
      'Tables',
      'Chairs',
      'Podium',
      'Stage',
      'Dance Floor',
      'Lighting',
      'Decorations',
    ];

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
        'Venue Setup Options',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),

      // Setup time
      TextField(
        controller: setupTimeController,
        decoration: const InputDecoration(
          labelText: 'Setup Time (minutes)',
          hintText: 'Enter setup time in minutes',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: (_) => updateOptions(),
      ),
      const SizedBox(height: 16),

      // Teardown time
      TextField(
        controller: teardownTimeController,
        decoration: const InputDecoration(
          labelText: 'Teardown Time (minutes)',
          hintText: 'Enter teardown time in minutes',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: (_) => updateOptions(),
      ),
      const SizedBox(height: 16),

      // Layout preference
      const Text(
        'Layout Preference',
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
                        selectedLayout = value;
                      });
                      updateOptions();
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
                    onChanged: (_) => updateOptions(),
                  ),
                ),
            ],
          );
        },
      ),
      const SizedBox(height: 16),

      // Equipment needs
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
                        if (value == true) {
                          if (!selectedEquipment.contains(equipment)) {
                            selectedEquipment.add(equipment);
                          }
                        } else {
                          selectedEquipment.remove(equipment);
                        }
                      });
                      updateOptions();
                    },
                  );
                }).toList(),
          );
        },
      ),
    ];
  }

  /// Generate form fields for catering options
  static List<Widget> generateCateringOptionsFields({
    required BuildContext context,
    required CateringOptions initialOptions,
    required Function(CateringOptions) onOptionsChanged,
  }) {
    // No theme variables needed for this widget

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

    // Local state - variables can't be final because they're modified in setState
    // ignore: prefer_final_locals
    MealServiceStyle selectedMealStyle = initialOptions.mealServiceStyle;
    // ignore: prefer_final_locals
    BeverageOption selectedBeverageOption = initialOptions.beverageOption;
    // ignore: prefer_final_locals
    List<String> selectedDietaryRestrictions = List.from(
      initialOptions.dietaryRestrictions,
    );
    // ignore: prefer_final_locals
    bool includeStaffService = initialOptions.includeStaffService;

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
      const Text(
        'Catering Service Options',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),

      // Meal service style
      const Text(
        'Meal Service Style',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                        selectedMealStyle = value;
                      });
                      updateOptions();
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
                    onChanged: (_) => updateOptions(),
                  ),
                ),
            ],
          );
        },
      ),
      const SizedBox(height: 16),

      // Dietary restrictions
      const Text(
        'Dietary Restrictions to Accommodate',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                        if (value == true) {
                          if (!selectedDietaryRestrictions.contains(
                            restriction,
                          )) {
                            selectedDietaryRestrictions.add(restriction);
                          }
                        } else {
                          selectedDietaryRestrictions.remove(restriction);
                        }
                      });
                      updateOptions();
                    },
                  );
                }).toList(),
          );
        },
      ),
      const SizedBox(height: 16),

      // Beverage options
      const Text(
        'Beverage Service',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                        selectedBeverageOption = value;
                      });
                      updateOptions();
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
                    onChanged: (_) => updateOptions(),
                  ),
                ),
            ],
          );
        },
      ),
      const SizedBox(height: 16),

      // Staff service
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              SwitchListTile(
                title: const Text('Include Staff Service'),
                value: includeStaffService,
                onChanged: (value) {
                  setState(() {
                    includeStaffService = value;
                  });
                  updateOptions();
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
                    onChanged: (_) => updateOptions(),
                  ),
                ),
            ],
          );
        },
      ),
    ];
  }

  /// Generate form fields for photography options
  static List<Widget> generatePhotographyOptionsFields({
    required BuildContext context,
    required PhotographyOptions initialOptions,
    required Function(PhotographyOptions) onOptionsChanged,
  }) {
    // No theme variables needed for this widget

    // Controllers for text fields
    final customSessionTypeController = TextEditingController(
      text: initialOptions.customSessionTypeDescription ?? '',
    );
    final specificLocationController = TextEditingController(
      text: initialOptions.specificLocationDescription ?? '',
    );

    // Local state - variables can't be final because they're modified in setState
    // ignore: prefer_final_locals
    List<PhotoSessionType> selectedSessionTypes = List.from(
      initialOptions.sessionTypes,
    );
    // ignore: prefer_final_locals
    PhotoLocationPreference selectedLocationPreference =
        initialOptions.locationPreference;
    // ignore: prefer_final_locals
    List<String> selectedEquipment = List.from(
      initialOptions.equipmentRequests,
    );
    // ignore: prefer_final_locals
    bool includeSecondPhotographer = initialOptions.includeSecondPhotographer;
    // ignore: prefer_final_locals
    bool includeVideography = initialOptions.includeVideography;

    // Equipment options
    final equipmentOptions = [
      'Drone',
      'Wide-Angle Lens',
      'Telephoto Lens',
      'Macro Lens',
      'Studio Lighting',
      'Portable Lighting',
      'Backdrop',
      'Tripod',
      'Gimbal',
      'Props',
    ];

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

      // Photo session types
      const Text(
        'Photo Session Types',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),

      // Session type options
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children:
                PhotoSessionType.values.map((type) {
                  return CheckboxListTile(
                    title: Text(type.displayName),
                    value: selectedSessionTypes.contains(type),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          if (!selectedSessionTypes.contains(type)) {
                            selectedSessionTypes.add(type);
                          }
                        } else {
                          selectedSessionTypes.remove(type);
                        }
                      });
                      updateOptions();
                    },
                  );
                }).toList(),
          );
        },
      ),

      // Custom session type description
      StatefulBuilder(
        builder: (context, setState) {
          return Visibility(
            visible: selectedSessionTypes.contains(PhotoSessionType.custom),
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextField(
                controller: customSessionTypeController,
                decoration: const InputDecoration(
                  labelText: 'Custom Session Type Description',
                  hintText: 'Describe your custom session type',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => updateOptions(),
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 16),

      // Location preference
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
                        selectedLocationPreference = value;
                      });
                      updateOptions();
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
                      labelText: 'Location Description',
                      hintText: 'Describe your preferred location',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => updateOptions(),
                  ),
                ),
            ],
          );
        },
      ),
      const SizedBox(height: 16),

      // Equipment requests
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
                        if (value == true) {
                          if (!selectedEquipment.contains(equipment)) {
                            selectedEquipment.add(equipment);
                          }
                        } else {
                          selectedEquipment.remove(equipment);
                        }
                      });
                      updateOptions();
                    },
                  );
                }).toList(),
          );
        },
      ),
      const SizedBox(height: 16),

      // Additional options
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              SwitchListTile(
                title: const Text('Include Second Photographer'),
                value: includeSecondPhotographer,
                onChanged: (value) {
                  setState(() {
                    includeSecondPhotographer = value;
                  });
                  updateOptions();
                },
              ),
              SwitchListTile(
                title: const Text('Include Videography'),
                value: includeVideography,
                onChanged: (value) {
                  setState(() {
                    includeVideography = value;
                  });
                  updateOptions();
                },
              ),
            ],
          );
        },
      ),
    ];
  }

  /// Generate form fields for planner options
  static List<Widget> generatePlannerOptionsFields({
    required BuildContext context,
    required PlannerOptions initialOptions,
    required Function(PlannerOptions) onOptionsChanged,
  }) {
    // No theme variables needed for this widget

    // Controllers for text fields
    final customConsultationController = TextEditingController(
      text: initialOptions.customConsultationDescription ?? '',
    );
    final customPackageController = TextEditingController(
      text: initialOptions.customPackageDescription ?? '',
    );

    // Local state - variables can't be final because they're modified in setState
    // ignore: prefer_final_locals
    ConsultationPreference selectedConsultationPreference =
        initialOptions.consultationPreference;
    // ignore: prefer_final_locals
    PlanningPackageType selectedPackageType = initialOptions.packageType;
    // ignore: prefer_final_locals
    List<String> selectedPlanningNeeds = List.from(
      initialOptions.specificPlanningNeeds,
    );
    // ignore: prefer_final_locals
    bool includeVendorCoordination = initialOptions.includeVendorCoordination;
    // ignore: prefer_final_locals
    bool includeBudgetManagement = initialOptions.includeBudgetManagement;

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
      const Text(
        'Planner Service Options',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),

      // Consultation preference
      const Text(
        'Consultation Preference',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                        selectedConsultationPreference = value;
                      });
                      updateOptions();
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
                    onChanged: (_) => updateOptions(),
                  ),
                ),
            ],
          );
        },
      ),
      const SizedBox(height: 16),

      // Planning package type
      const Text(
        'Planning Package Type',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),

      // Planning package options
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              ...PlanningPackageType.values.map((packageType) {
                return RadioListTile<PlanningPackageType>(
                  title: Text(packageType.displayName),
                  value: packageType,
                  groupValue: selectedPackageType,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedPackageType = value;
                      });
                      updateOptions();
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
                      hintText: 'Describe your custom planning package',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => updateOptions(),
                  ),
                ),
            ],
          );
        },
      ),
      const SizedBox(height: 16),

      // Specific planning needs
      const Text(
        'Specific Planning Needs',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                        if (value == true) {
                          if (!selectedPlanningNeeds.contains(need)) {
                            selectedPlanningNeeds.add(need);
                          }
                        } else {
                          selectedPlanningNeeds.remove(need);
                        }
                      });
                      updateOptions();
                    },
                  );
                }).toList(),
          );
        },
      ),
      const SizedBox(height: 16),

      // Additional options
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              SwitchListTile(
                title: const Text('Include Vendor Coordination'),
                value: includeVendorCoordination,
                onChanged: (value) {
                  setState(() {
                    includeVendorCoordination = value;
                  });
                  updateOptions();
                },
              ),
              SwitchListTile(
                title: const Text('Include Budget Management'),
                value: includeBudgetManagement,
                onChanged: (value) {
                  setState(() {
                    includeBudgetManagement = value;
                  });
                  updateOptions();
                },
              ),
            ],
          );
        },
      ),
    ];
  }

  /// Generate service-specific form fields based on service type
  static List<Widget> generateServiceOptionsFields({
    required BuildContext context,
    required String serviceType,
    required Map<String, dynamic> initialOptions,
    required Function(Map<String, dynamic>) onOptionsChanged,
  }) {
    switch (serviceType) {
      case 'venue':
        final venueOptions =
            initialOptions.containsKey('venue')
                ? VenueOptions.fromJson(initialOptions['venue'])
                : VenueOptions.defaultOptions();

        return generateVenueOptionsFields(
          context: context,
          initialOptions: venueOptions,
          onOptionsChanged: (options) {
            final newOptions = Map<String, dynamic>.from(initialOptions);
            newOptions['venue'] = options.toJson();
            onOptionsChanged(newOptions);
          },
        );

      case 'catering':
        final cateringOptions =
            initialOptions.containsKey('catering')
                ? CateringOptions.fromJson(initialOptions['catering'])
                : CateringOptions.defaultOptions();

        return generateCateringOptionsFields(
          context: context,
          initialOptions: cateringOptions,
          onOptionsChanged: (options) {
            final newOptions = Map<String, dynamic>.from(initialOptions);
            newOptions['catering'] = options.toJson();
            onOptionsChanged(newOptions);
          },
        );

      case 'photography':
        final photographyOptions =
            initialOptions.containsKey('photography')
                ? PhotographyOptions.fromJson(initialOptions['photography'])
                : PhotographyOptions.defaultOptions();

        return generatePhotographyOptionsFields(
          context: context,
          initialOptions: photographyOptions,
          onOptionsChanged: (options) {
            final newOptions = Map<String, dynamic>.from(initialOptions);
            newOptions['photography'] = options.toJson();
            onOptionsChanged(newOptions);
          },
        );

      case 'planner':
        final plannerOptions =
            initialOptions.containsKey('planner')
                ? PlannerOptions.fromJson(initialOptions['planner'])
                : PlannerOptions.defaultOptions();

        return generatePlannerOptionsFields(
          context: context,
          initialOptions: plannerOptions,
          onOptionsChanged: (options) {
            final newOptions = Map<String, dynamic>.from(initialOptions);
            newOptions['planner'] = options.toJson();
            onOptionsChanged(newOptions);
          },
        );

      default:
        return [
          const SizedBox(height: 16),
          const Text(
            'No service-specific options available for this service type.',
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
        ];
    }
  }
}
