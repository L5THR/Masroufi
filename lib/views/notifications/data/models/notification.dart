import 'package:equatable/equatable.dart';
import 'package:flutter_alinfo9/views/admin/data/models/user_account.dart';

class Notification extends Equatable {
  final int id;
  final UserAccount user;
  final String message;
  final DateTime createdAt;
  final bool read;

  const Notification({
    required this.id,
    required this.user,
    required this.message,
    required this.createdAt,
    required this.read,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as int,
      user: UserAccount.fromJson(json['user'] as Map<String, dynamic>),
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      read: json['read'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'read': read,
    };
  }

  Notification copyWith({
    int? id,
    UserAccount? user,
    String? message,
    DateTime? createdAt,
    bool? read,
  }) {
    return Notification(
      id: id ?? this.id,
      user: user ?? this.user,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
    );
  }

  @override
  List<Object?> get props => [id, user, message, createdAt, read];
}
