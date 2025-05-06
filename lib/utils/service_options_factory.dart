import 'package:flutter/material.dart';
import 'package:eventati_book/models/service_options/service_options.dart';
import 'package:eventati_book/utils/service/venue_options_builder.dart';
import 'package:eventati_book/utils/service/catering_options_builder.dart';
import 'package:eventati_book/utils/service/photography_options_builder.dart';
import 'package:eventati_book/utils/service/planner_options_builder.dart';

/// Factory class for generating service-specific form fields
class ServiceOptionsFactory {
  /// Generate form fields for venue options
  ///
  /// Note: The [context] parameter is passed to the builder but not currently used.
  /// It's kept for future implementation where the context might be needed for
  /// theme-aware or responsive form fields.
  static List<Widget> generateVenueOptionsFields({
    // TODO: Use context parameter for theme-aware or responsive form fields
    required BuildContext context,
    required VenueOptions initialOptions,
    required Function(VenueOptions) onOptionsChanged,
  }) {
    return VenueOptionsBuilder.buildVenueOptionsFields(
      context: context,
      initialOptions: initialOptions,
      onOptionsChanged: onOptionsChanged,
    );
  }

  /// Generate form fields for catering options
  ///
  /// Note: The [context] parameter is passed to the builder but not currently used.
  /// It's kept for future implementation where the context might be needed for
  /// theme-aware or responsive form fields.
  static List<Widget> generateCateringOptionsFields({
    // TODO: Use context parameter for theme-aware or responsive form fields
    required BuildContext context,
    required CateringOptions initialOptions,
    required Function(CateringOptions) onOptionsChanged,
  }) {
    return CateringOptionsBuilder.buildCateringOptionsFields(
      context: context,
      initialOptions: initialOptions,
      onOptionsChanged: onOptionsChanged,
    );
  }

  /// Generate form fields for photography options
  ///
  /// Note: The [context] parameter is passed to the builder but not currently used.
  /// It's kept for future implementation where the context might be needed for
  /// theme-aware or responsive form fields.
  static List<Widget> generatePhotographyOptionsFields({
    // TODO: Use context parameter for theme-aware or responsive form fields
    required BuildContext context,
    required PhotographyOptions initialOptions,
    required Function(PhotographyOptions) onOptionsChanged,
  }) {
    return PhotographyOptionsBuilder.buildPhotographyOptionsFields(
      context: context,
      initialOptions: initialOptions,
      onOptionsChanged: onOptionsChanged,
    );
  }

  /// Generate form fields for planner options
  ///
  /// Note: The [context] parameter is passed to the builder but not currently used.
  /// It's kept for future implementation where the context might be needed for
  /// theme-aware or responsive form fields.
  static List<Widget> generatePlannerOptionsFields({
    // TODO: Use context parameter for theme-aware or responsive form fields
    required BuildContext context,
    required PlannerOptions initialOptions,
    required Function(PlannerOptions) onOptionsChanged,
  }) {
    return PlannerOptionsBuilder.buildPlannerOptionsFields(
      context: context,
      initialOptions: initialOptions,
      onOptionsChanged: onOptionsChanged,
    );
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
