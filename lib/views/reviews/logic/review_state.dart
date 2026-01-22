// lib/views/reviews/logic/review_state.dart

import 'package:equatable/equatable.dart';
import '../data/models/review.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

// ==================== INITIAL STATE ====================

class ReviewInitial extends ReviewState {
  const ReviewInitial();
}

// ==================== CREATE REVIEW STATES ====================

class ReviewCreating extends ReviewState {
  const ReviewCreating();
}

class ReviewCreated extends ReviewState {
  final ReviewDetail review;

  const ReviewCreated(this.review);

  @override
  List<Object?> get props => [review];
}

class ReviewCreateError extends ReviewState {
  final String error;

  const ReviewCreateError(this.error);

  @override
  List<Object?> get props => [error];
}

// ==================== GET USER REVIEWS STATES ====================

class UserReviewsLoading extends ReviewState {
  const UserReviewsLoading();
}

class UserReviewsLoaded extends ReviewState {
  final List<ReviewListItem> reviews;
  final int userId;
  final bool hasMore;
  final int currentPage;

  const UserReviewsLoaded({
    required this.reviews,
    required this.userId,
    this.hasMore = false,
    this.currentPage = 0,
  });

  @override
  List<Object?> get props => [reviews, userId, hasMore, currentPage];
}

class UserReviewsEmpty extends ReviewState {
  final int userId;

  const UserReviewsEmpty(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UserReviewsError extends ReviewState {
  final String error;

  const UserReviewsError(this.error);

  @override
  List<Object?> get props => [error];
}

// ==================== RATING SUMMARY STATES ====================

class RatingSummaryLoading extends ReviewState {
  const RatingSummaryLoading();
}

class RatingSummaryLoaded extends ReviewState {
  final RatingSummary summary;

  const RatingSummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class RatingSummaryError extends ReviewState {
  final String error;

  const RatingSummaryError(this.error);

  @override
  List<Object?> get props => [error];
}

// ==================== MY REVIEWS STATES ====================

class MyReviewsLoading extends ReviewState {
  const MyReviewsLoading();
}

class MyReceivedReviewsLoaded extends ReviewState {
  final List<ReviewListItem> reviews;
  final bool hasMore;
  final int currentPage;

  const MyReceivedReviewsLoaded({
    required this.reviews,
    this.hasMore = false,
    this.currentPage = 0,
  });

  @override
  List<Object?> get props => [reviews, hasMore, currentPage];
}

class MyGivenReviewsLoaded extends ReviewState {
  final List<ReviewListItem> reviews;
  final bool hasMore;
  final int currentPage;

  const MyGivenReviewsLoaded({
    required this.reviews,
    this.hasMore = false,
    this.currentPage = 0,
  });

  @override
  List<Object?> get props => [reviews, hasMore, currentPage];
}

class MyReviewsEmpty extends ReviewState {
  final String type; // 'received' or 'given'

  const MyReviewsEmpty(this.type);

  @override
  List<Object?> get props => [type];
}

class MyReviewsError extends ReviewState {
  final String error;

  const MyReviewsError(this.error);

  @override
  List<Object?> get props => [error];
}

// ==================== REVIEW STATUS STATES ====================

class ReviewStatusLoading extends ReviewState {
  const ReviewStatusLoading();
}

class ReviewStatusLoaded extends ReviewState {
  final ReviewStatus status;

  const ReviewStatusLoaded(this.status);

  @override
  List<Object?> get props => [status];
}

class ReviewStatusError extends ReviewState {
  final String error;

  const ReviewStatusError(this.error);

  @override
  List<Object?> get props => [error];
}
