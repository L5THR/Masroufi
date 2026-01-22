// lib/views/quiz/data/models/quiz.dart

import 'package:flutter_alinfo9/views/jobs/data/models/job.dart';
import 'quiz_question.dart';

export 'quiz_question.dart';
export 'option_choice.dart';
export 'quiz_attempt.dart';

class Quiz {
  final int id;
  final Job? job;
  final String title;
  final List<QuizQuestion> questions;

  Quiz({
    required this.id,
    this.job,
    required this.title,
    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      job: json['job'] != null ? Job.fromJson(json['job']) : null,
      title: json['title'] ?? '',
      questions: (json['questions'] as List?)
              ?.map((q) => QuizQuestion.fromJson(q))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (job != null) 'job': job!.toJson(),
      'title': title,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

/// Request model for creating a quiz
class QuizCreateRequest {
  final int jobId;
  final String title;
  final List<QuestionDto> questions;

  QuizCreateRequest({
    required this.jobId,
    required this.title,
    required this.questions,
  });

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'title': title,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

/// Request model for updating a quiz
class QuizUpdateRequest {
  final String title;
  final List<QuestionDto> questions;

  QuizUpdateRequest({
    required this.title,
    required this.questions,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

/// Request model for submitting quiz answers
class QuizSubmitRequest {
  final List<int> answers; // List of selected option IDs

  QuizSubmitRequest({required this.answers});

  Map<String, dynamic> toJson() {
    return {
      'answers': answers,
    };
  }
}
