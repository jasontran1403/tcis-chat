import 'dart:async';
import 'dart:convert';
import 'package:chat/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/ChatMessage.dart';
import '../../service/apiService.dart';
import '../../service/websocket_service.dart';
import 'components/chat_input_field.dart';
import 'components/message.dart';

class MessagesScreen extends StatefulWidget {
  final String username;
  final String usernameReceive;
  final String accessToken;
  final bool isGroup;

  const MessagesScreen({
    super.key,
    required this.username,
    required this.usernameReceive,
    required this.accessToken,
    this.isGroup = false,
  });

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<ChatMessage> messages = [];
  bool _isConnected = false;
  StreamSubscription<Map<String, dynamic>>? _messageSubscription;
  final TextEditingController _addMemberController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _checkWebSocketConnection();
    _setupMessageListener();
    _loadInitialMessages();
  }

  void _checkWebSocketConnection() {
    setState(() {
      _isConnected = stompClient?.connected ?? false;
    });
  }

  Future<void> _handleAddMember(String username) async {
    dynamic result = await ApiService.addMember(widget.username, widget.usernameReceive, username, widget.accessToken);

    Get.snackbar(
      result,
      "Notification",
      backgroundColor: Colors.indigoAccent,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
    );

    if (result.contains("successful.")) {
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
      _checkWebSocketConnection();
      _setupMessageListener();
      _loadInitialMessages();
      _addMemberController.clear();
    }
  }

  void _setupMessageListener() {
    _messageSubscription = messageStream.listen((message) {
      try {
        final sender = message['sender'];
        bool isGroupMessage = false;
        final recipient = message['recipient'] ?? '';

        if (recipient.startsWith("Group")) {  // Thay contains bằng startsWith
          isGroupMessage = true;
        }
        final groupName = message['groupName'] ?? message['recipient'];

        bool isCurrentConversation;
        if (widget.isGroup) {
          isCurrentConversation = isGroupMessage && groupName == widget.usernameReceive;
        } else {
          isCurrentConversation = (sender == widget.usernameReceive ||
              message['recipient'] == widget.usernameReceive);
        }

        if (isCurrentConversation) {
          final newMessage = ChatMessage(
            text: message['content'],
            messageType: message['imageUrl'] != null
                ? ChatMessageType.image
                : ChatMessageType.text,
            messageStatus: MessageStatus.not_view,
            isSender: sender == widget.username,
            imageUrl: message['imageUrl'] ?? "",
            time: DateTime.parse(message['timestamp']),
            sender: sender,
            isGroupMessage: isGroupMessage,
          );

          final isDuplicate = messages.any((msg) =>
          msg.text == newMessage.text &&
              msg.time == newMessage.time &&
              msg.sender == newMessage.sender);

          if (!isDuplicate && mounted) {
            setState(() {
              messages.insert(0, newMessage);
            });
          }
        }
      } catch (e) {
        print('Error processing message: $e');
      }
    }, onError: (error) {
      print('Error in message stream: $error');
    });
  }

  Future<void> _loadInitialMessages() async {
    try {
      final response = await ApiService.fetchMessages(
        widget.username,
        widget.usernameReceive,
        widget.accessToken,
      );

      if (response is List) {
        List<ChatMessage> loadedMessages = response
            .map((json) => ChatMessage.fromJson(json, widget.username))
            .toList();

        if (mounted) {
          setState(() {
            messages = loadedMessages;
          });
        }
      } else {
        print("Unexpected response format: $response");
      }
    } catch (e) {
      print('Error loading initial messages: $e');
    }
  }

  void _handleMessageSent(ChatMessage newMessage) {
    if (mounted) {
      setState(() {
        messages.insert(0, newMessage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
            CircleAvatar(
              backgroundImage: AssetImage(
                widget.isGroup ? "assets/images/group.png" : "assets/images/user_2.png",
              ),
            ),
            const SizedBox(width: defaultPadding * 0.75),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.usernameReceive,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  widget.isGroup
                      ? "Group Chat"
                      : (_isConnected ? "Online" : "Connecting..."),
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isGroup
                        ? Colors.blue
                        : (_isConnected ? Colors.green : Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (widget.isGroup) // Chỉ hiển thị nút thêm thành viên trong nhóm
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => _showAddMemberDialog(),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final currentMessage = messages[index];
                  bool isOldestInSequence = false;
                  bool isNewestInSequence = false;

                  // Kiểm tra chuỗi tin nhắn
                  isOldestInSequence = index == messages.length - 1 ||
                      messages[index + 1].sender != currentMessage.sender;
                  isNewestInSequence = index == 0 ||
                      messages[index - 1].sender != currentMessage.sender;

                  return Message(
                    message: currentMessage,
                    showSender: widget.isGroup,
                    isOldestInSequence: isOldestInSequence,
                    isNewestInSequence: isNewestInSequence,
                  );
                },
              ),
            ),
          ),
          ChatInputField(
            sender: widget.username,
            recipient: widget.usernameReceive,
            accessToken: widget.accessToken,
            isGroup: widget.isGroup,
            onMessageSent: _handleMessageSent,
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _addMemberController,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'Enter username to add',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _isSearching = false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_addMemberController.text.trim().isEmpty) {
                Get.snackbar(
                  "Please enter a username",
                  "Error",
                  backgroundColor: Colors.redAccent,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                  snackPosition: SnackPosition.TOP,
                );
                return;
              }
              await _handleAddMember(_addMemberController.text.trim());
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ).then((_) {
      setState(() => _isSearching = false);
      _addMemberController.clear();
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _addMemberController.dispose();
    super.dispose();
  }
}