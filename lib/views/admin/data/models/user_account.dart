class UserAccount {
  final int id;
  final String? email; // Nullable for minimal format (e.g., reporter in reports list)
  final String? role; // JOB_SEEKER, RECRUITER, ADMIN - Nullable for minimal format
  final String? status; // ACTIVE, BLOCKED - Nullable for minimal format
  final DateTime? createdAt; // Nullable for UserAccountSummary format
  final DateTime? updatedAt; // Nullable for UserAccountSummary format

  UserAccount({
    required this.id,
    this.email,
    this.role,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  /// Parses full UserAccount, UserAccountSummary, and minimal formats
  /// Full format includes all fields, Summary format excludes dates,
  /// Minimal format may only include id
  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id'] as int,
      email: json['email'] as String?,
      role: json['role'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (status != null) 'status': status,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Convenience getters
  bool get isActive => status == 'ACTIVE';
  bool get isBlocked => status == 'BLOCKED';
  bool get isJobSeeker => role == 'JOB_SEEKER';
  bool get isRecruiter => role == 'RECRUITER';
  bool get isAdmin => role == 'ADMIN';

  /// Display name - returns email or a fallback
  String get displayName => email ?? 'User #$id';

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
