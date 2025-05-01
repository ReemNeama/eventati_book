import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/event_wizard/event_name_input.dart';
import 'package:eventati_book/widgets/event_wizard/event_type_dropdown.dart';
import 'package:eventati_book/widgets/event_wizard/date_picker_tile.dart';
import 'package:eventati_book/widgets/event_wizard/guest_count_input.dart';
import 'package:eventati_book/widgets/event_wizard/services_selection.dart';
import 'wedding_checklist_screen.dart';
import 'package:eventati_book/utils/utils.dart';

class WeddingWizardScreen extends StatefulWidget {
  const WeddingWizardScreen({super.key});

  @override
  State<WeddingWizardScreen> createState() => _WeddingWizardScreenState();
}

class _WeddingWizardScreenState extends State<WeddingWizardScreen> {
  int _currentStep = 0;

  // Form controllers
  final _eventNameController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedEventType;
  int? _guestCount;
  final Map<String, bool> _selectedServices = {
    'Venue': false,
    'Catering': false,
    'Photography/Videography': false,
    'Wedding Dress/Attire': false,
    'Flowers & Decoration': false,
    'Music & Entertainment': false,
    'Wedding Cake': false,
    'Invitations': false,
    'Transportation': false,
    'Accommodation': false,
    'Hair & Makeup': false,
    'Wedding Rings': false,
  };

  final List<String> _weddingEventTypes = [
    'Wedding',
    'Engagement Party',
    'Wedding Shower',
    'Rehearsal Dinner',
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          "Plan Your Wedding",
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
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: primaryColor)),
          child: Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 3) setState(() => _currentStep++);
            },
            onStepCancel: () {
              if (_currentStep > 0) setState(() => _currentStep--);
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
                            backgroundColor: Colors.grey,
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
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => WeddingChecklistScreen(
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
                      eventTypes: _weddingEventTypes,
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
                title: const Text('Date & Guests'),
                content: Column(
                  children: [
                    DatePickerTile(
                      selectedDate: _selectedDate,
                      primaryColor: primaryColor,
                      onDateSelected: (date) {
                        setState(() => _selectedDate = date);
                      },
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
                      Text('Event Name: ${_eventNameController.text}'),
                      const SizedBox(height: 8),
                      Text(
                        'Event Type: ${_selectedEventType ?? "Not selected"}',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Date: ${_selectedDate != null ? DateTimeUtils.formatDate(_selectedDate!) : "Not selected"}',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Guest Count: ${_guestCount != null ? NumberUtils.formatWithCommas(_guestCount!) : "Not specified"}',
                      ),
                      const SizedBox(height: 16),
                      const Text('Selected Services:'),
                      ...(_selectedServices.entries
                          .where((entry) => entry.value)
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(left: 16, top: 4),
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
