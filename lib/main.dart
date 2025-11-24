import 'package:flutter/material.dart';
import 'package:flutter_alinfo9/views/chat/data/websocket_service.dart';
import 'package:flutter_alinfo9/views/chat/logic/chat_cubit.dart';
import 'package:provider/provider.dart';
import 'views/chat/presentation/pages/chat_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<ChatCubit>(
          create: (_) => ChatCubit(WebSocketService()),
          dispose: (_, cubit) => cubit.close(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:
          // Useer 1
          // ChatPage(userId: "user_1", role: "student", roomId: "room_123"),
          // User 2
          ChatPage(userId: "user_2", role: "jobOfferer", roomId: "room_123"),
    );
  }
}
