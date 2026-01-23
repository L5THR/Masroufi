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
import '../../../applications/data/models/job_application.dart';
import '../../../applications/data/models/application_status.dart';
import '../../../applications/presentation/widgets/application_detail_sheet.dart';
import '../../../chat/data/repositories/chat_repository.dart';
import '../../../chat/logic/chat_cubit.dart';
import '../../../chat/presentation/pages/chat_screen.dart';
import '../../../reports/data/models/report.dart';
import '../../../reports/presentation/widgets/create_report_dialog.dart';
import '../../../reviews/presentation/widgets/user_rating_widget.dart';
import '../../../reviews/presentation/widgets/create_review_dialog.dart';

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
  JobApplication? _myApplication; // Store the actual application

  @override
  void initState() {
    super.initState();
    if (widget.jobId != null) {
      context.read<JobCubit>().getJobById(widget.jobId!);
      // Check if user has already applied to this job
      _checkIfAlreadyApplied();
    }
  }

  Future<void> _checkIfAlreadyApplied() async {
    if (widget.jobId == null) return;

    final applicationCubit = context.read<ApplicationCubit>();
    // Load user's applications
    await applicationCubit.getMyApplications();

    // Check the state after loading
    final state = applicationCubit.state;
    if (state is ApplicationsLoaded) {
      // Find the application for this job
      final application = state.applications.cast<JobApplication?>().firstWhere(
        (app) => app?.job.id == widget.jobId,
        orElse: () => null,
      );
      if (mounted) {
        setState(() {
          _myApplication = application;
        });
      }
    }
  }

  void _refreshApplication() {
    _checkIfAlreadyApplied();
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
            // Report Job button
            IconButton(
              icon: const Icon(Icons.flag_outlined),
              tooltip: 'Report Job',
              onPressed: () {
                if (widget.jobId == null) return;
                // Get job title from state
                final jobState = context.read<JobCubit>().state;
                String jobTitle = 'This Job';
                if (jobState is JobLoaded) {
                  jobTitle = jobState.job.title;
                }
                showCreateReportDialog(
                  context: context,
                  targetId: widget.jobId!,
                  targetType: ReportTargetType.JOB,
                  targetName: jobTitle,
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
                                // Recruiter rating
                                if (job.recruiter?.userId != null) ...[
                                  const SizedBox(height: 6),
                                  UserRatingWidget(
                                    userId: job.recruiter!.userId!,
                                    size: 14,
                                    showCount: true,
                                  ),
                                ],
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
                            color: AppTheme.accentBlue.withValues(alpha: 0.1),
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
          : BlocBuilder<JobCubit, JobState>(
              builder: (context, jobState) {
                // Get recruiter info from job state
                int? recruiterUserId;
                String recruiterName = 'Recruiter';
                if (jobState is JobLoaded) {
                  recruiterUserId = jobState.job.recruiter?.userId ??
                                    jobState.job.recruiter?.user?.id;
                  recruiterName = jobState.job.recruiter?.companyName ?? 'Recruiter';
                }

                return Container(
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

                        // Show application status and management options
                        if (_myApplication != null) {
                          return _buildApplicationStatusBar(
                            context,
                            _myApplication!,
                            recruiterUserId,
                            recruiterName,
                          );
                        }

                        // Show Apply button only (chat available after applying)
                        return CustomButton(
                          text: isApplying ? 'Applying...' : 'Apply Now',
                          isLoading: isApplying,
                          onPressed: () {
                            if (widget.jobId != null) {
                              _showApplyConfirmation(context, widget.jobId!);
                            } else {
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
                );
              },
            ),
    );
  }

  void _openChat(BuildContext context, int userId, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => ChatCubit(ChatRepository()),
          child: ChatScreen(
            userId: userId,
            userName: userName,
            userRole: 'RECRUITER',
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

  /// Builds the application status bar with appropriate actions based on status
  Widget _buildApplicationStatusBar(
    BuildContext context,
    JobApplication application,
    int? recruiterUserId,
    String recruiterName,
  ) {
    final status = application.status;

    // Different UI based on application status
    switch (status) {
      case ApplicationStatus.PENDING:
      case ApplicationStatus.VIEWED:
        // Waiting for recruiter - show status and chat
        return _buildWaitingStatusBar(
          context,
          application,
          recruiterUserId,
          recruiterName,
          status == ApplicationStatus.PENDING
              ? 'Waiting for Review'
              : 'Application Viewed',
          status == ApplicationStatus.PENDING
              ? 'The recruiter will review your application soon.'
              : 'The recruiter has seen your application.',
          AppTheme.accentYellow,
          Icons.hourglass_empty,
        );

      case ApplicationStatus.ACCEPTED:
        // Accepted - show prominent "Start Work" action
        return _buildAcceptedStatusBar(
          context,
          application,
          recruiterUserId,
          recruiterName,
        );

      case ApplicationStatus.IN_PROGRESS:
        // Working - show "Mark Complete" action
        return _buildInProgressStatusBar(
          context,
          application,
          recruiterUserId,
          recruiterName,
        );

      case ApplicationStatus.PENDING_COMPLETION:
        // Awaiting confirmation
        return _buildPendingCompletionStatusBar(
          context,
          application,
          recruiterUserId,
          recruiterName,
        );

      case ApplicationStatus.COMPLETED:
        // Completed - show review option
        return _buildCompletedStatusBar(
          context,
          application,
          recruiterUserId,
          recruiterName,
        );

      case ApplicationStatus.REJECTED:
        // Rejected
        return _buildRejectedStatusBar(context);

      default:
        // Default: show status with manage button
        return _buildDefaultStatusBar(
          context,
          application,
          recruiterUserId,
          recruiterName,
        );
    }
  }

  Widget _buildWaitingStatusBar(
    BuildContext context,
    JobApplication application,
    int? recruiterUserId,
    String recruiterName,
    String title,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status info
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.textGrey
                            : AppTheme.textDarkGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Chat and View Details buttons
        Row(
          children: [
            if (recruiterUserId != null) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openChat(context, recruiterUserId, recruiterName),
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Chat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentBlue,
                    side: const BorderSide(color: AppTheme.accentBlue),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _openApplicationDetail(context, application),
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('View Details'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textGrey,
                  side: const BorderSide(color: AppTheme.textGrey),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAcceptedStatusBar(
    BuildContext context,
    JobApplication application,
    int? recruiterUserId,
    String recruiterName,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Congratulations banner
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.successGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.successGreen),
          ),
          child: Row(
            children: [
              const Icon(Icons.celebration, color: AppTheme.successGreen, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'You\'re Accepted!',
                      style: TextStyle(
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Mark as complete when the work is done.',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.textGrey
                            : AppTheme.textDarkGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Leave Review button (for testing - skip completion requirement)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              await showCreateReviewDialog(
                context: context,
                jobApplicationId: application.id,
                applicantName: recruiterName,
              );
              _refreshApplication();
            },
            icon: const Icon(Icons.star, size: 20),
            label: const Text('Leave a Review for Recruiter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentYellow,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Chat button
        if (recruiterUserId != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openChat(context, recruiterUserId, recruiterName),
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('Chat with Recruiter'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accentBlue,
                side: const BorderSide(color: AppTheme.accentBlue),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        const SizedBox(height: 8),
        // View Details button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _openApplicationDetail(context, application),
            icon: const Icon(Icons.visibility, size: 18),
            label: const Text('View Application Details'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textGrey,
              side: const BorderSide(color: AppTheme.textGrey),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInProgressStatusBar(
    BuildContext context,
    JobApplication application,
    int? recruiterUserId,
    String recruiterName,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // In Progress banner
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.accentBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accentBlue),
          ),
          child: Row(
            children: [
              const Icon(Icons.engineering, color: AppTheme.accentBlue, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Work In Progress',
                      style: TextStyle(
                        color: AppTheme.accentBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Mark as complete when finished.',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.textGrey
                            : AppTheme.textDarkGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Mark Complete button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _openApplicationDetail(context, application),
            icon: const Icon(Icons.check_circle_outline, size: 20),
            label: const Text('Mark as Complete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Chat button
        if (recruiterUserId != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openChat(context, recruiterUserId, recruiterName),
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('Chat with Recruiter'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accentBlue,
                side: const BorderSide(color: AppTheme.accentBlue),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPendingCompletionStatusBar(
    BuildContext context,
    JobApplication application,
    int? recruiterUserId,
    String recruiterName,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pending completion banner
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.accentYellow.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accentYellow),
          ),
          child: Row(
            children: [
              const Icon(Icons.hourglass_top, color: AppTheme.accentYellow, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Awaiting Confirmation',
                      style: TextStyle(
                        color: AppTheme.accentYellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Completion requested. Waiting for confirmation.',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.textGrey
                            : AppTheme.textDarkGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Manage button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _openApplicationDetail(context, application),
            icon: const Icon(Icons.manage_accounts, size: 20),
            label: const Text('Manage Completion'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentYellow,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedStatusBar(
    BuildContext context,
    JobApplication application,
    int? recruiterUserId,
    String recruiterName,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Completed banner
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.successGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.successGreen),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified, color: AppTheme.successGreen, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Job Completed!',
                      style: TextStyle(
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Great work! Don\'t forget to leave a review.',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.textGrey
                            : AppTheme.textDarkGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Leave Review button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _openApplicationDetail(context, application),
            icon: const Icon(Icons.star, size: 20),
            label: const Text('Leave a Review'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentYellow,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRejectedStatusBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.errorRed),
      ),
      child: Row(
        children: [
          const Icon(Icons.cancel, color: AppTheme.errorRed, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Application Rejected',
                  style: TextStyle(
                    color: AppTheme.errorRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Unfortunately, your application was not selected.',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.textGrey
                        : AppTheme.textDarkGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultStatusBar(
    BuildContext context,
    JobApplication application,
    int? recruiterUserId,
    String recruiterName,
  ) {
    return Row(
      children: [
        if (recruiterUserId != null) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _openChat(context, recruiterUserId, recruiterName),
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('Chat'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accentBlue,
                side: const BorderSide(color: AppTheme.accentBlue),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _openApplicationDetail(context, application),
            icon: const Icon(Icons.visibility, size: 18),
            label: const Text('View Application'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _openApplicationDetail(BuildContext context, JobApplication application) {
    showJobSeekerApplicationDetail(
      context,
      application,
      _refreshApplication,
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
        color: AppTheme.accentBlue.withValues(alpha: 0.2),
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
