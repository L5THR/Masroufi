// lib/views/reviews/logic/review_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/review.dart';
import '../data/repositories/review_repository.dart';
import 'review_state.dart';

class ReviewCubit extends Cubit<ReviewState> {
  final ReviewRepository _repository;

  ReviewCubit(this._repository) : super(const ReviewInitial());

  // ==================== CREATE REVIEW ====================

  /// Create a new review
  Future<void> createReview({
    required int jobApplicationId,
    required int rating,
    String? comment,
  }) async {
    if (rating < 1 || rating > 5) {
      emit(const ReviewCreateError('Rating must be between 1 and 5'));
      return;
    }

    emit(const ReviewCreating());

    try {
      final review = await _repository.createReview(
        jobApplicationId: jobApplicationId,
        rating: rating,
        comment: comment,
      );
      emit(ReviewCreated(review));
    } catch (e) {
      emit(ReviewCreateError(e.toString()));
    }
  }

  // ==================== GET USER REVIEWS ====================

  /// Get reviews for a specific user
  Future<void> getUserReviews({
    required int userId,
    int page = 0,
    int size = 20,
  }) async {
    if (page == 0) {
      emit(const UserReviewsLoading());
    }

    try {
      final reviews = await _repository.getUserReviews(
        userId: userId,
        page: page,
        size: size,
      );

      if (reviews.isEmpty && page == 0) {
        emit(UserReviewsEmpty(userId));
      } else {
        final currentState = state;
        final existingReviews = currentState is UserReviewsLoaded
            ? currentState.reviews
            : <ReviewListItem>[];

        final allReviews = page == 0
            ? reviews
            : [...existingReviews, ...reviews];

        emit(UserReviewsLoaded(
          reviews: allReviews,
          userId: userId,
          hasMore: reviews.length == size,
          currentPage: page,
        ));
      }
    } catch (e) {
      emit(UserReviewsError(e.toString()));
    }
  }

  /// Get rating summary for a user
  Future<void> getUserRatingSummary(int userId) async {
    emit(const RatingSummaryLoading());

    try {
      final summary = await _repository.getUserRatingSummary(userId);
      emit(RatingSummaryLoaded(summary));
    } catch (e) {
      emit(RatingSummaryError(e.toString()));
    }
  }

  // ==================== MY REVIEWS ====================

  /// Get reviews I received
  Future<void> getMyReceivedReviews({int page = 0, int size = 20}) async {
    if (page == 0) {
      emit(const MyReviewsLoading());
    }

    try {
      final reviews = await _repository.getMyReceivedReviews(
        page: page,
        size: size,
      );

      if (reviews.isEmpty && page == 0) {
        emit(const MyReviewsEmpty('received'));
      } else {
        final currentState = state;
        final existingReviews = currentState is MyReceivedReviewsLoaded
            ? currentState.reviews
            : <ReviewListItem>[];

        final allReviews = page == 0
            ? reviews
            : [...existingReviews, ...reviews];

        emit(MyReceivedReviewsLoaded(
          reviews: allReviews,
          hasMore: reviews.length == size,
          currentPage: page,
        ));
      }
    } catch (e) {
      emit(MyReviewsError(e.toString()));
    }
  }

  /// Get reviews I gave
  Future<void> getMyGivenReviews({int page = 0, int size = 20}) async {
    if (page == 0) {
      emit(const MyReviewsLoading());
    }

    try {
      final reviews = await _repository.getMyGivenReviews(
        page: page,
        size: size,
      );

      if (reviews.isEmpty && page == 0) {
        emit(const MyReviewsEmpty('given'));
      } else {
        final currentState = state;
        final existingReviews = currentState is MyGivenReviewsLoaded
            ? currentState.reviews
            : <ReviewListItem>[];

        final allReviews = page == 0
            ? reviews
            : [...existingReviews, ...reviews];

        emit(MyGivenReviewsLoaded(
          reviews: allReviews,
          hasMore: reviews.length == size,
          currentPage: page,
        ));
      }
    } catch (e) {
      emit(MyReviewsError(e.toString()));
    }
  }

  // ==================== REVIEW STATUS ====================

  /// Check if current user can review an application
  Future<void> getReviewStatus(int applicationId) async {
    emit(const ReviewStatusLoading());

    try {
      final status = await _repository.getReviewStatus(applicationId);
      emit(ReviewStatusLoaded(status));
    } catch (e) {
      emit(ReviewStatusError(e.toString()));
    }
  }

  // ==================== UTILITY ====================

  /// Reset to initial state
  void reset() {
    emit(const ReviewInitial());
  }
}
