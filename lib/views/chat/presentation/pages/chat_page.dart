// import 'package:flutter/material.dart';
// import 'package:flutter_alinfo9/views/chat/presentation/widgets/messege_bubble.dart';
// import 'package:flutter_alinfo9/views/chat/presentation/widgets/messege_input.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../logic/chat_cubit.dart';
// import '../../logic/chat_state.dart';
// import '../widgets/typing_indicator.dart';

// class ChatPage extends StatefulWidget {
//   final String userId;
//   final String role;
//   final String roomId;

//   const ChatPage({
//     super.key,
//     required this.userId,
//     required this.role,
//     required this.roomId,
//   });

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final controller = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     context.read<ChatCubit>().init(widget.userId, widget.role, widget.roomId);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Chat Room")),
//       body: Column(
//         children: [
//           Expanded(
//             child: BlocBuilder<ChatCubit, ChatState>(
//               builder: (context, state) {
//                 return ListView(
//                   padding: EdgeInsets.all(12),
//                   children: [
//                     for (final msg in state.messages)
//                       MessageBubble(
//                         message: msg,
//                         isMe: msg.senderId == widget.userId,
//                       ),
//                   ],
//                 );
//               },
//             ),
//           ),
//           BlocBuilder<ChatCubit, ChatState>(
//             builder: (_, state) => TypingIndicator(isTyping: state.isTyping),
//           ),
//           MessageInput(
//             controller: controller,
//             onSend: () {
//               if (controller.text.isNotEmpty) {
//                 context.read<ChatCubit>().sendMessage(controller.text);
//                 controller.clear();
//               }
//             },
//             onTyping: (v) => context.read<ChatCubit>().setTyping(v.isNotEmpty),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! Thanks for applying to the Web Developer position.',
      'isMe': false,
      'time': '10:30 AM',
    },
    {
      'text': 'Thank you! I\'m very interested in this opportunity.',
      'isMe': true,
      'time': '10:32 AM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: isDark
                  ? AppTheme.tertiaryGrey
                  : AppTheme.lightGrey,
              child: Icon(
                Icons.business,
                color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tech Solutions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.accentGreen,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return _MessageBubble(
                  text: message['text'],
                  isMe: message['isMe'],
                  time: message['time'],
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  style: TextStyle(
                    color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppTheme.accentBlue,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: AppTheme.textWhite),
                onPressed: () {
                  if (_messageController.text.isNotEmpty) {
                    setState(() {
                      _messages.add({
                        'text': _messageController.text,
                        'isMe': true,
                        'time': 'Now',
                      });
                      _messageController.clear();
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;

  const _MessageBubble({
    required this.text,
    required this.isMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: isDark
                  ? AppTheme.tertiaryGrey
                  : AppTheme.lightGrey,
              child: Icon(
                Icons.business,
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
                          ? AppTheme.textWhite.withOpacity(0.7)
                          : (isDark
                                ? AppTheme.textGrey
                                : AppTheme.textDarkGrey),
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
              backgroundColor: isDark
                  ? AppTheme.tertiaryGrey
                  : AppTheme.lightGrey,
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
