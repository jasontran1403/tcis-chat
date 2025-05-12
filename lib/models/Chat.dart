// models/Chat.dart
class Chat {
  final String name;
  final String lastMessage;
  final String image;
  final String time;
  final String? imageUrl;
  final bool isActive;
  final bool isRead;
  final bool isGroup;
  final String? lastSender;
  final DateTime timestamp;

  Chat({
    required this.name,
    required this.lastMessage,
    required this.image,
    required this.time,
    this.imageUrl,
    required this.isActive,
    required this.isRead,
    this.isGroup = false,
    this.lastSender,
    required this.timestamp,

  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      name: json['name'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      image: json['image'] ?? 'assets/images/user.png',
      time: json['time'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isActive: json['isActive'] ?? false,
      isRead: json['isRead'] ?? false,
      isGroup: json['isGroup'] ?? false,
      lastSender: json['lastSender'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}