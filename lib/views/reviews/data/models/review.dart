// lib/views/reviews/data/models/review.dart

export 'review_request.dart';

/// User info in review context
class ReviewUserInfo {
  final int id;
  final String? email;
  final String role;
  final String status;
  final String displayName;
  final String? profilePictureUrl;

  ReviewUserInfo({
    required this.id,
    this.email,
    required this.role,
    required this.status,
    required this.displayName,
    this.profilePictureUrl,
  });

  factory ReviewUserInfo.fromJson(Map<String, dynamic> json) {
    return ReviewUserInfo(
      id: json['id'] as int,
      email: json['email'] as String?,
      role: json['role'] as String? ?? 'JOB_SEEKER',
      status: json['status'] as String? ?? 'ACTIVE',
      displayName: json['displayName'] as String? ?? '',
      profilePictureUrl: json['profilePictureUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'status': status,
      'displayName': displayName,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  bool get isJobSeeker => role == 'JOB_SEEKER';
  bool get isRecruiter => role == 'RECRUITER';
}

/// Job application info in review context
class ReviewJobApplicationInfo {
  final int id;
  final String status;
  final DateTime? appliedAt;
  final DateTime? completedAt;

  ReviewJobApplicationInfo({
    required this.id,
    required this.status,
    this.appliedAt,
    this.completedAt,
  });

  factory ReviewJobApplicationInfo.fromJson(Map<String, dynamic> json) {
    return ReviewJobApplicationInfo(
      id: json['id'] as int,
      status: json['status'] as String,
      appliedAt: json['appliedAt'] != null
          ? DateTime.parse(json['appliedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'appliedAt': appliedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

/// Review detail response - full review information
class ReviewDetail {
  final int id;
  final ReviewUserInfo reviewer;
  final ReviewUserInfo reviewee;
  final int rating;
  final String? comment;
  final String? jobTitle;
  final ReviewJobApplicationInfo? jobApplication;
  final DateTime createdAt;

  ReviewDetail({
    required this.id,
    required this.reviewer,
    required this.reviewee,
    required this.rating,
    this.comment,
    this.jobTitle,
    this.jobApplication,
    required this.createdAt,
  });

  factory ReviewDetail.fromJson(Map<String, dynamic> json) {
    return ReviewDetail(
      id: json['id'] as int,
      reviewer: ReviewUserInfo.fromJson(json['reviewer'] as Map<String, dynamic>),
      reviewee: ReviewUserInfo.fromJson(json['reviewee'] as Map<String, dynamic>),
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      jobTitle: json['jobTitle'] as String?,
      jobApplication: json['jobApplication'] != null
          ? ReviewJobApplicationInfo.fromJson(json['jobApplication'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewer': reviewer.toJson(),
      'reviewee': reviewee.toJson(),
      'rating': rating,
      'comment': comment,
      'jobTitle': jobTitle,
      'jobApplication': jobApplication?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get hasComment => comment != null && comment!.isNotEmpty;
  double get ratingAsDouble => rating.toDouble();
  String get ratingText => '$rating / 5';
}

/// Review list item - condensed review for lists
class ReviewListItem {
  final int id;
  final ReviewUserInfo reviewer;
  final ReviewUserInfo reviewee;
  final int rating;
  final String? comment;
  final String? jobTitle;
  final DateTime createdAt;

  ReviewListItem({
    required this.id,
    required this.reviewer,
    required this.reviewee,
    required this.rating,
    this.comment,
    this.jobTitle,
    required this.createdAt,
  });

  factory ReviewListItem.fromJson(Map<String, dynamic> json) {
    return ReviewListItem(
      id: json['id'] as int,
      reviewer: ReviewUserInfo.fromJson(json['reviewer'] as Map<String, dynamic>),
      reviewee: ReviewUserInfo.fromJson(json['reviewee'] as Map<String, dynamic>),
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      jobTitle: json['jobTitle'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewer': reviewer.toJson(),
      'reviewee': reviewee.toJson(),
      'rating': rating,
      'comment': comment,
      'jobTitle': jobTitle,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get hasComment => comment != null && comment!.isNotEmpty;
  double get ratingAsDouble => rating.toDouble();
}

/// Rating summary for a user
class RatingSummary {
  final int userId;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;

  RatingSummary({
    required this.userId,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory RatingSummary.fromJson(Map<String, dynamic> json) {
    final Map<int, int> distribution = {};
    if (json['ratingDistribution'] != null) {
      final dist = json['ratingDistribution'] as Map<String, dynamic>;
      dist.forEach((key, value) {
        distribution[int.parse(key)] = value as int;
      });
    }

    return RatingSummary(
      userId: json['userId'] as int,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      ratingDistribution: distribution,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'ratingDistribution': ratingDistribution.map((k, v) => MapEntry(k.toString(), v)),
    };
  }

  bool get hasReviews => totalReviews > 0;
  String get formattedRating => averageRating.toStringAsFixed(1);
}

/// Review status for an application
class ReviewStatus {
  final int applicationId;
  final bool hasReviewed;
  final int? reviewId;
  final bool canReview;

  ReviewStatus({
    required this.applicationId,
    required this.hasReviewed,
    this.reviewId,
    required this.canReview,
  });

  factory ReviewStatus.fromJson(Map<String, dynamic> json) {
    return ReviewStatus(
      applicationId: json['applicationId'] as int,
      hasReviewed: json['hasReviewed'] as bool? ?? false,
      reviewId: json['reviewId'] as int?,
      canReview: json['canReview'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicationId': applicationId,
      'hasReviewed': hasReviewed,
      'reviewId': reviewId,
      'canReview': canReview,
    };
  }
}
