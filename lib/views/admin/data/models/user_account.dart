class UserAccount {
  final int id;
  final String email;
  final String role; // JOB_SEEKER, RECRUITER, ADMIN
  final String status; // ACTIVE, BLOCKED
  final DateTime createdAt;
  final DateTime updatedAt;

  UserAccount({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id'] as int,
      email: json['email'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Convenience getters
  bool get isActive => status == 'ACTIVE';
  bool get isBlocked => status == 'BLOCKED';
  bool get isJobSeeker => role == 'JOB_SEEKER';
  bool get isRecruiter => role == 'RECRUITER';
  bool get isAdmin => role == 'ADMIN';

  // Copy with method for updates
  UserAccount copyWith({
    int? id,
    String? email,
    String? role,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserAccount(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserAccount(id: $id, email: $email, role: $role, status: $status)';
  }
}
