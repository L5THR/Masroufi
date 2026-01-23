// lib/views/applications/presentation/widgets/application_detail_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import 'package:intl/intl.dart';
import '../../data/models/job_application.dart';
import '../../data/models/application_status.dart';
import '../../data/repositories/application_repository.dart';
import '../../logic/application_cubit.dart';
import '../../logic/application_state.dart';
import '../../../reviews/presentation/widgets/user_rating_widget.dart';
import '../../../reviews/presentation/widgets/create_review_dialog.dart';
import '../../../chat/data/repositories/chat_repository.dart';
import '../../../chat/logic/chat_cubit.dart';
import '../../../chat/presentation/pages/chat_screen.dart';
import 'completion_actions.dart';

/// Shows detailed view of an application with completion actions
/// For Job Seekers viewing their applications
void showJobSeekerApplicationDetail(
  BuildContext context,
  JobApplication application,
  VoidCallback onRefresh,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => BlocProvider(
      create: (_) => ApplicationCubit(ApplicationRepository()),
      child: _JobSeekerApplicationDetailSheet(
        application: application,
        onRefresh: onRefresh,
      ),
    ),
  );
}

class _JobSeekerApplicationDetailSheet extends StatelessWidget {
  final JobApplication application;
  final VoidCallback onRefresh;

