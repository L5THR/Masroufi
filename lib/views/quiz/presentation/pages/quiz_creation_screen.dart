// lib/views/quiz/presentation/pages/quiz_creation_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../jobs/data/models/pending_job_data.dart';
import '../../logic/quiz_creation_cubit.dart';
import '../../logic/quiz_state.dart';
import '../../data/models/quiz.dart';
import '../../data/models/quiz_question.dart';

/// Screen for creating or editing quizzes
///
/// Two modes:
/// 1. NEW JOB + QUIZ: Pass [pendingJobData] - creates job first, then quiz
/// 2. EDIT EXISTING QUIZ: Pass [jobId] and optionally [existingQuiz]
class QuizCreationScreen extends StatelessWidget {
  final int? jobId; // For editing existing job's quiz
  final Quiz? existingQuiz; // For edit mode
  final PendingJobData? pendingJobData; // For new job + quiz flow

  const QuizCreationScreen({
    super.key,
    this.jobId,
    this.existingQuiz,
    this.pendingJobData,
  }) : assert(jobId != null || pendingJobData != null,
         'Either jobId or pendingJobData must be provided');

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = QuizCreationCubit(
          context.read(),
          jobRepository: context.read(),
          fileUploadRepository: context.read(),
        );
        if (existingQuiz != null) {
          cubit.loadQuizForEditing(existingQuiz!);
        } else if (pendingJobData != null) {
          // New job + quiz flow - start fresh quiz creation
          cubit.startCreatingWithPendingJob(pendingJobData!);
        } else if (jobId != null) {
          // Editing existing job's quiz
          cubit.startCreatingForJob(jobId!);
        }
        return cubit;
      },
      child: _QuizCreationView(
        jobId: jobId,
        existingQuiz: existingQuiz,
        pendingJobData: pendingJobData,
      ),
    );
  }
}

class _QuizCreationView extends StatefulWidget {
  final int? jobId;
  final Quiz? existingQuiz;
  final PendingJobData? pendingJobData;

  const _QuizCreationView({
    this.jobId,
    this.existingQuiz,
    this.pendingJobData,
  });

  @override
  State<_QuizCreationView> createState() => _QuizCreationViewState();
}

class _QuizCreationViewState extends State<_QuizCreationView> {
  final _titleController = TextEditingController();
  bool _titleInitialized = false;

  bool get isNewJobFlow => widget.pendingJobData != null;

