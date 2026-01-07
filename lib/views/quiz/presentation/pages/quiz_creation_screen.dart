// lib/views/quiz/presentation/pages/quiz_creation_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../logic/quiz_creation_cubit.dart';
import '../../logic/quiz_state.dart';
import '../../data/models/quiz_question.dart';

class QuizCreationScreen extends StatelessWidget {
  final int jobId;

  const QuizCreationScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuizCreationCubit(context.read())..startCreating(),
      child: _QuizCreationView(jobId: jobId),
    );
  }
}

class _QuizCreationView extends StatefulWidget {
  final int jobId;

  const _QuizCreationView({required this.jobId});

  @override
  State<_QuizCreationView> createState() => _QuizCreationViewState();
}

class _QuizCreationViewState extends State<_QuizCreationView> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<QuizCreationCubit, QuizCreationState>(
      listener: (context, state) {
        if (state is QuizCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quiz created successfully!'),
              backgroundColor: AppTheme.accentGreen,
            ),
          );
          Navigator.pop(context, state.quiz);
        } else if (state is QuizCreationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is QuizCreating) {
          return Scaffold(
            appBar: AppBar(title: const Text('Create Quiz')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is! QuizCreationInProgress) {
          return Scaffold(
            appBar: AppBar(title: const Text('Create Quiz')),
            body: const Center(child: Text('Initializing...')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Create Quiz'),
            actions: [
              TextButton(
                onPressed: state.isValid
                    ? () => context.read<QuizCreationCubit>().createQuiz(
                        widget.jobId,
                      )
                    : null,
                child: Text(
                  'Create',
                  style: TextStyle(
                    color: state.isValid
                        ? AppTheme.accentBlue
                        : AppTheme.textGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Quiz Title
              Container(
                padding: const EdgeInsets.all(20),
                color: isDark
                    ? AppTheme.secondaryBlack
                    : AppTheme.secondaryWhite,
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Quiz Title',
                    hintText: 'e.g., Flutter Developer Assessment',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                              color: isDark
                                  ? AppTheme.textGrey
                                  : AppTheme.textDarkGrey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No questions yet',
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.textGrey
                                    : AppTheme.textDarkGrey,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to add a question',
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.textGrey
                                    : AppTheme.textDarkGrey,
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
                  color: isDark
                      ? AppTheme.secondaryBlack
                      : AppTheme.secondaryWhite,
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? AppTheme.tertiaryGrey
                          : AppTheme.lightGrey,
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
        side: BorderSide(
          color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.errorRed,
                  ),
                  onPressed: () {
                    cubit.removeQuestion(widget.questionIndex);
                  },
                  tooltip: 'Delete question',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Question Text
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                labelText: 'Question',
                hintText: 'Enter your question here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
              onChanged: (value) {
                cubit.updateQuestionText(widget.questionIndex, value);
              },
            ),
            const SizedBox(height: 16),

            // Question Type
            Row(
              children: [
                Text(
                  'Type:',
                  style: TextStyle(
                    color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Single Choice'),
                  selected: widget.question.type == QuestionType.SINGLE_CHOICE,
                  onSelected: (selected) {
                    if (selected) {
                      cubit.updateQuestionType(
                        widget.questionIndex,
                        QuestionType.SINGLE_CHOICE,
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Multiple Choice'),
                  selected:
                      widget.question.type == QuestionType.MULTIPLE_CHOICE,
                  onSelected: (selected) {
                    if (selected) {
                      cubit.updateQuestionType(
                        widget.questionIndex,
                        QuestionType.MULTIPLE_CHOICE,
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Options
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

            // Add Option Button
            if (widget.question.options.length < 6)
              TextButton.icon(
                onPressed: () {
                  cubit.addOption(widget.questionIndex);
                },
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
          // Correct Answer Checkbox
          Checkbox(
            value: widget.option.correct,
            onChanged: (value) {
              cubit.toggleOptionCorrect(
                widget.questionIndex,
                widget.optionIndex,
              );
            },
            activeColor: AppTheme.accentGreen,
          ),

          // Option Text Field
          Expanded(
            child: TextField(
              controller: _optionController,
              decoration: InputDecoration(
                hintText: 'Option ${widget.optionIndex + 1}',
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) {
                cubit.updateOptionText(
                  widget.questionIndex,
                  widget.optionIndex,
                  value,
                );
              },
            ),
          ),

          // Delete Option Button
          if (widget.optionIndex >= 2)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                cubit.removeOption(widget.questionIndex, widget.optionIndex);
              },
              tooltip: 'Remove option',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
