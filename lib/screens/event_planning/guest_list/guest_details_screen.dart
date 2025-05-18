import 'package:flutter/material.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/screens/event_planning/guest_list/guest_form_screen.dart';
import 'package:eventati_book/styles/text_styles.dart';

class GuestDetailsScreen extends StatelessWidget {
  final String eventId;
  final GuestListProvider guestListProvider;
  final Guest guest;

  const GuestDetailsScreen({
    super.key,
    required this.eventId,
    required this.guestListProvider,
    required this.guest,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    // Get group name
    String groupName = 'No Group';
    if (guest.groupId != null) {
      final group = guestListProvider.groups.firstWhere(
        (g) => g.id == guest.groupId,
        orElse: () => GuestGroup(id: '', name: 'Unknown'),
      );
      groupName = group.name;
    }

    // No meal preference

    // RSVP status color and icon
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (guest.rsvpStatus) {
      case RsvpStatus.confirmed:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        statusText = 'Confirmed';
        break;
      case RsvpStatus.pending:
        statusColor = AppColors.warning;
        statusIcon = Icons.pending;
        statusText = 'Pending';
        break;
      case RsvpStatus.declined:
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        statusText = 'Declined';
        break;
      case RsvpStatus.tentative:
        statusColor = AppColors.primary;
        statusIcon = Icons.help;
        statusText = 'Tentative';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(guest.fullName),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Guest',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => GuestFormScreen(
                        eventId: eventId,
                        guestListProvider: guestListProvider,
                        guest: guest,
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Guest header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Hero(
                  tag: 'guest-avatar-${guest.id}',
                  child: CircleAvatar(
                    backgroundColor: statusColor.withAlpha(
                      51,
                    ), // 0.2 * 255 = 51
                    radius: 40,
                    child: Text(
                      '${guest.firstName[0]}${guest.lastName[0]}',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Guest info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(guest.fullName, style: TextStyles.title),
                      const SizedBox(height: 8),
                      // RSVP status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(51), // 0.2 * 255 = 51
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, color: statusColor, size: 18),
                            const SizedBox(width: 8),
                            Text(statusText, style: TextStyles.bodyLarge),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Contact Information
            _buildSectionCard(
              context,
              'Contact Information',
              Icons.contact_mail,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (guest.email != null) ...[
                    _buildInfoRow(context, 'Email', guest.email!, Icons.email),
                    const SizedBox(height: 12),
                  ],
                  if (guest.phone != null) ...[
                    _buildInfoRow(context, 'Phone', guest.phone!, Icons.phone),
                    const SizedBox(height: 12),
                  ],
                  if (guest.email == null && guest.phone == null)
                    Text(
                      'No contact information provided',
                      style: TextStyle(
                        color:
                            isDarkMode
                                ? Color.fromRGBO(
                                  AppColors.disabled.r.toInt(),
                                  AppColors.disabled.g.toInt(),
                                  AppColors.disabled.b.toInt(),
                                  0.4,
                                )
                                : Color.fromRGBO(
                                  AppColors.disabled.r.toInt(),
                                  AppColors.disabled.g.toInt(),
                                  AppColors.disabled.b.toInt(),
                                  0.6,
                                ),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Group Information
            _buildSectionCard(
              context,
              'Group',
              Icons.group,
              _buildInfoRow(context, 'Group', groupName, Icons.group),
            ),
            const SizedBox(height: 16),

            // Plus One Information
            _buildSectionCard(
              context,
              'Additional Guests',
              Icons.person_add,
              guest.plusOne
                  ? _buildInfoRow(
                    context,
                    'Plus',
                    '${guest.plusOneCount ?? 1} additional guest(s)',
                    Icons.person_add,
                  )
                  : Text(
                    'No additional guests',
                    style: TextStyle(
                      color:
                          isDarkMode
                              ? Color.fromRGBO(
                                AppColors.disabled.r.toInt(),
                                AppColors.disabled.g.toInt(),
                                AppColors.disabled.b.toInt(),
                                0.4,
                              )
                              : Color.fromRGBO(
                                AppColors.disabled.r.toInt(),
                                AppColors.disabled.g.toInt(),
                                AppColors.disabled.b.toInt(),
                                0.6,
                              ),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
            ),
            const SizedBox(height: 16),

            // Notes
            if (guest.notes != null && guest.notes!.isNotEmpty)
              _buildSectionCard(
                context,
                'Notes',
                Icons.note,
                Text(guest.notes!, style: TextStyles.bodyLarge),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRsvpUpdateDialog(context),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.update),
        label: const Text('Update RSVP'),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget content,
  ) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(title, style: TextStyles.sectionTitle),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final isDarkMode = UIUtils.isDarkMode(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color:
              isDarkMode
                  ? Color.fromRGBO(
                    AppColors.disabled.r.toInt(),
                    AppColors.disabled.g.toInt(),
                    AppColors.disabled.b.toInt(),
                    0.4,
                  )
                  : Color.fromRGBO(
                    AppColors.disabled.r.toInt(),
                    AppColors.disabled.g.toInt(),
                    AppColors.disabled.b.toInt(),
                    0.6,
                  ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyles.bodyMedium),
            Text(value, style: TextStyles.bodyLarge),
          ],
        ),
      ],
    );
  }

  void _showRsvpUpdateDialog(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    RsvpStatus selectedStatus = guest.rsvpStatus;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Update RSVP Status'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<RsvpStatus>(
                      title: const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text('Confirmed'),
                        ],
                      ),
                      value: RsvpStatus.confirmed,
                      groupValue: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                    RadioListTile<RsvpStatus>(
                      title: const Row(
                        children: [
                          Icon(
                            Icons.pending,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text('Pending'),
                        ],
                      ),
                      value: RsvpStatus.pending,
                      groupValue: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                    RadioListTile<RsvpStatus>(
                      title: const Row(
                        children: [
                          Icon(Icons.cancel, color: AppColors.error, size: 20),
                          SizedBox(width: 8),
                          Text('Declined'),
                        ],
                      ),
                      value: RsvpStatus.declined,
                      groupValue: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                    RadioListTile<RsvpStatus>(
                      title: const Row(
                        children: [
                          Icon(Icons.help, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text('Tentative'),
                        ],
                      ),
                      value: RsvpStatus.tentative,
                      groupValue: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (selectedStatus != guest.rsvpStatus) {
                        final updatedGuest = guest.copyWith(
                          rsvpStatus: selectedStatus,
                        );
                        guestListProvider.updateGuest(updatedGuest);
                      }
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Update',
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }
}
