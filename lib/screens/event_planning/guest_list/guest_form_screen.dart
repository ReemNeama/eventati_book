import 'package:flutter/material.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';

class GuestFormScreen extends StatefulWidget {
  final String eventId;
  final GuestListProvider guestListProvider;
  final Guest? guest;

  const GuestFormScreen({
    super.key,
    required this.eventId,
    required this.guestListProvider,
    this.guest,
  });

  @override
  State<GuestFormScreen> createState() => _GuestFormScreenState();
}

class _GuestFormScreenState extends State<GuestFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _groupId;
  RsvpStatus _rsvpStatus = RsvpStatus.pending;
  DateTime? _rsvpResponseDate;
  bool _plusOne = false;
  int _plusOneCount = 1;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.guest != null) {
      // Edit mode - populate form with existing data
      _firstNameController.text = widget.guest!.firstName;
      _lastNameController.text = widget.guest!.lastName;
      _emailController.text = widget.guest!.email ?? '';
      _phoneController.text = widget.guest!.phone ?? '';
      _groupId = widget.guest!.groupId;
      _rsvpStatus = widget.guest!.rsvpStatus;
      _rsvpResponseDate = widget.guest!.rsvpResponseDate;
      _plusOne = widget.guest!.plusOne;
      _plusOneCount = widget.guest!.plusOneCount ?? 1;
      _notesController.text = widget.guest!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final isEditing = widget.guest != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Guest' : 'Add Guest'),
        backgroundColor: primaryColor,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(context),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Information Section
            _buildSectionHeader('Basic Information'),

            // First Name
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a first name';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),

            // Last Name
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a last name';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email (optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  // Simple email validation
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email address';
                  }
                }

                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone (optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Group
            DropdownButtonFormField<String?>(
              value: _groupId,
              decoration: const InputDecoration(
                labelText: 'Group',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No Group'),
                ),
                ...widget.guestListProvider.groups.map((group) {
                  return DropdownMenuItem<String>(
                    value: group.id,
                    child: Text(group.name),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _groupId = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // RSVP Section
            _buildSectionHeader('RSVP Information'),

            // RSVP Status
            DropdownButtonFormField<RsvpStatus>(
              value: _rsvpStatus,
              decoration: const InputDecoration(
                labelText: 'RSVP Status',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: RsvpStatus.pending,
                  child: Row(
                    children: [
                      Icon(Icons.pending, size: 20, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Pending'),
                    ],
                  ),
                ),
                const DropdownMenuItem(
                  value: RsvpStatus.confirmed,
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 20, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Confirmed'),
                    ],
                  ),
                ),
                const DropdownMenuItem(
                  value: RsvpStatus.declined,
                  child: Row(
                    children: [
                      Icon(Icons.cancel, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Declined'),
                    ],
                  ),
                ),
                const DropdownMenuItem(
                  value: RsvpStatus.tentative,
                  child: Row(
                    children: [
                      Icon(Icons.help, size: 20, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Tentative'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _rsvpStatus = value;
                    // If status is changing from pending, set response date to now
                    if (widget.guest?.rsvpStatus == RsvpStatus.pending &&
                        value != RsvpStatus.pending) {
                      _rsvpResponseDate = DateTime.now();
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Additional Guests Section
            _buildSectionHeader('Additional Guests'),

            // Plus One
            SwitchListTile(
              title: const Text('Plus One'),
              value: _plusOne,
              activeColor: primaryColor,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  _plusOne = value;
                });
              },
            ),

            // Plus One Count (only shown if plus one is enabled)
            if (_plusOne) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Number of additional guests:'),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _plusOneCount,
                      items: List.generate(5, (index) {
                        final count = index + 1;

                        return DropdownMenuItem<int>(
                          value: count,
                          child: Text(count.toString()),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _plusOneCount = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            const SizedBox(height: 24),

            // Notes Section
            _buildSectionHeader('Additional Notes'),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _saveGuest,
              child: Text(
                isEditing ? 'Update Guest' : 'Add Guest',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Divider(),
        const SizedBox(height: 8),
      ],
    );
  }

  void _saveGuest() async {
    if (_formKey.currentState!.validate()) {
      // Create or update guest
      final firstName = _firstNameController.text;
      final lastName = _lastNameController.text;
      final email =
          _emailController.text.isNotEmpty ? _emailController.text : null;
      final phone =
          _phoneController.text.isNotEmpty ? _phoneController.text : null;
      final notes =
          _notesController.text.isNotEmpty ? _notesController.text : null;

      // Set response date if status is changing from pending
      DateTime? responseDate = _rsvpResponseDate;
      if (widget.guest != null) {
        if (widget.guest!.rsvpStatus == RsvpStatus.pending &&
            _rsvpStatus != RsvpStatus.pending &&
            widget.guest!.rsvpResponseDate == null) {
          responseDate = DateTime.now();
        }
      } else if (_rsvpStatus != RsvpStatus.pending) {
        // New guest with non-pending status
        responseDate = DateTime.now();
      }

      if (widget.guest != null) {
        // Update existing guest
        final updatedGuest = widget.guest!.copyWith(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          groupId: _groupId,
          rsvpStatus: _rsvpStatus,
          rsvpResponseDate: responseDate,
          plusOne: _plusOne,
          plusOneCount: _plusOne ? _plusOneCount : null,
          notes: notes,
        );

        await widget.guestListProvider.updateGuest(updatedGuest);
      } else {
        // Create new guest
        final newGuest = Guest(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          groupId: _groupId,
          rsvpStatus: _rsvpStatus,
          rsvpResponseDate: responseDate,
          plusOne: _plusOne,
          plusOneCount: _plusOne ? _plusOneCount : null,
          notes: notes,
        );

        await widget.guestListProvider.addGuest(newGuest);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Guest'),
            content: Text(
              'Are you sure you want to delete "${widget.guest!.fullName}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  widget.guestListProvider.deleteGuest(widget.guest!.id);
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to previous screen
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
