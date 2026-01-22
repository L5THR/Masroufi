// lib/views/recruiter/logic/job_wizard_state.dart

import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../jobs/data/models/category.dart';
import '../../quiz/logic/quiz_state.dart';

/// Unified state for the Job Creation Wizard
/// Combines job details and quiz creation in one state
class JobWizardState extends Equatable {
  // Wizard navigation
  final int currentStep;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  // Step 1: Job Details
  final String title;
  final String description;
  final double? salary;
  final String? duration;
  final String? location;
  final int? categoryId;
  final bool requiresQuiz;
  final List<String> selectedSkills;
  final File? imageFile;

  // Categories (loaded from API)
  final List<Category> categories;
  final bool categoriesLoading;

  // Step 2: Quiz (only if requiresQuiz is true)
  final String quizTitle;
  final List<QuestionDraft> questions;

  // Result
  final int? createdJobId;

  const JobWizardState({
    // Navigation
    this.currentStep = 0,
    this.isLoading = false,
    this.error,
    this.successMessage,
    // Job Details
    this.title = '',
    this.description = '',
    this.salary,
    this.duration,
    this.location,
    this.categoryId,
    this.requiresQuiz = false,
    this.selectedSkills = const [],
    this.imageFile,
    // Categories
    this.categories = const [],
    this.categoriesLoading = false,
    // Quiz
    this.quizTitle = '',
    this.questions = const [],
    // Result
    this.createdJobId,
  });

  /// Get the total number of steps (2 if no quiz, 3 if quiz required)
  int get totalSteps => requiresQuiz ? 2 : 1;

  /// Check if currently on the last step
  bool get isLastStep => currentStep >= totalSteps;

  /// Check if job details are valid (Step 1)
  bool get isJobDetailsValid {
    return title.trim().isNotEmpty &&
        description.trim().isNotEmpty &&
        categoryId != null;
  }

  /// Check if quiz is valid (Step 2)
  bool get isQuizValid {
    if (!requiresQuiz) return true;
    return quizTitle.trim().isNotEmpty &&
        questions.isNotEmpty &&
        questions.every((q) => q.isValid);
  }

  /// Check if current step is valid
  bool get isCurrentStepValid {
    switch (currentStep) {
      case 0:
        return isJobDetailsValid;
      case 1:
        return requiresQuiz ? isQuizValid : true;
      default:
        return true;
    }
  }

  /// Check if the entire form is valid and ready to submit
  bool get canSubmit {
    return isJobDetailsValid && isQuizValid;
  }

  /// Get step title for display
  String getStepTitle(int step) {
    if (step == 0) return 'Job Details';
    if (step == 1 && requiresQuiz) return 'Quiz';
    return '';
  }

  JobWizardState copyWith({
    int? currentStep,
    bool? isLoading,
    String? error,
    String? successMessage,
    String? title,
    String? description,
    double? salary,
    String? duration,
    String? location,
    int? categoryId,
    bool? requiresQuiz,
    List<String>? selectedSkills,
    File? imageFile,
    List<Category>? categories,
    bool? categoriesLoading,
    String? quizTitle,
    List<QuestionDraft>? questions,
    int? createdJobId,
    // Special flags to set values to null
    bool clearError = false,
    bool clearSuccessMessage = false,
    bool clearSalary = false,
    bool clearDuration = false,
    bool clearLocation = false,
    bool clearImageFile = false,
  }) {
    return JobWizardState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      title: title ?? this.title,
      description: description ?? this.description,
      salary: clearSalary ? null : (salary ?? this.salary),
      duration: clearDuration ? null : (duration ?? this.duration),
      location: clearLocation ? null : (location ?? this.location),
      categoryId: categoryId ?? this.categoryId,
      requiresQuiz: requiresQuiz ?? this.requiresQuiz,
      selectedSkills: selectedSkills ?? this.selectedSkills,
      imageFile: clearImageFile ? null : (imageFile ?? this.imageFile),
      categories: categories ?? this.categories,
      categoriesLoading: categoriesLoading ?? this.categoriesLoading,
      quizTitle: quizTitle ?? this.quizTitle,
      questions: questions ?? this.questions,
      createdJobId: createdJobId ?? this.createdJobId,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        isLoading,
        error,
        successMessage,
        title,
        description,
        salary,
        duration,
        location,
        categoryId,
        requiresQuiz,
        selectedSkills,
        imageFile,
        categories,
        categoriesLoading,
        quizTitle,
        questions,
        createdJobId,
      ];
}
