import 'dart:convert';
import 'package:flutter_alinfo9/views/chat/data/models/chat_messege.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/websocket_service.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final WebSocketService service;

  ChatCubit(this.service) : super(ChatState(messages: [], isTyping: false));

  void init(String userId, String role, String roomId) {
    // service.connect("ws://10.0.2.2:8000"); // andriod emulator
    service.connect("ws://localhost:8000"); // chrome emulator

    service.joinRoom(userId, role, roomId);

    service.stream.listen((event) {
      final data = jsonDecode(event);

      switch (data["type"]) {
        case "joined":
          final list = (data["messages"] as List)
              .map((m) => ChatMessage.fromJson(m))
              .toList();
          emit(state.copyWith(messages: list));
          break;

        case "new_message":
          final msg = ChatMessage.fromJson(data["message"]);
          emit(state.copyWith(messages: [...state.messages, msg]));
          break;

        case "typing":
          emit(state.copyWith(isTyping: data["isTyping"]));
          break;

        case "delivered":
        case "seen":
          _updateMessageStatus(data);
          break;
      }
    });
  }

  void _updateMessageStatus(data) {
    final updated = state.messages.map((m) {
      if (m.id == data["messageId"]) {
        return ChatMessage(
          id: m.id,
          roomId: m.roomId,
          senderId: m.senderId,
          senderRole: m.senderRole,
          text: m.text,
          timestamp: m.timestamp,
          delivered: data["type"] == "delivered" ? true : m.delivered,
          seen: data["type"] == "seen" ? true : m.seen,
        );
      }
      return m;
    }).toList();

    emit(state.copyWith(messages: updated));
  }

  void sendMessage(String text) => service.sendMessage(text);

  void setTyping(bool typing) => service.setTyping(typing);
}
