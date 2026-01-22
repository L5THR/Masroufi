// lib/views/reviews/presentation/widgets/user_rating_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import '../../data/models/review.dart';
import '../../data/repositories/review_repository.dart';
import '../../logic/review_cubit.dart';
import '../../logic/review_state.dart';
import 'rating_display.dart';

/// A widget that fetches and displays a user's rating summary
/// Use this when you need to show rating for a user by their ID
class UserRatingWidget extends StatelessWidget {
  final int userId;
  final double size;
  final bool showCount;
  final bool compact;
  final VoidCallback? onTap;

  const UserRatingWidget({
    super.key,
    required this.userId,
    this.size = 16,
    this.showCount = true,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReviewCubit(ReviewRepository())..getUserRatingSummary(userId),
      child: _UserRatingContent(
        size: size,
        showCount: showCount,
        compact: compact,
        onTap: onTap,
      ),
    );
  }
}

class _UserRatingContent extends StatelessWidget {
  final double size;
  final bool showCount;
  final bool compact;
  final VoidCallback? onTap;

  const _UserRatingContent({
    required this.size,
    required this.showCount,
    required this.compact,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewCubit, ReviewState>(
      builder: (context, state) {
        if (state is RatingSummaryLoading) {
          return SizedBox(
            height: size,
            width: size * 5,
            child: const Center(
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (state is RatingSummaryLoaded) {
          final summary = state.summary;

          final widget = compact
              ? CompactRatingDisplay(
                  rating: summary.averageRating,
                  reviewCount: summary.totalReviews,
                )
              : RatingDisplay(
                  rating: summary.averageRating,
                  reviewCount: summary.totalReviews,
                  showCount: showCount,
                  size: size,
                );

          if (onTap != null) {
            return GestureDetector(
              onTap: onTap,
              child: widget,
            );
          }
          return widget;
        }

        // Error or initial state - show no reviews
        return compact
            ? const SizedBox.shrink()
            : RatingDisplay(
                rating: 0,
                reviewCount: 0,
                showCount: showCount,
                size: size,
              );
      },
    );
  }
}

/// A card that displays user rating with more details
/// Good for profile pages or detailed views
class UserRatingCard extends StatelessWidget {
  final int userId;
  final String userName;
  final VoidCallback? onViewReviews;

  const UserRatingCard({
    super.key,
    required this.userId,
    required this.userName,
    this.onViewReviews,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReviewCubit(ReviewRepository())..getUserRatingSummary(userId),
      child: _UserRatingCardContent(
        userName: userName,
        onViewReviews: onViewReviews,
      ),
    );
  }
}

class _UserRatingCardContent extends StatelessWidget {
  final String userName;
  final VoidCallback? onViewReviews;

  const _UserRatingCardContent({
    required this.userName,
    this.onViewReviews,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<ReviewCubit, ReviewState>(
      builder: (context, state) {
        if (state is RatingSummaryLoading) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        RatingSummary? summary;
        if (state is RatingSummaryLoaded) {
          summary = state.summary;
        }

        return Container(
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
              // Header
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: AppTheme.accentYellow,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Rating & Reviews',
                    style: TextStyle(
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (summary == null || summary.totalReviews == 0) ...[
                // No reviews
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.star_border,
                        color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No reviews yet',
                        style: TextStyle(
                          color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Rating summary
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Big rating number
                    Column(
                      children: [
                        Text(
                          summary.formattedRating,
                          style: TextStyle(
                            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        RatingDisplay(
                          rating: summary.averageRating,
                          reviewCount: summary.totalReviews,
                          showCount: false,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${summary.totalReviews} review${summary.totalReviews != 1 ? 's' : ''}',
                          style: TextStyle(
                            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    // Rating distribution
                    Expanded(
                      child: Column(
                        children: List.generate(5, (index) {
                          final stars = 5 - index;
                          final count = summary!.ratingDistribution[stars] ?? 0;
                          final percentage = summary.totalReviews > 0
                              ? count / summary.totalReviews
                              : 0.0;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Text(
                                  '$stars',
                                  style: TextStyle(
                                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.star,
                                  color: AppTheme.accentYellow,
                                  size: 12,
                                ),
                                const SizedBox(width: 8),
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
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 24,
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),

                // View all reviews button
                if (onViewReviews != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onViewReviews,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accentBlue,
                        side: const BorderSide(color: AppTheme.accentBlue),
                      ),
                      child: const Text('View All Reviews'),
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Inline rating badge - very compact, good for lists
class UserRatingBadge extends StatelessWidget {
  final int userId;

  const UserRatingBadge({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return UserRatingWidget(
      userId: userId,
      compact: true,
    );
  }
}
