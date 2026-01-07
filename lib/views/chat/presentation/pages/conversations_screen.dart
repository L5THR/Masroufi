import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import 'package:flutter_alinfo9/views/chat/data/repositories/chat_repository.dart';
import 'package:flutter_alinfo9/views/chat/logic/chat_cubit.dart';
import 'package:flutter_alinfo9/views/chat/presentation/pages/chat_screen.dart';
import 'package:intl/intl.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final ChatRepository _chatRepository = ChatRepository();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _chatRepository.getConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load conversations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {}); // Trigger rebuild
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final conversations = snapshot.data ?? [];

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: isDark ? AppTheme.textGrey : AppTheme.lightGrey,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No conversations yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start chatting with recruiters or job seekers!',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                    ),
                  ),
                ],
              ),
            );
          }

          // Group conversations by user (sender or recipient)
          final Map<int, dynamic> conversationMap = {};
          for (final message in conversations) {
            // Determine the other user (not the current user)
            // We'll use the sender for now - in production, check against current user ID
            final otherUser = message.sender;
            final userId = otherUser.id;

            if (!conversationMap.containsKey(userId) ||
                message.timestamp.isAfter(
                    conversationMap[userId]['timestamp'])) {
              conversationMap[userId] = {
                'user': otherUser,
                'lastMessage': message.message,
                'timestamp': message.timestamp,
              };
            }
          }

          final conversationList = conversationMap.values.toList();
          conversationList.sort((a, b) =>
              (b['timestamp'] as DateTime).compareTo(a['timestamp']));

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.separated(
              itemCount: conversationList.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
              ),
              itemBuilder: (context, index) {
                final conversation = conversationList[index];
                final user = conversation['user'];
                final lastMessage = conversation['lastMessage'] as String;
                final timestamp = conversation['timestamp'] as DateTime;

                return _ConversationTile(
                  userName: user.email, // Using email as name for now
                  userRole: user.role,
                  lastMessage: lastMessage,
                  timestamp: timestamp,
                  onTap: () {
                    // Navigate to chat screen with BLoC provider
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (context) => ChatCubit(ChatRepository()),
                          child: ChatScreen(
                            userId: user.id,
                            userName: user.email,
                            userRole: user.role,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final String userName;
  final String userRole;
  final String lastMessage;
  final DateTime timestamp;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.userName,
    required this.userRole,
    required this.lastMessage,
    required this.timestamp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
        child: Icon(
          userRole == 'RECRUITER' ? Icons.business : Icons.person,
          color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              userName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatTimestamp(timestamp),
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
            ),
          ),
        ],
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE').format(timestamp);
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}
