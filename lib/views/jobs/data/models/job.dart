import 'category.dart';
import '../../../auth/data/models/recruiter_profile.dart';

class Job {
  final int id;
  final String title;
  final String description;
  final String? requirements;
  final String? location;
  final double? salary;
  final String? duration;
  final RecruiterProfile? recruiter;
  final Category? category; // Nullable for DTO format
  final String status;
  final bool requiresQuiz;
  final String? imageUrl;
  final List<String>? skills;
  final DateTime createdAt;
  final DateTime? updatedAt; // Nullable for DTO format

  Job({
    required this.id,
    required this.title,
    required this.description,
    this.requirements,
    this.location,
    this.salary,
    this.duration,
    this.recruiter,
    this.category, // Now nullable
    required this.status,
    required this.requiresQuiz,
    this.imageUrl,
    this.skills,
    required this.createdAt,
    this.updatedAt, // Now nullable
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    try {
      return Job(
        id: int.tryParse(json['id'].toString()) ?? 0,
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        requirements: json['requirements']?.toString(),
        location: json['location']?.toString(),
        salary: json['salary'] != null
            ? double.tryParse(json['salary'].toString())
            : null,
        duration: json['duration']?.toString(),
        recruiter: json['recruiter'] != null && json['recruiter'] is Map
            ? RecruiterProfile.fromJson(json['recruiter'] as Map<String, dynamic>)
            : null,
        // Handle both DTO format (no category) and full format (with category)
        category: json['category'] != null && json['category'] is Map
            ? Category.fromJson(json['category'] as Map<String, dynamic>)
            : null, // Can be null for DTO format
        status: json['status']?.toString() ?? 'OPEN',
        requiresQuiz: json['requiresQuiz'] == true || json['requiresQuiz'] == 'true',
        imageUrl: json['imageUrl']?.toString(),
        skills: _parseSkills(json['skills']),
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        // updatedAt is nullable for DTO format
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'].toString())
            : null,
      );
    } catch (e) {
      print('Error parsing Job from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static List<String>? _parseSkills(dynamic skillsData) {
    if (skillsData == null) return null;
    if (skillsData is List) {
      return skillsData.map((e) => e.toString()).toList();
    }
    if (skillsData is String) {
      // Handle comma-separated string
      return skillsData.split(',').map((e) => e.trim()).toList();
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'requirements': requirements,
      'location': location,
      'salary': salary,
      'duration': duration,
      'recruiter': recruiter?.toJson(),
      'category': category?.toJson(),
      'status': status,
      'requiresQuiz': requiresQuiz,
      'imageUrl': imageUrl,
      'skills': skills,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
