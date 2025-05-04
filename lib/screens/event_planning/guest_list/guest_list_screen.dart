import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/screens/event_planning/guest_list/guest_form_screen.dart';
import 'package:eventati_book/screens/event_planning/guest_list/guest_details_screen.dart';
import 'package:eventati_book/screens/event_planning/guest_list/guest_groups_screen.dart';

class GuestListScreen extends StatefulWidget {
  final String eventId;
  final String eventName;

  const GuestListScreen({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<GuestListScreen> createState() => _GuestListScreenState();
}

class _GuestListScreenState extends State<GuestListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedGroupId;
  RsvpStatus? _selectedRsvpStatus;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return ChangeNotifierProvider(
      create: (_) => GuestListProvider(eventId: widget.eventId),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Guest List for ${widget.eventName}'),
          backgroundColor: primaryColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.group),
              tooltip: 'Manage Groups',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => GuestGroupsScreen(
                          eventId: widget.eventId,
                          guestListProvider: Provider.of<GuestListProvider>(
                            context,
                            listen: false,
                          ),
                        ),
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: const [Tab(text: 'All Guests'), Tab(text: 'Summary')],
          ),
        ),
        body: Consumer<GuestListProvider>(
          builder: (context, guestListProvider, _) {
            if (guestListProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (guestListProvider.error != null) {
              return Center(child: Text('Error: ${guestListProvider.error}'));
            }

            return TabBarView(
              controller: _tabController,
              children: [
                _buildGuestListTab(guestListProvider),
                _buildSummaryTab(guestListProvider),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => GuestFormScreen(
                      eventId: widget.eventId,
                      guestListProvider: Provider.of<GuestListProvider>(
                        context,
                        listen: false,
                      ),
                    ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGuestListTab(GuestListProvider guestListProvider) {
    final filteredGuests = _getFilteredGuests(guestListProvider);

    return Column(
      children: [
        _buildFilterBar(guestListProvider),
        Expanded(
          child:
              filteredGuests.isEmpty
                  ? Center(
                    child: Text(
                      guestListProvider.guests.isEmpty
                          ? 'No guests yet. Add your first guest!'
                          : 'No guests match your filters',
                      style: TextStyle(
                        color:
                            UIUtils.isDarkMode(context)
                                ? Colors.white70
                                : Colors.black54,
                      ),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredGuests.length,
                    itemBuilder: (context, index) {
                      return _buildGuestCard(
                        context,
                        filteredGuests[index],
                        guestListProvider,
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildSummaryTab(GuestListProvider guestListProvider) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    // Calculate total guests including plus ones
    int totalGuestCount = guestListProvider.guests.length;
    int plusOneCount = 0;

    for (final guest in guestListProvider.guests) {
      if (guest.plusOne && guest.plusOneCount != null) {
        plusOneCount += guest.plusOneCount!;
      }
    }

    totalGuestCount += plusOneCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // RSVP Summary
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RSVP Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRsvpStat(
                        'Total',
                        guestListProvider.totalGuests,
                        primaryColor,
                      ),
                      _buildRsvpStat(
                        'Confirmed',
                        guestListProvider.confirmedGuests,
                        Colors.green,
                      ),
                      _buildRsvpStat(
                        'Pending',
                        guestListProvider.pendingGuests,
                        Colors.orange,
                      ),
                      _buildRsvpStat(
                        'Declined',
                        guestListProvider.declinedGuests,
                        Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total Guest Count (including plus ones): $totalGuestCount',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Group Summary
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Groups',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...guestListProvider.groups.map((group) {
                    final groupGuests = guestListProvider.getGuestsByGroup(
                      group.id,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            group.name,
                            style: TextStyle(fontSize: 16, color: textColor),
                          ),
                          Text(
                            '${groupGuests.length} guests',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRsvpStat(String label, int count, Color color) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withAlpha(51), // 0.2 * 255 = 51
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14, color: textColor)),
      ],
    );
  }

  List<Guest> _getFilteredGuests(GuestListProvider guestListProvider) {
    var guests = guestListProvider.guests;

    // Filter by group if selected
    if (_selectedGroupId != null) {
      guests =
          guests.where((guest) => guest.groupId == _selectedGroupId).toList();
    }

    // Filter by RSVP status if selected
    if (_selectedRsvpStatus != null) {
      guests =
          guests
              .where((guest) => guest.rsvpStatus == _selectedRsvpStatus)
              .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      guests =
          guests
              .where(
                (guest) =>
                    guest.firstName.toLowerCase().contains(query) ||
                    guest.lastName.toLowerCase().contains(query) ||
                    guest.email?.toLowerCase().contains(query) == true ||
                    guest.phone?.toLowerCase().contains(query) == true,
              )
              .toList();
    }

    // Sort by name
    guests.sort((a, b) => a.lastName.compareTo(b.lastName));

    return guests;
  }

  Widget _buildFilterBar(GuestListProvider guestListProvider) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final backgroundColor = isDarkMode ? Colors.grey[800] : Colors.grey[200];

    return Container(
      padding: const EdgeInsets.all(16),
      color: backgroundColor,
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search guests...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDarkMode ? Colors.grey[700] : Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          // Group filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildGroupChip(
                  context,
                  null,
                  'All Groups',
                  Icons.people,
                  primaryColor,
                ),
                ...guestListProvider.groups.map((group) {
                  return _buildGroupChip(
                    context,
                    group.id,
                    group.name,
                    Icons.group,
                    primaryColor,
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // RSVP status filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRsvpStatusChip(
                  context,
                  null,
                  'All Statuses',
                  Icons.filter_list,
                  primaryColor,
                ),
                _buildRsvpStatusChip(
                  context,
                  RsvpStatus.confirmed,
                  'Confirmed',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildRsvpStatusChip(
                  context,
                  RsvpStatus.pending,
                  'Pending',
                  Icons.pending,
                  Colors.orange,
                ),
                _buildRsvpStatusChip(
                  context,
                  RsvpStatus.declined,
                  'Declined',
                  Icons.cancel,
                  Colors.red,
                ),
                _buildRsvpStatusChip(
                  context,
                  RsvpStatus.tentative,
                  'Tentative',
                  Icons.help,
                  Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupChip(
    BuildContext context,
    String? groupId,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedGroupId == groupId;
    final isDarkMode = UIUtils.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        avatar: Icon(
          icon,
          size: 18,
          color:
              isSelected
                  ? Colors.white
                  : isDarkMode
                  ? Colors.white
                  : color,
        ),
        backgroundColor: isDarkMode ? Colors.grey[700] : Colors.white,
        selectedColor: color,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color:
              isSelected
                  ? Colors.white
                  : isDarkMode
                  ? Colors.white
                  : Colors.black,
        ),
        onSelected: (selected) {
          setState(() {
            _selectedGroupId = selected ? groupId : null;
          });
        },
      ),
    );
  }

  Widget _buildRsvpStatusChip(
    BuildContext context,
    RsvpStatus? status,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedRsvpStatus == status;
    final isDarkMode = UIUtils.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        avatar: Icon(
          icon,
          size: 18,
          color:
              isSelected
                  ? Colors.white
                  : isDarkMode
                  ? Colors.white
                  : color,
        ),
        backgroundColor: isDarkMode ? Colors.grey[700] : Colors.white,
        selectedColor: color,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color:
              isSelected
                  ? Colors.white
                  : isDarkMode
                  ? Colors.white
                  : Colors.black,
        ),
        onSelected: (selected) {
          setState(() {
            _selectedRsvpStatus = selected ? status : null;
          });
        },
      ),
    );
  }

  Widget _buildGuestCard(
    BuildContext context,
    Guest guest,
    GuestListProvider guestListProvider,
  ) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final textColor = isDarkMode ? Colors.white : Colors.black;

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
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Confirmed';
        break;
      case RsvpStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'Pending';
        break;
      case RsvpStatus.declined:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Declined';
        break;
      case RsvpStatus.tentative:
        statusColor = Colors.blue;
        statusIcon = Icons.help;
        statusText = 'Tentative';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => GuestDetailsScreen(
                    eventId: widget.eventId,
                    guestListProvider: guestListProvider,
                    guest: guest,
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    backgroundColor: statusColor.withAlpha(
                      51,
                    ), // 0.2 * 255 = 51
                    radius: 24,
                    child: Text(
                      '${guest.firstName[0]}${guest.lastName[0]}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Guest info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guest.fullName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (guest.email != null) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.email,
                                size: 14,
                                color:
                                    isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                guest.email!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                        ],
                        if (guest.phone != null) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 14,
                                color:
                                    isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                guest.phone!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // RSVP status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(51), // 0.2 * 255 = 51
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              // Additional info
              Row(
                children: [
                  Icon(
                    Icons.group,
                    size: 16,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    groupName,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (guest.plusOne) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person_add,
                      size: 16,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Plus ${guest.plusOneCount ?? 1}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