  const _JobSeekerApplicationDetailSheet({
    required this.application,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recruiter = application.job.recruiter;
    final recruiterUserId = recruiter?.userId ?? recruiter?.user?.id;
    final recruiterName = recruiter?.companyName ?? 'Recruiter';

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Job Info Header
            Row(
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
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.job.title,
                        style: TextStyle(
                          color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recruiterName,
                        style: TextStyle(
                          color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                          fontSize: 14,
                        ),
                      ),
                      if (recruiterUserId != null) ...[
                        const SizedBox(height: 4),
                        UserRatingWidget(
                          userId: recruiterUserId,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Application Flow Progress Indicator
            _ApplicationFlowIndicator(status: application.status),
            const SizedBox(height: 20),

            // Status and Date
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.primaryBlack : AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Status',
                          style: TextStyle(
                            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Color(application.status.colorValue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            application.status.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Applied',
                          style: TextStyle(
                            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(application.appliedAt),
                          style: TextStyle(
                            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                            fontWeight: FontWeight.w600,
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

            // ==================== PENDING: Waiting for Recruiter ====================
            if (application.status == ApplicationStatus.PENDING) ...[
              _InfoBanner(
                icon: Icons.hourglass_empty,
                color: AppTheme.accentYellow,
                title: 'Waiting for Review',
                message: 'Your application is pending. The recruiter will review it soon.',
              ),
              const SizedBox(height: 20),
            ],

            // ==================== VIEWED: Recruiter Saw Application ====================
            if (application.status == ApplicationStatus.VIEWED) ...[
              _InfoBanner(
                icon: Icons.visibility,
                color: AppTheme.accentBlue,
                title: 'Application Viewed',
                message: 'The recruiter has seen your application and is reviewing it.',
              ),
              const SizedBox(height: 20),
            ],

            // ==================== REJECTED: Application Rejected ====================
            if (application.status == ApplicationStatus.REJECTED) ...[
              _InfoBanner(
                icon: Icons.cancel,
                color: AppTheme.errorRed,
                title: 'Application Rejected',
                message: 'Unfortunately, your application was not selected for this position.',
              ),
              const SizedBox(height: 20),
            ],

            // ==================== ACCEPTED: Mark Complete ====================
            if (application.status == ApplicationStatus.ACCEPTED) ...[
              _InfoBanner(
                icon: Icons.celebration,
                color: AppTheme.successGreen,
                title: 'You\'re Accepted!',
                message: 'Mark the job as completed when you finish the work.',
              ),
              const SizedBox(height: 16),
              BlocConsumer<ApplicationCubit, ApplicationState>(
                listener: (context, state) {
                  if (state is ApplicationStatusUpdated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Status updated to ${state.application.status.displayName}'),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                    Navigator.pop(context);
                    onRefresh();
                  } else if (state is ApplicationStatusUpdateError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppTheme.errorRed,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final isUpdating = state is ApplicationStatusUpdating;

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isUpdating
                          ? null
                          : () => _showConfirmDialog(
                                context,
                                title: 'Mark as Complete',
                                message: 'Have you finished all the work for this job?',
                                confirmLabel: 'Mark Complete',
                                onConfirm: () {
                                  context.read<ApplicationCubit>().updateApplicationStatus(
                                        applicationId: application.id,
                                        status: ApplicationStatus.COMPLETED,
                                      );
                                },
                              ),
                      icon: isUpdating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle, size: 20),
                      label: const Text('Mark Job as Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // ==================== HIRED/IN_PROGRESS: Can Mark Complete ====================
            if (application.status == ApplicationStatus.HIRED ||
                application.status == ApplicationStatus.IN_PROGRESS) ...[
              const SizedBox(height: 16),
              CompletionActions(
                applicationId: application.id,
                status: application.status,
                isJobSeeker: true,
                onActionCompleted: () {
                  Navigator.pop(context);
                  onRefresh();
                },
              ),
              const SizedBox(height: 24),
            ],

            // ==================== COMPLETED: Job Done ====================
            if (application.status == ApplicationStatus.COMPLETED) ...[
              _InfoBanner(
                icon: Icons.verified,
                color: AppTheme.successGreen,
                title: 'Job Completed!',
                message: 'Great work! This job has been completed successfully. Don\'t forget to leave a review.',
              ),
              const SizedBox(height: 24),
            ],

            // Job Details Section
            Text(
              'Job Details',
              style: TextStyle(
                color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.location_on,
              label: 'Location',
              value: application.job.location ?? 'Remote',
            ),
            if (application.job.salary != null)
              _DetailRow(
                icon: Icons.attach_money,
                label: 'Salary',
                value: '${application.job.salary!.toStringAsFixed(0)} DT',
              ),
            if (application.job.duration != null)
              _DetailRow(
                icon: Icons.access_time,
                label: 'Duration',
                value: application.job.duration!,
              ),
            const SizedBox(height: 24),

            // ==================== Action Buttons ====================
            Row(
              children: [
                // Chat button
                if (recruiterUserId != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (_) => ChatCubit(ChatRepository()),
                              child: ChatScreen(
                                userId: recruiterUserId,
                                userName: recruiterName,
                                userRole: 'RECRUITER',
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text('Chat with Recruiter'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accentBlue,
                        side: const BorderSide(color: AppTheme.accentBlue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),

            // Review button (only for COMPLETED) - Full width for emphasis
            if (application.status == ApplicationStatus.COMPLETED) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await showCreateReviewDialog(
                      context: context,
                      jobApplicationId: application.id,
                      applicantName: recruiterName,
                    );
                    onRefresh();
                  },
                  icon: const Icon(Icons.star, size: 20),
                  label: const Text('Leave a Review for Recruiter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentYellow,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? AppTheme.errorRed : AppTheme.accentGreen,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}

/// Shows detailed view of an applicant with completion actions
/// For Recruiters viewing applicants
void showRecruiterApplicationDetail(
  BuildContext context,
  JobApplication application,
  VoidCallback onRefresh,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => BlocProvider(
      create: (_) => ApplicationCubit(ApplicationRepository()),
      child: _RecruiterApplicationDetailSheet(
        application: application,
        onRefresh: onRefresh,
      ),
    ),
  );
}

class _RecruiterApplicationDetailSheet extends StatelessWidget {
  final JobApplication application;
  final VoidCallback onRefresh;

  const _RecruiterApplicationDetailSheet({
    required this.application,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final jobSeeker = application.jobSeeker;
    final jobSeekerUserId = jobSeeker.userId ?? jobSeeker.user?.id;

    return BlocConsumer<ApplicationCubit, ApplicationState>(
      listener: (context, state) {
        if (state is ApplicationStatusUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Application ${state.application.status.displayName}'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          Navigator.pop(context);
          onRefresh();
        } else if (state is ApplicationStatusUpdateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      },
      builder: (context, state) {
        final isUpdating = state is ApplicationStatusUpdating;

        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) => Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Applicant Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
                      child: const Icon(
                        Icons.person,
                        color: AppTheme.accentBlue,
                        size: 35,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jobSeeker.fullName,
                            style: TextStyle(
                              color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (jobSeeker.phoneNumber != null)
                            Text(
                              jobSeeker.phoneNumber!,
                              style: TextStyle(
                                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                                fontSize: 14,
                              ),
                            ),
                          if (jobSeekerUserId != null) ...[
                            const SizedBox(height: 4),
                            UserRatingWidget(
                              userId: jobSeekerUserId,
                              size: 14,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Application Flow Progress Indicator
                _ApplicationFlowIndicator(status: application.status),
                const SizedBox(height: 20),

                // Status Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.primaryBlack : AppTheme.lightGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Status',
                              style: TextStyle(
                                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Color(application.status.colorValue),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                application.status.displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Applied',
                              style: TextStyle(
                                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM dd, yyyy').format(application.appliedAt),
                              style: TextStyle(
                                color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                                fontWeight: FontWeight.w600,
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

                // ==================== PENDING: Accept/Reject Section ====================
                if (application.status == ApplicationStatus.PENDING) ...[
                  Text(
                    'Review Application',
                    style: TextStyle(
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Accept this applicant to start working together, or reject if not a good fit.',
                    style: TextStyle(
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isUpdating
                              ? null
                              : () => _showConfirmDialog(
                                    context,
                                    title: 'Reject Application',
                                    message: 'Are you sure you want to reject this application? The applicant will be notified.',
                                    confirmLabel: 'Reject',
                                    isDestructive: true,
                                    onConfirm: () {
                                      context.read<ApplicationCubit>().updateApplicationStatus(
                                            applicationId: application.id,
                                            status: ApplicationStatus.REJECTED,
                                          );
                                    },
                                  ),
                          icon: isUpdating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.close, size: 18),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorRed,
                            side: const BorderSide(color: AppTheme.errorRed),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isUpdating
                              ? null
                              : () => _showConfirmDialog(
                                    context,
                                    title: 'Accept Application',
                                    message: 'Accept this applicant? They will be notified and can start working once they confirm.',
                                    confirmLabel: 'Accept',
                                    onConfirm: () {
                                      context.read<ApplicationCubit>().updateApplicationStatus(
                                            applicationId: application.id,
                                            status: ApplicationStatus.ACCEPTED,
                                          );
                                    },
                                  ),
                          icon: isUpdating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check, size: 18),
                          label: const Text('Accept'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // ==================== VIEWED: Accept/Reject Section ====================
                if (application.status == ApplicationStatus.VIEWED) ...[
                  Text(
                    'Review Application',
                    style: TextStyle(
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have viewed this application. Accept to proceed or reject if not suitable.',
                    style: TextStyle(
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isUpdating
                              ? null
                              : () => _showConfirmDialog(
                                    context,
                                    title: 'Reject Application',
                                    message: 'Are you sure you want to reject this application?',
                                    confirmLabel: 'Reject',
                                    isDestructive: true,
                                    onConfirm: () {
                                      context.read<ApplicationCubit>().updateApplicationStatus(
                                            applicationId: application.id,
                                            status: ApplicationStatus.REJECTED,
                                          );
                                    },
                                  ),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorRed,
                            side: const BorderSide(color: AppTheme.errorRed),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isUpdating
                              ? null
                              : () => _showConfirmDialog(
                                    context,
                                    title: 'Accept Application',
                                    message: 'Accept this applicant?',
                                    confirmLabel: 'Accept',
                                    onConfirm: () {
                                      context.read<ApplicationCubit>().updateApplicationStatus(
                                            applicationId: application.id,
                                            status: ApplicationStatus.ACCEPTED,
                                          );
                                    },
                                  ),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Accept'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // ==================== ACCEPTED: Mark Complete + Review Option ====================
                if (application.status == ApplicationStatus.ACCEPTED) ...[
                  _InfoBanner(
                    icon: Icons.check_circle,
                    color: AppTheme.successGreen,
                    title: 'Applicant Accepted',
                    message: 'Mark the job as completed to enable reviews.',
                  ),
                  const SizedBox(height: 16),
                  // Mark as Complete button (Required for reviews)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isUpdating
                          ? null
                          : () => _showConfirmDialog(
                                context,
                                title: 'Mark as Complete',
                                message: 'Mark this job as completed? This will allow both parties to leave reviews.',
                                confirmLabel: 'Mark Complete',
                                onConfirm: () {
                                  context.read<ApplicationCubit>().updateApplicationStatus(
                                        applicationId: application.id,
                                        status: ApplicationStatus.COMPLETED,
                                      );
                                },
                              ),
                      icon: isUpdating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle, size: 20),
                      label: const Text('Mark Job as Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ==================== Job Progress Section (IN_PROGRESS onwards) ====================
                if (application.status == ApplicationStatus.IN_PROGRESS ||
                    application.status == ApplicationStatus.PENDING_COMPLETION ||
                    application.status == ApplicationStatus.COMPLETED) ...[
                  Text(
                    'Job Progress',
                    style: TextStyle(
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CompletionActions(
                    applicationId: application.id,
                    status: application.status,
                    isJobSeeker: false,
                    onActionCompleted: () {
                      Navigator.pop(context);
                      onRefresh();
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // ==================== REJECTED: Status Message ====================
                if (application.status == ApplicationStatus.REJECTED) ...[
                  _InfoBanner(
                    icon: Icons.cancel,
                    color: AppTheme.errorRed,
                    title: 'Application Rejected',
                    message: 'This application has been rejected.',
                  ),
                  const SizedBox(height: 24),
                ],

                // ==================== Action Buttons ====================
                Row(
                  children: [
                    // Chat button
                    if (jobSeekerUserId != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider(
                                  create: (_) => ChatCubit(ChatRepository()),
                                  child: ChatScreen(
                                    userId: jobSeekerUserId,
                                    userName: jobSeeker.fullName,
                                    userRole: 'JOB_SEEKER',
                                  ),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                          label: const Text('Chat'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.accentBlue,
                            side: const BorderSide(color: AppTheme.accentBlue),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    if (jobSeekerUserId != null) const SizedBox(width: 12),

                    // Review button (only for COMPLETED)
                    if (application.status == ApplicationStatus.COMPLETED)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            await showCreateReviewDialog(
                              context: context,
                              jobApplicationId: application.id,
                              applicantName: jobSeeker.fullName,
                            );
                            onRefresh();
                          },
                          icon: const Icon(Icons.star_outline, size: 18),
                          label: const Text('Leave Review'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentYellow,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                  ],
                ),

                // CV Button
                if (jobSeeker.cvUrl != null) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening CV...')),
                      );
                    },
                    icon: const Icon(Icons.description, size: 18),
                    label: const Text('View CV'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accentGreen,
                      side: const BorderSide(color: AppTheme.accentGreen),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? AppTheme.errorRed : AppTheme.accentBlue,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}

/// Visual indicator showing the application lifecycle flow
class _ApplicationFlowIndicator extends StatelessWidget {
  final ApplicationStatus status;

  const _ApplicationFlowIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Define the main flow steps
    final steps = [
      _FlowStep('Applied', Icons.description, _getStepState(0)),
      _FlowStep('Accepted', Icons.check_circle, _getStepState(1)),
      _FlowStep('In Progress', Icons.engineering, _getStepState(2)),
      _FlowStep('Completed', Icons.verified, _getStepState(3)),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.primaryBlack : AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Progress',
            style: TextStyle(
              color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                Expanded(child: _buildStep(context, steps[i])),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: steps[i].state == _StepState.completed
                          ? AppTheme.successGreen
                          : (isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey),
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  _StepState _getStepState(int stepIndex) {
    // If rejected, show special state
    if (status == ApplicationStatus.REJECTED) {
      if (stepIndex == 0) return _StepState.completed;
      return _StepState.inactive;
    }

    switch (stepIndex) {
      case 0: // Applied
        return _StepState.completed;
      case 1: // Accepted
        if (status == ApplicationStatus.PENDING || status == ApplicationStatus.VIEWED) {
          return _StepState.current;
        }
        return status.index >= ApplicationStatus.ACCEPTED.index
            ? _StepState.completed
            : _StepState.inactive;
      case 2: // In Progress
        if (status == ApplicationStatus.ACCEPTED) {
          return _StepState.current;
        }
        if (status == ApplicationStatus.IN_PROGRESS ||
            status == ApplicationStatus.PENDING_COMPLETION) {
          return _StepState.current;
        }
        return status == ApplicationStatus.COMPLETED
            ? _StepState.completed
            : _StepState.inactive;
      case 3: // Completed
        if (status == ApplicationStatus.PENDING_COMPLETION) {
          return _StepState.current;
        }
        return status == ApplicationStatus.COMPLETED
            ? _StepState.completed
            : _StepState.inactive;
      default:
        return _StepState.inactive;
    }
  }

  Widget _buildStep(BuildContext context, _FlowStep step) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color iconColor;
    Color bgColor;

    switch (step.state) {
      case _StepState.completed:
        iconColor = Colors.white;
        bgColor = AppTheme.successGreen;
        break;
      case _StepState.current:
        iconColor = Colors.white;
        bgColor = AppTheme.accentBlue;
        break;
      case _StepState.inactive:
        iconColor = isDark ? AppTheme.textGrey : AppTheme.textDarkGrey;
        bgColor = isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey;
        break;
    }

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(step.icon, size: 16, color: iconColor),
        ),
        const SizedBox(height: 4),
        Text(
          step.label,
          style: TextStyle(
            color: step.state == _StepState.inactive
                ? (isDark ? AppTheme.textGrey : AppTheme.textDarkGrey)
                : (isDark ? AppTheme.textWhite : AppTheme.textBlack),
            fontSize: 10,
            fontWeight: step.state == _StepState.current ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

enum _StepState { inactive, current, completed }

class _FlowStep {
  final String label;
  final IconData icon;
  final _StepState state;

  _FlowStep(this.label, this.icon, this.state);
}

/// Info banner for status messages
class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;

  const _InfoBanner({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
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
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
