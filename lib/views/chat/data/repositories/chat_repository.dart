// lib/views/chat/data/repositories/chat_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter_alinfo9/core/network/dio_client.dart';
import 'package:flutter_alinfo9/core/utils/endpoints.dart';
import 'package:flutter_alinfo9/views/chat/data/models/chat_messege.dart';

class ChatRepository {
  final Dio _dioClient = DioClient.instance.dio;

  // ==================== SEND MESSAGE ====================

  /// Send a chat message
  /// POST /api/chat/messages
  Future<ChatMessage> sendMessage({
    required int recipientId,
    required String message,
  }) async {
    try {
      final requestData = {
        'recipientId': recipientId,
        'message': message,
      };

      final response = await _dioClient.post(
        ApiEndpoints.chatMessages,
        data: requestData,
      );

      return ChatMessage.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Failed to send message: ${e.response?.statusCode}');
      throw _handleError(e);
    }
  }

  // ==================== GET CHAT HISTORY ====================

  /// Get chat history with a specific user
  /// GET /api/chat/history/{userId}
  Future<List<ChatMessage>> getChatHistory({
    required int userId,
    int page = 0,
    int size = 50,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.chatHistory(userId),
        queryParameters: {
          'page': page,
          'size': size,
          'sort': ['timestamp,asc'], // Oldest first for chat
        },
      );

      final content = response.data['content'] as List;
      return content.map((json) => ChatMessage.fromJson(json)).toList();
    } on DioException catch (e) {
      print('❌ Failed to get chat history: ${e.response?.statusCode}');
      throw _handleError(e);
    }
  }

  // ==================== GET CONVERSATIONS ====================

  /// Get all conversations (list of users you've chatted with)
  /// GET /api/chat/conversations
  Future<List<ChatMessage>> getConversations({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.chatConversations,
        queryParameters: {
          'page': page,
          'size': size,
          'sort': ['timestamp,desc'], // Newest first for conversations
        },
      );

      final content = response.data['content'] as List;
      return content.map((json) => ChatMessage.fromJson(json)).toList();
    } on DioException catch (e) {
      print('❌ Failed to get conversations: ${e.response?.statusCode}');
      throw _handleError(e);
    }
  }

  // ==================== ERROR HANDLING ====================

  String _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      switch (statusCode) {
        case 400:
          if (data is Map && data.containsKey('message')) {
            return data['message'];
          }
          return 'Invalid request. Please check your input.';
        case 401:
          return 'Authentication required. Please login again.';
        case 403:
          return 'Access denied.';
        case 404:
          return 'User not found or no chat history available.';
        case 500:
          String message = 'Server error. ';
          if (data is Map && data.containsKey('message')) {
            message += data['message'];
          } else {
            message += 'Could not send message. Please try again.';
          }
          return message;
        default:
          return 'Something went wrong (HTTP $statusCode). Please try again.';
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Make sure the backend is running.';
    }

    return 'An unexpected error occurred: ${error.message}';
  }
}
