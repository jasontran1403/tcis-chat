enum ChatMessageType { text, audio, image, video }
enum MessageStatus { not_sent, not_view, viewed }

class ChatMessage {
  final String text;
  final ChatMessageType messageType;
  final MessageStatus messageStatus;
  final String? imageUrl;
  final bool isSender;
  final DateTime time;
  final String? sender;
  final bool? isGroupMessage;

  ChatMessage({
    required this.text,
    required this.messageType,
    required this.messageStatus,
    required this.isSender,
    this.imageUrl,
    required this.time,
    this.sender,
    this.isGroupMessage,
  });

  String get formattedTime => '${time.hour}:${time.minute}';

  factory ChatMessage.fromJson(Map<String, dynamic> json, String currentUsername) {
    return ChatMessage(
      text: json['content'] ?? '',
      messageType: json['imageUrl'] != null ? ChatMessageType.image : ChatMessageType.text,
      messageStatus: json['read'] == true ? MessageStatus.viewed : MessageStatus.not_view,
      isSender: json['sender'] == currentUsername,
      imageUrl: json['imageUrl'],
      time: DateTime.parse(json['timestamp'] ?? DateTime.now().toString()),
      sender: json['sender'], // Lưu thông tin sender
    );
  }
}
