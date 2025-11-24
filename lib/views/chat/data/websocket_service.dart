import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  late WebSocketChannel channel;

  void connect(String url) {
    channel = WebSocketChannel.connect(Uri.parse(url));
  }

  Stream get stream => channel.stream;

  void joinRoom(String userId, String role, String roomId) {
    channel.sink.add(
      jsonEncode({
        "type": "join",
        "userId": userId,
        "role": role,
        "roomId": roomId,
      }),
    );
  }

  void sendMessage(String text) {
    channel.sink.add(jsonEncode({"type": "send_message", "text": text}));
  }

  void setTyping(bool isTyping) {
    channel.sink.add(jsonEncode({"type": "typing", "isTyping": isTyping}));
  }

  void markSeen(int messageId) {
    channel.sink.add(jsonEncode({"type": "seen", "messageId": messageId}));
  }

  void disconnect() {
    channel.sink.close(status.goingAway);
  }
}

// class WebSocketService {
//   final String url;
//   WebSocketChannel? _channel;

//   WebSocketService(this.url);

//   void connect() {
//     _channel = WebSocketChannel.connect(Uri.parse(url));
//   }

//   Stream get stream => _channel!.stream;

//   void send(String data) {
//     _channel?.sink.add(data);
//   }

//   void disconnect() {
//     _channel?.sink.close();
//   }
// }
