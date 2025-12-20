import 'package:dio/dio.dart';
import 'package:flutter_alinfo9/core/network/dio_client.dart';
import 'package:flutter_alinfo9/core/network/dio_exceptions.dart';
import 'package:flutter_alinfo9/views/jobs/data/models/paginated_response.dart';
import 'package:flutter_alinfo9/views/jobs/data/models/saved_job.dart';

class SavedJobRepository {
  final DioClient dioClient;

  SavedJobRepository({required this.dioClient});

  Future<void> saveJob(int jobId) async {
    try {
      await dioClient.dio.post('/api/jobs/$jobId/save');
    } on DioException catch (e) {
      final errorMessage = AppDioException.fromDioError(e).toString();
      throw errorMessage;
    }
  }

  Future<void> unSaveJob(int jobId) async {
    try {
      await dioClient.dio.delete('/api/jobs/$jobId/save');
    } on DioException catch (e) {
      final errorMessage = AppDioException.fromDioError(e).toString();
      throw errorMessage;
    }
  }

  Future<PaginatedResponse<SavedJob>> getSavedJobs({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await dioClient.dio.get(
        '/api/job-seekers/me/saved-jobs',
        queryParameters: {'page': page, 'size': size},
      );
      return PaginatedResponse.fromJson(
        response.data,
        (json) => SavedJob.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final errorMessage = AppDioException.fromDioError(e).toString();
      throw errorMessage;
    }
  }
}
