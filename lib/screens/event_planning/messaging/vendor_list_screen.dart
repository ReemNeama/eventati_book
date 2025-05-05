import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/screens/event_planning/messaging/conversation_screen.dart';
import 'package:eventati_book/widgets/event_planning/messaging/vendor_card.dart';

class VendorListScreen extends StatefulWidget {
  final String eventId;
  final String eventName;

  const VendorListScreen({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final searchBarColor =
        isDarkMode
            ? AppColorsDark.searchBarBackground
            : AppColors.filterBarBackground;

    return ChangeNotifierProvider(
      create: (_) => MessagingProvider(eventId: widget.eventId),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Vendors for ${widget.eventName}'),
          backgroundColor: primaryColor,
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search vendors...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: searchBarColor,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),

            // Vendor list
            Expanded(
              child: Consumer<MessagingProvider>(
                builder: (context, messagingProvider, _) {
                  if (messagingProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (messagingProvider.error != null) {
                    return Center(
                      child: Text('Error: ${messagingProvider.error}'),
                    );
                  }

                  final vendors = messagingProvider.vendors;

                  if (vendors.isEmpty) {
                    return const Center(
                      child: Text('No vendors found for this event'),
                    );
                  }

                  // Filter vendors based on search query
                  final filteredVendors =
                      vendors.where((vendor) {
                        final nameMatch = vendor.name.toLowerCase().contains(
                          _searchQuery,
                        );
                        final serviceMatch = vendor.serviceType
                            .toLowerCase()
                            .contains(_searchQuery);
                        final contactMatch =
                            vendor.contactPerson?.toLowerCase().contains(
                              _searchQuery,
                            ) ??
                            false;

                        return nameMatch || serviceMatch || contactMatch;
                      }).toList();

                  if (filteredVendors.isEmpty) {
                    return Center(
                      child: Text('No vendors match "$_searchQuery"'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredVendors.length,
                    itemBuilder: (context, index) {
                      final vendor = filteredVendors[index];
                      final conversation = messagingProvider.conversations
                          .firstWhere(
                            (c) => c.vendorId == vendor.id,
                            orElse:
                                () => Conversation(
                                  vendorId: vendor.id,
                                  messages: const [],
                                  lastMessageTime: DateTime.now(),
                                  hasUnreadMessages: false,
                                ),
                          );

                      return VendorCard(
                        vendor: vendor,
                        conversation: conversation,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ConversationScreen(
                                    eventId: widget.eventId,
                                    eventName: widget.eventName,
                                    vendorId: vendor.id,
                                    vendorName: vendor.name,
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
