// lib/views/quiz/data/repositories/quiz_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter_alinfo9/core/network/dio_client.dart';
import 'package:flutter_alinfo9/core/network/dio_exceptions.dart';
import 'package:flutter_alinfo9/core/utils/endpoints.dart';
import '../models/quiz.dart';
import '../models/quiz_attempt.dart';

class QuizRepository {
  final Dio _dio = DioClient.instance.dio;

  // ==================== JOB SEEKER METHODS ====================

  /// Get quiz for a specific job
  /// GET /api/jobs/{jobId}/quiz
  Future<Quiz> getQuizForJob(int jobId) async {
    try {
      print('📡 Getting quiz for job ID: $jobId');

      final response = await _dio.get(ApiEndpoints.jobQuiz(jobId));

      print('✅ Quiz loaded successfully');
      return Quiz.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error loading quiz: ${e.message}');
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
      print('📡 Submitting quiz ID: $quizId');
      print('📡 Selected options: $selectedOptionIds');

      final request = QuizSubmitRequest(answers: selectedOptionIds);

      final response = await _dio.post(
        ApiEndpoints.submitQuiz(quizId),
        data: request.toJson(),
      );

      print('✅ Quiz submitted successfully');
      print('✅ Response: ${response.data}');

      return QuizAttempt.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error submitting quiz: ${e.message}');
      print('❌ Response: ${e.response?.data}');
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
      print('📡 Getting quiz attempts for quiz ID: $quizId');

      final response = await _dio.get(
        ApiEndpoints.quizAttempts(quizId),
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      print('✅ Quiz attempts loaded');

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
      print('📡 Creating quiz for job ID: $jobId');
      print('📡 Quiz title: $title');
      print('📡 Number of questions: ${questions.length}');

      final request = QuizCreateRequest(
        jobId: jobId,
        title: title,
        questions: questions,
      );

      final response = await _dio.post(
        ApiEndpoints.quizzes,
        data: request.toJson(),
      );

      print('✅ Quiz created successfully');
      print('✅ Quiz ID: ${response.data['id']}');

      return Quiz.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error creating quiz: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      throw AppDioException.fromDioError(e);
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
          return 'Invalid quiz data. Please check your inputs.';
        case 401:
          return 'Please login to access quizzes.';
        case 403:
          return 'You don\'t have permission to perform this action.';
        case 404:
          return 'Quiz not found. It may have been deleted.';
        case 409:
          return 'You have already submitted this quiz.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'An error occurred. Please try again.';
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Please check your connection.';
    }

    return 'An unexpected error occurred: ${error.message}';
  }
}
