import 'package:flutter/material.dart';
import 'package:flutter_alinfo9/views/chat/presentation/widgets/messege_bubble.dart';
import 'package:flutter_alinfo9/views/chat/presentation/widgets/messege_input.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/chat_cubit.dart';
import '../../logic/chat_state.dart';
import '../widgets/typing_indicator.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String role;
  final String roomId;

  const ChatPage({
    super.key,
    required this.userId,
    required this.role,
    required this.roomId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().init(widget.userId, widget.role, widget.roomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat Room")),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                return ListView(
                  padding: EdgeInsets.all(12),
                  children: [
                    for (final msg in state.messages)
                      MessageBubble(
                        message: msg,
                        isMe: msg.senderId == widget.userId,
                      ),
                  ],
                );
              },
            ),
          ),
          BlocBuilder<ChatCubit, ChatState>(
            builder: (_, state) => TypingIndicator(isTyping: state.isTyping),
          ),
          MessageInput(
            controller: controller,
            onSend: () {
              if (controller.text.isNotEmpty) {
                context.read<ChatCubit>().sendMessage(controller.text);
                controller.clear();
              }
            },
            onTyping: (v) => context.read<ChatCubit>().setTyping(v.isNotEmpty),
          ),
        ],
      ),
    );
  }
}
