import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:intl/intl.dart';

class VendorCard extends StatelessWidget {
  final Vendor vendor;
  final Conversation conversation;
  final VoidCallback onTap;

  const VendorCard({
    super.key,
    required this.vendor,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = Theme.of(context).primaryColor;
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.white70 : Colors.black54;

    // Format the last message time
    final formatter = DateFormat('MMM d, h:mm a');
    final timeString =
        conversation.messages.isNotEmpty
            ? formatter.format(conversation.lastMessageTime)
            : 'No messages';

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2.0,
      color: cardColor,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: CircleAvatar(
          backgroundColor: primaryColor,
          child: Text(
            vendor.name.substring(0, 1),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          vendor.name,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4.0),
            Text(vendor.serviceType, style: TextStyle(color: subtitleColor)),
            if (vendor.contactPerson != null) ...[
              const SizedBox(height: 2.0),
              Text(
                'Contact: ${vendor.contactPerson}',
                style: TextStyle(color: subtitleColor),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              timeString,
              style: TextStyle(color: subtitleColor, fontSize: 12.0),
            ),
            const SizedBox(height: 4.0),
            if (conversation.hasUnreadMessages)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 2.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Text(
                  'New',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
