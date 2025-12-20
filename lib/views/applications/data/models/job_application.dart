import 'package:flutter_alinfo9/views/auth/data/models/job_seeker_profile.dart';
import 'package:flutter_alinfo9/views/jobs/data/models/category.dart';
import 'package:flutter_alinfo9/views/jobs/data/models/job.dart';
import 'package:flutter_alinfo9/views/auth/data/models/recruiter_profile.dart';
import 'application_status.dart';

class JobApplication {
  final int id;
  final Job job;
  final JobSeekerProfile jobSeeker;
  final ApplicationStatus status;
  final DateTime appliedAt;

  JobApplication({
    required this.id,
    required this.job,
    required this.jobSeeker,
    required this.status,
    required this.appliedAt,
  });

  // From JSON
  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'] as int,
      job: Job.fromJson(json['job'] as Map<String, dynamic>),
      jobSeeker: JobSeekerProfile.fromJson(
        json['jobSeeker'] as Map<String, dynamic>,
      ),
      status: ApplicationStatus.fromString(json['status'] as String),
      appliedAt: DateTime.parse(json['appliedAt'] as String),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job': job.toJson(),
      'jobSeeker': jobSeeker.toJson(),
      'status': status.toApiString(),
      'appliedAt': appliedAt.toIso8601String(),
    };
  }

  // CopyWith method for updating
  JobApplication copyWith({
    int? id,
    Job? job,
    JobSeekerProfile? jobSeeker,
    ApplicationStatus? status,
    DateTime? appliedAt,
  }) {
    return JobApplication(
      id: id ?? this.id,
      job: job ?? this.job,
      jobSeeker: jobSeeker ?? this.jobSeeker,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
    );
  }
}
