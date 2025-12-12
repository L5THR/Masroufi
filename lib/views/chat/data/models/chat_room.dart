import 'package:flutter_alinfo9/views/chat/data/models/chat_messege.dart';

class ChatRoom {
  final String roomId;
  final List<ChatMessage> messages;

  ChatRoom({required this.roomId, required this.messages});
}
