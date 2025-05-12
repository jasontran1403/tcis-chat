import 'dart:async';
import 'package:chat/constants.dart';
import 'package:chat/screens/messages/message_screen.dart';
import 'package:chat/service/apiService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/Chat.dart';
import '../../service/websocket_service.dart';
import '../splash/splash_screen.dart';
import 'components/chat_card.dart';

class ChatsScreen extends StatefulWidget {
  final String? accessToken;
  final String? username;

  const ChatsScreen({this.accessToken, this.username, super.key});

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  dynamic accountInfo;
  List<Chat> _chats = [];
  bool _isLoading = true;
  String? _error;
  bool _isEditingBio = false;
  late TextEditingController _bioController;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newGroupController = TextEditingController();
  StreamSubscription<Map<String, dynamic>>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController();
    _loadChats();
    _listenToMessages();
  }

  Future<void> _handleSearch() async {
    final usernameSearch = _searchController.text.trim();
    if (usernameSearch.isEmpty) {
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

    if (usernameSearch == widget.username) {
      Get.snackbar(
        "You can't find yourself",
        "Error",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      final userExists = await ApiService.checkUserExists(
        usernameSearch,
        widget.accessToken!,
      );

      if (userExists && mounted) {
        Navigator.pop(context);
        Get.to(MessagesScreen(
          username: widget.username!,
          usernameReceive: usernameSearch,
          accessToken: widget.accessToken!,
        ));
      } else {
        Get.snackbar(
          "User not found",
          "Error",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Server busy, please try again later",
        "Error",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _handleCreateNewGroup(String groupName) async {
    dynamic result = await ApiService.createGroup(groupName, widget.username!, widget.accessToken);

    Get.snackbar(
      result,
      "Notification",
      backgroundColor: Colors.indigoAccent,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
    );

    if (result.contains("successful")) {
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
      _loadChats();
      _listenToMessages();
      _newGroupController.clear();
    }
  }


  void _listenToMessages() {
    _messageSubscription = messageStream.listen((message) {
      bool isGroupMessage = false;
      final recipient = message['recipient'] ?? '';

      if (recipient.startsWith("Group")) {  // Thay contains bằng startsWith
        isGroupMessage = true;
      }

      final sender = message['sender'];
      final content = message['content'];
      final timestamp = DateTime.parse(message['timestamp']);
      final isRead = message['read'] ?? false;  // Sửa 'isRead' thành 'read'
      final groupName = message['recipient'];    // Sử dụng recipient làm groupName

      setState(() {
        if (isGroupMessage) {
          int index = _chats.indexWhere((chat) => chat.isGroup && chat.name == groupName);
          if (index != -1) {
            _chats[index] = Chat(
              name: groupName,
              lastMessage: content,
              image: "assets/images/group.png",
              time: _formatRelativeTime(timestamp),
              imageUrl: "",
              isActive: true,
              isRead: isRead,
              isGroup: true,
              lastSender: sender,
            );
            _chats.insert(0, _chats.removeAt(index));
          } else {
            _chats.insert(
              0,
              Chat(
                name: groupName,
                lastMessage: content,
                image: "assets/images/group.png",
                time: _formatRelativeTime(timestamp),
                imageUrl: "",
                isActive: true,
                isRead: isRead,
                isGroup: true,
                lastSender: sender,
              ),
            );
          }
        } else {
          // Xử lý tin nhắn cá nhân như cũ
          int index = _chats.indexWhere((chat) => !chat.isGroup && chat.name == sender);
          if (index != -1) {
            _chats[index] = Chat(
              name: sender,
              lastMessage: content,
              image: "assets/images/user.png",
              time: _formatRelativeTime(timestamp),
              imageUrl: "",
              isActive: true,
              isRead: isRead,
            );
            _chats.insert(0, _chats.removeAt(index));
          } else {
            _chats.insert(
              0,
              Chat(
                name: sender,
                lastMessage: content,
                image: "assets/images/user.png",
                time: _formatRelativeTime(timestamp),
                imageUrl: "",
                isActive: true,
                isRead: isRead,
              ),
            );
          }
        }
      });
    }, onError: (error) {
      print('Error in message stream: $error');
    });
  }

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

  Future<void> _loadChats() async {
    try {
      if (widget.username == null || widget.accessToken == null) {
        _clearAndNavigateToSplash();
        return;
      }

      // Lấy thông tin tài khoản và tin nhắn cá nhân
      final accountInfoResult = await ApiService.fetchAccountInfo(
        widget.username!,
        widget.accessToken!,
      );

      // Lấy danh sách nhóm user tham gia
      List userGroups = accountInfoResult?['userGroups'] ?? [];

      setState(() {
        accountInfo = accountInfoResult;
        _bioController.text = accountInfo?['bio'] ?? '';
        _isLoading = false;
        _error = null;

        // Xử lý tin nhắn cá nhân
        final latestMessages = accountInfoResult?['latestMessage'] as List<dynamic>?;
        List<Chat> personalChats = [];
        if (latestMessages != null) {
          personalChats = latestMessages.map((message) {
            final sender = message['sender'] as String;
            final receiver = message['receiver'] as String;
            // Determine the chat name (use the other user, not the current user)
            final chatName = sender == widget.username ? receiver : sender;
            return Chat(
              name: chatName,
              lastMessage: message['content'] ?? '',
              image: 'assets/images/user.png',
              time: _formatRelativeTime(DateTime.parse(message['timestamp'] ?? DateTime.now().toString())),
              imageUrl: message['imageUrl'] ?? '',
              isActive: true, // You can adjust this based on your logic
              isRead: message['read'] ?? false,
              isGroup: false,
              lastSender: sender,
            );
          }).toList();
        }

        // Xử lý tin nhắn nhóm
        List<Chat> groupChats = [];
        if (userGroups != null) {
          groupChats = userGroups.map<Chat>((group) {
            final messages = group['messages'] as List<dynamic>? ?? [];
            String lastMessage = 'Chưa có tin nhắn';
            String time = _formatRelativeTime(DateTime.now());
            String? lastSender;
            bool isRead = false;

            // Lấy tin nhắn mới nhất từ messages (nếu có)
            if (messages.isNotEmpty) {
              final latestGroupMessage = messages.last;
              lastMessage = latestGroupMessage['content'] ?? 'Chưa có tin nhắn';
              time = _formatRelativeTime(DateTime.parse(latestGroupMessage['timestamp'] ?? DateTime.now().toString()));
              lastSender = latestGroupMessage['sender'];
              isRead = latestGroupMessage['read'] ?? false;
            }

            return Chat(
              name: group['groupName'],
              lastMessage: lastMessage,
              image: "assets/images/group.png",
              time: time,
              imageUrl: "",
              isActive: true,
              isRead: isRead,
              isGroup: true,
              lastSender: lastSender,
            );
          }).toList();
        }

        // Kết hợp cả 2 danh sách và sắp xếp theo thời gian
        _chats = [...personalChats, ...groupChats];
        _chats.sort((a, b) => b.time.compareTo(a.time));
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        title: Text(
          accountInfo?['fullname'] ?? 'Chats',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_rounded, color: Colors.white),
            onPressed: () => _showAddGroupDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header với thông tin tài khoản (màu xanh)
          Container(
            padding: const EdgeInsets.fromLTRB(
                defaultPadding, defaultPadding, defaultPadding, defaultPadding/2),
            color: primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBioSection(),
                const SizedBox(height: 4),
                _buildStatusDropdown(),
                const SizedBox(height: defaultPadding),
              ],
            ),
          ),
          // Danh sách chat (màu trắng)
          Expanded(
            child: Container(
              color: Colors.white,
              child: RefreshIndicator(
                onRefresh: _loadChats,
                child: _error != null
                    ? Center(child: Text('Error: $_error'))
                    : ListView.builder(
                  padding: const EdgeInsets.only(top: defaultPadding),
                  itemCount: _chats.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding,
                      vertical: defaultPadding/2,
                    ),
                    child: ChatCard(
                      chat: _chats[index],
                      press: () => Get.to(
                        MessagesScreen(
                          username: widget.username!,
                          usernameReceive: _chats[index].name,
                          accessToken: widget.accessToken!,
                          isGroup: _chats[index].isGroup
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSearchDialog,
        backgroundColor: primaryColor,
        child: const Icon(Icons.person_add_alt_1, color: Colors.white),
      ),
    );
  }

  Widget _buildBioSection() {
    return GestureDetector(
      onDoubleTap: () => setState(() {
        _isEditingBio = true;
        _bioController.text = accountInfo?['bio'] ?? '';
      }),
      child: _isEditingBio
          ? Row(
        children: [
          Expanded(
            child: TextField(
              controller: _bioController,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              decoration: const InputDecoration(border: InputBorder.none),
              maxLines: 2,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: () => setState(() {
              _isEditingBio = false;
              accountInfo['bio'] = _bioController.text;
            }),
          ),
        ],
      )
          : Text(
        accountInfo?['bio'] ?? '',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Row(
      children: [
        DropdownButton<String>(
          value: accountInfo?['status'] ?? 'Online',
          dropdownColor: Colors.blueGrey,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          underline: Container(height: 1, color: Colors.white),
          style: const TextStyle(color: Colors.white),
          items: <String>['Online', 'Not Available', 'Busy']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              accountInfo['status'] = newValue;
            });
          },
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearAndNavigateToSplash();
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'Enter username to search',
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
              if (_searchController.text.trim().isEmpty) {
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
              await _handleSearch();
            },
            child: const Text('Search'),
          ),
        ],
      ),
    ).then((_) {
      setState(() => _isSearching = false);
      _searchController.clear();
    });
  }

  void _showAddGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newGroupController,
              decoration: const InputDecoration(
                labelText: 'Group name',
                hintText: 'Group name must start with prefix Group',
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
              if (_newGroupController.text.trim().isEmpty) {
                Get.snackbar(
                  "Please enter a valid Group name (Group name must start with prefix 'Group...'",
                  "Error",
                  backgroundColor: Colors.redAccent,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                  snackPosition: SnackPosition.TOP,
                );
                return;
              }
              await _handleCreateNewGroup(_newGroupController.text);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    ).then((_) {
      setState(() => _isSearching = false);
      _searchController.clear();
    });
  }

  Future<void> _clearAndNavigateToSplash() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('username');
    if (mounted) {
      try {
        disconnectWebSocket();
        await Future.delayed(Duration(milliseconds: 500));
      } catch (e) {
        print('Error disconnecting WebSocket: $e');
      }
      Get.offAll(const SplashScreen());
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _bioController.dispose();
    _searchController.dispose();
    _newGroupController.dispose();
    super.dispose();
  }
}