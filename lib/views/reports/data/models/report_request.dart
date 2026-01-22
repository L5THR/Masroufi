// lib/views/reports/data/models/report_request.dart

import 'report.dart';

/// Request model for creating a report
class ReportRequest {
  final int targetId;
  final ReportTargetType targetType;
  final String reason;

  ReportRequest({
    required this.targetId,
    required this.targetType,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'targetId': targetId,
      'targetType': targetType.toJson(),
      'reason': reason,
    };
  }

  /// Validate reason is not empty
  bool get hasReason => reason.isNotEmpty;

  /// Validate the entire request
  bool get isValid => hasReason;
}
