// lib/views/reviews/data/repositories/review_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter_alinfo9/core/network/dio_client.dart';
import 'package:flutter_alinfo9/core/utils/endpoints.dart';
import '../models/review.dart';

class ReviewRepository {
  final Dio _dio = DioClient.instance.dio;

  // ==================== CREATE REVIEW ====================

  /// Create a new review
  /// POST /api/reviews
  Future<ReviewDetail> createReview({
    required int jobApplicationId,
    required int rating,
    String? comment,
  }) async {
    try {
      final request = ReviewRequest(
        jobApplicationId: jobApplicationId,
        rating: rating,
        comment: comment,
      );

      if (!request.isValid) {
        throw Exception('Invalid review data. Rating must be between 1 and 5.');
      }

      final response = await _dio.post(
        ApiEndpoints.reviews,
        data: request.toJson(),
      );

      return ReviewDetail.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== GET REVIEWS ====================

  /// Get a specific review by ID
  /// GET /api/reviews/{reviewId}
  Future<ReviewDetail> getReviewById(int reviewId) async {
    try {
      final response = await _dio.get(ApiEndpoints.reviewById(reviewId));
      return ReviewDetail.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get reviews received by a user (paginated)
  /// GET /api/reviews/user/{userId}
  Future<List<ReviewListItem>> getUserReviews({
    required int userId,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.userReviews(userId),
        queryParameters: {
          'page': page,
          'size': size,
          'sort': ['createdAt,desc'],
        },
      );

      final List<dynamic> reviewsJson = response.data['content'] ?? [];
      return reviewsJson.map((json) => ReviewListItem.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get rating summary for a user
  /// GET /api/reviews/user/{userId}/summary
  Future<RatingSummary> getUserRatingSummary(int userId) async {
    try {
      final response = await _dio.get(ApiEndpoints.userRatingSummary(userId));
      return RatingSummary.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== MY REVIEWS ====================

  /// Get reviews I received (paginated)
  /// GET /api/reviews/me/received
  Future<List<ReviewListItem>> getMyReceivedReviews({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.myReceivedReviews,
        queryParameters: {
          'page': page,
          'size': size,
          'sort': ['createdAt,desc'],
        },
      );

      final List<dynamic> reviewsJson = response.data['content'] ?? [];
      return reviewsJson.map((json) => ReviewListItem.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get reviews I gave (paginated)
  /// GET /api/reviews/me/given
  Future<List<ReviewListItem>> getMyGivenReviews({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.myGivenReviews,
        queryParameters: {
          'page': page,
          'size': size,
          'sort': ['createdAt,desc'],
        },
      );

      final List<dynamic> reviewsJson = response.data['content'] ?? [];
      return reviewsJson.map((json) => ReviewListItem.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== REVIEW STATUS ====================

  /// Check review status for an application
  /// GET /api/reviews/application/{applicationId}/status
  Future<ReviewStatus> getReviewStatus(int applicationId) async {
    try {
      final response = await _dio.get(ApiEndpoints.reviewStatus(applicationId));
      return ReviewStatus.fromJson(response.data);
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
          return 'Access denied. You cannot perform this action.';
        case 404:
          return 'Review not found.';
        case 409:
          return 'You have already reviewed this job.';
        case 500:
          String message = 'Server error. ';
          if (data is Map && data.containsKey('message')) {
            message += data['message'];
          }
          return message;
        default:
          return 'Something went wrong (HTTP $statusCode). Please try again.';
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server.';
    }

    return 'An unexpected error occurred: ${error.message}';
  }
}
