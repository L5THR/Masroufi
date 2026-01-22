// lib/views/quiz/logic/quiz_creation_cubit.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/core/network/file_upload_repository.dart';
import '../../jobs/data/models/pending_job_data.dart';
import '../../jobs/data/repositories/job_repository.dart';
import '../data/repositories/quiz_repository.dart';
import '../data/models/quiz.dart';
import 'quiz_state.dart';

class QuizCreationCubit extends Cubit<QuizCreationState> {
  final QuizRepository _quizRepository;
  final JobRepository? _jobRepository;
  final FileUploadRepository? _fileUploadRepository;

  // Store pending job data for the new flow
  PendingJobData? _pendingJobData;

  QuizCreationCubit(
    this._quizRepository, {
    JobRepository? jobRepository,
    FileUploadRepository? fileUploadRepository,
  })  : _jobRepository = jobRepository,
        _fileUploadRepository = fileUploadRepository,
        super(QuizCreationInitial());

  /// Initialize quiz creation (simple mode, no pending job)
  void startCreating() {
    emit(const QuizCreationInProgress(
      title: '',
      questions: [],
    ));
  }

  /// Initialize quiz creation with pending job data (new flow)
  void startCreatingWithPendingJob(PendingJobData pendingJobData) {
    _pendingJobData = pendingJobData;
    emit(const QuizCreationInProgress(
      title: '',
      questions: [],
    ));
  }

