import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chat/constants.dart';
import 'package:chat/service/websocket_service.dart';
import '../../../models/ChatMessage.dart';
import 'message_attachment.dart';

class ChatInputField extends StatefulWidget {
  final String sender;
  final String recipient;
  final String accessToken;
  final bool isGroup; // Thêm tham số isGroup
  final Function(ChatMessage) onMessageSent;

  const ChatInputField({
    Key? key,
    required this.sender,
    required this.recipient,
    required this.accessToken,
    required this.onMessageSent,
    this.isGroup = false, // Mặc định là false
  }) : super(key: key);

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool _showAttachment = false;
  final TextEditingController _messageController = TextEditingController();

  void _updateAttachmentState() {
    setState(() {
      _showAttachment = !_showAttachment;
    });
  }

  void _sendMessage() {
    final messageContent = _messageController.text.trim();
    if (messageContent.isEmpty) return;

    final newMessage = ChatMessage(
      text: messageContent,
      messageType: ChatMessageType.text,
      messageStatus: MessageStatus.not_view,
      isSender: true,
      imageUrl: "",
      time: DateTime.now(),
      sender: widget.sender, // Lưu thông tin sender
    );

    // Gửi tin nhắn qua WebSocket
    if (widget.isGroup) {
      sendGroupMessage(
        sender: widget.sender,
        groupName: widget.recipient,
        content: messageContent,
        accessToken: widget.accessToken,
      );
    } else {
      sendPrivateMessage(
        sender: widget.sender,
        recipient: widget.recipient,
        content: messageContent,
        accessToken: widget.accessToken,
        isGroup: widget.isGroup
      );
    }

    widget.onMessageSent(newMessage);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -4),
            blurRadius: 32,
            color: const Color(0xFF087949).withOpacity(0.08),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const SizedBox(width: defaultPadding / 4),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: "Type message",
                            suffixIcon: SizedBox(
                              width: 65,
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: _updateAttachmentState,
                                    child: Icon(
                                      Icons.attach_file,
                                      color: _showAttachment
                                          ? primaryColor
                                          : Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color!
                                          .withOpacity(0.64),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: defaultPadding / 2),
                                    child: InkWell(
                                      onTap: _sendMessage,
                                      child: Icon(
                                        Icons.send_rounded,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color!
                                            .withOpacity(0.80),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_showAttachment)
              MessageAttachment(
                onImageSelected: (File image) {
                  // Xử lý ảnh đã chọn
                  print("Image selected: ${image.path}");
                  // Gửi ảnh hoặc hiển thị preview
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}