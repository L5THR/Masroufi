// lib/views/onboarding/presentation/pages/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.search_rounded,
      'title': 'Find Mini-Jobs',
      'description':
          'Browse hundreds of short-term opportunities perfect for students and young workers',
    },
    {
      'icon': Icons.flash_on_rounded,
      'title': 'Apply Instantly',
      'description':
          'Quick application process with real-time updates on your candidacy status',
    },
    {
      'icon': Icons.chat_bubble_outline_rounded,
      'title': 'Connect & Work',
      'description':
          'Direct messaging with recruiters once your application is accepted',
    },
  ];

  void _navigateToRoleSelection() {
    Navigator.of(context).pushReplacementNamed('/role-selection');
  }

  void _handleNextOrGetStarted() {
    if (_currentPage == _pages.length - 1) {
      // Last page - Get Started
      _navigateToRoleSelection();
    } else {
      // Not last page - Go to next page
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.primaryBlack : AppTheme.primaryWhite,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.tertiaryGrey
                                : AppTheme.lightGrey,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            _pages[index]['icon'],
                            size: 80,
                            color: AppTheme.accentBlue,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          _pages[index]['title'],
                          style: TextStyle(
                            color: isDark
                                ? AppTheme.textWhite
                                : AppTheme.textBlack,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _pages[index]['description'],
                          style: TextStyle(
                            color: isDark
                                ? AppTheme.textGrey
                                : AppTheme.textDarkGrey,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.accentBlue
                              : (isDark
                                    ? AppTheme.tertiaryGrey
                                    : AppTheme.lightGrey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Next/Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _handleNextOrGetStarted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentBlue,
                        foregroundColor: AppTheme.textWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Skip button
                  TextButton(
                    onPressed: _navigateToRoleSelection,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.textGrey
                            : AppTheme.textDarkGrey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
