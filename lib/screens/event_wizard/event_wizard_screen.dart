import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/event_template.dart';
import 'package:eventati_book/models/milestone.dart';
import 'package:eventati_book/providers/milestone_provider.dart';
import 'package:eventati_book/providers/wizard_provider.dart';
import 'package:eventati_book/screens/event_planning/milestones/milestone_screen.dart';
import 'package:eventati_book/styles/wizard_styles.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/event_wizard/event_name_input.dart';
import 'package:eventati_book/widgets/event_wizard/event_type_dropdown.dart';
import 'package:eventati_book/widgets/event_wizard/date_picker_tile.dart';
import 'package:eventati_book/widgets/event_wizard/guest_count_input.dart';
import 'package:eventati_book/widgets/event_wizard/services_selection.dart';
import 'package:eventati_book/widgets/event_wizard/time_picker_tile.dart';
import 'package:eventati_book/widgets/event_wizard/wizard_progress_indicator.dart';
import 'package:eventati_book/widgets/milestones/milestone_celebration_overlay.dart';

/// A unified wizard screen for creating events of different types
class EventWizardScreen extends StatefulWidget {
  /// The template for the event type
  final EventTemplate template;

  /// Function to call when the wizard is completed
  final Function(Map<String, dynamic>) onComplete;

  const EventWizardScreen({
    super.key,
    required this.template,
    required this.onComplete,
  });

  @override
  State<EventWizardScreen> createState() => _EventWizardScreenState();
}

class _EventWizardScreenState extends State<EventWizardScreen> {
  // Form controllers
  final _eventNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize the wizard provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final wizardProvider = Provider.of<WizardProvider>(
          context,
          listen: false,
        );
        wizardProvider.initializeWizard(widget.template);

        // Set up the event name controller
        if (wizardProvider.state != null &&
            wizardProvider.state!.eventName.isNotEmpty) {
          _eventNameController.text = wizardProvider.state!.eventName;
        }

