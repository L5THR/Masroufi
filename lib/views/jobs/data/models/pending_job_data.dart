// Model to hold job data before it's submitted to the server
// Used when creating a job with a quiz - we store the job data,
// navigate to quiz creation, then submit both together

import 'dart:io';
import 'job_request.dart';

class PendingJobData {
  final String title;
  final String description;
  final String? requirements;
  final String? location;
  final double? salary;
  final String? duration;
  final int categoryId;
  final bool requiresQuiz;
  final List<String>? skills;
  final File? imageFile;

  const PendingJobData({
    required this.title,
    required this.description,
    this.requirements,
    this.location,
    this.salary,
    this.duration,
    required this.categoryId,
    this.requiresQuiz = true,
    this.skills,
    this.imageFile,
  });

  JobRequest toJobRequest({String? imageUrl}) {
    return JobRequest(
      title: title,
      description: description,
      requirements: requirements,
      location: location,
      salary: salary,
      duration: duration,
      categoryId: categoryId,
      requiresQuiz: requiresQuiz,
      imageUrl: imageUrl,
      skills: skills,
    );
  }

  @override
  String toString() {
    return 'PendingJobData(title: $title, categoryId: $categoryId, requiresQuiz: $requiresQuiz)';
  }
}
