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
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'categoryId': categoryId,
    };

    // Only include non-null optional fields
    if (requirements != null) map['requirements'] = requirements;
    if (location != null) map['location'] = location;
    if (salary != null) map['salary'] = salary;
    if (duration != null) map['duration'] = duration;
    if (requiresQuiz != null) map['requiresQuiz'] = requiresQuiz;
    if (imageUrl != null) map['imageUrl'] = imageUrl;
    if (skills != null && skills!.isNotEmpty) map['skills'] = skills;

    return map;
  }
}
