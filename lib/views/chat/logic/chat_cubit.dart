import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/views/chat/data/models/chat_messege.dart';
import 'package:flutter_alinfo9/views/chat/data/repositories/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;

  ChatCubit(this._repository) : super(ChatInitial());

  // ==================== LOAD CHAT HISTORY ====================

  /// Load chat history with a specific user
  Future<void> loadChatHistory(int userId, {int page = 0}) async {
    try {
      emit(ChatLoading());

      final messages = await _repository.getChatHistory(
        userId: userId,
        page: page,
        size: 50,
      );

      // Sort messages by timestamp (oldest first for chat)
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      emit(ChatHistoryLoaded(
        messages: messages,
        userId: userId,
        hasMore: messages.length >= 50, // If we got a full page, there might be more
      ));
    } catch (e) {
      print('❌ Error loading chat history: $e');
      emit(ChatError(e.toString()));
    }
  }

  // ==================== SEND MESSAGE ====================

  /// Send a message to a user
  Future<void> sendMessage(int recipientId, String message) async {
    try {
      // Get current messages if we're in a loaded state
      List<ChatMessage> currentMessages = [];
      if (state is ChatHistoryLoaded) {
        currentMessages = (state as ChatHistoryLoaded).messages;
      }

      emit(ChatSendingMessage());

      final sentMessage = await _repository.sendMessage(
        recipientId: recipientId,
        message: message,
      );

      // Add the new message to the list
      final updatedMessages = [...currentMessages, sentMessage];

      // Emit success state with updated messages
      emit(ChatHistoryLoaded(
        messages: updatedMessages,
        userId: recipientId,
      ));

      // Briefly show message sent confirmation
      emit(ChatMessageSent(sentMessage));

      // Return to loaded state with all messages
      emit(ChatHistoryLoaded(
        messages: updatedMessages,
        userId: recipientId,
      ));
    } catch (e) {
      print('❌ Error sending message: $e');

      // Preserve current messages on error
      List<ChatMessage> currentMessages = [];
      if (state is ChatHistoryLoaded) {
        currentMessages = (state as ChatHistoryLoaded).messages;
      }

      emit(ChatSendError(e.toString(), currentMessages));

      // After showing error, return to loaded state
      if (currentMessages.isNotEmpty) {
        emit(ChatHistoryLoaded(
          messages: currentMessages,
          userId: recipientId,
        ));
      }
    }
  }

  // ==================== LOAD MORE MESSAGES ====================

  /// Load more messages (pagination)
  Future<void> loadMoreMessages(int userId, int currentPage) async {
    try {
      if (state is! ChatHistoryLoaded) return;

      final currentState = state as ChatHistoryLoaded;
      final currentMessages = currentState.messages;

      final moreMessages = await _repository.getChatHistory(
        userId: userId,
        page: currentPage + 1,
        size: 50,
      );

      // Combine and sort all messages
      final allMessages = [...currentMessages, ...moreMessages];
      allMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      emit(ChatHistoryLoaded(
        messages: allMessages,
        userId: userId,
        hasMore: moreMessages.length >= 50,
      ));
    } catch (e) {
      print('❌ Error loading more messages: $e');
      // Keep current state on error
    }
  }

  // ==================== REFRESH CHAT ====================

  /// Refresh chat history (pull-to-refresh)
  Future<void> refreshChat(int userId) async {
    await loadChatHistory(userId, page: 0);
  }

  // ==================== CLEAR CHAT ====================

  /// Clear chat state and return to initial
  void clearChat() {
    emit(ChatInitial());
  }
}
