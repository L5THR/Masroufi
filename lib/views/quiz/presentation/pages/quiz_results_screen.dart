// lib/views/quiz/presentation/pages/quiz_results_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import 'package:intl/intl.dart';
import '../../../widgets/custom_button.dart';
import '../../data/models/quiz_attempt.dart';

class QuizResultsScreen extends StatelessWidget {
  final QuizAttempt attempt;

  const QuizResultsScreen({
    super.key,
    required this.attempt,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final passed = attempt.passed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Result Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: passed
                    ? AppTheme.accentGreen.withValues(alpha: 0.1)
                    : AppTheme.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: passed ? AppTheme.accentGreen : AppTheme.errorRed,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    passed ? Icons.check_circle : Icons.cancel,
                    color: passed ? AppTheme.accentGreen : AppTheme.errorRed,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    passed ? 'Passed!' : 'Not Passed',
                    style: TextStyle(
                      color: passed ? AppTheme.accentGreen : AppTheme.errorRed,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Score',
                    style: TextStyle(
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${attempt.scorePercentage}%',
                    style: TextStyle(
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Score: ${attempt.score.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Details Section
            _SectionHeader(
              title: 'Quiz Details',
              icon: Icons.info_outline,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _DetailItem(
              label: 'Quiz',
              value: attempt.quiz?.title ?? 'N/A',
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _DetailItem(
              label: 'Submitted',
              value: DateFormat('MMM dd, yyyy • hh:mm a').format(attempt.submittedAt),
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _DetailItem(
              label: 'Status',
              value: passed ? 'Passed (≥70%)' : 'Failed (<70%)',
              isDark: isDark,
              valueColor: passed ? AppTheme.accentGreen : AppTheme.errorRed,
            ),

            if (attempt.quiz != null && attempt.quiz!.questions.isNotEmpty) ...[
              const SizedBox(height: 32),
              _SectionHeader(
                title: 'Questions Review',
                icon: Icons.quiz,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              Text(
                'Total Questions: ${attempt.quiz!.questions.length}',
                style: TextStyle(
                  color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(
                attempt.quiz!.questions.length,
                (index) => _QuestionReviewCard(
                  questionNumber: index + 1,
                  question: attempt.quiz!.questions[index],
                  isDark: isDark,
                ),
              ),
            ],

            const SizedBox(height: 32),
            CustomButton(
              text: 'Close',
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.accentBlue,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
              fontSize: 14,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? (isDark ? AppTheme.textWhite : AppTheme.textBlack),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionReviewCard extends StatelessWidget {
  final int questionNumber;
  final dynamic question;
  final bool isDark;

  const _QuestionReviewCard({
    required this.questionNumber,
    required this.question,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final correctOptions = (question.options as List)
        .where((opt) => opt.correct == true)
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Q$questionNumber',
                    style: const TextStyle(
                      color: AppTheme.accentBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.text ?? 'Question text not available',
                    style: TextStyle(
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Correct Answer${correctOptions.length > 1 ? 's' : ''}:',
              style: TextStyle(
                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...correctOptions.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.accentGreen,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        option.text ?? '',
                        style: TextStyle(
                          color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
