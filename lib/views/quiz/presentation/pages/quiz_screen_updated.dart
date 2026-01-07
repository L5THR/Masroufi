// lib/views/quiz/presentation/pages/quiz_screen_updated.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../logic/quiz_cubit.dart';
import '../../logic/quiz_state.dart';
import '../../data/models/quiz_question.dart';

class QuizScreenUpdated extends StatelessWidget {
  final int jobId;

  const QuizScreenUpdated({
    super.key,
    required this.jobId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuizCubit(context.read())..loadQuiz(jobId),
      child: const _QuizView(),
    );
  }
}

class _QuizView extends StatelessWidget {
  const _QuizView();

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<QuizCubit, QuizState>(
      listener: (context, state) {
        if (state is QuizSubmitted) {
          final attempt = state.attempt;
          final passed = attempt.passed;

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              backgroundColor: isDark
                  ? AppTheme.secondaryBlack
                  : AppTheme.secondaryWhite,
              title: Text(
                passed ? '🎉 Congratulations!' : '📝 Quiz Completed',
                style: TextStyle(
                  color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Your Score: ${attempt.scorePercentage}%',
                    style: TextStyle(
                      color: passed ? AppTheme.accentGreen : AppTheme.errorRed,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Score: ${attempt.score.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    passed
                        ? 'You passed! Your application has been submitted.'
                        : 'You need 70% to pass. Please try again later.',
                    style: TextStyle(
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                    if (passed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Application submitted successfully!'),
                          backgroundColor: AppTheme.accentGreen,
                        ),
                      );
                    }
                  },
                  child: Text(passed ? 'Continue' : 'Close'),
                ),
              ],
            ),
          );
        } else if (state is QuizFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is QuizLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Skill Assessment')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is QuizSubmitting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Skill Assessment')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Submitting your quiz...'),
                ],
              ),
            ),
          );
        }

        if (state is! QuizLoaded) {
          return Scaffold(
            appBar: AppBar(title: const Text('Skill Assessment')),
            body: const Center(child: Text('Unable to load quiz')),
          );
        }

        final quiz = state.quiz;
        final currentQuestion = quiz.questions[state.currentQuestionIndex];
        final selectedOptions = state.selectedAnswers[currentQuestion.id] ?? [];
        final isMultipleChoice = currentQuestion.type == QuestionType.MULTIPLE_CHOICE;

        return WillPopScope(
          onWillPop: () async {
            final shouldPop = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                backgroundColor: isDark
                    ? AppTheme.secondaryBlack
                    : AppTheme.secondaryWhite,
                title: Text(
                  'Exit Quiz?',
                  style: TextStyle(
                    color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                  ),
                ),
                content: Text(
                  'Your progress will be lost. Are you sure you want to exit?',
                  style: TextStyle(
                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text(
                      'Exit',
                      style: TextStyle(color: AppTheme.errorRed),
                    ),
                  ),
                ],
              ),
            );
            return shouldPop ?? false;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(quiz.title),
              actions: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _formatTime(state.timeRemaining),
                      style: TextStyle(
                        color: state.timeRemaining < 60
                            ? AppTheme.errorRed
                            : (isDark ? AppTheme.textWhite : AppTheme.textBlack),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                // Progress
                Container(
                  padding: const EdgeInsets.all(20),
                  color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Question ${state.currentQuestionIndex + 1}/${quiz.questions.length}',
                            style: TextStyle(
                              color: isDark
                                  ? AppTheme.textWhite
                                  : AppTheme.textBlack,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${((state.currentQuestionIndex + 1) / quiz.questions.length * 100).toInt()}%',
                            style: const TextStyle(
                              color: AppTheme.accentBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: (state.currentQuestionIndex + 1) / quiz.questions.length,
                        backgroundColor: isDark
                            ? AppTheme.tertiaryGrey
                            : AppTheme.lightGrey,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.accentBlue,
                        ),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                // Question
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isMultipleChoice)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.accentBlue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Multiple Choice - Select all that apply',
                              style: TextStyle(
                                color: AppTheme.accentBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Text(
                          currentQuestion.text,
                          style: TextStyle(
                            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ...currentQuestion.options.map(
                          (option) => _AnswerOption(
                            text: option.text,
                            isSelected: selectedOptions.contains(option.id),
                            isMultipleChoice: isMultipleChoice,
                            onTap: () {
                              context.read<QuizCubit>().selectAnswer(
                                currentQuestion.id,
                                option.id,
                                isMultipleChoice: isMultipleChoice,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Navigation
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.secondaryBlack
                        : AppTheme.secondaryWhite,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        if (state.currentQuestionIndex > 0)
                          Expanded(
                            child: CustomButton(
                              text: 'Previous',
                              onPressed: () {
                                context.read<QuizCubit>().previousQuestion();
                              },
                              isOutlined: true,
                            ),
                          ),
                        if (state.currentQuestionIndex > 0) const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: state.isLastQuestion ? 'Submit' : 'Next',
                            onPressed: !state.hasAnsweredCurrentQuestion
                                ? () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please select at least one answer'),
                                        backgroundColor: AppTheme.errorRed,
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                : () {
                                    if (state.isLastQuestion) {
                                      context.read<QuizCubit>().submitQuiz();
                                    } else {
                                      context.read<QuizCubit>().nextQuestion();
                                    }
                                  },
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
      },
    );
  }
}

class _AnswerOption extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isMultipleChoice;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.text,
    required this.isSelected,
    required this.isMultipleChoice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentBlue.withValues(alpha: 0.2)
              : (isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentBlue
                : (isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: isMultipleChoice ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: isMultipleChoice ? BorderRadius.circular(4) : null,
                color: isSelected ? AppTheme.accentBlue : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.accentBlue
                      : (isDark ? AppTheme.textGrey : AppTheme.textDarkGrey),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: AppTheme.textWhite, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected
                      ? (isDark ? AppTheme.textWhite : AppTheme.textBlack)
                      : (isDark ? AppTheme.textGrey : AppTheme.textDarkGrey),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
