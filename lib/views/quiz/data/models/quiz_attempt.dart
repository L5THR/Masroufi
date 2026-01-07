// lib/views/quiz/data/models/quiz_attempt.dart

import 'quiz.dart';

class QuizAttempt {
  final int id;
  final JobSeekerProfile? jobSeeker;
  final Quiz? quiz;
  final double score;
  final DateTime submittedAt;

  QuizAttempt({
    required this.id,
    this.jobSeeker,
    this.quiz,
    required this.score,
    required this.submittedAt,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'],
      jobSeeker: json['jobSeeker'] != null
          ? JobSeekerProfile.fromJson(json['jobSeeker'])
          : null,
      quiz: json['quiz'] != null ? Quiz.fromJson(json['quiz']) : null,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      submittedAt: DateTime.parse(json['submittedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (jobSeeker != null) 'jobSeeker': jobSeeker!.toJson(),
      if (quiz != null) 'quiz': quiz!.toJson(),
      'score': score,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }

  /// Check if the attempt passed (score >= 70%)
  bool get passed => score >= 70.0;

  /// Get score percentage as integer
  int get scorePercentage => score.round();
}

class JobSeekerProfile {
  final int id;
  final String? fullName;
  final String? email;
  final String? phoneNumber;

  JobSeekerProfile({
    required this.id,
    this.fullName,
    this.email,
    this.phoneNumber,
  });

  factory JobSeekerProfile.fromJson(Map<String, dynamic> json) {
    return JobSeekerProfile(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (fullName != null) 'fullName': fullName,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    };
  }
}
