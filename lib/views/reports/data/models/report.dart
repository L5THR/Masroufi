// lib/views/reports/data/models/report.dart

import 'package:flutter_alinfo9/views/admin/data/models/user_account.dart';

export 'report_request.dart';

/// Report target type enum
enum ReportTargetType {
  JOB,
  USER;

  String toJson() => name;

  static ReportTargetType fromString(String value) {
    return ReportTargetType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReportTargetType.JOB,
    );
  }
}

/// Report status enum
enum ReportStatus {
  PENDING,
  UNDER_REVIEW,
  RESOLVED;

  String toJson() => name;

  static ReportStatus fromString(String value) {
    return ReportStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReportStatus.PENDING,
    );
  }
}

/// Report model - represents a report filed by a user
class Report {
  final int id;
  final UserAccount reporter;
  final int targetId;
  final ReportTargetType targetType;
  final String reason;
  final ReportStatus status;
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
      id: json['id'],
      reporter: UserAccount.fromJson(json['reporter']),
      targetId: json['targetId'],
      targetType: ReportTargetType.fromString(json['targetType']),
      reason: json['reason'],
      status: ReportStatus.fromString(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter': reporter.toJson(),
      'targetId': targetId,
      'targetType': targetType.toJson(),
      'reason': reason,
      'status': status.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Check if report is pending
  bool get isPending => status == ReportStatus.PENDING;

  /// Check if report is under review
  bool get isUnderReview => status == ReportStatus.UNDER_REVIEW;

  /// Check if report is resolved
  bool get isResolved => status == ReportStatus.RESOLVED;

  /// Check if report is about a job
  bool get isJobReport => targetType == ReportTargetType.JOB;

  /// Check if report is about a user
  bool get isUserReport => targetType == ReportTargetType.USER;

  /// Get status display text
  String get statusText {
    switch (status) {
      case ReportStatus.PENDING:
        return 'Pending';
      case ReportStatus.UNDER_REVIEW:
        return 'Under Review';
      case ReportStatus.RESOLVED:
        return 'Resolved';
    }
  }

  /// Get target type display text
  String get targetTypeText {
    switch (targetType) {
      case ReportTargetType.JOB:
        return 'Job';
      case ReportTargetType.USER:
        return 'User';
    }
  }
}
