// lib/views/reviews/data/models/review_request.dart

/// Request model for creating a review
class ReviewRequest {
  final int jobApplicationId;
  final int rating; // 1-5
  final String? comment;

  ReviewRequest({
    required this.jobApplicationId,
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'jobApplicationId': jobApplicationId,
      'rating': rating,
      if (comment != null && comment!.isNotEmpty) 'comment': comment,
    };
  }

  /// Validate rating is within valid range
  bool get isValidRating => rating >= 1 && rating <= 5;

  /// Validate the entire request
  bool get isValid => isValidRating;
}
