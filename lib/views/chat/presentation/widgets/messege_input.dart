import 'package:flutter/material.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final Function(String) onTyping;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onTyping,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onTyping,
            decoration: InputDecoration(
              hintText: "Type a message...",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        IconButton(icon: Icon(Icons.send), onPressed: onSend),
      ],
    );
  }
}
