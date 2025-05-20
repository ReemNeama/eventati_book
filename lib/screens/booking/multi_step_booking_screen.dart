import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:eventati_book/widgets/common/error_message.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/widgets/common/step_progress_indicator.dart';
import 'package:eventati_book/routing/routing.dart';

/// Screen for creating a booking with multiple steps
class MultiStepBookingScreen extends StatefulWidget {
  /// Service ID for the booking
  final String serviceId;

  /// Service type (venue, catering, photography, etc.)
  final String serviceType;

  /// Service name
  final String serviceName;

  /// Base price per hour
  final double basePrice;

  /// Existing booking ID (for editing)
  final String? bookingId;

  /// Event ID (optional)
  final String? eventId;

  /// Event name (optional)
  final String? eventName;

  /// Constructor
  const MultiStepBookingScreen({
    super.key,
    required this.serviceId,
    required this.serviceType,
    required this.serviceName,
    required this.basePrice,
    this.bookingId,
    this.eventId,
    this.eventName,
  });

  @override
  State<MultiStepBookingScreen> createState() => _MultiStepBookingScreenState();
}

class _MultiStepBookingScreenState extends State<MultiStepBookingScreen> {
  // Current step
  int _currentStep = 0;

  // Form keys for each step
  final _dateTimeFormKey = GlobalKey<FormState>();
  final _detailsFormKey = GlobalKey<FormState>();
  final _contactFormKey = GlobalKey<FormState>();
  final _reviewFormKey = GlobalKey<FormState>();

  // Form controllers
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _durationController = TextEditingController();
  final _guestCountController = TextEditingController();
  final _specialRequestsController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  // Form values
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  double _duration = 2.0; // Default 2 hours
  int _guestCount = 50; // Default 50 guests
  bool _isEventRelated = false;

  // Service options
  Map<String, dynamic> _serviceOptions = {};

  // Loading state
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _error;

  // Price calculation
  double _totalPrice = 0.0;

  // Step titles
  final List<String> _stepTitles = [
    'Date & Time',
    'Details',
    'Contact',
    'Review',
  ];

