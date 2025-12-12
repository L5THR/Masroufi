import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  final bool isTyping;

  const TypingIndicator({super.key, required this.isTyping});

  @override
  Widget build(BuildContext context) {
    if (!isTyping) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text("Typing...", style: TextStyle(color: Colors.grey)),
    );
  }
}