        // Initialize milestone provider
        final milestoneProvider = Provider.of<MilestoneProvider>(
          context,
          listen: false,
        );
        milestoneProvider.initializeMilestones(widget.template.id);
      }
    });
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WizardProvider, MilestoneProvider>(
      builder: (context, wizardProvider, milestoneProvider, _) {
        if (wizardProvider.isLoading || milestoneProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (wizardProvider.state == null) {
          return Scaffold(
            body: Center(
              child: Text(
                'Failed to initialize wizard: ${wizardProvider.error ?? "Unknown error"}',
              ),
            ),
          );
        }

        // Check for newly completed milestones
        final newlyCompleted = milestoneProvider.newlyCompletedMilestones;
        if (newlyCompleted.isNotEmpty) {
          // Show celebration overlay for the first newly completed milestone
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showMilestoneCelebration(
              context,
              newlyCompleted.first,
              milestoneProvider,
            );
          });
        }

        final state = wizardProvider.state!;
        final primaryColor = Theme.of(context).primaryColor;

        return Scaffold(
          backgroundColor: primaryColor,
          appBar: AppBar(
            backgroundColor: primaryColor,
            elevation: 0,
            title: Text(
              'Plan Your ${widget.template.name}',
              style: WizardStyles.getTitleStyle(),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              // Milestones button
              IconButton(
                icon: const Icon(Icons.emoji_events),
                tooltip: 'Milestones',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              MilestoneScreen(eventId: widget.template.id),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Container(
            decoration: WizardStyles.getWizardBodyDecoration(),
            child: Column(
              children: [
                // Progress indicator
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: WizardProgressIndicator(
                    currentStep: state.currentStep,
                    totalSteps: state.totalSteps,
                    showStepLabels: true,
                    stepLabels: const [
                      'Event Details',
                      'Date & Guests',
                      'Services',
                      'Review',
                    ],
                  ),
                ),

                // Wizard content
                Expanded(
                  child: Theme(
                    data: WizardStyles.getStepperTheme(context, primaryColor),
                    child: Stepper(
                      currentStep: state.currentStep,
                      onStepContinue: () {
                        // Update the event name before proceeding
                        if (state.currentStep == 0) {
                          wizardProvider.updateEventName(
                            _eventNameController.text,
                          );
                        }

                        final success = wizardProvider.nextStep();

                        // If we've completed the wizard, call the onComplete callback
                        if (success &&
                            state.currentStep == state.totalSteps - 1) {
                          wizardProvider.completeWizard(context);

                          // Prepare the data for the callback
                          final data = {
                            'eventName': state.eventName,
                            'eventType': state.selectedEventType ?? '',
                            'eventDate': state.eventDate ?? DateTime.now(),
                            'guestCount': state.guestCount ?? 0,
                            'selectedServices': Map<String, bool>.from(
                              state.selectedServices,
                            ),
                            'eventDuration': state.eventDuration,
                            'dailyStartTime': state.dailyStartTime,
                            'dailyEndTime': state.dailyEndTime,
                            'needsSetup': state.needsSetup,
                            'setupHours': state.setupHours,
                            'needsTeardown': state.needsTeardown,
                            'teardownHours': state.teardownHours,
                          };

                          widget.onComplete(data);
                        }
                      },
                      onStepCancel: () {
                        wizardProvider.previousStep();
                      },
                      controlsBuilder: (context, details) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            children: [
                              if (state.currentStep > 0)
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: details.onStepCancel,
                                    style: WizardStyles.getPreviousButtonStyle(
                                      context,
                                    ),
                                    child: Text(
                                      'Previous',
                                      style: WizardStyles.getButtonTextStyle(),
                                    ),
                                  ),
                                ),
                              if (state.currentStep > 0)
                                const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: details.onStepContinue,
                                  style: WizardStyles.getNextButtonStyle(
                                    context,
                                  ),
                                  child: Text(
                                    state.currentStep == state.totalSteps - 1
                                        ? 'Finish'
                                        : 'Next',
                                    style: WizardStyles.getButtonTextStyle(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      steps: [
                        // Step 1: Event Details
                        Step(
                          title: Text(
                            'Event Details',
                            style: WizardStyles.getStepTitleStyle(),
                          ),
                          content: Column(
                            children: [
                              EventNameInput(
                                controller: _eventNameController,
                                primaryColor: primaryColor,
                              ),
                              const SizedBox(height: 16),
                              EventTypeDropdown(
                                selectedValue: state.selectedEventType,
                                eventTypes: widget.template.subtypes,
                                primaryColor: primaryColor,
                                onChanged: (value) {
                                  if (value != null) {
                                    wizardProvider.updateEventType(value);
                                  }
                                },
                              ),
                            ],
                          ),
                          isActive: state.currentStep >= 0,
                        ),

                        // Step 2: Date & Guests
                        Step(
                          title: Text(
                            'Date & Guests',
                            style: WizardStyles.getStepTitleStyle(),
                          ),
                          content: Column(
                            children: [
                              DatePickerTile(
                                selectedDate: state.eventDate,
                                primaryColor: primaryColor,
                                onDateSelected: (date) {
                                  if (date != null) {
                                    wizardProvider.updateEventDate(date);
                                  }
                                },
                                label: 'Select Event Date',
                              ),
                              const SizedBox(height: 16),

                              // Business event specific fields
                              if (widget.template.id == 'business') ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<int>(
                                        decoration: InputDecoration(
                                          labelText: 'Event Duration (Days)',
                                          border: const OutlineInputBorder(),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: primaryColor,
                                            ),
                                          ),
                                        ),
                                        value: state.eventDuration,
                                        items:
                                            List.generate(
                                                  14,
                                                  (index) => index + 1,
                                                )
                                                .map(
                                                  (days) => DropdownMenuItem(
                                                    value: days,
                                                    child: Text(
                                                      '$days ${days == 1 ? 'day' : 'days'}',
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            wizardProvider.updateEventDuration(
                                              value,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TimePickerTile(
                                        selectedTime: state.dailyStartTime,
                                        label: 'Daily Start Time',
                                        onTimeSelected: (time) {
                                          if (time != null) {
                                            wizardProvider.updateDailyStartTime(
                                              time,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TimePickerTile(
                                        selectedTime: state.dailyEndTime,
                                        label: 'Daily End Time',
                                        onTimeSelected: (time) {
                                          if (time != null) {
                                            wizardProvider.updateDailyEndTime(
                                              time,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                CheckboxListTile(
                                  title: const Text('Needs Setup Day/Time'),
                                  value: state.needsSetup,
                                  activeColor: primaryColor,
                                  onChanged: (value) {
                                    wizardProvider.updateSetupNeeds(
                                      value ?? false,
                                    );
                                  },
                                ),
                                if (state.needsSetup)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 32.0),
                                    child: DropdownButtonFormField<int>(
                                      decoration: InputDecoration(
                                        labelText: 'Setup Hours Needed',
                                        border: const OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: primaryColor,
                                          ),
                                        ),
                                      ),
                                      value: state.setupHours,
                                      items:
                                          List.generate(
                                                12,
                                                (index) => index + 1,
                                              )
                                              .map(
                                                (hours) => DropdownMenuItem(
                                                  value: hours,
                                                  child: Text(
                                                    '$hours ${hours == 1 ? 'hour' : 'hours'}',
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          wizardProvider.updateSetupHours(
                                            value,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                CheckboxListTile(
                                  title: const Text('Needs Teardown Day/Time'),
                                  value: state.needsTeardown,
                                  activeColor: primaryColor,
                                  onChanged: (value) {
                                    wizardProvider.updateTeardownNeeds(
                                      value ?? false,
                                    );
                                  },
                                ),
                                if (state.needsTeardown)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 32.0),
                                    child: DropdownButtonFormField<int>(
                                      decoration: InputDecoration(
                                        labelText: 'Teardown Hours Needed',
                                        border: const OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: primaryColor,
                                          ),
                                        ),
                                      ),
                                      value: state.teardownHours,
                                      items:
                                          List.generate(
                                                12,
                                                (index) => index + 1,
                                              )
                                              .map(
                                                (hours) => DropdownMenuItem(
                                                  value: hours,
                                                  child: Text(
                                                    '$hours ${hours == 1 ? 'hour' : 'hours'}',
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          wizardProvider.updateTeardownHours(
                                            value,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                const SizedBox(height: 16),
                              ],

                              GuestCountInput(
                                primaryColor: primaryColor,
                                onChanged: (value) {
                                  final count = int.tryParse(value);
                                  if (count != null) {
                                    wizardProvider.updateGuestCount(count);
                                  }
                                },
                              ),
                            ],
                          ),
                          isActive: state.currentStep >= 1,
                        ),

                        // Step 3: Required Services
                        Step(
                          title: Text(
                            'Required Services',
                            style: WizardStyles.getStepTitleStyle(),
                          ),
                          content: ServicesSelection(
                            selectedServices: state.selectedServices,
                            primaryColor: primaryColor,
                            onServiceChanged: (service, value) {
                              wizardProvider.updateServiceSelection(
                                service,
                                value ?? false,
                              );
                            },
                          ),
                          isActive: state.currentStep >= 2,
                        ),

                        // Step 4: Review
                        Step(
                          title: Text(
                            'Review',
                            style: WizardStyles.getStepTitleStyle(),
                          ),
                          content: Container(
                            padding: const EdgeInsets.all(16),
                            decoration:
                                WizardStyles.getReviewContainerDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Event Details',
                                  style:
                                      WizardStyles.getReviewSectionTitleStyle(
                                        context,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text('Event Name: ${state.eventName}'),
                                Text(
                                  'Event Type: ${state.selectedEventType ?? "Not selected"}',
                                ),
                                Text(
                                  'Date: ${state.eventDate != null ? DateTimeUtils.formatDate(state.eventDate!) : "Not selected"}',
                                ),
                                Text(
                                  'Guest Count: ${state.guestCount != null ? NumberUtils.formatWithCommas(state.guestCount!) : "Not specified"}',
                                ),

                                // Business event specific details
                                if (widget.template.id == 'business') ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Duration: ${state.eventDuration} ${state.eventDuration == 1 ? "day" : "days"}',
                                  ),
                                  if (state.dailyStartTime != null)
                                    Text(
                                      'Daily Start Time: ${state.dailyStartTime!.format(context)}',
                                    ),
                                  if (state.dailyEndTime != null)
                                    Text(
                                      'Daily End Time: ${state.dailyEndTime!.format(context)}',
                                    ),
                                  if (state.needsSetup)
                                    Text('Setup Hours: ${state.setupHours}'),
                                  if (state.needsTeardown)
                                    Text(
                                      'Teardown Hours: ${state.teardownHours}',
                                    ),
                                ],

                                const SizedBox(height: 16),
                                Text(
                                  'Selected Services',
                                  style:
                                      WizardStyles.getReviewSectionTitleStyle(
                                        context,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                ...state.selectedServices.entries
                                    .where((entry) => entry.value)
                                    .map(
                                      (entry) => Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Text('• ${entry.key}'),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                          isActive: state.currentStep >= 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Show milestone celebration overlay
  void _showMilestoneCelebration(
    BuildContext context,
    Milestone milestone,
    MilestoneProvider provider,
  ) {
    // Show the celebration overlay
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return MilestoneCelebrationOverlay(
          milestone: milestone,
          onDismiss: () {
            // Acknowledge the milestone and dismiss the overlay
            provider.acknowledgeNewlyCompletedMilestone(milestone.id);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
