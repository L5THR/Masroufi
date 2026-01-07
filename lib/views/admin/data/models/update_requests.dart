// Request DTOs for admin operations

class UpdateUserStatusRequest {
  final String status; // ACTIVE, BLOCKED

  UpdateUserStatusRequest({required this.status});

  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}

class UpdateUserRoleRequest {
  final String role; // JOB_SEEKER, RECRUITER, ADMIN

  UpdateUserRoleRequest({required this.role});

  Map<String, dynamic> toJson() {
    return {
      'role': role,
    };
  }
}

class UpdateReportStatusRequest {
  final String status; // PENDING, UNDER_REVIEW, RESOLVED

  UpdateReportStatusRequest({required this.status});

  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}