  /// Initialize quiz creation, checking if job already has a quiz
  Future<void> startCreatingForJob(int jobId) async {
    emit(QuizCreating());

    try {
      final existingQuiz = await _quizRepository.getQuizForJob(jobId);
      loadQuizForEditing(existingQuiz);
    } catch (e) {
      // No existing quiz found or error - start fresh creation
      emit(const QuizCreationInProgress(
        title: '',
        questions: [],
      ));
    }
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

      if (question.type == QuestionType.SINGLE_CHOICE) {
        final newOptions = question.options.asMap().entries.map((entry) {
          final idx = entry.key;
          final opt = entry.value;
          return opt.copyWith(correct: idx == optionIndex);
        }).toList();
        updateQuestion(questionIndex, question.copyWith(options: newOptions));
      } else {
        updateOption(questionIndex, optionIndex, option.copyWith(correct: !option.correct));
      }
    }
  }

  /// Load an existing quiz for editing
  void loadQuizForEditing(Quiz quiz) {
    final questions = quiz.questions.map((q) {
      return QuestionDraft(
        text: q.text,
        type: q.type,
        options: q.options.map((o) {
          return OptionDraft(
            text: o.text,
            correct: o.correct,
          );
        }).toList(),
      );
    }).toList();

    emit(QuizCreationInProgress(
      title: quiz.title,
      questions: questions,
      editingQuizId: quiz.id,
    ));
  }

  /// NEW FLOW: Create job first, then quiz
  Future<void> createJobAndQuiz() async {
    final currentState = state;
    if (currentState is! QuizCreationInProgress) return;
    if (_pendingJobData == null) {
      emit(const QuizCreationFailure(error: 'No pending job data found'));
      emit(currentState);
      return;
    }
    if (_jobRepository == null) {
      emit(const QuizCreationFailure(error: 'Job repository not available'));
      emit(currentState);
      return;
    }

    if (!currentState.isValid) {
      emit(const QuizCreationFailure(
          error: 'Please complete all fields and mark correct answers'));
      emit(currentState);
      return;
    }

    emit(QuizCreating());

    try {
      // Step 1: Upload image if present
      String? imageUrl;
      final pendingJob = _pendingJobData!;
      if (pendingJob.imageFile != null && _fileUploadRepository != null) {
        imageUrl = await _fileUploadRepository!.uploadFile(pendingJob.imageFile!);
      }

      // Step 2: Create the job
      final jobRequest = pendingJob.toJobRequest(imageUrl: imageUrl);
      final job = await _jobRepository!.createJob(jobRequest);

      // Step 3: Create the quiz
      final questionDtos = currentState.questions.map((q) => q.toDto()).toList();
      final quiz = await _quizRepository.createQuiz(
        jobId: job.id,
        title: currentState.title,
        questions: questionDtos,
      );

      // Clear pending job data
      _pendingJobData = null;

      emit(JobAndQuizCreated(jobId: job.id, quiz: quiz));
    } catch (e) {
      debugPrint('QuizCreationCubit.createJobAndQuiz error: $e');

      String userFriendlyError;
      final errorMessage = e.toString();

      if (errorMessage.contains('401')) {
        userFriendlyError = 'You are not authorized. Please login again.';
      } else if (errorMessage.contains('400')) {
        userFriendlyError = 'Invalid data. Please check all fields.';
      } else if (errorMessage.contains('500')) {
        userFriendlyError = 'Server error. Please try again later.';
      } else {
        userFriendlyError = 'Failed to create job and quiz: ${errorMessage.length > 100 ? "${errorMessage.substring(0, 100)}..." : errorMessage}';
      }

      emit(QuizCreationFailure(error: userFriendlyError));
      emit(currentState);
    }
  }

  /// Create the quiz (for existing job)
  Future<void> createQuiz(int jobId) async {
    final currentState = state;

    if (currentState is! QuizCreationInProgress) {
      return;
    }

    if (!currentState.isValid) {
      emit(const QuizCreationFailure(
          error: 'Please complete all fields and mark correct answers'));
      emit(currentState);
      return;
    }

    emit(QuizCreating());

    try {
      final questionDtos = currentState.questions.map((q) => q.toDto()).toList();

      final quiz = await _quizRepository.createQuiz(
        jobId: jobId,
        title: currentState.title,
        questions: questionDtos,
      );

      emit(QuizCreated(quiz: quiz));
    } catch (e) {
      debugPrint('QuizCreationCubit.createQuiz error: $e');
      final errorMessage = e.toString();
      String userFriendlyError;

      if (errorMessage.contains('duplicate key') ||
          errorMessage.contains('quizzes_job_id_key') ||
          errorMessage.contains('already exists')) {
        userFriendlyError = 'This job already has a quiz. Each job can only have one quiz.';
      } else if (errorMessage.contains('500')) {
        userFriendlyError = 'Server error occurred. Please try again later.';
      } else if (errorMessage.contains('401')) {
        userFriendlyError = 'You are not authorized to create quizzes.';
      } else if (errorMessage.contains('400')) {
        userFriendlyError = 'Invalid quiz data. Please check all fields.';
      } else {
        userFriendlyError = 'Failed to create quiz: ${errorMessage.length > 100 ? "${errorMessage.substring(0, 100)}..." : errorMessage}';
      }

      emit(QuizCreationFailure(error: userFriendlyError));
      emit(currentState);
    }
  }

  /// Update an existing quiz
  Future<void> updateQuiz(int quizId) async {
    final currentState = state;
    if (currentState is! QuizCreationInProgress) return;

    if (!currentState.isValid) {
      emit(const QuizCreationFailure(
          error: 'Please complete all fields and mark correct answers'));
      emit(currentState);
      return;
    }

    emit(QuizCreating());

    try {
      final questionDtos = currentState.questions.map((q) => q.toDto()).toList();

      final quiz = await _quizRepository.updateQuiz(
        quizId: quizId,
        title: currentState.title,
        questions: questionDtos,
      );

      emit(QuizCreated(quiz: quiz, wasUpdate: true));
    } catch (e) {
      final errorMessage = e.toString();
      String userFriendlyError;

      if (errorMessage.contains('500')) {
        userFriendlyError = 'Server error occurred. Please try again later.';
      } else if (errorMessage.contains('401')) {
        userFriendlyError = 'You are not authorized to update quizzes.';
      } else if (errorMessage.contains('404')) {
        userFriendlyError = 'Quiz not found. It may have been deleted.';
      } else if (errorMessage.contains('400')) {
        userFriendlyError = 'Invalid quiz data. Please check all fields.';
      } else {
        userFriendlyError = 'Failed to update quiz: ${errorMessage.length > 100 ? "${errorMessage.substring(0, 100)}..." : errorMessage}';
      }

      emit(QuizCreationFailure(error: userFriendlyError));
      emit(currentState);
    }
  }

  /// Delete a quiz
  Future<void> deleteQuiz(int quizId) async {
    emit(QuizCreating());

    try {
      await _quizRepository.deleteQuiz(quizId);
      emit(const QuizDeleted());
    } catch (e) {
      final errorMessage = e.toString();
      String userFriendlyError;

      if (errorMessage.contains('500')) {
        userFriendlyError = 'Server error occurred. Please try again later.';
      } else if (errorMessage.contains('401')) {
        userFriendlyError = 'You are not authorized to delete quizzes.';
      } else if (errorMessage.contains('404')) {
        userFriendlyError = 'Quiz not found. It may have been already deleted.';
      } else {
        userFriendlyError = 'Failed to delete quiz: ${errorMessage.length > 100 ? "${errorMessage.substring(0, 100)}..." : errorMessage}';
      }

      emit(QuizCreationFailure(error: userFriendlyError));
    }
  }
}
