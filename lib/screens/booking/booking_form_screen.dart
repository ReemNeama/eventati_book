import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:eventati_book/models/booking.dart';
import 'package:eventati_book/providers/booking_provider.dart';
import 'package:eventati_book/providers/auth_provider.dart';
import 'package:eventati_book/utils/date_utils.dart' as date_utils;
import 'package:eventati_book/utils/form_utils.dart';
import 'package:eventati_book/utils/ui_utils.dart';
import 'package:eventati_book/utils/service_options_factory.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:eventati_book/widgets/common/error_message.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// Screen for creating or editing a booking
class BookingFormScreen extends StatefulWidget {
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
  const BookingFormScreen({
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
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  // Form key
  final _formKey = GlobalKey<FormState>();

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

          _dateController.text = date_utils.DateTimeUtils.formatDate(
            _selectedDate!,
          );
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
        _dateController.text = date_utils.DateTimeUtils.formatDate(picked);
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

  /// Submit the form
  Future<void> _submitForm() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

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
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
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
    final textColor =
        isDarkMode ? AppColorsDark.textPrimary : AppColors.textPrimary;

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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service info
                        Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Service Information',
                                  style: TextStyles.sectionTitle.copyWith(
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Service: ${widget.serviceName}',
                                  style: TextStyles.bodyMedium.copyWith(
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  'Type: ${widget.serviceType}',
                                  style: TextStyles.bodyMedium.copyWith(
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  'Base Price: \$${widget.basePrice.toStringAsFixed(2)} per hour',
                                  style: TextStyles.bodyMedium.copyWith(
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Error message
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ErrorMessage(message: _error!),
                          ),

                        // Date and time
                        Text(
                          'Date and Time',
                          style: TextStyles.sectionTitle.copyWith(
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _dateController,
                                decoration: InputDecoration(
                                  labelText: 'Date',
                                  border: const OutlineInputBorder(),
                                  suffixIcon: Icon(
                                    Icons.calendar_today,
                                    color: primaryColor,
                                  ),
                                ),
                                readOnly: true,
                                onTap: _selectDate,
                                validator: FormUtils.validateRequired,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _timeController,
                                decoration: InputDecoration(
                                  labelText: 'Time',
                                  border: const OutlineInputBorder(),
                                  suffixIcon: Icon(
                                    Icons.access_time,
                                    color: primaryColor,
                                  ),
                                ),
                                readOnly: true,
                                onTap: _selectTime,
                                validator: FormUtils.validateRequired,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Duration and guest count
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
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
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
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
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Special requests
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
                        Text(
                          'Service-Specific Options',
                          style: TextStyles.sectionTitle.copyWith(
                            color: primaryColor,
                          ),
                        ),
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
                            activeColor: primaryColor,
                            onChanged: (value) {
                              setState(() {
                                _isEventRelated = value ?? false;
                              });
                            },
                          ),
                        const SizedBox(height: 16),

                        // Contact information
                        Text(
                          'Contact Information',
                          style: TextStyles.sectionTitle.copyWith(
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                        const SizedBox(height: 24),

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
                                  style: TextStyles.sectionTitle.copyWith(
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Base Price:',
                                      style: TextStyles.bodyMedium.copyWith(
                                        color: textColor,
                                      ),
                                    ),
                                    Text(
                                      '\$${widget.basePrice.toStringAsFixed(2)} per hour',
                                      style: TextStyles.bodyMedium.copyWith(
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Duration:',
                                      style: TextStyles.bodyMedium.copyWith(
                                        color: textColor,
                                      ),
                                    ),
                                    Text(
                                      '$_duration hours',
                                      style: TextStyles.bodyMedium.copyWith(
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Guest Count:',
                                      style: TextStyles.bodyMedium.copyWith(
                                        color: textColor,
                                      ),
                                    ),
                                    Text(
                                      '$_guestCount guests',
                                      style: TextStyles.bodyMedium.copyWith(
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Price:',
                                      style: TextStyles.subtitle.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                    Text(
                                      '\$${_totalPrice.toStringAsFixed(2)}',
                                      style: TextStyles.subtitle.copyWith(
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
                        const SizedBox(height: 24),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
                                      widget.bookingId != null
                                          ? 'Update Booking'
                                          : 'Create Booking',
                                      style: TextStyles.buttonText,
                                    ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
