// lib/views/applications/data/models/completion_info.dart

class CompletionUserInfo {
  final int id;
  final String role;
  final String displayName;

  CompletionUserInfo({
    required this.id,
    required this.role,
    required this.displayName,
  });

  factory CompletionUserInfo.fromJson(Map<String, dynamic> json) {
    return CompletionUserInfo(
      id: json['id'] as int,
      role: json['role'] as String,
      displayName: json['displayName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'displayName': displayName,
    };
  }

  bool get isJobSeeker => role == 'JOB_SEEKER';
  bool get isRecruiter => role == 'RECRUITER';
}

class CompletionInfo {
  final DateTime? requestedAt;
  final CompletionUserInfo? requestedBy;
  final bool canConfirm;
  final bool canCancel;

  CompletionInfo({
    this.requestedAt,
    this.requestedBy,
    required this.canConfirm,
    required this.canCancel,
  });

  factory CompletionInfo.fromJson(Map<String, dynamic> json) {
    return CompletionInfo(
      requestedAt: json['requestedAt'] != null
          ? DateTime.parse(json['requestedAt'] as String)
          : null,
      requestedBy: json['requestedBy'] != null
          ? CompletionUserInfo.fromJson(json['requestedBy'] as Map<String, dynamic>)
          : null,
      canConfirm: json['canConfirm'] as bool? ?? false,
      canCancel: json['canCancel'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestedAt': requestedAt?.toIso8601String(),
      'requestedBy': requestedBy?.toJson(),
      'canConfirm': canConfirm,
      'canCancel': canCancel,
    };
  }
}
