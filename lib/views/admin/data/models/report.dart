import 'user_account.dart';

class Report {
  final int id;
  final UserAccount reporter;
  final int targetId;
  final String targetType; // JOB, USER
  final String reason;
  final String status; // PENDING, UNDER_REVIEW, RESOLVED
  final DateTime createdAt;

  Report({
    required this.id,
    required this.reporter,
    required this.targetId,
    required this.targetType,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as int,
      reporter: UserAccount.fromJson(json['reporter'] as Map<String, dynamic>),
      targetId: json['targetId'] as int,
      targetType: json['targetType'] as String,
      reason: json['reason'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter': reporter.toJson(),
      'targetId': targetId,
      'targetType': targetType,
      'reason': reason,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'PENDING';
  bool get isUnderReview => status == 'UNDER_REVIEW';
  bool get isResolved => status == 'RESOLVED';

  bool get isJobReport => targetType == 'JOB';
  bool get isUserReport => targetType == 'USER';

  @override
  String toString() {
    return 'Report(id: $id, targetType: $targetType, status: $status, reason: $reason)';
  }
}
