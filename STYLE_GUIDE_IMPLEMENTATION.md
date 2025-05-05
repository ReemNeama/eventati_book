# Style Guide Implementation Tracker

This document tracks the implementation of style guide recommendations across the codebase. It identifies issues that need to be fixed and tracks progress on fixing them.

## High Priority Issues

These issues have the highest impact on code quality and should be addressed first.

### ALARM Level Issues (Very Low Maintainability Index)

- [ ] `ServiceOptionsFactory.generateCateringOptionsFields` (MI: 23)
- [ ] `ServiceOptionsFactory.generatePhotographyOptionsFields` (MI: 23)
- [ ] `ServiceOptionsFactory.generatePlannerOptionsFields` (MI: 24)
- [ ] `_PricingComparisonTableState.build` (MI: 17)

### High Cyclomatic Complexity

- [ ] `FeatureComparisonTable._buildFeatureValue` (CC: 39)
- [ ] `_PricingComparisonTableState.build` (CC: 25)
- [ ] `FeatureComparisonTable._getValueFromObject` (CC: 26)
- [ ] `_VenueListScreenState.filteredVenues` (CC: 20)

### Long Methods (>100 lines)

- [ ] `ServiceOptionsFactory.generateVenueOptionsFields` (139 lines)
- [ ] `ServiceOptionsFactory.generateCateringOptionsFields` (206 lines)
- [ ] `ServiceOptionsFactory.generatePhotographyOptionsFields` (211 lines)
- [ ] `ServiceOptionsFactory.generatePlannerOptionsFields` (197 lines)
- [ ] `AppTheme.lightTheme` (95 lines)
- [ ] `AppTheme.darkTheme` (104 lines)
- [ ] `ServiceDB.getCateringServices` (247 lines)
- [ ] `ServiceDB.getPhotographyServices` (181 lines)
- [ ] `VenueDB.getVenues` (131 lines)
- [ ] `WizardConnectionService._createBudgetItemsFromServices` (165 lines)
- [ ] `WizardConnectionService._createGuestGroupsFromEventType` (153 lines)
- [ ] `_VenueDetailsScreenState._buildPackagesTab` (112 lines)
- [ ] `_VenueDetailsScreenState._buildVenueDetailsTab` (133 lines)
- [ ] `FeatureComparisonTable._getFeaturesToCompare` (122 lines)
- [ ] `FeatureComparisonTable._buildFeatureValue` (117 lines)

## Medium Priority Issues

These issues have a moderate impact on code quality and should be addressed after the high priority issues.

### Missing Blank Lines Before Return Statements

- [ ] Implement automatic fix using `tool/style_guide_fixer.dart`

### Non-null Assertions

- [ ] `venue_details_screen.dart` (3 instances)
- [ ] `empty_state.dart` (3 instances)
- [ ] `error_message.dart` (2 instances)
- [ ] `error_screen.dart` (1 instance)
- [ ] `loading_indicator.dart` (1 instance)
- [ ] `package_card.dart` (1 instance)
- [ ] `date_picker_tile.dart` (2 instances)
- [ ] `wizard_progress_indicator.dart` (4 instances)
- [ ] `milestone_card.dart` (8 instances)
- [ ] `milestone_detail_dialog.dart` (6 instances)
- [ ] `milestone_grid.dart` (1 instance)
- [ ] `responsive_builder.dart` (3 instances)
- [ ] `responsive_layout.dart` (2 instances)
- [ ] `recommended_badge.dart` (1 instance)
- [ ] `service_card.dart` (2 instances)
- [ ] `validation_utils.dart` (1 instance)

### Unused Parameters

- [ ] `wizard_connection_service.dart` (3 instances)
- [ ] `service_options_factory.dart` (4 instances)
- [ ] `accessibility_utils.dart` (2 instances)
- [ ] `ui_utils.dart` (1 instance)
- [ ] `empty_state.dart` (2 instances)
- [ ] `error_message.dart` (1 instance)

### Nested Conditional Expressions

- [ ] `venue_details_screen.dart` (1 instance)
- [ ] `message_input.dart` (2 instances)
- [ ] `message_input.dart` (in messaging directory) (2 instances)
- [ ] `milestone_detail_dialog.dart` (1 instance)

## Low Priority Issues

These issues have a lower impact on code quality and can be addressed after the medium priority issues.

### Prefer Conditional Expressions

- [ ] `string_utils.dart` (1 instance)
- [ ] `accessibility_utils.dart` (1 instance)
- [ ] `pricing_comparison_table.dart` (2 instances)

### Use First/Last Instead of Index Access

- [ ] `string_utils.dart` (3 instances)

### Avoid Late Keyword

- [ ] `venue_details_screen.dart` (1 instance)
- [ ] `milestone_celebration_overlay.dart` (3 instances)

## Progress Tracking

| Category | Total Issues | Fixed | Remaining | Progress |
|----------|--------------|-------|-----------|----------|
| ALARM Level Issues | 4 | 0 | 4 | 0% |
| High Cyclomatic Complexity | 4 | 0 | 4 | 0% |
| Long Methods | 15 | 0 | 15 | 0% |
| Missing Blank Lines | ~100 | 0 | ~100 | 0% |
| Non-null Assertions | 41 | 0 | 41 | 0% |
| Unused Parameters | 13 | 0 | 13 | 0% |
| Nested Conditional Expressions | 6 | 0 | 6 | 0% |
| Prefer Conditional Expressions | 4 | 0 | 4 | 0% |
| Use First/Last | 3 | 0 | 3 | 0% |
| Avoid Late Keyword | 4 | 0 | 4 | 0% |
| **Total** | **~194** | **0** | **~194** | **0%** |

## Refactoring Plan

1. Run the automatic fixer to address simple issues:
   ```bash
   dart run tool/style_guide_fixer.dart
   ```

2. Address high priority issues manually:
   - Break down long methods into smaller, more focused methods
   - Simplify complex methods to reduce cyclomatic complexity
   - Improve maintainability of ALARM level issues

3. Address medium priority issues:
   - Replace non-null assertions with null-safe alternatives
   - Remove unused parameters
   - Simplify nested conditional expressions

4. Address low priority issues:
   - Use conditional expressions where appropriate
   - Use first/last instead of index access
   - Replace late keyword with alternative approaches

## Completion Criteria

The style guide implementation will be considered complete when:

1. All high priority issues are fixed
2. At least 90% of medium priority issues are fixed
3. At least 75% of low priority issues are fixed
4. The dart_code_metrics analysis shows no ALARM or WARNING level issues
5. The codebase passes all automated code quality checks
