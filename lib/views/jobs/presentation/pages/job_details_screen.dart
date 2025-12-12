// lib/views/jobs/presentation/pages/job_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';

class JobDetailsScreen extends StatelessWidget {
  final bool isRecruiter;
  const JobDetailsScreen({Key? key, required this.isRecruiter})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Job saved!')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Header
            Container(
              padding: const EdgeInsets.all(20),
              color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: AppTheme.accentBlue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Web Developer',
                          style: TextStyle(
                            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tech Solutions',
                          style: TextStyle(
                            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Job Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _InfoBox(
                    icon: Icons.attach_money,
                    label: '50 DT',
                    title: 'Salary',
                  ),
                  const SizedBox(width: 12),
                  _InfoBox(
                    icon: Icons.location_on,
                    label: 'Tunis',
                    title: 'Location',
                  ),
                  const SizedBox(width: 12),
                  _InfoBox(
                    icon: Icons.access_time,
                    label: '2 days',
                    title: 'Duration',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Job Description',
                    style: TextStyle(
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We are looking for a skilled web developer to create a responsive landing page for our new product. The project requires proficiency in HTML, CSS, and JavaScript.',
                    style: TextStyle(
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Requirements
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Requirements',
                    style: TextStyle(
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _RequirementItem(text: 'Experience with Flutter framework'),
                  _RequirementItem(text: 'Knowledge of UI/UX principles'),
                  _RequirementItem(text: 'Strong problem-solving skills'),
                  _RequirementItem(text: 'Available for 2-3 days'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Skills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Required Skills',
                    style: TextStyle(
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SkillChip(label: 'Flutter'),
                      _SkillChip(label: 'Dart'),
                      _SkillChip(label: 'UI/UX'),
                      _SkillChip(label: 'Firebase'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Quiz Required Notice
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.accentBlue),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.quiz, color: AppTheme.accentBlue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Quiz Required: You must pass a skill assessment to apply',
                        style: TextStyle(
                          color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Posted Date
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Posted 2 hours ago',
                      style: TextStyle(color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey, fontSize: 14),
                    ),
                    const Spacer(),
                    const Text(
                      '12 applicants',
                      style: TextStyle(
                        color: AppTheme.accentBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: isRecruiter
          ? null
          : Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
                border: Border(
                    top: BorderSide(
                        color:
                            isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey)),
              ),
              child: SafeArea(
                child: CustomButton(
                  text: 'Take Quiz & Apply',
                  onPressed: () {
                    // Navigate to quiz
                    Navigator.pushNamed(context, '/quiz');
                  },
                ),
              ),
            ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String title;

  const _InfoBox({
    required this.icon,
    required this.label,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.accentBlue, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String text;

  const _RequirementItem({required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;

  const _SkillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentBlue),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.accentBlue,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
