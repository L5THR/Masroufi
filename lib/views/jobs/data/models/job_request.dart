class JobRequest {
  final String title;
  final String description;
  final String? requirements;
  final String? location;
  final double? salary;
  final String? duration;
  final int categoryId;
  final bool? requiresQuiz;
  final String? imageUrl;
  final List<String>? skills;

  JobRequest({
    required this.title,
    required this.description,
    this.requirements,
    this.location,
    this.salary,
    this.duration,
    required this.categoryId,
    this.requiresQuiz,
    this.imageUrl,
    this.skills,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'requirements': requirements,
      'location': location,
      'salary': salary,
      'duration': duration,
      'categoryId': categoryId,
      'requiresQuiz': requiresQuiz,
      'imageUrl': imageUrl,
      'skills': skills,
    };
  }
}
