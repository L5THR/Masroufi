// lib/views/applications/data/models/application_detail.dart

import 'package:flutter_alinfo9/views/auth/data/models/job_seeker_profile.dart';
import 'package:flutter_alinfo9/views/jobs/data/models/job.dart';
import 'application_status.dart';
import 'completion_info.dart';

class ApplicationDetail {
  final int id;
  final ApplicationStatus status;
  final Job job;
  final JobSeekerProfile jobSeeker;
  final DateTime appliedAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final CompletionInfo? completionInfo;

  ApplicationDetail({
    required this.id,
    required this.status,
    required this.job,
    required this.jobSeeker,
    required this.appliedAt,
    this.updatedAt,
    this.completedAt,
    this.completionInfo,
  });

  factory ApplicationDetail.fromJson(Map<String, dynamic> json) {
    return ApplicationDetail(
      id: json['id'] as int,
      status: ApplicationStatus.fromString(json['status'] as String),
      job: Job.fromJson(json['job'] as Map<String, dynamic>),
      jobSeeker: JobSeekerProfile.fromJson(json['jobSeeker'] as Map<String, dynamic>),
      appliedAt: DateTime.parse(json['appliedAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      completionInfo: json['completionInfo'] != null
          ? CompletionInfo.fromJson(json['completionInfo'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.toApiString(),
      'job': job.toJson(),
      'jobSeeker': jobSeeker.toJson(),
      'appliedAt': appliedAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'completionInfo': completionInfo?.toJson(),
    };
  }

  ApplicationDetail copyWith({
    int? id,
    ApplicationStatus? status,
    Job? job,
    JobSeekerProfile? jobSeeker,
    DateTime? appliedAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    CompletionInfo? completionInfo,
  }) {
    return ApplicationDetail(
      id: id ?? this.id,
      status: status ?? this.status,
      job: job ?? this.job,
      jobSeeker: jobSeeker ?? this.jobSeeker,
      appliedAt: appliedAt ?? this.appliedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      completionInfo: completionInfo ?? this.completionInfo,
    );
  }

  // Helper methods for completion actions
  bool get canStartWork => status.canStartWork;
  bool get canRequestCompletion => status.canRequestCompletion;
  bool get canConfirmCompletion => completionInfo?.canConfirm ?? false;
  bool get canCancelCompletionRequest => completionInfo?.canCancel ?? false;
  bool get isAwaitingConfirmation => status.isAwaitingConfirmation;
  bool get isCompleted => status.isCompleted;
}
