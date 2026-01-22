// lib/views/recruiter/logic/job_wizard_cubit.dart

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/file_upload_repository.dart';
import '../../jobs/data/models/job_request.dart';
import '../../jobs/data/repositories/job_repository.dart';
import '../../quiz/data/repositories/quiz_repository.dart';
import '../../quiz/logic/quiz_state.dart';
import '../../quiz/data/models/quiz_question.dart';
import 'job_wizard_state.dart';

class JobWizardCubit extends Cubit<JobWizardState> {
  final JobRepository _jobRepository;
  final QuizRepository _quizRepository;
  final FileUploadRepository _fileUploadRepository;

  JobWizardCubit({
    required JobRepository jobRepository,
    required QuizRepository quizRepository,
    required FileUploadRepository fileUploadRepository,
  })  : _jobRepository = jobRepository,
        _quizRepository = quizRepository,
        _fileUploadRepository = fileUploadRepository,
        super(const JobWizardState());

  /// Initialize the wizard and load categories
  Future<void> initialize() async {
    emit(state.copyWith(categoriesLoading: true));
    try {
      final categoriesResponse = await _jobRepository.getCategories();
      emit(state.copyWith(
        categories: categoriesResponse.content,
        categoriesLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to load categories: $e',
        categoriesLoading: false,
      ));
    }
  }

  // ==================== NAVIGATION ====================

  /// Move to the next step
  void nextStep() {
    if (!state.isCurrentStepValid) {
      emit(state.copyWith(error: 'Please complete all required fields'));
      return;
    }

    emit(state.copyWith(
      currentStep: state.currentStep + 1,
      clearError: true,
    ));
  }

