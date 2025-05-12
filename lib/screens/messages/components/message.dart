import 'package:flutter/material.dart';
import 'package:chat/constants.dart';
import '../../../models/ChatMessage.dart';

class Message extends StatelessWidget {
  const Message({
    Key? key,
    required this.message,
    required this.showSender,
    required this.isOldestInSequence,
    required this.isNewestInSequence,
  }) : super(key: key);

  final ChatMessage message;
  final bool showSender;
  final bool isOldestInSequence;
  final bool isNewestInSequence;

  String _formatRelativeTime(DateTime messageTime) {
    final now = DateTime.now();
    final difference = now.difference(messageTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment:
        message.isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar cho người gửi không phải người dùng hiện tại
          if (!message.isSender && isNewestInSequence && showSender) ...[
            Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 18,
                backgroundImage: const AssetImage("assets/images/user.png"),
              ),
            ),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isSender
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Tên người gửi (dạng badge, chỉ hiển thị cho tin nhắn cũ nhất)
                if (!message.isSender &&
                    message.sender != null &&
                    isOldestInSequence && showSender)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2, left: 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message.sender!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                // Ô nội dung tin nhắn
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding * 0.75,
                    vertical: defaultPadding / 2,
                  ),
                  decoration: BoxDecoration(
                    color: (message.isSender
                        ? Colors.blue
                        : Colors.greenAccent)
                        .withOpacity(1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: message.messageType == ChatMessageType.text
                      ? Text(
                    message.text,
                    style: TextStyle(
                      color: message.isSender
                          ? Colors.white
                          : Colors.black,
                    ),
                  )
                      : Image.network(
                    message.imageUrl!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                // Thời gian (chỉ hiển thị cho tin nhắn mới nhất trong chat không phải nhóm)
                if (!showSender && isNewestInSequence)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _formatRelativeTime(message.time),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}