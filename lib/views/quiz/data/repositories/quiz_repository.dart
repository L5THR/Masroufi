// lib/views/quiz/data/repositories/quiz_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter_alinfo9/core/network/dio_client.dart';
import 'package:flutter_alinfo9/core/network/dio_exceptions.dart';
import 'package:flutter_alinfo9/core/utils/endpoints.dart';
import '../models/quiz.dart';

class QuizRepository {
  final Dio _dio = DioClient.instance.dio;

  // ==================== JOB SEEKER METHODS ====================

  /// Get quiz for a specific job
  /// GET /api/jobs/{jobId}/quiz
  Future<Quiz> getQuizForJob(int jobId) async {
    try {
      final response = await _dio.get(ApiEndpoints.jobQuiz(jobId));
      return Quiz.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error loading quiz for job $jobId: ${e.message}');
      throw AppDioException.fromDioError(e);
    }
  }

  /// Get quiz by ID
  /// GET /api/quizzes/{quizId}
  Future<Quiz> getQuizById(int quizId) async {
    try {
      final response = await _dio.get(ApiEndpoints.getQuizById(quizId));
      return Quiz.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error loading quiz $quizId: ${e.message}');
      throw AppDioException.fromDioError(e);
    }
  }

  /// Submit quiz answers
  /// POST /api/quizzes/{quizId}/submit
  Future<QuizAttempt> submitQuiz({
    required int quizId,
    required List<int> selectedOptionIds,
  }) async {
    try {
      final request = QuizSubmitRequest(answers: selectedOptionIds);

      final response = await _dio.post(
        ApiEndpoints.submitQuiz(quizId),
        data: request.toJson(),
      );

      return QuizAttempt.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error submitting quiz $quizId: ${e.message}');
      throw AppDioException.fromDioError(e);
    }
  }

  /// Get my quiz attempts for a specific quiz
  /// GET /api/quizzes/{quizId}/attempts
  Future<List<QuizAttempt>> getQuizAttempts({
    required int quizId,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.quizAttempts(quizId),
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      final content = response.data['content'] as List?;
      if (content == null) {
        return [];
      }

      return content.map((json) => QuizAttempt.fromJson(json)).toList();
    } on DioException catch (e) {
      print('❌ Error loading quiz attempts: ${e.message}');
      throw AppDioException.fromDioError(e);
    }
  }

  // ==================== RECRUITER METHODS ====================

  /// Create a new quiz for a job
  /// POST /api/quizzes
  Future<Quiz> createQuiz({
    required int jobId,
    required String title,
    required List<QuestionDto> questions,
  }) async {
    try {
      final request = QuizCreateRequest(
        jobId: jobId,
        title: title,
        questions: questions,
      );

      final response = await _dio.post(
        ApiEndpoints.quizzes,
        data: request.toJson(),
      );

      return Quiz.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error creating quiz: ${e.message}');

      // Check if it's a duplicate quiz error
      if (e.response?.statusCode == 400 || e.response?.statusCode == 409) {
        final data = e.response?.data;
        if (data != null && data.toString().contains('already')) {
          throw Exception('This job already has a quiz');
        }
      }

      throw AppDioException.fromDioError(e);
    }
  }

  /// Update an existing quiz
  /// PUT /api/quizzes/{quizId}
  Future<Quiz> updateQuiz({
    required int quizId,
    required String title,
    required List<QuestionDto> questions,
  }) async {
    try {
      final request = QuizUpdateRequest(
        title: title,
        questions: questions,
      );

      final response = await _dio.put(
        ApiEndpoints.updateQuiz(quizId),
        data: request.toJson(),
      );

      return Quiz.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error updating quiz $quizId: ${e.message}');
      throw AppDioException.fromDioError(e);
    }
  }

  /// Delete a quiz
  /// DELETE /api/quizzes/{quizId}
  Future<void> deleteQuiz(int quizId) async {
    try {
      await _dio.delete(ApiEndpoints.deleteQuiz(quizId));
    } on DioException catch (e) {
      print('❌ Error deleting quiz $quizId: ${e.message}');
      throw AppDioException.fromDioError(e);
    }
  }
}
