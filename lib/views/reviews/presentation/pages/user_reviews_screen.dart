// lib/views/reviews/presentation/pages/user_reviews_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import 'package:intl/intl.dart';
import '../../data/models/review.dart';
import '../../data/repositories/review_repository.dart';
import '../../logic/review_cubit.dart';
import '../../logic/review_state.dart';
import '../widgets/rating_display.dart';

class UserReviewsScreen extends StatelessWidget {
  final int userId;
  final String userName;

  const UserReviewsScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReviewCubit(ReviewRepository())
        ..getUserRatingSummary(userId)
        ..getUserReviews(userId: userId),
      child: _UserReviewsContent(userName: userName, userId: userId),
    );
  }
}

class _UserReviewsContent extends StatelessWidget {
  final String userName;
  final int userId;

  const _UserReviewsContent({
    required this.userName,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('$userName\'s Reviews'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ReviewCubit>().getUserRatingSummary(userId);
          context.read<ReviewCubit>().getUserReviews(userId: userId);
        },
        child: CustomScrollView(
          slivers: [
            // Rating Summary Header
            SliverToBoxAdapter(
              child: _buildRatingSummaryHeader(context, isDark),
            ),

            // Reviews List
            BlocBuilder<ReviewCubit, ReviewState>(
              buildWhen: (prev, current) =>
                  current is UserReviewsLoading ||
                  current is UserReviewsLoaded ||
                  current is UserReviewsEmpty ||
                  current is UserReviewsError,
              builder: (context, state) {
                if (state is UserReviewsLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is UserReviewsError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.error,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ReviewCubit>().getUserReviews(userId: userId);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is UserReviewsEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_border,
                            size: 64,
                            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No reviews yet',
                            style: TextStyle(
                              color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This user hasn\'t received any reviews',
                            style: TextStyle(
                              color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is UserReviewsLoaded) {
                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final review = state.reviews[index];
                          return _ReviewCard(review: review);
                        },
                        childCount: state.reviews.length,
                      ),
                    ),
                  );
                }

                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSummaryHeader(BuildContext context, bool isDark) {
    return BlocBuilder<ReviewCubit, ReviewState>(
      buildWhen: (prev, current) =>
          current is RatingSummaryLoading ||
          current is RatingSummaryLoaded ||
          current is RatingSummaryError,
      builder: (context, state) {
        if (state is RatingSummaryLoaded) {
          final summary = state.summary;

          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
              ),
            ),
            child: Column(
              children: [
                // Big rating display
                Text(
                  summary.formattedRating,
                  style: TextStyle(
                    color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                RatingDisplay(
                  rating: summary.averageRating,
                  reviewCount: summary.totalReviews,
                  showCount: false,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  'Based on ${summary.totalReviews} review${summary.totalReviews != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),

                // Rating distribution
                ...List.generate(5, (index) {
                  final stars = 5 - index;
                  final count = summary.ratingDistribution[stars] ?? 0;
                  final percentage = summary.totalReviews > 0
                      ? count / summary.totalReviews
                      : 0.0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          child: Text(
                            '$stars',
                            style: TextStyle(
                              color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.star,
                          color: AppTheme.accentYellow,
                          size: 16,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: isDark
                                  ? AppTheme.tertiaryGrey
                                  : AppTheme.lightGrey,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.accentYellow,
                              ),
                              minHeight: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 32,
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        }

        if (state is RatingSummaryLoading) {
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewListItem review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer info and rating
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
                backgroundImage: review.reviewer.profilePictureUrl != null
                    ? NetworkImage(review.reviewer.profilePictureUrl!)
                    : null,
                child: review.reviewer.profilePictureUrl == null
                    ? Icon(
                        Icons.person,
                        color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Name and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewer.displayName,
                      style: TextStyle(
                        color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDate(review.createdAt),
                      style: TextStyle(
                        color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Star rating
              RatingDisplay(
                rating: review.ratingAsDouble,
                reviewCount: 1,
                showCount: false,
                size: 16,
              ),
            ],
          ),

          // Job title if available
          if (review.jobTitle != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.work_outline,
                  size: 14,
                  color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    review.jobTitle!,
                    style: TextStyle(
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          // Comment
          if (review.hasComment) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: TextStyle(
                color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
}
