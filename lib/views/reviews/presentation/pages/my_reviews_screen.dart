// lib/views/reviews/presentation/pages/my_reviews_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import 'package:intl/intl.dart';
import '../../data/models/review.dart';
import '../../data/repositories/review_repository.dart';
import '../../logic/review_cubit.dart';
import '../../logic/review_state.dart';
import '../widgets/rating_display.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReviewCubit(ReviewRepository()),
      child: const _MyReviewsContent(),
    );
  }
}

class _MyReviewsContent extends StatefulWidget {
  const _MyReviewsContent();

  @override
  State<_MyReviewsContent> createState() => _MyReviewsContentState();
}

class _MyReviewsContentState extends State<_MyReviewsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    // Load received reviews by default
    context.read<ReviewCubit>().getMyReceivedReviews();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    if (_tabController.index == 0) {
      context.read<ReviewCubit>().getMyReceivedReviews();
    } else {
      context.read<ReviewCubit>().getMyGivenReviews();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reviews'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentBlue,
          labelColor: AppTheme.accentBlue,
          unselectedLabelColor: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
          tabs: const [
            Tab(text: 'Received'),
            Tab(text: 'Given'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ReceivedReviewsTab(),
          _GivenReviewsTab(),
        ],
      ),
    );
  }
}

class _ReceivedReviewsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewCubit, ReviewState>(
      buildWhen: (prev, current) =>
          current is MyReviewsLoading ||
          current is MyReceivedReviewsLoaded ||
          current is MyReviewsEmpty ||
          current is MyReviewsError,
      builder: (context, state) {
        if (state is MyReviewsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MyReviewsError) {
          return _ErrorView(
            message: state.error,
            onRetry: () => context.read<ReviewCubit>().getMyReceivedReviews(),
          );
        }

        if (state is MyReviewsEmpty && state.type == 'received') {
          return _EmptyView(
            icon: Icons.star_border,
            title: 'No reviews received',
            subtitle: 'Complete jobs to start receiving reviews',
          );
        }

        if (state is MyReceivedReviewsLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ReviewCubit>().getMyReceivedReviews();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.reviews.length,
              itemBuilder: (context, index) {
                return _ReviewCard(
                  review: state.reviews[index],
                  showReviewer: true,
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _GivenReviewsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewCubit, ReviewState>(
      buildWhen: (prev, current) =>
          current is MyReviewsLoading ||
          current is MyGivenReviewsLoaded ||
          current is MyReviewsEmpty ||
          current is MyReviewsError,
      builder: (context, state) {
        if (state is MyReviewsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MyReviewsError) {
          return _ErrorView(
            message: state.error,
            onRetry: () => context.read<ReviewCubit>().getMyGivenReviews(),
          );
        }

        if (state is MyReviewsEmpty && state.type == 'given') {
          return _EmptyView(
            icon: Icons.rate_review_outlined,
            title: 'No reviews given',
            subtitle: 'Review completed jobs to help others',
          );
        }

        if (state is MyGivenReviewsLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ReviewCubit>().getMyGivenReviews();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.reviews.length,
              itemBuilder: (context, index) {
                return _ReviewCard(
                  review: state.reviews[index],
                  showReviewer: false,
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewListItem review;
  final bool showReviewer;

  const _ReviewCard({
    required this.review,
    required this.showReviewer,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = showReviewer ? review.reviewer : review.reviewee;

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
          // User info and rating
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
                backgroundImage: user.profilePictureUrl != null
                    ? NetworkImage(user.profilePictureUrl!)
                    : null,
                child: user.profilePictureUrl == null
                    ? Icon(
                        Icons.person,
                        color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showReviewer ? 'From: ${user.displayName}' : 'To: ${user.displayName}',
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
              RatingDisplay(
                rating: review.ratingAsDouble,
                reviewCount: 1,
                showCount: false,
                size: 16,
              ),
            ],
          ),

          // Job title
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

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentBlue,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyView({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
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
}
