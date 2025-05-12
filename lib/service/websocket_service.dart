import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

StompClient? stompClient;

final StreamController<Map<String, dynamic>> _messageController =
StreamController<Map<String, dynamic>>.broadcast();

// Lấy Stream để các widget lắng nghe
Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

void connectWebSocket(String username, String accessToken) {
  // Disconnect if already connected
  disconnectWebSocket();

  stompClient = StompClient(
    config: StompConfig(
      url: 'wss://mutt-discrete-gently.ngrok-free.app/ws/websocket',
      onConnect: (StompFrame frame) {
        stompClient?.subscribe(
          destination: '/user/$username/private',
          callback: (frame) {
            try {
              if (frame.body != null) {
                final message = jsonDecode(frame.body!);
                _messageController.add(message);
              } else {
                print('⚠️ Received empty message frame');
              }
            } catch (e) {
              print('❌ Error processing message: $e');
            }
          },
        );
      },
      beforeConnect: () async {
        print('🔌 Attempting to connect WebSocket...');
        await Future.delayed(const Duration(milliseconds: 200));
      },
      stompConnectHeaders: {
        'Authorization': 'Bearer $accessToken',
        'ngrok-skip-browser-warning': 'true',
      },
      webSocketConnectHeaders: {
        'Authorization': 'Bearer $accessToken',
        'ngrok-skip-browser-warning': 'true',
      },
      onWebSocketError: (dynamic error) {
        print('‼️ WebSocket connection error: $error');
      },
      onStompError: (dynamic error) {
        print('‼️ STOMP protocol error: $error');
      },
      onDisconnect: (frame) {
        print('♻️ WebSocket disconnected');
        print('Disconnection details: ${frame.body}');
      },
      connectionTimeout: const Duration(seconds: 5),
      reconnectDelay: const Duration(seconds: 5),
    ),
  );

  print('🚀 Activating WebSocket connection...');
  stompClient?.activate();
}

void disconnectWebSocket() {
  if (stompClient != null && stompClient!.connected) {
    stompClient?.deactivate();
  }
  stompClient = null;
}

void sendPrivateMessage({
  required String sender,
  required String recipient,
  required String content,
  String? imageUrl,
  required String accessToken,
  required bool isGroup
}) {
  try {
    if (stompClient == null || !stompClient!.connected) {
      print('⚠️ WebSocket not connected - Attempting to reconnect...');
      throw Exception('WebSocket not connected');
    }

    final message = {
      "sender": sender,
      "recipient": recipient,
      "content": content,
      "timestamp": DateTime.now().toIso8601String(),
      "imageUrl": imageUrl,
      "isRead": false,
      "isGroup": isGroup,
    };

    stompClient?.send(
      destination: '/app/private-message',
      body: jsonEncode(message),
      headers: {
        'content-type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('✅ Private message sent to $recipient: $content');
  } catch (e) {
    print('❌ Error sending private message: $e');
    throw Exception('Failed to send private message: $e');
  }
}

void sendGroupMessage({
  required String sender,
  required String groupName,
  required String content,
  String? imageUrl,
  required String accessToken,
}) {
  try {
    if (stompClient == null || !stompClient!.connected) {
      print('⚠️ WebSocket not connected - Attempting to reconnect...');
      throw Exception('WebSocket not connected');
    }

    final message = {
      "sender": sender,
      "recipient": groupName, // Gửi đến tên nhóm
      "content": content,
      "timestamp": DateTime.now().toIso8601String(),
      "imageUrl": imageUrl,
      "isRead": false,
      "isGroup": true, // Đánh dấu là tin nhắn nhóm
      "groupName": groupName,
    };

    stompClient?.send(
      destination: '/app/private-message', // Sử dụng cùng endpoint
      body: jsonEncode(message),
      headers: {
        'content-type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('✅ Group message sent to $groupName: $content');
  } catch (e) {
    print('❌ Error sendin group message: $e');
    throw Exception('Failed to send group message: $e');
  }
}

void dispose() {
  _messageController.close();
}