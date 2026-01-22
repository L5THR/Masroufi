// lib/views/reviews/presentation/widgets/create_review_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import '../../logic/review_cubit.dart';
import '../../logic/review_state.dart';
import '../../data/repositories/review_repository.dart';

/// Dialog for creating a review for a job application
class CreateReviewDialog extends StatefulWidget {
  final int jobApplicationId;
  final String applicantName;

  const CreateReviewDialog({
    Key? key,
    required this.jobApplicationId,
    required this.applicantName,
  }) : super(key: key);

  @override
  State<CreateReviewDialog> createState() => _CreateReviewDialogState();
}

class _CreateReviewDialogState extends State<CreateReviewDialog> {
  int _rating = 3;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => ReviewCubit(ReviewRepository()),
      child: BlocConsumer<ReviewCubit, ReviewState>(
        listener: (context, state) {
          if (state is ReviewCreated) {
            Navigator.pop(context, state.review);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Review submitted successfully!'),
                backgroundColor: AppTheme.accentGreen,
              ),
            );
          } else if (state is ReviewCreateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ReviewCreating;

          return AlertDialog(
            backgroundColor: isDark
                ? AppTheme.secondaryBlack
                : AppTheme.secondaryWhite,
            title: Text(
              'Review ${widget.applicantName}',
              style: TextStyle(
                color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating Section
                  Text(
                    'Rating',
                    style: TextStyle(
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Star Rating
                  Center(
                    child: Wrap(
                      spacing: 4,
                      alignment: WrapAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: AppTheme.accentYellow,
                            size: 36,
                          ),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          onPressed: isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _rating = index + 1;
                                  });
                                },
                        );
                      }),
                    ),
                  ),

                  Center(
                    child: Text(
                      '$_rating / 5',
                      style: TextStyle(
                        color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Comment Section
                  Text(
                    'Comment (Optional)',
                    style: TextStyle(
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _commentController,
                    enabled: !isLoading,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: 'Share your experience working with ${widget.applicantName}...',
                      hintStyle: TextStyle(
                        color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppTheme.primaryBlack
                          : Colors.white,
                    ),
                    style: TextStyle(
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        context.read<ReviewCubit>().createReview(
                              jobApplicationId: widget.jobApplicationId,
                              rating: _rating,
                              comment: _commentController.text.trim().isEmpty
                                  ? null
                                  : _commentController.text.trim(),
                            );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentBlue,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Review'),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Helper function to show the review dialog
Future<void> showCreateReviewDialog({
  required BuildContext context,
  required int jobApplicationId,
  required String applicantName,
}) async {
  return showDialog(
    context: context,
    builder: (context) => CreateReviewDialog(
      jobApplicationId: jobApplicationId,
      applicantName: applicantName,
    ),
  );
}
