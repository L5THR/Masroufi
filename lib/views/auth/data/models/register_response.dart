import 'job_seeker_profile.dart';
import 'recruiter_profile.dart';

class RegisterResponse {
  final int id;
  final String email;
  final String role;
  final String status;
  final JobSeekerProfile? jobSeekerProfile;
  final RecruiterProfile? recruiterProfile;

  RegisterResponse({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    this.jobSeekerProfile,
    this.recruiterProfile,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      jobSeekerProfile: json['jobSeekerProfile'] != null
          ? JobSeekerProfile.fromJson(json['jobSeekerProfile'])
          : null,
      recruiterProfile: json['recruiterProfile'] != null
          ? RecruiterProfile.fromJson(json['recruiterProfile'])
          : null,
    );
  }
}
