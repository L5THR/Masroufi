import 'package:equatable/equatable.dart';
import 'package:flutter_alinfo9/views/chat/data/models/chat_messege.dart';

// ==================== BASE CHAT STATE ====================

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== INITIAL STATE ====================

class ChatInitial extends ChatState {}

// ==================== LOADING STATES ====================

class ChatLoading extends ChatState {}

class ChatSendingMessage extends ChatState {}

// ==================== SUCCESS STATES ====================

class ChatHistoryLoaded extends ChatState {
  final List<ChatMessage> messages;
  final int userId; // User we're chatting with
  final bool hasMore; // For pagination

  ChatHistoryLoaded({
    required this.messages,
    required this.userId,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [messages, userId, hasMore];

  ChatHistoryLoaded copyWith({
    List<ChatMessage>? messages,
    int? userId,
    bool? hasMore,
  }) {
    return ChatHistoryLoaded(
      messages: messages ?? this.messages,
      userId: userId ?? this.userId,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ChatMessageSent extends ChatState {
  final ChatMessage message;

  ChatMessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== ERROR STATES ====================

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatSendError extends ChatState {
  final String message;
  final List<ChatMessage> currentMessages; // Preserve messages on error

  ChatSendError(this.message, this.currentMessages);

  @override
  List<Object?> get props => [message, currentMessages];
}
