class ChatMessage {
  final int id;
  final String roomId;
  final String senderId;
  final String senderRole;
  final String text;
  final DateTime timestamp;
  final bool delivered;
  final bool seen;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderRole,
    required this.text,
    required this.timestamp,
    required this.delivered,
    required this.seen,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      roomId: json['roomId'],
      senderId: json['senderId'],
      senderRole: json['senderRole'],
      text: json['text'],
      timestamp: DateTime.parse(json['timestamp']),
      delivered: json['delivered'],
      seen: json['seen'],
    );
  }
}
