import '../../../admin/data/models/user_account.dart';

class ChatMessage {
  final int id;
  final UserAccount sender;
  final UserAccount recipient;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.recipient,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      sender: UserAccount.fromJson(json['sender'] as Map<String, dynamic>),
      recipient: UserAccount.fromJson(json['recipient'] as Map<String, dynamic>),
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.toJson(),
      'recipient': recipient.toJson(),
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
