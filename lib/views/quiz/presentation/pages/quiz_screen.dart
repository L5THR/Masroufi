// lib/views/quiz/presentation/pages/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import 'dart:async';
import '../../../../core/widgets/custom_button.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestion = 0;
  int _timeRemaining = 300; // 5 minutes
  Timer? _timer;
  int? _selectedAnswer;
  final List<int?> _answers = List.filled(5, null);

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is Flutter?',
      'options': [
        'A programming language',
        'A UI framework',
        'A database',
        'An operating system',
      ],
      'correct': 1,
    },
    {
      'question': 'Which language is Flutter based on?',
      'options': ['Java', 'Kotlin', 'Dart', 'Swift'],
      'correct': 2,
    },
    {
      'question': 'What does UI stand for?',
      'options': [
        'User Interface',
        'Universal Integration',
        'Unified Information',
        'User Input',
      ],
      'correct': 0,
    },
    {
      'question': 'Which company developed Flutter?',
      'options': ['Facebook', 'Google', 'Apple', 'Microsoft'],
      'correct': 1,
    },
    {
      'question': 'What is a widget in Flutter?',
      'options': [
        'A type of variable',
        'A database table',
        'A UI building block',
        'A function',
      ],
      'correct': 2,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() => _timeRemaining--);
      } else {
        _timer?.cancel();
        _submitQuiz();
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _submitQuiz() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _timer?.cancel();

    // Calculate score
    _answers[_currentQuestion] = _selectedAnswer;
    int correctAnswers = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_answers[i] == _questions[i]['correct']) {
        correctAnswers++;
      }
    }

    final score = (correctAnswers / _questions.length * 100).round();
    final passed = score >= 70;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
        title: Text(
          passed ? '🎉 Congratulations!' : '📝 Quiz Completed',
          style: TextStyle(color: isDark ? AppTheme.textWhite : AppTheme.textBlack),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your Score: $score%',
              style: TextStyle(
                color: passed ? AppTheme.accentGreen : AppTheme.errorRed,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Correct Answers: $correctAnswers/${_questions.length}',
              style: TextStyle(color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey),
            ),
            const SizedBox(height: 16),
            Text(
              passed
                  ? 'You passed! Your application has been submitted.'
                  : 'You need 70% to pass. Please try again later.',
              style: TextStyle(color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to job details
              if (passed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Application submitted successfully!'),
                    backgroundColor: AppTheme.accentGreen,
                  ),
                );
              }
            },
            child: Text(passed ? 'Continue' : 'Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
            title: Text(
              'Exit Quiz?',
              style: TextStyle(color: isDark ? AppTheme.textWhite : AppTheme.textBlack),
            ),
            content: Text(
              'Your progress will be lost. Are you sure you want to exit?',
              style: TextStyle(color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Exit',
                  style: TextStyle(color: AppTheme.errorRed),
                ),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Skill Assessment'),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  _formatTime(_timeRemaining),
                  style: TextStyle(
                    color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress
            Container(
              padding: const EdgeInsets.all(20),
              color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${_currentQuestion + 1}/${_questions.length}',
                        style: TextStyle(
                          color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${((_currentQuestion + 1) / _questions.length * 100).toInt()}%',
                        style: const TextStyle(
                          color: AppTheme.accentBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (_currentQuestion + 1) / _questions.length,
                    backgroundColor: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.accentBlue,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            // Question
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      _questions[_currentQuestion]['question'],
                      style: TextStyle(
                        color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ...List.generate(
                      _questions[_currentQuestion]['options'].length,
                      (index) => _AnswerOption(
                        text: _questions[_currentQuestion]['options'][index],
                        isSelected: _selectedAnswer == index,
                        onTap: () => setState(() => _selectedAnswer = index),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Navigation
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
                border: Border(top: BorderSide(color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    if (_currentQuestion > 0)
                      Expanded(
                        child: CustomButton(
                          text: 'Previous',
                          onPressed: () {
                            setState(() {
                              _answers[_currentQuestion] = _selectedAnswer;
                              _currentQuestion--;
                              _selectedAnswer = _answers[_currentQuestion];
                            });
                          },
                          isOutlined: true,
                        ),
                      ),
                    if (_currentQuestion > 0) const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: _currentQuestion == _questions.length - 1
                            ? 'Submit'
                            : 'Next',
                        onPressed: _selectedAnswer == null
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select an answer'),
                                    backgroundColor: AppTheme.errorRed,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            : () {
                                if (_currentQuestion == _questions.length - 1) {
                                  _submitQuiz();
                                } else {
                                  setState(() {
                                    _answers[_currentQuestion] =
                                        _selectedAnswer;
                                    _currentQuestion++;
                                    _selectedAnswer =
                                        _answers[_currentQuestion];
                                  });
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class _AnswerOption extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentBlue.withOpacity(0.2)
              : (isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.accentBlue : (isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.accentBlue : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppTheme.accentBlue : (isDark ? AppTheme.textGrey : AppTheme.textDarkGrey),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: AppTheme.textWhite, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? (isDark ? AppTheme.textWhite : AppTheme.textBlack) : (isDark ? AppTheme.textGrey : AppTheme.textDarkGrey),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
