// lib/views/quiz/logic/quiz_state.dart

import 'package:equatable/equatable.dart';
import '../data/models/quiz.dart';
import '../data/models/quiz_attempt.dart';

// ==================== QUIZ TAKING (Job Seeker) ====================

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizLoaded extends QuizState {
  final Quiz quiz;
  final int currentQuestionIndex;
  final Map<int, List<int>> selectedAnswers; // questionId -> list of optionIds
  final int timeRemaining; // seconds

  const QuizLoaded({
    required this.quiz,
    this.currentQuestionIndex = 0,
    this.selectedAnswers = const {},
    required this.timeRemaining,
  });

  @override
  List<Object?> get props => [
        quiz,
        currentQuestionIndex,
        selectedAnswers,
        timeRemaining,
      ];

  QuizLoaded copyWith({
    Quiz? quiz,
    int? currentQuestionIndex,
    Map<int, List<int>>? selectedAnswers,
    int? timeRemaining,
  }) {
    return QuizLoaded(
      quiz: quiz ?? this.quiz,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      timeRemaining: timeRemaining ?? this.timeRemaining,
    );
  }

  bool get isLastQuestion => currentQuestionIndex >= quiz.questions.length - 1;
  bool get hasAnsweredCurrentQuestion {
    final currentQuestion = quiz.questions[currentQuestionIndex];
    return selectedAnswers.containsKey(currentQuestion.id) &&
        selectedAnswers[currentQuestion.id]!.isNotEmpty;
  }
}

class QuizSubmitting extends QuizState {}

class QuizSubmitted extends QuizState {
  final QuizAttempt attempt;

  const QuizSubmitted({required this.attempt});

  @override
  List<Object?> get props => [attempt];
}

class QuizFailure extends QuizState {
  final String error;

  const QuizFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== QUIZ CREATION (Recruiter) ====================

abstract class QuizCreationState extends Equatable {
  const QuizCreationState();

  @override
  List<Object?> get props => [];
}

class QuizCreationInitial extends QuizCreationState {}

class QuizCreationInProgress extends QuizCreationState {
  final String title;
  final List<QuestionDraft> questions;

  const QuizCreationInProgress({
    this.title = '',
    this.questions = const [],
  });

  @override
  List<Object?> get props => [title, questions];

  QuizCreationInProgress copyWith({
    String? title,
    List<QuestionDraft>? questions,
  }) {
    return QuizCreationInProgress(
      title: title ?? this.title,
      questions: questions ?? this.questions,
    );
  }

  bool get isValid {
    return title.isNotEmpty &&
        questions.isNotEmpty &&
        questions.every((q) => q.isValid);
  }
}

class QuizCreating extends QuizCreationState {}

class QuizCreated extends QuizCreationState {
  final Quiz quiz;

  const QuizCreated({required this.quiz});

  @override
  List<Object?> get props => [quiz];
}

class QuizCreationFailure extends QuizCreationState {
  final String error;

  const QuizCreationFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== HELPER MODELS ====================

class QuestionDraft extends Equatable {
  final String text;
  final QuestionType type;
  final List<OptionDraft> options;

  const QuestionDraft({
    this.text = '',
    this.type = QuestionType.SINGLE_CHOICE,
    this.options = const [],
  });

  @override
  List<Object?> get props => [text, type, options];

  QuestionDraft copyWith({
    String? text,
    QuestionType? type,
    List<OptionDraft>? options,
  }) {
    return QuestionDraft(
      text: text ?? this.text,
      type: type ?? this.type,
      options: options ?? this.options,
    );
  }

  bool get isValid {
    return text.isNotEmpty &&
        options.length >= 2 &&
        options.any((o) => o.correct) &&
        options.every((o) => o.text.isNotEmpty);
  }

  QuestionDto toDto() {
    return QuestionDto(
      text: text,
      type: type,
      options: options.map((o) => o.toDto()).toList(),
    );
  }
}

class OptionDraft extends Equatable {
  final String text;
  final bool correct;

  const OptionDraft({
    this.text = '',
    this.correct = false,
  });

  @override
  List<Object?> get props => [text, correct];

  OptionDraft copyWith({
    String? text,
    bool? correct,
  }) {
    return OptionDraft(
      text: text ?? this.text,
      correct: correct ?? this.correct,
    );
  }

  OptionDto toDto() {
    return OptionDto(
      text: text,
      correct: correct,
    );
  }
}
