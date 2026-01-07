// lib/views/quiz/logic/quiz_creation_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/quiz_repository.dart';
import '../data/models/quiz_question.dart';
import 'quiz_state.dart';

class QuizCreationCubit extends Cubit<QuizCreationState> {
  final QuizRepository _repository;

  QuizCreationCubit(this._repository) : super(QuizCreationInitial());

  /// Initialize quiz creation
  void startCreating() {
    emit(const QuizCreationInProgress(
      title: '',
      questions: [],
    ));
  }

  /// Update quiz title
  void updateTitle(String title) {
    final currentState = state;
    if (currentState is QuizCreationInProgress) {
      emit(currentState.copyWith(title: title));
    }
  }

  /// Add a new question
  void addQuestion() {
    final currentState = state;
    if (currentState is QuizCreationInProgress) {
      final newQuestions = List<QuestionDraft>.from(currentState.questions);
      newQuestions.add(const QuestionDraft(
        text: '',
        type: QuestionType.SINGLE_CHOICE,
        options: [
          OptionDraft(text: '', correct: false),
          OptionDraft(text: '', correct: false),
        ],
      ));
      emit(currentState.copyWith(questions: newQuestions));
    }
  }

  /// Update a question
  void updateQuestion(int index, QuestionDraft question) {
    final currentState = state;
    if (currentState is QuizCreationInProgress) {
      final newQuestions = List<QuestionDraft>.from(currentState.questions);
      if (index >= 0 && index < newQuestions.length) {
        newQuestions[index] = question;
        emit(currentState.copyWith(questions: newQuestions));
      }
    }
  }

  /// Remove a question
  void removeQuestion(int index) {
    final currentState = state;
    if (currentState is QuizCreationInProgress) {
      final newQuestions = List<QuestionDraft>.from(currentState.questions);
      if (index >= 0 && index < newQuestions.length) {
        newQuestions.removeAt(index);
        emit(currentState.copyWith(questions: newQuestions));
      }
    }
  }

  /// Update question text
  void updateQuestionText(int questionIndex, String text) {
    final currentState = state;
    if (currentState is QuizCreationInProgress) {
      final question = currentState.questions[questionIndex];
      updateQuestion(questionIndex, question.copyWith(text: text));
    }
  }

  /// Update question type
  void updateQuestionType(int questionIndex, QuestionType type) {
    final currentState = state;
    if (currentState is QuizCreationInProgress) {
      final question = currentState.questions[questionIndex];
      updateQuestion(questionIndex, question.copyWith(type: type));
    }
  }

  /// Add option to a question
  void addOption(int questionIndex) {
    final currentState = state;
    if (currentState is QuizCreationInProgress) {
      final question = currentState.questions[questionIndex];
      final newOptions = List<OptionDraft>.from(question.options);
      newOptions.add(const OptionDraft(text: '', correct: false));
      updateQuestion(questionIndex, question.copyWith(options: newOptions));
    }
  }

  /// Update an option
  void updateOption(int questionIndex, int optionIndex, OptionDraft option) {
    final currentState = state;
    if (currentState is QuizCreationInProgress) {
      final question = currentState.questions[questionIndex];
      final newOptions = List<OptionDraft>.from(question.options);
      if (optionIndex >= 0 && optionIndex < newOptions.length) {
        newOptions[optionIndex] = option;
        updateQuestion(questionIndex, question.copyWith(options: newOptions));
      }
    }
  }

  /// Remove an option
  void removeOption(int questionIndex, int optionIndex) {
    final currentState = state;
    if (currentState is QuizCreationInProgress) {
      final question = currentState.questions[questionIndex];
      final newOptions = List<OptionDraft>.from(question.options);
      if (optionIndex >= 0 && optionIndex < newOptions.length && newOptions.length > 2) {
        newOptions.removeAt(optionIndex);
        updateQuestion(questionIndex, question.copyWith(options: newOptions));
      }
    }
  }

  /// Update option text
  void updateOptionText(int questionIndex, int optionIndex, String text) {
    final currentState = state;
    if (currentState is QuizCreationInProgress) {
      final question = currentState.questions[questionIndex];
      final option = question.options[optionIndex];
      updateOption(questionIndex, optionIndex, option.copyWith(text: text));
    }
  }

  /// Toggle option as correct answer
  void toggleOptionCorrect(int questionIndex, int optionIndex) {
    final currentState = state;
    if (currentState is QuizCreationInProgress) {
      final question = currentState.questions[questionIndex];
      final option = question.options[optionIndex];

      // For single choice, uncheck all other options
      if (question.type == QuestionType.SINGLE_CHOICE) {
        final newOptions = question.options.asMap().entries.map((entry) {
          final idx = entry.key;
          final opt = entry.value;
          return opt.copyWith(correct: idx == optionIndex);
        }).toList();
        updateQuestion(questionIndex, question.copyWith(options: newOptions));
      } else {
        // For multiple choice, just toggle this option
        updateOption(questionIndex, optionIndex, option.copyWith(correct: !option.correct));
      }
    }
  }

  /// Create the quiz
  Future<void> createQuiz(int jobId) async {
    final currentState = state;
    if (currentState is! QuizCreationInProgress) return;

    if (!currentState.isValid) {
      emit(const QuizCreationFailure(
          error: 'Please complete all fields and mark correct answers'));
      emit(currentState); // Return to current state
      return;
    }

    emit(QuizCreating());

    try {
      final questionDtos = currentState.questions.map((q) => q.toDto()).toList();

      final quiz = await _repository.createQuiz(
        jobId: jobId,
        title: currentState.title,
        questions: questionDtos,
      );

      emit(QuizCreated(quiz: quiz));
    } catch (e) {
      final errorMessage = e.toString();
      String userFriendlyError;

      // Check for duplicate quiz error
      if (errorMessage.contains('duplicate key') ||
          errorMessage.contains('quizzes_job_id_key') ||
          errorMessage.contains('already exists')) {
        userFriendlyError = 'This job already has a quiz. Each job can only have one quiz. Please delete the existing quiz first or contact support.';
      } else if (errorMessage.contains('500')) {
        userFriendlyError = 'Server error occurred. Please try again later.';
      } else if (errorMessage.contains('401')) {
        userFriendlyError = 'You are not authorized to create quizzes.';
      } else if (errorMessage.contains('400')) {
        userFriendlyError = 'Invalid quiz data. Please check all fields.';
      } else {
        userFriendlyError = 'Failed to create quiz: ${errorMessage.length > 100 ? errorMessage.substring(0, 100) + "..." : errorMessage}';
      }

      emit(QuizCreationFailure(error: userFriendlyError));
      emit(currentState); // Return to editing state
    }
  }
}
