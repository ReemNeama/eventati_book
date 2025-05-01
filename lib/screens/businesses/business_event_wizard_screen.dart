import 'package:eventati_book/screens/businesses/business_event_checklist_screen.dart';
import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/event_wizard/event_name_input.dart';
import 'package:eventati_book/widgets/event_wizard/event_type_dropdown.dart';
import 'package:eventati_book/widgets/event_wizard/date_picker_tile.dart';
import 'package:eventati_book/widgets/event_wizard/guest_count_input.dart';
import 'package:eventati_book/widgets/event_wizard/services_selection.dart';
import 'package:eventati_book/widgets/event_wizard/time_picker_tile.dart';
import 'package:eventati_book/utils/utils.dart';

class BusinessEventWizardScreen extends StatefulWidget {
  const BusinessEventWizardScreen({super.key});

  @override
  State<BusinessEventWizardScreen> createState() =>
      _BusinessEventWizardScreenState();
}

class _BusinessEventWizardScreenState extends State<BusinessEventWizardScreen> {
  int _currentStep = 0;

  // Form controllers
  final _eventNameController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedEventType;
  int? _guestCount;
  final Map<String, bool> _selectedServices = {
    'Venue': false,
    'Catering': false,
    'Audio/Visual Equipment': false,
    'Photography': false,
    'Transportation': false,
    'Accommodation': false,
    'Event Staff': false,
    'Decoration': false,
  };

  // Add new controllers for duration
  int _eventDuration = 1; // Default to 1 day
  TimeOfDay? _dailyStartTime;
  TimeOfDay? _dailyEndTime;
  bool _needsSetup = false;
  bool _needsTeardown = false;
  int _setupHours = 2; // Default setup hours
  int _teardownHours = 2; // Default teardown hours

  final List<String> _businessEventTypes = [
    'Conference',
    'Seminar',
    'Workshop',
    'Corporate Meeting',
    'Trade Show',
    'Team Building',
    'Product Launch',
    'Award Ceremony',
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final hintColor = Theme.of(context).hintColor;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          "Plan Your Business Event",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              secondary: hintColor,
            ),
          ),
          child: Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 3) {
                setState(() => _currentStep++);
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              }
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: details.onStepCancel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hintColor,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: const Text(
                            'Previous',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentStep < 3) {
                            setState(() => _currentStep++);
                          } else {
                            // Navigate to checklist screen and replace the current screen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => BusinessEventChecklistScreen(
                                      eventName: _eventNameController.text,
                                      eventType: _selectedEventType ?? '',
                                      eventDate:
                                          _selectedDate ?? DateTime.now(),
                                      guestCount: _guestCount ?? 0,
                                      selectedServices: Map.from(
                                        _selectedServices,
                                      ),
                                    ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          _currentStep == 3 ? 'Finish' : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Event Details'),
                content: Column(
                  children: [
                    EventNameInput(
                      controller: _eventNameController,
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 16),
                    EventTypeDropdown(
                      selectedValue: _selectedEventType,
                      eventTypes: _businessEventTypes,
                      primaryColor: primaryColor,
                      onChanged: (value) {
                        setState(() => _selectedEventType = value);
                      },
                    ),
                  ],
                ),
                isActive: _currentStep >= 0,
              ),
              Step(
                title: const Text('Date & Duration'),
                content: Column(
                  children: [
                    DatePickerTile(
                      selectedDate: _selectedDate,
                      primaryColor: primaryColor,
                      onDateSelected: (date) {
                        setState(() => _selectedDate = date);
                      },
                      label: 'Select Event Start Date',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'Event Duration (Days)',
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: primaryColor),
                              ),
                            ),
                            value: _eventDuration,
                            items:
                                List.generate(
                                      14,
                                      (index) => index + 1,
                                    ) // Up to 14 days
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
                              setState(() => _eventDuration = value ?? 1);
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
                            selectedTime: _dailyStartTime,
                            label: 'Daily Start Time',
                            onTimeSelected: (time) {
                              setState(() => _dailyStartTime = time);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TimePickerTile(
                            selectedTime: _dailyEndTime,
                            label: 'Daily End Time',
                            onTimeSelected: (time) {
                              setState(() => _dailyEndTime = time);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Needs Setup Day/Time'),
                      value: _needsSetup,
                      activeColor: primaryColor,
                      onChanged: (value) {
                        setState(() => _needsSetup = value ?? false);
                      },
                    ),
                    if (_needsSetup)
                      Padding(
                        padding: const EdgeInsets.only(left: 32.0),
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: 'Setup Hours Needed',
                            border: const OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: primaryColor),
                            ),
                          ),
                          value: _setupHours,
                          items:
                              List.generate(12, (index) => index + 1)
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
                            setState(() => _setupHours = value ?? 2);
                          },
                        ),
                      ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text('Needs Teardown Day/Time'),
                      value: _needsTeardown,
                      activeColor: primaryColor,
                      onChanged: (value) {
                        setState(() => _needsTeardown = value ?? false);
                      },
                    ),
                    if (_needsTeardown)
                      Padding(
                        padding: const EdgeInsets.only(left: 32.0),
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: 'Teardown Hours Needed',
                            border: const OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: primaryColor),
                            ),
                          ),
                          value: _teardownHours,
                          items:
                              List.generate(12, (index) => index + 1)
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
                            setState(() => _teardownHours = value ?? 2);
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    GuestCountInput(
                      primaryColor: primaryColor,
                      onChanged: (value) {
                        setState(() => _guestCount = int.tryParse(value));
                      },
                    ),
                  ],
                ),
                isActive: _currentStep >= 1,
              ),
              Step(
                title: const Text('Required Services'),
                content: ServicesSelection(
                  selectedServices: _selectedServices,
                  primaryColor: primaryColor,
                  onServiceChanged: (service, value) {
                    setState(() => _selectedServices[service] = value ?? false);
                  },
                ),
                isActive: _currentStep >= 2,
              ),
              Step(
                title: const Text('Review'),
                content: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Event Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Event Name: ${_eventNameController.text}'),
                      Text(
                        'Event Type: ${_selectedEventType ?? "Not selected"}',
                      ),
                      Text(
                        'Date: ${_selectedDate != null ? DateTimeUtils.formatDate(_selectedDate!) : "Not selected"}',
                      ),
                      Text(
                        'Guest Count: ${_guestCount != null ? NumberUtils.formatWithCommas(_guestCount!) : "Not specified"}',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Selected Services',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(_selectedServices.entries
                          .where((entry) => entry.value)
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text('• ${entry.key}'),
                            ),
                          )),
                    ],
                  ),
                ),
                isActive: _currentStep >= 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    super.dispose();
  }
}