  @override
  void initState() {
    super.initState();
    if (widget.existingQuiz != null) {
      _titleController.text = widget.existingQuiz!.title;
      _titleInitialized = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(BuildContext context, int quizId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
        title: Text(
          'Delete Quiz',
          style: TextStyle(color: isDark ? AppTheme.textWhite : AppTheme.textBlack),
        ),
        content: Text(
          'Are you sure you want to delete this quiz? This action cannot be undone.',
          style: TextStyle(color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<QuizCreationCubit>().deleteQuiz(quizId);
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<QuizCreationCubit, QuizCreationState>(
      listener: (context, state) {
        if (state is JobAndQuizCreated) {
          // New flow: both job and quiz created successfully
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Job and quiz created successfully!'),
              backgroundColor: AppTheme.accentGreen,
            ),
          );
          Navigator.pop(context, state.quiz);
        } else if (state is QuizCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.wasUpdate ? 'Quiz updated successfully!' : 'Quiz created successfully!',
              ),
              backgroundColor: AppTheme.accentGreen,
            ),
          );
          Navigator.pop(context, state.quiz);
        } else if (state is QuizDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quiz deleted successfully!'),
              backgroundColor: AppTheme.accentGreen,
            ),
          );
          Navigator.pop(context, true);
        } else if (state is QuizCreationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        } else if (state is QuizCreationInProgress) {
          if (state.isEditMode && !_titleInitialized) {
            _titleController.text = state.title;
            _titleInitialized = true;
          }
        }
      },
      builder: (context, state) {
        final isEditMode = state is QuizCreationInProgress && state.isEditMode;
        final editingQuizId = state is QuizCreationInProgress ? state.editingQuizId : null;

        if (state is QuizCreating) {
          return Scaffold(
            appBar: AppBar(title: Text(isNewJobFlow ? 'Creating Job & Quiz...' : 'Loading...')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    isNewJobFlow ? 'Creating your job and quiz...' : 'Please wait...',
                    style: TextStyle(color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! QuizCreationInProgress) {
          return Scaffold(
            appBar: AppBar(title: const Text('Quiz')),
            body: const Center(child: Text('Initializing...')),
          );
        }

        final buttonText = isNewJobFlow
            ? 'Create Job & Quiz'
            : (isEditMode ? 'Update' : 'Create');

        return Scaffold(
          appBar: AppBar(
            title: Text(isEditMode ? 'Edit Quiz' : 'Create Quiz'),
            actions: [
              if (isEditMode && editingQuizId != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppTheme.errorRed,
                  onPressed: () => _showDeleteConfirmation(context, editingQuizId),
                  tooltip: 'Delete Quiz',
                ),
              TextButton(
                onPressed: state.isValid
                    ? () {
                        if (isNewJobFlow) {
                          // Create job first, then quiz
                          context.read<QuizCreationCubit>().createJobAndQuiz();
                        } else if (isEditMode && editingQuizId != null) {
                          context.read<QuizCreationCubit>().updateQuiz(editingQuizId);
                        } else if (widget.jobId != null) {
                          context.read<QuizCreationCubit>().createQuiz(widget.jobId!);
                        }
                      }
                    : null,
                child: Text(
                  buttonText,
                  style: TextStyle(
                    color: state.isValid ? AppTheme.accentBlue : AppTheme.textGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Job Summary (only for new job flow)
              if (isNewJobFlow && widget.pendingJobData != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.work_outline, color: AppTheme.accentBlue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Job to be created:',
                              style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
                            ),
                            Text(
                              widget.pendingJobData!.title,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Quiz Title
              Container(
                padding: const EdgeInsets.all(20),
                color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Quiz Title',
                    hintText: 'e.g., Flutter Developer Assessment',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (value) {
                    context.read<QuizCreationCubit>().updateTitle(value);
                  },
                ),
              ),

              // Questions List
              Expanded(
                child: state.questions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.quiz_outlined,
                              size: 64,
                              color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No questions yet',
                              style: TextStyle(
                                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to add a question',
                              style: TextStyle(
                                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.questions.length,
                        itemBuilder: (context, index) {
                          return _QuestionCard(
                            questionIndex: index,
                            question: state.questions[index],
                          );
                        },
                      ),
              ),

              // Add Question Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: CustomButton(
                    text: '+ Add Question',
                    onPressed: () {
                      context.read<QuizCreationCubit>().addQuestion();
                    },
                    isOutlined: true,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuestionCard extends StatefulWidget {
  final int questionIndex;
  final QuestionDraft question;

  const _QuestionCard({required this.questionIndex, required this.question});

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  late TextEditingController _questionController;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question.text);
  }

  @override
  void didUpdateWidget(_QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.text != widget.question.text) {
      _questionController.text = widget.question.text;
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cubit = context.read<QuizCreationCubit>();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Q${widget.questionIndex + 1}',
                    style: const TextStyle(
                      color: AppTheme.accentBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
                  onPressed: () => cubit.removeQuestion(widget.questionIndex),
                  tooltip: 'Delete question',
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                labelText: 'Question',
                hintText: 'Enter your question here',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
              onChanged: (value) => cubit.updateQuestionText(widget.questionIndex, value),
            ),
            const SizedBox(height: 16),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text(
                  'Type:',
                  style: TextStyle(
                    color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ChoiceChip(
                  label: const Text('Single Choice'),
                  selected: widget.question.type == QuestionType.SINGLE_CHOICE,
                  onSelected: (selected) {
                    if (selected) {
                      cubit.updateQuestionType(widget.questionIndex, QuestionType.SINGLE_CHOICE);
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Multiple Choice'),
                  selected: widget.question.type == QuestionType.MULTIPLE_CHOICE,
                  onSelected: (selected) {
                    if (selected) {
                      cubit.updateQuestionType(widget.questionIndex, QuestionType.MULTIPLE_CHOICE);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Options:',
              style: TextStyle(
                color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(
              widget.question.options.length,
              (optionIndex) => _OptionField(
                questionIndex: widget.questionIndex,
                optionIndex: optionIndex,
                option: widget.question.options[optionIndex],
                questionType: widget.question.type,
              ),
            ),
            if (widget.question.options.length < 6)
              TextButton.icon(
                onPressed: () => cubit.addOption(widget.questionIndex),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add Option'),
              ),
          ],
        ),
      ),
    );
  }
}

class _OptionField extends StatefulWidget {
  final int questionIndex;
  final int optionIndex;
  final OptionDraft option;
  final QuestionType questionType;

  const _OptionField({
    required this.questionIndex,
    required this.optionIndex,
    required this.option,
    required this.questionType,
  });

  @override
  State<_OptionField> createState() => _OptionFieldState();
}

class _OptionFieldState extends State<_OptionField> {
  late TextEditingController _optionController;

  @override
  void initState() {
    super.initState();
    _optionController = TextEditingController(text: widget.option.text);
  }

  @override
  void didUpdateWidget(_OptionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.option.text != widget.option.text) {
      _optionController.text = widget.option.text;
    }
  }

  @override
  void dispose() {
    _optionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cubit = context.read<QuizCreationCubit>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.option.correct
            ? AppTheme.accentGreen.withValues(alpha: 0.1)
            : (isDark ? AppTheme.primaryBlack : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.option.correct
              ? AppTheme.accentGreen
              : (isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey),
          width: widget.option.correct ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: widget.option.correct,
            onChanged: (value) {
              cubit.toggleOptionCorrect(widget.questionIndex, widget.optionIndex);
            },
            activeColor: AppTheme.accentGreen,
          ),
          Expanded(
            child: TextField(
              controller: _optionController,
              decoration: InputDecoration(
                hintText: 'Option ${widget.optionIndex + 1}',
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) {
                cubit.updateOptionText(widget.questionIndex, widget.optionIndex, value);
              },
            ),
          ),
          if (widget.optionIndex >= 2)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => cubit.removeOption(widget.questionIndex, widget.optionIndex),
              tooltip: 'Remove option',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
