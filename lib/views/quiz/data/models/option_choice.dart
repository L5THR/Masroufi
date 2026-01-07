// lib/views/quiz/data/models/option_choice.dart

/// Option model (when reading from API)
class OptionChoice {
  final int id;
  final String text;
  final bool correct;

  OptionChoice({
    required this.id,
    required this.text,
    required this.correct,
  });

  factory OptionChoice.fromJson(Map<String, dynamic> json) {
    return OptionChoice(
      id: json['id'],
      text: json['text'] ?? '',
      correct: json['correct'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'correct': correct,
    };
  }
}

/// OptionDto for creating quizzes
class OptionDto {
  final String text;
  final bool correct;

  OptionDto({
    required this.text,
    required this.correct,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'correct': correct,
    };
  }
}
