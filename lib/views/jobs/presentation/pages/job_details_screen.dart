// lib/views/jobs/presentation/pages/job_details_screen.dart

import 'package:flutter/material.dart';

import 'package:flutter_alinfo9/views/jobs/data/repositories/job_repository.dart';
import 'package:flutter_alinfo9/views/jobs/logic/job_cubit.dart';
import 'package:flutter_alinfo9/views/jobs/logic/job_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_theme.dart';
import '../../../../core/utils/auth_guard.dart';
import '../../../widgets/custom_button.dart';
import '../../../applications/logic/application_cubit.dart';
import '../../../applications/logic/application_state.dart';
import '../../../applications/data/repositories/application_repository.dart';

class JobDetailsScreen extends StatelessWidget {
  final bool isRecruiter;
  final int? jobId;

  const JobDetailsScreen({Key? key, required this.isRecruiter, this.jobId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ApplicationCubit(ApplicationRepository()),
        ),
        BlocProvider(create: (context) => JobCubit(JobRepository())),
      ],
      child: _JobDetailsView(isRecruiter: isRecruiter, jobId: jobId),
    );
  }
}

class _JobDetailsView extends StatefulWidget {
  final bool isRecruiter;
  final int? jobId;

  const _JobDetailsView({required this.isRecruiter, this.jobId});

  @override
  State<_JobDetailsView> createState() => _JobDetailsViewState();
}

class _JobDetailsViewState extends State<_JobDetailsView> {
  @override
  void initState() {
    super.initState();
    if (widget.jobId != null) {
      context.read<JobCubit>().getJobById(widget.jobId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          if (!widget.isRecruiter) ...[
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () {
                // Check if user is authenticated before saving
                if (!AuthGuard.requireAuth(
                  context,
                  title: 'Login to Save Jobs',
                  message:
                      'Create an account or login to save jobs for later.',
                )) {
                  return;
                }

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
        ],
      ),
      body: BlocListener<ApplicationCubit, ApplicationState>(
        listener: (context, state) {
          if (state is ApplicationApplySuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Application submitted successfully!'),
                backgroundColor: AppTheme.successGreen,
              ),
            );
            // Navigate to applications screen
            Navigator.pushReplacementNamed(context, '/job-seeker-home');
          } else if (state is ApplicationApplyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
        },
        child: BlocBuilder<JobCubit, JobState>(
          builder: (context, state) {
            if (state is JobLoading || state is JobInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is JobError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (widget.jobId != null) {
                            context.read<JobCubit>().getJobById(widget.jobId!);
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is JobLoaded) {
              final job = state.job;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      color: isDark
                          ? AppTheme.secondaryBlack
                          : AppTheme.secondaryWhite,
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.tertiaryGrey
                                  : AppTheme.lightGrey,
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
                                  job.title,
                                  style: TextStyle(
                                    color: isDark
                                        ? AppTheme.textWhite
                                        : AppTheme.textBlack,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  job.recruiter?.companyName ?? 'N/A',
                                  style: TextStyle(
                                    color: isDark
                                        ? AppTheme.textGrey
                                        : AppTheme.textDarkGrey,
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
                          if (job.salary != null)
                            _InfoBox(
                              icon: Icons.attach_money,
                              label: '\$${job.salary}',
                              title: 'Salary',
                            ),
                          const SizedBox(width: 12),
                          if (job.location != null)
                            _InfoBox(
                              icon: Icons.location_on,
                              label: job.location!,
                              title: 'Location',
                            ),
                          const SizedBox(width: 12),
                          if (job.duration != null)
                            _InfoBox(
                              icon: Icons.access_time,
                              label: job.duration!,
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
                              color: isDark
                                  ? AppTheme.textWhite
                                  : AppTheme.textBlack,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            job.description,
                            style: TextStyle(
                              color: isDark
                                  ? AppTheme.textGrey
                                  : AppTheme.textDarkGrey,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Requirements
                    if (job.requirements != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Requirements',
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.textWhite
                                    : AppTheme.textBlack,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Assuming requirements is a single string with newlines
                            ...job.requirements!
                                .split('\n')
                                .map((req) => _RequirementItem(text: req))
                                .toList(),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Skills
                    if (job.skills != null && job.skills!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Required Skills',
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.textWhite
                                    : AppTheme.textBlack,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: job.skills!
                                  .map((skill) => _SkillChip(label: skill))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Quiz Required Notice (if applicable)
                    if (job.requiresQuiz)
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
                              const Icon(
                                Icons.quiz,
                                color: AppTheme.accentBlue,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Quiz Required: You must pass a skill assessment to apply',
                                  style: TextStyle(
                                    color: isDark
                                        ? AppTheme.textWhite
                                        : AppTheme.textBlack,
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
                          color: isDark
                              ? AppTheme.secondaryBlack
                              : AppTheme.secondaryWhite,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: isDark
                                  ? AppTheme.textGrey
                                  : AppTheme.textDarkGrey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Posted ${job.createdAt.toLocal().toString().substring(0, 10)}',
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.textGrey
                                    : AppTheme.textDarkGrey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      bottomNavigationBar: widget.isRecruiter
          ? null
          : Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.secondaryBlack
                    : AppTheme.secondaryWhite,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
                  ),
                ),
              ),
              child: SafeArea(
                child: BlocBuilder<ApplicationCubit, ApplicationState>(
                  builder: (context, state) {
                    final isApplying = state is ApplicationApplyLoading;

                    return CustomButton(
                      text: isApplying ? 'Applying...' : 'Apply Now',
                      isLoading: isApplying,
                      onPressed: () {
                        print('🔵 Apply Now button clicked');

                        if (widget.jobId != null) {
                          print('🔵 Job ID: ${widget.jobId}');
                          // Show confirmation dialog
                          _showApplyConfirmation(context, widget.jobId!);
                        } else {
                          print('❌ Job ID is null!');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Job ID not found'),
                              backgroundColor: AppTheme.errorRed,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ),
    );
  }

  void _showApplyConfirmation(BuildContext context, int jobId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark
            ? AppTheme.secondaryBlack
            : AppTheme.secondaryWhite,
        title: Text(
          'Apply to Job',
          style: TextStyle(
            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
          ),
        ),
        content: Text(
          'Are you sure you want to apply to this job? Make sure your profile is complete.',
          style: TextStyle(
            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              print('🔵 Apply confirmation button clicked for job $jobId');
              Navigator.pop(dialogContext);
              // Apply to job
              context.read<ApplicationCubit>().applyToJob(jobId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

// Widget classes remain the same
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
              style: TextStyle(
                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                fontSize: 12,
              ),
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
              style: TextStyle(
                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                fontSize: 14,
              ),
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
