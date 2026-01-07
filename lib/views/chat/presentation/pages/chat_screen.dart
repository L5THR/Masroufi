import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import 'package:flutter_alinfo9/views/chat/logic/chat_cubit.dart';
import 'package:flutter_alinfo9/views/chat/logic/chat_state.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final int userId; // ID of the user we're chatting with
  final String userName; // Name to display in app bar
  final String? userRole; // RECRUITER or JOB_SEEKER (optional, for avatar icon)

  const ChatScreen({
    super.key,
    required this.userId,
    required this.userName,
    this.userRole,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load chat history when screen opens
    context.read<ChatCubit>().loadChatHistory(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
              child: Icon(
                widget.userRole == 'RECRUITER' ? Icons.business : Icons.person,
                color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ChatCubit>().refreshChat(widget.userId);
            },
          ),
        ],
      ),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          // Show error messages
          if (state is ChatError || state is ChatSendError) {
            final message = state is ChatError
                ? state.message
                : (state as ChatSendError).message;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }

          // Scroll to bottom when new message is sent
          if (state is ChatMessageSent) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: _buildMessageList(state, isDark),
              ),
              _buildMessageInput(state, isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageList(ChatState state, bool isDark) {
    if (state is ChatLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ChatError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load chat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ChatCubit>().loadChatHistory(widget.userId);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
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
                color: isDark ? AppTheme.textGrey : AppTheme.lightGrey,
              ),
              const SizedBox(height: 16),
              Text(
                'No messages yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start the conversation!',
                style: TextStyle(
                  color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          // Determine if this message is from the current user
          // We need to get the current user's ID from storage/context
          // For now, check if sender ID matches the userId we're chatting with
          final isOtherUser = message.sender.id == widget.userId;

          return _MessageBubble(
            text: message.message,
            isMe: !isOtherUser,
            time: _formatTime(message.timestamp),
            senderName: isOtherUser ? widget.userName : 'You',
          );
        },
      );
    }

    // Default: Show empty state
    return Center(
      child: Text(
        'Select a conversation to start chatting',
        style: TextStyle(
          color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
        ),
      ),
    );
  }

  Widget _buildMessageInput(ChatState state, bool isDark) {
    final isSending = state is ChatSendingMessage;

    return Container(
      padding: const EdgeInsets.all(16),
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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  enabled: !isSending,
                  style: TextStyle(
                    color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSending ? Colors.grey : AppTheme.accentBlue,
                shape: BoxShape.circle,
              ),
              child: isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.send, color: AppTheme.textWhite),
                      onPressed: () {
                        final message = _messageController.text.trim();
                        if (message.isNotEmpty) {
                          context
                              .read<ChatCubit>()
                              .sendMessage(widget.userId, message);
                          _messageController.clear();
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      // Today: show time
      return DateFormat('HH:mm').format(timestamp);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday ${DateFormat('HH:mm').format(timestamp)}';
    } else if (difference.inDays < 7) {
      // This week: show day name
      return DateFormat('EEE HH:mm').format(timestamp);
    } else {
      // Older: show date
      return DateFormat('MMM d, HH:mm').format(timestamp);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;
  final String senderName;

  const _MessageBubble({
    required this.text,
    required this.isMe,
    required this.time,
    required this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor:
                  isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
              child: Icon(
                Icons.person,
                size: 16,
                color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe
                    ? AppTheme.accentBlue
                    : (isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: isMe
                          ? AppTheme.textWhite
                          : (isDark ? AppTheme.textWhite : AppTheme.textBlack),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      color: isMe
                          ? AppTheme.textWhite.withValues(alpha: 0.7)
                          : (isDark ? AppTheme.textGrey : AppTheme.textDarkGrey),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor:
                  isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
              child: Icon(
                Icons.person,
                size: 16,
                color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
