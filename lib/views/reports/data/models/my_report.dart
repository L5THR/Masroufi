// lib/views/reports/data/models/my_report.dart

import 'report.dart';

/// Resolution type for resolved reports
enum ReportResolution {
  ACTION_TAKEN,
  DISMISSED,
  DUPLICATE;

  String toJson() => name;

  static ReportResolution? fromString(String? value) {
    if (value == null) return null;
    return ReportResolution.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReportResolution.DISMISSED,
    );
  }

  String get displayText {
    switch (this) {
      case ReportResolution.ACTION_TAKEN:
        return 'Action Taken';
      case ReportResolution.DISMISSED:
        return 'Dismissed';
      case ReportResolution.DUPLICATE:
        return 'Duplicate';
    }
  }
}

/// Target summary for reports (job title/company or user name)
class ReportTargetSummary {
  final String? title;
  final String? companyName;

  ReportTargetSummary({
    this.title,
    this.companyName,
  });

  factory ReportTargetSummary.fromJson(Map<String, dynamic> json) {
    return ReportTargetSummary(
      title: json['title'],
      companyName: json['companyName'],
    );
  }

  String get displayName {
    if (title != null && title!.isNotEmpty) {
      return title!;
    }
    if (companyName != null && companyName!.isNotEmpty) {
      return companyName!;
    }
    return 'Unknown';
  }
}

/// MyReport model - represents a report from the user's perspective
/// Used for GET /api/reports/me endpoint
class MyReport {
  final int id;
  final int targetId;
  final ReportTargetType targetType;
  final ReportTargetSummary? targetSummary;
  final String reason;
  final ReportStatus status;
  final ReportResolution? resolution;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  MyReport({
    required this.id,
    required this.targetId,
    required this.targetType,
    this.targetSummary,
    required this.reason,
    required this.status,
    this.resolution,
    required this.createdAt,
    this.resolvedAt,
  });

  factory MyReport.fromJson(Map<String, dynamic> json) {
    return MyReport(
      id: json['id'],
      targetId: json['targetId'],
      targetType: ReportTargetType.fromString(json['targetType']),
      targetSummary: json['targetSummary'] != null
          ? ReportTargetSummary.fromJson(json['targetSummary'])
          : null,
      reason: json['reason'] ?? '',
      status: ReportStatus.fromString(json['status']),
      resolution: ReportResolution.fromString(json['resolution']),
      createdAt: DateTime.parse(json['createdAt']),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
    );
  }

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

  /// Get status color value
  int get statusColorValue {
    switch (status) {
      case ReportStatus.PENDING:
        return 0xFFFF9800; // Orange
      case ReportStatus.UNDER_REVIEW:
        return 0xFF2196F3; // Blue
      case ReportStatus.RESOLVED:
        return 0xFF4CAF50; // Green
    }
  }

  /// Check if report is resolved
  bool get isResolved => status == ReportStatus.RESOLVED;

  /// Check if report is about a job
  bool get isJobReport => targetType == ReportTargetType.JOB;
}
