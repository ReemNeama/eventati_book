import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.mediumPadding,
        vertical: AppConstants.smallPadding / 2,
      ),
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
                  horizontal: AppConstants.mediumPadding,
                  vertical: AppConstants.smallPadding + 2,
                ),
                decoration: BoxDecoration(
                  color:
                      message.isFromUser ? userBubbleColor : vendorBubbleColor,
                  borderRadius: BorderRadius.circular(
                    AppConstants.largeBorderRadius,
                  ).copyWith(
                    bottomRight:
                        message.isFromUser
                            ? Radius.zero
                            : const Radius.circular(
                              AppConstants.largeBorderRadius,
                            ),
                    bottomLeft:
                        message.isFromUser
                            ? const Radius.circular(
                              AppConstants.largeBorderRadius,
                            )
                            : Radius.zero,
                  ),
                ),
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: message.isFromUser ? userTextColor : vendorTextColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: AppConstants.smallPadding / 2,
              left: AppConstants.smallPadding,
              right: AppConstants.smallPadding,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
                  message.isFromUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
              children: [
                Text(
                  timeString,
                  style: TextStyle(color: timestampColor, fontSize: 12),
                ),
                if (message.isFromUser) ...[
                  const SizedBox(width: AppConstants.smallPadding / 2),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead ? AppColors.info : timestampColor,
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
