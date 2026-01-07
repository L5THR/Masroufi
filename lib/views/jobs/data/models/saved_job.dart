import 'package:equatable/equatable.dart';
import 'package:flutter_alinfo9/views/jobs/data/models/job.dart';

class SavedJob extends Equatable {
  final int id; // ID of the saved job entry, not the job itself
  final Job job;
  final DateTime? savedAt; // Nullable for DTO format

  const SavedJob({
    required this.id,
    required this.job,
    this.savedAt, // Now nullable
  });

  factory SavedJob.fromJson(Map<String, dynamic> json) {
    return SavedJob(
      id: json['id'] as int,
      job: Job.fromJson(json['job'] as Map<String, dynamic>),
      // Handle DTO format where savedAt is missing
      savedAt: json['savedAt'] != null
          ? DateTime.parse(json['savedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job': job.toJson(),
      'savedAt': savedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, job, savedAt];
}
