// lib/views/applications/data/repositories/application_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter_alinfo9/core/network/dio_client.dart';
import 'package:flutter_alinfo9/core/utils/endpoints.dart';
import 'package:flutter_alinfo9/views/applications/data/models/application_status.dart';
import 'package:flutter_alinfo9/views/applications/data/models/job_application.dart';
import 'package:flutter_alinfo9/views/applications/data/models/application_detail.dart';
import 'package:flutter_alinfo9/views/jobs/data/repositories/job_repository.dart';

class ApplicationRepository {
  final Dio _dioClient = DioClient.instance.dio;
  final JobRepository _jobRepository;

  ApplicationRepository() : _jobRepository = JobRepository();

  // ==================== JOB SEEKER METHODS ====================
  /// Apply to a job
  /// POST /api/jobs/{jobId}/apply
  Future<JobApplication> applyToJob(int jobId) async {
    try {
      final response = await _dioClient.post(ApiEndpoints.applyToJob(jobId));
      return JobApplication.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get my applications (Job Seeker)
  /// GET /api/job-seekers/me/applications
  Future<List<JobApplication>> getMyApplications({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.myApplications,
        queryParameters: {
          'page': page,
          'size': size,
          'sort': ['appliedAt,desc'],
        },
      );

      final content = response.data['content'] as List;
      return content.map((json) => JobApplication.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== RECRUITER METHODS ====================

  Future<List<JobApplication>> getApplicantsForRecruiter() async {
    try {
      final myJobsResponse = await _jobRepository.getMyJobs();
      final List<JobApplication> allApplicants = [];
      for (final job in myJobsResponse.content) {
        final applicants = await getJobApplications(jobId: job.id);
        allApplicants.addAll(applicants);
      }
      return allApplicants;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get applications for a specific job (Recruiter)
  /// GET /api/jobs/{jobId}/applications
  Future<List<JobApplication>> getJobApplications({
    required int jobId,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.jobApplications(jobId),
        queryParameters: {
          'page': page,
          'size': size,
          'sort': ['appliedAt,desc'],
        },
      );

      final content = response.data['content'] as List;
      return content.map((json) => JobApplication.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update application status (Recruiter)
  /// PUT /api/applications/{applicationId}/status
  Future<JobApplication> updateApplicationStatus({
    required int applicationId,
    required ApplicationStatus status,
  }) async {
    try {
      final response = await _dioClient.put(
        ApiEndpoints.updateApplicationStatus(applicationId),
        data: {'status': status.toApiString()},
      );

      return JobApplication.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get application details
  /// GET /api/applications/{applicationId}
  Future<ApplicationDetail> getApplicationDetail(int applicationId) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.applicationDetail(applicationId),
      );
      return ApplicationDetail.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== JOB COMPLETION METHODS ====================

  /// Start work on an accepted application (Job Seeker)
  /// PUT /api/applications/{applicationId}/start
  Future<ApplicationDetail> startWork(int applicationId) async {
    try {
      final response = await _dioClient.put(
        ApiEndpoints.startWork(applicationId),
      );
      return ApplicationDetail.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Request job completion (Either party)
  /// PUT /api/applications/{applicationId}/request-completion
  Future<ApplicationDetail> requestCompletion(int applicationId) async {
    try {
      final response = await _dioClient.put(
        ApiEndpoints.requestCompletion(applicationId),
      );
      return ApplicationDetail.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Confirm job completion (The other party)
  /// PUT /api/applications/{applicationId}/confirm-completion
  Future<ApplicationDetail> confirmCompletion(int applicationId) async {
    try {
      final response = await _dioClient.put(
        ApiEndpoints.confirmCompletion(applicationId),
      );
      return ApplicationDetail.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Cancel completion request (The requester)
  /// PUT /api/applications/{applicationId}/cancel-completion-request
  Future<ApplicationDetail> cancelCompletionRequest(int applicationId) async {
    try {
      final response = await _dioClient.put(
        ApiEndpoints.cancelCompletionRequest(applicationId),
      );
      return ApplicationDetail.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== ERROR HANDLING ====================

  String _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      switch (statusCode) {
        case 400:
          if (data is Map && data.containsKey('message')) {
            return data['message'];
          }
          return 'Invalid request. Please check your input.';
        case 401:
          return 'Authentication required. Please login again.';
        case 403:
          return 'Access denied. This feature requires job seeker privileges.';
        case 404:
          return 'Job or application not found.';
        case 409:
          return 'You have already applied to this job.';
        case 500:
          String message = 'Server error. ';
          if (data is Map && data.containsKey('message')) {
            message += data['message'];
          } else if (data is Map && data.containsKey('error')) {
            message += data['error'];
          } else {
            message += 'The backend server may not be running or the endpoint may not be implemented yet.';
          }
          return message;
        default:
          return 'Something went wrong (HTTP $statusCode). Please try again.';
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Make sure the backend is running at ${error.requestOptions.baseUrl}';
    }

    return 'An unexpected error occurred: ${error.message}';
  }
}
