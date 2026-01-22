// lib/views/applications/presentation/widgets/completion_actions.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import '../../data/models/application_status.dart';
import '../../logic/application_cubit.dart';
import '../../logic/application_state.dart';

/// Widget that displays completion action buttons based on application status
/// Simplified flow: ACCEPTED → COMPLETED (direct)
class CompletionActions extends StatelessWidget {
  final int applicationId;
  final ApplicationStatus status;
  final bool isJobSeeker;
  final VoidCallback? onActionCompleted;

  const CompletionActions({
    super.key,
    required this.applicationId,
    required this.status,
    required this.isJobSeeker,
    this.onActionCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ApplicationCubit, ApplicationState>(
      listener: (context, state) {
        if (state is ApplicationStatusUpdated) {
          final newStatus = state.application.status;
          if (newStatus == ApplicationStatus.COMPLETED) {
            _showSuccessMessage(context, 'Job marked as completed! You can now leave a review.');
          } else {
            _showSuccessMessage(context, 'Status updated to ${newStatus.displayName}');
          }
          onActionCompleted?.call();
        } else if (state is ApplicationStatusUpdateError) {
          _showErrorMessage(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is ApplicationStatusUpdating;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ACCEPTED: Show "Mark as Complete" button (Either party can do this)
            if (status == ApplicationStatus.ACCEPTED) ...[
              _AcceptedBanner(isJobSeeker: isJobSeeker),
              const SizedBox(height: 16),
              _ActionButton(
                label: 'Mark Job as Complete',
                icon: Icons.check_circle,
                color: AppTheme.accentGreen,
                isLoading: isLoading,
                onPressed: () {
                  _showConfirmDialog(
                    context,
                    title: 'Mark as Complete',
                    message: isJobSeeker
                        ? 'Have you finished all the work for this job?'
                        : 'Has the job seeker completed all the work?',
                    confirmLabel: 'Mark Complete',
                    onConfirm: () {
                      context.read<ApplicationCubit>().updateApplicationStatus(
                            applicationId: applicationId,
                            status: ApplicationStatus.COMPLETED,
                          );
                    },
                  );
                },
              ),
            ],

            // IN_PROGRESS: Also show "Mark as Complete" (in case backend has this status)
            if (status == ApplicationStatus.IN_PROGRESS) ...[
              _InProgressBanner(),
              const SizedBox(height: 16),
              _ActionButton(
                label: 'Mark Job as Complete',
                icon: Icons.check_circle,
                color: AppTheme.accentGreen,
                isLoading: isLoading,
                onPressed: () {
                  _showConfirmDialog(
                    context,
                    title: 'Mark as Complete',
                    message: 'Confirm that this job has been completed?',
                    confirmLabel: 'Mark Complete',
                    onConfirm: () {
                      context.read<ApplicationCubit>().updateApplicationStatus(
                            applicationId: applicationId,
                            status: ApplicationStatus.COMPLETED,
                          );
                    },
                  );
                },
              ),
            ],

            // HIRED: Also allow marking as complete
            if (status == ApplicationStatus.HIRED) ...[
              _HiredBanner(),
              const SizedBox(height: 16),
              _ActionButton(
                label: 'Mark Job as Complete',
                icon: Icons.check_circle,
                color: AppTheme.accentGreen,
                isLoading: isLoading,
                onPressed: () {
                  _showConfirmDialog(
                    context,
                    title: 'Mark as Complete',
                    message: 'Confirm that this job has been completed?',
                    confirmLabel: 'Mark Complete',
                    onConfirm: () {
                      context.read<ApplicationCubit>().updateApplicationStatus(
                            applicationId: applicationId,
                            status: ApplicationStatus.COMPLETED,
                          );
                    },
                  );
                },
              ),
            ],

            // COMPLETED: Show completed banner
            if (status == ApplicationStatus.COMPLETED)
              const _CompletedBanner(),
          ],
        );
      },
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.accentGreen,
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
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

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final bool isOutlined;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onPressed,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            : Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}

class _AcceptedBanner extends StatelessWidget {
  final bool isJobSeeker;

  const _AcceptedBanner({required this.isJobSeeker});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.successGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.successGreen),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.celebration,
            color: AppTheme.successGreen,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isJobSeeker ? 'You\'re Accepted!' : 'Applicant Accepted',
                  style: TextStyle(
                    color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isJobSeeker
                      ? 'Mark the job as complete when you\'re done with the work.'
                      : 'Mark the job as complete when the work is finished.',
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

class _InProgressBanner extends StatelessWidget {
  const _InProgressBanner();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentBlue),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.engineering,
            color: AppTheme.accentBlue,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Work In Progress',
                  style: TextStyle(
                    color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mark the job as complete when all work is finished.',
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

class _HiredBanner extends StatelessWidget {
  const _HiredBanner();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentBlue),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.work,
            color: AppTheme.accentBlue,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hired',
                  style: TextStyle(
                    color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mark the job as complete when all work is finished.',
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

class _CompletedBanner extends StatelessWidget {
  const _CompletedBanner();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentGreen),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: AppTheme.accentGreen,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Job Completed',
                  style: TextStyle(
                    color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This job has been completed. You can now leave a review!',
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

/// Compact version for use in cards
class CompletionStatusBadge extends StatelessWidget {
  final ApplicationStatus status;

  const CompletionStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    if (status == ApplicationStatus.IN_PROGRESS) {
      return _buildBadge(
        icon: Icons.engineering,
        label: 'In Progress',
        color: AppTheme.accentBlue,
      );
    }

    if (status == ApplicationStatus.HIRED) {
      return _buildBadge(
        icon: Icons.work,
        label: 'Hired',
        color: AppTheme.accentBlue,
      );
    }

    if (status == ApplicationStatus.COMPLETED) {
      return _buildBadge(
        icon: Icons.check_circle,
        label: 'Completed',
        color: AppTheme.accentGreen,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
