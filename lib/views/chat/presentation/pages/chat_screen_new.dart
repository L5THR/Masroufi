// lib/views/chat/presentation/pages/chat_screen_new.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import 'package:flutter_alinfo9/core/storage/hive_storage.dart';
import '../../logic/chat_cubit.dart';
import '../../logic/chat_state.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/models/chat_messege.dart';

/// Chat screen with job context support
class JobChatScreen extends StatefulWidget {
  final int recipientId;
  final String recipientName;
  final String? jobTitle; // Optional job context
  final int? jobId; // Optional job context

  const JobChatScreen({
    Key? key,
    required this.recipientId,
    required this.recipientName,
    this.jobTitle,
    this.jobId,
  }) : super(key: key);

  @override
  State<JobChatScreen> createState() => _JobChatScreenState();
}

class _JobChatScreenState extends State<JobChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load chat history when screen opens
    Future.microtask(() {
      context.read<ChatCubit>().loadChatHistory(widget.recipientId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        // Check again if the controller is still attached after the delay
        if (_scrollController.hasClients && mounted) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    context.read<ChatCubit>().sendMessage(widget.recipientId, message);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.recipientName,
                style: const TextStyle(fontSize: 16),
              ),
              if (widget.jobTitle != null)
                Text(
                  'Regarding: ${widget.jobTitle}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Messages List
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                listener: (context, state) {
                  if (state is ChatHistoryLoaded) {
                    _scrollToBottom();
                  } else if (state is ChatSendError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to send message: ${state.message}'),
                        backgroundColor: AppTheme.errorRed,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ChatError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppTheme.errorRed,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load messages',
                            style: TextStyle(
                              color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: TextStyle(
                              color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ChatCubit>().refreshChat(widget.recipientId);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ChatHistoryLoaded || state is ChatSendError) {
                    final messages = state is ChatHistoryLoaded
                        ? state.messages
                        : (state as ChatSendError).currentMessages;

                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start the conversation!',
                              style: TextStyle(
                                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => context.read<ChatCubit>().refreshChat(widget.recipientId),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return _MessageBubble(
                            message: message,
                            isDark: isDark,
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),

            // Message Input
            BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                final isSending = state is ChatSendingMessage;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            enabled: !isSending,
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(
                                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                              ),
                              filled: true,
                              fillColor: isDark ? AppTheme.primaryBlack : Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: TextStyle(
                              color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlue,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: isSending
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.send, color: Colors.white),
                            onPressed: isSending ? null : _sendMessage,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
    );
  }
}

/// Message bubble widget
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDark;

  const _MessageBubble({
    required this.message,
    required this.isDark,
  });

  // Helper to determine if this is my message
  bool get isMyMessage {
    final userData = HiveStorage.getUserData();
    if (userData == null) return false;
    final currentUserId = userData['id'] as int?;
    return currentUserId != null && message.sender.id == currentUserId;
  }

  @override
  Widget build(BuildContext context) {
    final isMe = isMyMessage;
    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bgColor = isMe
        ? AppTheme.accentBlue
        : (isDark ? AppTheme.secondaryBlack : AppTheme.lightGrey.withValues(alpha: 0.3));
    final textColor = isMe ? Colors.white : (isDark ? AppTheme.textWhite : AppTheme.textBlack);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16).copyWith(
                topLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                topRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    color: isMe
                        ? Colors.white70
                        : (isDark ? AppTheme.textGrey : AppTheme.textDarkGrey),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
