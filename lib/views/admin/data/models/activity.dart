class Activity {
  final int id;
  final String type;
  final String message;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.type,
    required this.message,
    required this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as int,
      type: json['type'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Activity(id: $id, type: $type, message: $message, createdAt: $createdAt)';
  }
}
