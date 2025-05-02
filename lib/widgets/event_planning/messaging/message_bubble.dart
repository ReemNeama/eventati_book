import 'package:flutter/material.dart';
import 'package:eventati_book/models/vendor_message.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final double maxWidth;

  const MessageBubble({
    super.key,
    required this.message,
    this.maxWidth = 0.75, // 75% of available width
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    // Colors for user messages
    final userBubbleColor = primaryColor;
    const userTextColor = Colors.white;

    // Colors for vendor messages
    final vendorBubbleColor = isDarkMode ? Colors.grey[800] : Colors.grey[200];
    final vendorTextColor = isDarkMode ? Colors.white : Colors.black87;

    // Timestamp color
    final timestampColor = isDarkMode ? Colors.white70 : Colors.black54;

    // Format timestamp
    final formatter = DateFormat('MMM d, h:mm a');
    final timeString = formatter.format(message.timestamp);

    // Calculate max width based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final bubbleMaxWidth = screenWidth * maxWidth;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment:
            message.isFromUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                message.isFromUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color:
                      message.isFromUser ? userBubbleColor : vendorBubbleColor,
                  borderRadius: BorderRadius.circular(16.0).copyWith(
                    bottomRight:
                        message.isFromUser
                            ? Radius.zero
                            : const Radius.circular(16.0),
                    bottomLeft:
                        message.isFromUser
                            ? const Radius.circular(16.0)
                            : Radius.zero,
                  ),
                ),
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: message.isFromUser ? userTextColor : vendorTextColor,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
                  message.isFromUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
              children: [
                Text(
                  timeString,
                  style: TextStyle(color: timestampColor, fontSize: 12.0),
                ),
                if (message.isFromUser) ...[
                  const SizedBox(width: 4.0),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14.0,
                    color: message.isRead ? Colors.blue : timestampColor,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
