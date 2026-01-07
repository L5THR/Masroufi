// lib/views/quiz/data/models/quiz_question.dart

import 'option_choice.dart';

enum QuestionType {
  SINGLE_CHOICE,
  MULTIPLE_CHOICE;

  String toJson() => name;

  static QuestionType fromString(String value) {
    return QuestionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => QuestionType.SINGLE_CHOICE,
    );
  }
}

/// Question model (when reading from API)
class QuizQuestion {
  final int id;
  final String text;
  final QuestionType type;
  final List<OptionChoice> options;

  QuizQuestion({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      text: json['text'] ?? '',
      type: QuestionType.fromString(json['type'] ?? 'SINGLE_CHOICE'),
      options: (json['options'] as List?)
              ?.map((o) => OptionChoice.fromJson(o))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.toJson(),
      'options': options.map((o) => o.toJson()).toList(),
    };
  }

  /// Get the correct option(s) for this question
  List<OptionChoice> get correctOptions =>
      options.where((o) => o.correct).toList();
}

/// QuestionDto for creating quizzes
class QuestionDto {
  final String text;
  final QuestionType type;
  final List<OptionDto> options;

  QuestionDto({
    required this.text,
    required this.type,
    required this.options,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'type': type.toJson(),
      'options': options.map((o) => o.toJson()).toList(),
    };
  }
}
