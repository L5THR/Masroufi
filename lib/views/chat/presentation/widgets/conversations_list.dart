// lib/views/chat/presentation/widgets/conversations_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import 'package:flutter_alinfo9/core/storage/hive_storage.dart';
import '../../logic/chat_cubit.dart';
import '../../logic/chat_state.dart';
import '../../data/models/chat_messege.dart';

/// Conversations list widget - shows all users you've chatted with
class ConversationsList extends StatelessWidget {
  const ConversationsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChatError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load messages',
                    style: TextStyle(
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<ChatCubit>().loadConversations();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentBlue,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is ConversationsLoaded) {
          if (state.conversations.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
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
                      'No Messages Yet',
                      style: TextStyle(
                        color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your conversations will appear here once you start chatting',
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.textGrey
                            : AppTheme.textDarkGrey,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.accentBlue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppTheme.accentBlue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'How to start a conversation:',
                                  style: TextStyle(
                                    color: isDark
                                        ? AppTheme.textWhite
                                        : AppTheme.textBlack,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Once you apply to a job or receive applications, your conversations with recruiters or job seekers will appear here automatically.',
                            style: TextStyle(
                              color: isDark
                                  ? AppTheme.textGrey
                                  : AppTheme.textDarkGrey,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<ChatCubit>().refreshConversations(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.conversations.length,
              itemBuilder: (context, index) {
                final conversation = state.conversations[index];
                return _ConversationCard(
                  conversation: conversation,
                  isDark: isDark,
                );
              },
            ),
          );
        }

        // Initial state - show loading
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final ChatMessage conversation;
  final bool isDark;

  const _ConversationCard({required this.conversation, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Determine who we're chatting with
    final userData = HiveStorage.getUserData();
    final currentUserId = userData?['id'] as int?;

    final isMyMessage =
        currentUserId != null && conversation.sender.id == currentUserId;
    final otherUser = isMyMessage
        ? conversation.recipient
        : conversation.sender;

    return GestureDetector(
      onTap: () {
        // Navigate to chat with this user
        Navigator.pushNamed(
          context,
          '/chat',
          arguments: {
            'recipientId': otherUser.id,
            'recipientName': otherUser
                .email, // Use email since UserAccount doesn't have fullName
            'jobTitle': null, // No job context from conversations list
            'jobId': null,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: isDark
                  ? AppTheme.tertiaryGrey
                  : AppTheme.lightGrey,
              child: Icon(
                Icons.person,
                color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
              ),
            ),
            const SizedBox(width: 12),
            // Message info
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        otherUser
                            .email!, // Use email since UserAccount doesn't have fullName
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.textWhite
                              : AppTheme.textBlack,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(conversation.timestamp),
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.textGrey
                              : AppTheme.textDarkGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isMyMessage
                        ? 'You: ${conversation.message}'
                        : conversation.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                      fontSize: 14,
                    ),
                  ),
                ],
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

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
