// lib/views/reviews/presentation/widgets/rating_display.dart

import 'package:flutter/material.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';

/// Widget to display a user's rating with stars
class RatingDisplay extends StatelessWidget {
  final double rating; // Average rating (0.0 to 5.0)
  final int reviewCount; // Number of reviews
  final bool showCount; // Whether to show review count
  final double size; // Star size

  const RatingDisplay({
    Key? key,
    required this.rating,
    required this.reviewCount,
    this.showCount = true,
    this.size = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Don't show anything if no reviews
    if (reviewCount == 0) {
      return Text(
        'No reviews yet',
        style: TextStyle(
          color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
          fontSize: size * 0.875,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Star icons
        ...List.generate(5, (index) {
          // Full star, half star, or empty star
          if (rating >= index + 1) {
            return Icon(
              Icons.star,
              color: AppTheme.accentYellow,
              size: size,
            );
          } else if (rating > index && rating < index + 1) {
            return Icon(
              Icons.star_half,
              color: AppTheme.accentYellow,
              size: size,
            );
          } else {
            return Icon(
              Icons.star_border,
              color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
              size: size,
            );
          }
        }),

        const SizedBox(width: 4),

        // Rating value
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
            fontSize: size * 0.875,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Review count
        if (showCount) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
              fontSize: size * 0.75,
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact rating display for cards
class CompactRatingDisplay extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const CompactRatingDisplay({
    Key? key,
    required this.rating,
    required this.reviewCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (reviewCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accentYellow.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            color: AppTheme.accentYellow,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
