import 'package:flutter/material.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';

class GuestGroupsScreen extends StatefulWidget {
  final String eventId;
  final GuestListProvider guestListProvider;

  const GuestGroupsScreen({
    super.key,
    required this.eventId,
    required this.guestListProvider,
  });

  @override
  State<GuestGroupsScreen> createState() => _GuestGroupsScreenState();
}

class _GuestGroupsScreenState extends State<GuestGroupsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest Groups'),
        backgroundColor: primaryColor,
      ),
      body:
          widget.guestListProvider.groups.isEmpty
              ? Center(
                child: Text(
                  'No groups yet. Add your first group!',
                  style: TextStyle(
                    color: isDarkMode ? Color.fromRGBO(Colors.white.r.toInt(), Colors.white.g.toInt(), Colors.white.b.toInt(), 0.7) : AppColors.textSecondary,
                  ),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widget.guestListProvider.groups.length,
                itemBuilder: (context, index) {
                  final group = widget.guestListProvider.groups[index];
                  final groupGuests = widget.guestListProvider.getGuestsByGroup(
                    group.id,
                  );

                  return _buildGroupCard(context, group, groupGuests.length);
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
        onPressed: () => _showGroupFormDialog(context),
      ),
    );
  }

  Widget _buildGroupCard(
    BuildContext context,
    GuestGroup group,
    int guestCount,
  ) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Group icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(51), // 0.2 * 255 = 51
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(Icons.group, color: primaryColor, size: 24),
              ),
            ),
            const SizedBox(width: 16),
            // Group info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name, style: TextStyles.sectionTitle),
                  if (group.description != null) ...[
                    const SizedBox(height: 4),
                    Text(group.description!, style: TextStyles.bodyMedium),
                  ],
                  const SizedBox(height: 4),
                  Text('$guestCount guests', style: TextStyles.bodyMedium),
                ],
              ),
            ),
            // Actions
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showGroupFormDialog(context, group),
                  tooltip: 'Edit Group',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteConfirmation(context, group),
                  tooltip: 'Delete Group',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showGroupFormDialog(BuildContext context, [GuestGroup? group]) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final isEditing = group != null;

    final nameController = TextEditingController(text: group?.name ?? '');
    final descriptionController = TextEditingController(
      text: group?.description ?? '',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isEditing ? 'Edit Group' : 'Add Group'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Group Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Group name cannot be empty'),
                      ),
                    );

                    return;
                  }

                  final description =
                      descriptionController.text.trim().isNotEmpty
                          ? descriptionController.text.trim()
                          : null;

                  if (isEditing) {
                    // Update existing group
                    final updatedGroup = GuestGroup(
                      id: group.id,
                      name: name,
                      description: description,
                    );
                    widget.guestListProvider.updateGroup(updatedGroup);
                  } else {
                    // Create new group
                    final newGroup = GuestGroup(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      description: description,
                    );
                    widget.guestListProvider.addGroup(newGroup);
                  }

                  Navigator.pop(context);
                  setState(() {});
                },
                child: Text(
                  isEditing ? 'Update' : 'Add',
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, GuestGroup group) {
    final groupGuests = widget.guestListProvider.getGuestsByGroup(group.id);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Group'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure you want to delete "${group.name}"?'),
                if (groupGuests.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Warning: This group has ${groupGuests.length} guests. '
                    'Deleting this group will remove the group assignment from these guests.',
                    style: const TextStyle(color: AppColors.error),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Remove group from all guests
                  for (final guest in groupGuests) {
                    final updatedGuest = guest.copyWith(groupId: null);
                    widget.guestListProvider.updateGuest(updatedGuest);
                  }

                  // Delete the group
                  widget.guestListProvider.deleteGroup(group.id);
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }
}
