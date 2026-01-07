// lib/views/quiz/logic/quiz_cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/quiz_repository.dart';
import '../data/models/quiz.dart';
import 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  final QuizRepository _repository;
  Timer? _timer;

  QuizCubit(this._repository) : super(QuizInitial());

  /// Load quiz for a specific job
  Future<void> loadQuiz(int jobId) async {
    emit(QuizLoading());
    try {
      final quiz = await _repository.getQuizForJob(jobId);

      // Start with 30 minutes (1800 seconds) or calculate based on quiz length
      final timeLimit = _calculateTimeLimit(quiz);

      emit(QuizLoaded(
        quiz: quiz,
        currentQuestionIndex: 0,
        selectedAnswers: {},
        timeRemaining: timeLimit,
      ));

      _startTimer();
    } catch (e) {
      emit(QuizFailure(error: e.toString()));
    }
  }

  /// Calculate time limit based on number of questions
  /// 2 minutes per question as a reasonable time
  int _calculateTimeLimit(Quiz quiz) {
    return quiz.questions.length * 120; // 2 minutes per question in seconds
  }

  /// Start countdown timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentState = state;
      if (currentState is QuizLoaded) {
        final newTime = currentState.timeRemaining - 1;
        if (newTime <= 0) {
          _timer?.cancel();
          // Auto-submit when time runs out
          submitQuiz();
        } else {
          emit(currentState.copyWith(timeRemaining: newTime));
        }
      }
    });
  }

  /// Select an answer for the current question
  void selectAnswer(int questionId, int optionId, {bool isMultipleChoice = false}) {
    final currentState = state;
    if (currentState is! QuizLoaded) return;

    final Map<int, List<int>> newAnswers = Map.from(currentState.selectedAnswers);

    if (isMultipleChoice) {
      // For multiple choice, toggle the option
      if (newAnswers.containsKey(questionId)) {
        final currentOptions = List<int>.from(newAnswers[questionId]!);
        if (currentOptions.contains(optionId)) {
          currentOptions.remove(optionId);
        } else {
          currentOptions.add(optionId);
        }
        newAnswers[questionId] = currentOptions;
      } else {
        newAnswers[questionId] = [optionId];
      }
    } else {
      // For single choice, replace with new selection
      newAnswers[questionId] = [optionId];
    }

    emit(currentState.copyWith(selectedAnswers: newAnswers));
  }

  /// Go to next question
  void nextQuestion() {
    final currentState = state;
    if (currentState is! QuizLoaded) return;

    if (!currentState.isLastQuestion) {
      emit(currentState.copyWith(
        currentQuestionIndex: currentState.currentQuestionIndex + 1,
      ));
    }
  }

  /// Go to previous question
  void previousQuestion() {
    final currentState = state;
    if (currentState is! QuizLoaded) return;

    if (currentState.currentQuestionIndex > 0) {
      emit(currentState.copyWith(
        currentQuestionIndex: currentState.currentQuestionIndex - 1,
      ));
    }
  }

  /// Submit the quiz
  Future<void> submitQuiz() async {
    final currentState = state;
    if (currentState is! QuizLoaded) return;

    _timer?.cancel();
    emit(QuizSubmitting());

    try {
      // Flatten all selected option IDs into a single list
      final List<int> allSelectedOptions = [];
      currentState.selectedAnswers.forEach((questionId, optionIds) {
        allSelectedOptions.addAll(optionIds);
      });

      final attempt = await _repository.submitQuiz(
        quizId: currentState.quiz.id,
        selectedOptionIds: allSelectedOptions,
      );

      emit(QuizSubmitted(attempt: attempt));
    } catch (e) {
      emit(QuizFailure(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