  @override
  void initState() {
    super.initState();
    _durationController.text = _duration.toString();
    _guestCountController.text = _guestCount.toString();

    // Set event-related flag if event ID is provided
    if (widget.eventId != null) {
      _isEventRelated = true;
    }

    // Initialize with current user's contact info
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    _guestCountController.dispose();
    _specialRequestsController.dispose();
    _contactNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  /// Initialize the form
  Future<void> _initializeForm() async {
    setState(() {
      _isInitializing = true;
      _error = null;
    });

    try {
      // Get current user
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user != null) {
        _contactNameController.text = user.displayName;
        _contactEmailController.text = user.email;
        _contactPhoneController.text = user.phoneNumber ?? '';
      }

      // If editing an existing booking, load its data
      if (widget.bookingId != null) {
        final bookingProvider = Provider.of<BookingProvider>(
          context,
          listen: false,
        );
        final booking = bookingProvider.getBookingById(widget.bookingId!);

        if (booking != null) {
          _selectedDate = booking.bookingDateTime;
          _selectedTime = TimeOfDay.fromDateTime(booking.bookingDateTime);
          _duration = booking.duration;
          _guestCount = booking.guestCount;
          _isEventRelated = booking.eventId != null;

          _dateController.text = DateTimeUtils.formatDate(_selectedDate!);
          _timeController.text = _selectedTime!.format(context);
          _durationController.text = _duration.toString();
          _guestCountController.text = _guestCount.toString();
          _specialRequestsController.text = booking.specialRequests;
          _contactNameController.text = booking.contactName;
          _contactEmailController.text = booking.contactEmail;
          _contactPhoneController.text = booking.contactPhone;

          // Load service options
          _serviceOptions = booking.serviceOptions;
        }
      }

      // Calculate initial price
      _calculateTotalPrice();

      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _error = 'Failed to initialize form: $e';
      });
    }
  }

  /// Calculate the total price based on duration, guest count, and base price
  void _calculateTotalPrice() {
    // Base calculation: basePrice * duration
    double price = widget.basePrice * _duration;

    // Add guest count factor (example: 10% extra for each 50 guests over 50)
    if (_guestCount > 50) {
      final extraGuestGroups = (_guestCount - 50) / 50;
      price += price * 0.1 * extraGuestGroups.ceil();
    }

    setState(() {
      _totalPrice = price;
    });
  }

  /// Show date picker
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateTimeUtils.formatDate(picked);
      });

      // Check availability
      await _checkAvailability();
    }
  }

  /// Show time picker
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });

      // Check availability
      await _checkAvailability();
    }
  }

  /// Check if the service is available at the selected date and time
  Future<void> _checkAvailability() async {
    if (_selectedDate == null || _selectedTime == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Create DateTime from selected date and time
      final bookingDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Check availability
      final bookingProvider = Provider.of<BookingProvider>(
        context,
        listen: false,
      );
      final isAvailable = await bookingProvider.isServiceAvailable(
        widget.serviceId,
        bookingDateTime,
        _duration,
      );

      if (!isAvailable) {
        setState(() {
          _error =
              'Service is not available at the selected date and time. Please choose another time.';
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to check availability: $e';
      });
    }
  }

  /// Validate all steps
  bool _validateAllSteps() {
    bool isValid = true;

    // Validate date and time step
    if (_selectedDate == null || _selectedTime == null) {
      isValid = false;
      setState(() {
        _error = 'Please select a date and time for the booking.';
      });
      return isValid;
    }

    // Validate details step
    if (_guestCount <= 0 || _duration <= 0) {
      isValid = false;
      setState(() {
        _error = 'Please enter valid guest count and duration.';
      });
      return isValid;
    }

    // Validate contact step
    if (_contactNameController.text.isEmpty ||
        _contactEmailController.text.isEmpty ||
        _contactPhoneController.text.isEmpty) {
      isValid = false;
      setState(() {
        _error = 'Please fill in all contact information.';
      });
      return isValid;
    }

    // Validate email format
    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(_contactEmailController.text)) {
      isValid = false;
      setState(() {
        _error = 'Please enter a valid email address.';
      });
      return isValid;
    }

    return isValid;
  }

  /// Move to the next step
  void _nextStep() {
    bool canProceed = false;

    switch (_currentStep) {
      case 0: // Date & Time
        canProceed = _selectedDate != null && _selectedTime != null;
        if (!canProceed) {
          setState(() {
            _error = 'Please select a date and time for the booking.';
          });
        }
        break;
      case 1: // Details
        canProceed = _guestCount > 0 && _duration > 0;
        if (!canProceed) {
          setState(() {
            _error = 'Please enter valid guest count and duration.';
          });
        }
        break;
      case 2: // Contact
        canProceed =
            _contactNameController.text.isNotEmpty &&
            _contactEmailController.text.isNotEmpty &&
            _contactPhoneController.text.isNotEmpty;
        if (!canProceed) {
          setState(() {
            _error = 'Please fill in all contact information.';
          });
        }
        break;
      case 3: // Review
        // No validation needed for review step
        canProceed = true;
        break;
    }

    if (canProceed) {
      setState(() {
        _error = null;
        if (_currentStep < 3) {
          _currentStep++;
        }
      });
    }
  }

  /// Move to the previous step
  void _previousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }

  /// Build step indicator
  Widget _buildStepIndicator(Color primaryColor, bool isDarkMode) {
    return StepProgressIndicator(
      currentStep: _currentStep,
      totalSteps: _stepTitles.length,
      stepLabels: _stepTitles,
      activeColor: primaryColor,
      inactiveColor: isDarkMode ? AppColorsDark.disabled : AppColors.disabled,
      style: ProgressIndicatorStyle.numbered,
    );
  }

  /// Submit the form
  Future<void> _submitForm() async {
    // Validate form
    if (!_validateAllSteps()) return;

    // Check if date and time are selected
    if (_selectedDate == null || _selectedTime == null) {
      setState(() {
        _error = 'Please select a date and time for the booking.';
      });

      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Create DateTime from selected date and time
      final bookingDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Get current user
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      // Create or update booking
      final bookingProvider = Provider.of<BookingProvider>(
        context,
        listen: false,
      );

      if (widget.bookingId != null) {
        // Update existing booking
        final existingBooking = bookingProvider.getBookingById(
          widget.bookingId!,
        );

        if (existingBooking == null) {
          throw Exception('Booking not found');
        }

        final updatedBooking = existingBooking.copyWith(
          bookingDateTime: bookingDateTime,
          duration: _duration,
          guestCount: _guestCount,
          specialRequests: _specialRequestsController.text,
          totalPrice: _totalPrice,
          updatedAt: DateTime.now(),
          contactName: _contactNameController.text,
          contactEmail: _contactEmailController.text,
          contactPhone: _contactPhoneController.text,
          eventId: _isEventRelated ? widget.eventId : null,
          eventName: _isEventRelated ? widget.eventName : null,
          serviceOptions: _serviceOptions,
        );

        final success = await bookingProvider.updateBooking(updatedBooking);

        if (!success) {
          throw Exception(bookingProvider.error ?? 'Failed to update booking');
        }
      } else {
        // Create new booking
        final newBooking = Booking(
          id: const Uuid().v4(),
          userId: user.uid,
          serviceId: widget.serviceId,
          serviceType: widget.serviceType,
          serviceName: widget.serviceName,
          bookingDateTime: bookingDateTime,
          duration: _duration,
          guestCount: _guestCount,
          specialRequests: _specialRequestsController.text,
          status: BookingStatus.pending,
          totalPrice: _totalPrice,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          contactName: _contactNameController.text,
          contactEmail: _contactEmailController.text,
          contactPhone: _contactPhoneController.text,
          eventId: _isEventRelated ? widget.eventId : null,
          eventName: _isEventRelated ? widget.eventName : null,
          serviceOptions: _serviceOptions,
        );

        final success = await bookingProvider.createBooking(newBooking);

        if (!success) {
          throw Exception(bookingProvider.error ?? 'Failed to create booking');
        }
      }

      // Show success message and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.bookingId != null
                  ? 'Booking updated successfully'
                  : 'Booking created successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate to payment screen
        NavigationUtils.navigateToNamed(
          context,
          RouteNames.payment,
          arguments: PaymentArguments(
            bookingId: widget.bookingId ?? 'new_booking_id',
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final backgroundColor =
        isDarkMode ? AppColorsDark.background : AppColors.background;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookingId != null ? 'Edit Booking' : 'New Booking'),
        backgroundColor: primaryColor,
      ),
      body:
          _isInitializing
              ? const Center(
                child: LoadingIndicator(message: 'Loading booking form...'),
              )
              : Container(
                color: backgroundColor,
                child: Column(
                  children: [
                    // Step progress indicator
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildStepIndicator(primaryColor, isDarkMode),
                    ),

                    // Error message
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ErrorMessage(message: _error!),
                      ),

                    // Step content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildCurrentStep(),
                      ),
                    ),

                    // Navigation buttons
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back button
                          if (_currentStep > 0)
                            ElevatedButton(
                              onPressed: _isLoading ? null : _previousStep,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Back'),
                            )
                          else
                            const SizedBox.shrink(),

                          // Next/Submit button
                          ElevatedButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : () {
                                      if (_currentStep <
                                          _stepTitles.length - 1) {
                                        _nextStep();
                                      } else {
                                        _submitForm();
                                      }
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : Text(
                                      _currentStep < _stepTitles.length - 1
                                          ? 'Next'
                                          : 'Submit',
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  /// Build the current step content
  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildDateTimeStep();
      case 1:
        return _buildDetailsStep();
      case 2:
        return _buildContactStep();
      case 3:
        return _buildReviewStep();
      default:
        return const SizedBox.shrink();
    }
  }

  /// Build the date and time step
  Widget _buildDateTimeStep() {
    return Form(
      key: _dateTimeFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Date and Time', style: TextStyles.sectionTitle),
          const SizedBox(height: 16),
          TextFormField(
            controller: _dateController,
            decoration: const InputDecoration(
              labelText: 'Date',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: _selectDate,
            validator: FormUtils.validateRequired,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _timeController,
            decoration: const InputDecoration(
              labelText: 'Time',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.access_time),
            ),
            readOnly: true,
            onTap: _selectTime,
            validator: FormUtils.validateRequired,
          ),
          const SizedBox(height: 24),
          // Service info card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Service Information', style: TextStyles.subtitle),
                  const SizedBox(height: 8),
                  Text('Service: ${widget.serviceName}'),
                  Text('Type: ${widget.serviceType}'),
                  Text(
                    'Base Price: \$${widget.basePrice.toStringAsFixed(2)} per hour',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the details step
  Widget _buildDetailsStep() {
    return Form(
      key: _detailsFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking Details', style: TextStyles.sectionTitle),
          const SizedBox(height: 16),
          TextFormField(
            controller: _durationController,
            decoration: const InputDecoration(
              labelText: 'Duration (hours)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: FormUtils.validateNumber,
            onChanged: (value) {
              final duration = double.tryParse(value);
              if (duration != null) {
                setState(() {
                  _duration = duration;
                });
                _calculateTotalPrice();
                _checkAvailability();
              }
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _guestCountController,
            decoration: const InputDecoration(
              labelText: 'Number of Guests',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: FormUtils.validateInteger,
            onChanged: (value) {
              final count = int.tryParse(value);
              if (count != null) {
                setState(() {
                  _guestCount = count;
                });
                _calculateTotalPrice();
              }
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _specialRequestsController,
            decoration: const InputDecoration(
              labelText: 'Special Requests (Optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          // Service-specific options
          Text('Service-Specific Options', style: TextStyles.sectionTitle),
          const SizedBox(height: 8),
          // Generate service-specific options based on service type
          ...ServiceOptionsFactory.generateServiceOptionsFields(
            context: context,
            serviceType: widget.serviceType,
            initialOptions: _serviceOptions,
            onOptionsChanged: (newOptions) {
              setState(() {
                _serviceOptions = newOptions;
              });
            },
          ),
          const SizedBox(height: 16),
          // Event relation
          if (widget.eventId != null)
            CheckboxListTile(
              title: const Text('Associate with event'),
              subtitle: Text(widget.eventName ?? 'Your event'),
              value: _isEventRelated,
              onChanged: (value) {
                setState(() {
                  _isEventRelated = value ?? false;
                });
              },
            ),
        ],
      ),
    );
  }

  /// Build the contact step
  Widget _buildContactStep() {
    return Form(
      key: _contactFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact Information', style: TextStyles.sectionTitle),
          const SizedBox(height: 16),
          TextFormField(
            controller: _contactNameController,
            decoration: const InputDecoration(
              labelText: 'Contact Name',
              border: OutlineInputBorder(),
            ),
            validator: FormUtils.validateRequired,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _contactEmailController,
            decoration: const InputDecoration(
              labelText: 'Contact Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: FormUtils.validateEmail,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _contactPhoneController,
            decoration: const InputDecoration(
              labelText: 'Contact Phone',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            validator: FormUtils.validatePhone,
          ),
        ],
      ),
    );
  }

  /// Build the review step
  Widget _buildReviewStep() {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Form(
      key: _reviewFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review Booking', style: TextStyles.sectionTitle),
          const SizedBox(height: 16),
          // Service info
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Service Information', style: TextStyles.subtitle),
                  const SizedBox(height: 8),
                  Text('Service: ${widget.serviceName}'),
                  Text('Type: ${widget.serviceType}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Date and time
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date and Time', style: TextStyles.subtitle),
                  const SizedBox(height: 8),
                  Text('Date: ${_dateController.text}'),
                  Text('Time: ${_timeController.text}'),
                  Text('Duration: $_duration hours'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Details
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booking Details', style: TextStyles.subtitle),
                  const SizedBox(height: 8),
                  Text('Guest Count: $_guestCount'),
                  if (_specialRequestsController.text.isNotEmpty)
                    Text(
                      'Special Requests: ${_specialRequestsController.text}',
                    ),
                  if (widget.eventId != null && _isEventRelated)
                    Text('Event: ${widget.eventName}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Contact
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Contact Information', style: TextStyles.subtitle),
                  const SizedBox(height: 8),
                  Text('Name: ${_contactNameController.text}'),
                  Text('Email: ${_contactEmailController.text}'),
                  Text('Phone: ${_contactPhoneController.text}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Price summary
          Card(
            elevation: 2,
            color:
                isDarkMode
                    ? AppColorsDark.cardBackground
                    : AppColors.cardBackground,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price Summary',
                    style: TextStyles.subtitle.copyWith(color: primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Base Price:'),
                      Text('\$${widget.basePrice.toStringAsFixed(2)} per hour'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Duration:'),
                      Text('$_duration hours'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Guest Count:'),
                      Text('$_guestCount guests'),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Price:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        '\$${_totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Payment notice
          Card(
            elevation: 2,
            color: Color.fromRGBO(
              AppColors.warning.r.toInt(),
              AppColors.warning.g.toInt(),
              AppColors.warning.b.toInt(),
              0.1,
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.warning),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You will be redirected to the payment screen after submitting this booking.',
                      style: TextStyle(color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
