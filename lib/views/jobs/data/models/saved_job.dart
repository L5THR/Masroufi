import 'package:equatable/equatable.dart';
import 'package:flutter_alinfo9/views/jobs/data/models/job.dart';

class SavedJob extends Equatable {
  final int id; // ID of the saved job entry, not the job itself
  final Job job;
  final DateTime savedAt;

  const SavedJob({
    required this.id,
    required this.job,
    required this.savedAt,
  });

  factory SavedJob.fromJson(Map<String, dynamic> json) {
    return SavedJob(
      id: json['id'] as int,
      job: Job.fromJson(json['job'] as Map<String, dynamic>),
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job': job.toJson(),
      'savedAt': savedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, job, savedAt];
}
