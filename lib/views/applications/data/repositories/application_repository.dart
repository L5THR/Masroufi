// lib/views/applications/data/repositories/application_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter_alinfo9/core/network/dio_client.dart';
import 'package:flutter_alinfo9/core/utils/endpoints.dart';
import 'package:flutter_alinfo9/views/applications/data/models/application_status.dart';
import 'package:flutter_alinfo9/views/applications/data/models/job_application.dart';

import 'package:flutter_alinfo9/views/jobs/data/models/job.dart';
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
      print('📡 Applying to job ID: $jobId');
      print('📡 Endpoint: ${ApiEndpoints.applyToJob(jobId)}');
      print('📡 Headers: ${_dioClient.options.headers}');

      final response = await _dioClient.post(ApiEndpoints.applyToJob(jobId));

      print('✅ Application successful! Response: ${response.data}');
      return JobApplication.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Application failed: ${e.response?.statusCode} - ${e.message}');
      print('❌ Response data: ${e.response?.data}');
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
          return 'Please login to continue.';
        case 403:
          return 'You do not have permission to perform this action.';
        case 404:
          return 'Job or application not found.';
        case 409:
          return 'You have already applied to this job.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'Something went wrong. Please try again.';
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'No internet connection.';
    }

    return 'An unexpected error occurred.';
  }
}