  /// Move to the previous step
  void previousStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(
        currentStep: state.currentStep - 1,
        clearError: true,
      ));
    }
  }

  /// Jump to a specific step
  void goToStep(int step) {
    // Only allow going to steps that are before or at the current step
    // Or if all previous steps are valid
    if (step <= state.currentStep || (step == 1 && state.isJobDetailsValid)) {
      emit(state.copyWith(
        currentStep: step,
        clearError: true,
      ));
    }
  }

  /// Clear error message
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  // ==================== STEP 1: JOB DETAILS ====================

  void updateTitle(String value) {
    emit(state.copyWith(title: value, clearError: true));
  }

  void updateDescription(String value) {
    emit(state.copyWith(description: value, clearError: true));
  }

  void updateSalary(String value) {
    final salary = double.tryParse(value);
    if (value.isEmpty) {
      emit(state.copyWith(clearSalary: true, clearError: true));
    } else if (salary != null) {
      emit(state.copyWith(salary: salary, clearError: true));
    }
  }

  void updateDuration(String value) {
    if (value.isEmpty) {
      emit(state.copyWith(clearDuration: true, clearError: true));
    } else {
      emit(state.copyWith(duration: value, clearError: true));
    }
  }

  void updateLocation(String value) {
    if (value.isEmpty) {
      emit(state.copyWith(clearLocation: true, clearError: true));
    } else {
      emit(state.copyWith(location: value, clearError: true));
    }
  }

  void updateCategory(int? categoryId) {
    emit(state.copyWith(categoryId: categoryId, clearError: true));
  }

  void toggleRequiresQuiz(bool value) {
    emit(state.copyWith(requiresQuiz: value, clearError: true));
  }

  void toggleSkill(String skill) {
    final skills = List<String>.from(state.selectedSkills);
    if (skills.contains(skill)) {
      skills.remove(skill);
    } else {
      skills.add(skill);
    }
    emit(state.copyWith(selectedSkills: skills, clearError: true));
  }

  void setImage(File? file) {
    if (file == null) {
      emit(state.copyWith(clearImageFile: true, clearError: true));
    } else {
      emit(state.copyWith(imageFile: file, clearError: true));
    }
  }

  // ==================== STEP 2: QUIZ ====================

  void updateQuizTitle(String value) {
    emit(state.copyWith(quizTitle: value, clearError: true));
  }

  void addQuestion() {
    final questions = List<QuestionDraft>.from(state.questions);
    questions.add(const QuestionDraft(
      text: '',
      type: QuestionType.SINGLE_CHOICE,
      options: [
        OptionDraft(text: '', correct: false),
        OptionDraft(text: '', correct: false),
      ],
    ));
    emit(state.copyWith(questions: questions, clearError: true));
  }

  void removeQuestion(int index) {
    if (index >= 0 && index < state.questions.length) {
      final questions = List<QuestionDraft>.from(state.questions);
      questions.removeAt(index);
      emit(state.copyWith(questions: questions, clearError: true));
    }
  }

  void updateQuestionText(int questionIndex, String text) {
    if (questionIndex >= 0 && questionIndex < state.questions.length) {
      final questions = List<QuestionDraft>.from(state.questions);
      questions[questionIndex] = questions[questionIndex].copyWith(text: text);
      emit(state.copyWith(questions: questions, clearError: true));
    }
  }

  void updateQuestionType(int questionIndex, QuestionType type) {
    if (questionIndex >= 0 && questionIndex < state.questions.length) {
      final questions = List<QuestionDraft>.from(state.questions);
      questions[questionIndex] = questions[questionIndex].copyWith(type: type);
      emit(state.copyWith(questions: questions, clearError: true));
    }
  }

  void addOption(int questionIndex) {
    if (questionIndex >= 0 && questionIndex < state.questions.length) {
      final questions = List<QuestionDraft>.from(state.questions);
      final question = questions[questionIndex];
      final options = List<OptionDraft>.from(question.options);
      options.add(const OptionDraft(text: '', correct: false));
      questions[questionIndex] = question.copyWith(options: options);
      emit(state.copyWith(questions: questions, clearError: true));
    }
  }

  void removeOption(int questionIndex, int optionIndex) {
    if (questionIndex >= 0 && questionIndex < state.questions.length) {
      final questions = List<QuestionDraft>.from(state.questions);
      final question = questions[questionIndex];
      if (question.options.length > 2 &&
          optionIndex >= 0 &&
          optionIndex < question.options.length) {
        final options = List<OptionDraft>.from(question.options);
        options.removeAt(optionIndex);
        questions[questionIndex] = question.copyWith(options: options);
        emit(state.copyWith(questions: questions, clearError: true));
      }
    }
  }

  void updateOptionText(int questionIndex, int optionIndex, String text) {
    if (questionIndex >= 0 && questionIndex < state.questions.length) {
      final questions = List<QuestionDraft>.from(state.questions);
      final question = questions[questionIndex];
      if (optionIndex >= 0 && optionIndex < question.options.length) {
        final options = List<OptionDraft>.from(question.options);
        options[optionIndex] = options[optionIndex].copyWith(text: text);
        questions[questionIndex] = question.copyWith(options: options);
        emit(state.copyWith(questions: questions, clearError: true));
      }
    }
  }

  void toggleOptionCorrect(int questionIndex, int optionIndex) {
    if (questionIndex >= 0 && questionIndex < state.questions.length) {
      final questions = List<QuestionDraft>.from(state.questions);
      final question = questions[questionIndex];
      if (optionIndex >= 0 && optionIndex < question.options.length) {
        final options = List<OptionDraft>.from(question.options);

        if (question.type == QuestionType.SINGLE_CHOICE) {
          // For single choice, only one option can be correct
          for (int i = 0; i < options.length; i++) {
            options[i] = options[i].copyWith(correct: i == optionIndex);
          }
        } else {
          // For multiple choice, toggle the option
          options[optionIndex] = options[optionIndex].copyWith(
            correct: !options[optionIndex].correct,
          );
        }

        questions[questionIndex] = question.copyWith(options: options);
        emit(state.copyWith(questions: questions, clearError: true));
      }
    }
  }

  // ==================== SUBMISSION ====================

  /// Submit the job (and quiz if required)
  Future<void> submit() async {
    if (!state.canSubmit) {
      emit(state.copyWith(error: 'Please complete all required fields'));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // Step 1: Upload image if present
      String? imageUrl;
      if (state.imageFile != null) {
        imageUrl = await _fileUploadRepository.uploadFile(state.imageFile!);
      }

      // Step 2: Create the job
      final jobRequest = JobRequest(
        title: state.title,
        description: state.description,
        salary: state.salary,
        duration: state.duration,
        location: state.location,
        categoryId: state.categoryId!,
        requiresQuiz: state.requiresQuiz,
        skills: state.selectedSkills.isNotEmpty ? state.selectedSkills : null,
        imageUrl: imageUrl,
      );

      final job = await _jobRepository.createJob(jobRequest);

      // Step 3: Create quiz if required
      if (state.requiresQuiz) {
        final questionDtos = state.questions.map((q) => q.toDto()).toList();

        await _quizRepository.createQuiz(
          jobId: job.id,
          title: state.quizTitle,
          questions: questionDtos,
        );
      }

      emit(state.copyWith(
        isLoading: false,
        createdJobId: job.id,
        successMessage: state.requiresQuiz
            ? 'Job and quiz created successfully!'
            : 'Job created successfully!',
      ));

    } catch (e) {

      String errorMessage = 'Failed to create job';
      final errorStr = e.toString();

      if (errorStr.contains('401')) {
        errorMessage = 'Session expired. Please login again.';
      } else if (errorStr.contains('400')) {
        errorMessage = 'Invalid data. Please check all fields.';
      } else if (errorStr.contains('500')) {
        errorMessage = 'Server error. Please try again later.';
      } else if (errorStr.contains('timeout')) {
        errorMessage = 'Connection timeout. Please check your internet.';
      } else {
        errorMessage = errorStr.length > 100
            ? '${errorStr.substring(0, 100)}...'
            : errorStr;
      }

      emit(state.copyWith(
        isLoading: false,
        error: errorMessage,
      ));
    }
  }
}
