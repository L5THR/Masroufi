import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/endpoints.dart';
import '../models/job.dart';
import '../models/category.dart';
import '../models/job_request.dart';
import '../models/paginated_response.dart';

class JobRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<PaginatedResponse<Job>> getJobs({
    int page = 0,
    int size = 20,
    int? categoryId,
    String? sort,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.jobs,
        queryParameters: {
          'page': page,
          'size': size,
          if (categoryId != null) 'category': categoryId,
          if (sort != null) 'sort': sort,
        },
      );
      return PaginatedResponse.fromJson(response.data, Job.fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<PaginatedResponse<Job>> searchJobs({
    required String query,
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.searchJobs,
        queryParameters: {
          'query': query,
          'page': page,
          'size': size,
          if (sort != null) 'sort': sort,
        },
      );
      return PaginatedResponse.fromJson(response.data, Job.fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Job> getJobById(int jobId) async {
    try {
      final response = await _dio.get(ApiEndpoints.jobById(jobId));
      return Job.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<PaginatedResponse<Category>> getCategories({
    int page = 0,
    int size = 100,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.categories,
        queryParameters: {'page': page, 'size': size},
      );
      return PaginatedResponse.fromJson(response.data, Category.fromJson);
    } on DioException catch (e) {
      print('❌ getCategories failed: ${e.response?.statusCode}');
      throw _handleError(e);
    }
  }

  Future<Job> createJob(JobRequest jobRequest) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.jobs,
        data: jobRequest.toJson(),
      );
      return Job.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ createJob failed: ${e.response?.statusCode} - ${e.message}');
      throw _handleError(e);
    }
  }

  Future<Job> updateJob(int jobId, JobRequest jobRequest) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.jobById(jobId),
        data: jobRequest.toJson(),
      );
      return Job.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<PaginatedResponse<Job>> getMyJobs({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.myJobs,
        queryParameters: {
          'page': page,
          'size': size,
        },
      );
      return PaginatedResponse.fromJson(response.data, Job.fromJson);
    } on DioException catch (e) {
      print('❌ getMyJobs failed: ${e.response?.statusCode}');
      throw _handleError(e);
    }
  }

  Future<void> deleteJob(int jobId) async {
    try {
      await _dio.delete(ApiEndpoints.jobById(jobId));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message =
            e.response?.data['message'] ?? e.response?.data['error'];
        if (statusCode == 400) {
          return message ?? 'Invalid request.';
        } else if (statusCode == 401) {
          return message ?? 'Unauthorized. Please login again.';
        } else if (statusCode == 403) {
          return message ?? 'Access denied.';
        } else if (statusCode == 404) {
          return message ?? 'Resource not found.';
        } else if (statusCode == 500) {
          return 'Server error. Please try again later.';
        }
        return message ?? 'An error occurred.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      default:
        return 'Network error. Please check your connection.';
    }
  }
}
