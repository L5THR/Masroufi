import 'job_seeker_profile.dart';
import 'recruiter_profile.dart';

class MeResponse {
  final int id;
  final String email;
  final String role;
  final String status;
  final JobSeekerProfile? jobSeekerProfile;
  final RecruiterProfile? recruiterProfile;

  MeResponse({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    this.jobSeekerProfile,
    this.recruiterProfile,
  });

  factory MeResponse.fromJson(Map<String, dynamic> json) {
    return MeResponse(
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'status': status,
      if (jobSeekerProfile != null)
        'jobSeekerProfile': jobSeekerProfile!.toJson(),
      if (recruiterProfile != null)
        'recruiterProfile': recruiterProfile!.toJson(),
    };
  }

  bool get isBlocked => status.toUpperCase() == 'BLOCKED';
  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isJobSeeker => role.toUpperCase() == 'JOB_SEEKER';
  bool get isRecruiter => role.toUpperCase() == 'RECRUITER';
  bool get isAdmin => role.toUpperCase() == 'ADMIN';

  String get displayName {
    if (jobSeekerProfile != null) {
      return jobSeekerProfile!.fullName;
    } else if (recruiterProfile != null) {
      return recruiterProfile!.companyName;
    }
    return email;
  }
}
