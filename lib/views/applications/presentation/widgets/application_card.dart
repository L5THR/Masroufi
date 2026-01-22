// lib/views/applications/presentation/widgets/application_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_theme.dart';
import '../../data/models/job_application.dart';
import '../../data/models/application_status.dart';
import 'application_status_badge.dart';
import '../../../reviews/presentation/widgets/user_rating_widget.dart';

class ApplicationCard extends StatelessWidget {
  final JobApplication application;
  final VoidCallback onTap;
  final VoidCallback? onChat; // Optional chat button callback
  final VoidCallback? onReview; // Optional review button callback
  final bool showJobSeeker; // true for recruiters to see applicant info

  const ApplicationCard({
    super.key,
    required this.application,
    required this.onTap,
    this.onChat,
    this.onReview,
    this.showJobSeeker = false,
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
          color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Company Logo / Profile Picture
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: showJobSeeker
                      ? _buildProfileIcon()
                      : _buildCompanyIcon(),
                ),
                const SizedBox(width: 12),
                // Job/Applicant Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        showJobSeeker
                            ? application.jobSeeker.fullName
                            : application.job.title,
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.textWhite
                              : AppTheme.textBlack,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        showJobSeeker
                            ? application.jobSeeker.phoneNumber ?? 'No phone'
                            : application.job.recruiter?.companyName ?? 'N/A',
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.textGrey
                              : AppTheme.textDarkGrey,
                          fontSize: 14,
                        ),
                      ),
                      // Show rating for job seeker or recruiter
                      const SizedBox(height: 4),
                      if (showJobSeeker && application.jobSeeker.userId != null)
                        UserRatingWidget(
                          userId: application.jobSeeker.userId!,
                          size: 14,
                          showCount: true,
                        )
                      else if (!showJobSeeker && application.job.recruiter?.userId != null)
                        UserRatingWidget(
                          userId: application.job.recruiter!.userId!,
                          size: 14,
                          showCount: true,
                        ),
                    ],
                  ),
                ),
                // Status Badge
                ApplicationStatusBadge(status: application.status),
              ],
            ),
            const SizedBox(height: 16),

            // Job Details (only for job seeker view)
            if (!showJobSeeker) ...[
              _buildInfoRow(
                icon: Icons.location_on,
                text: application.job.location ?? 'Remote',
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.attach_money,
                text: application.job.salary != null
                    ? '${application.job.salary!.toStringAsFixed(0)} DT'
                    : 'Not specified',
                isDark: isDark,
              ),
              const SizedBox(height: 8),
            ],

            // Applied Date
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Applied ${_formatDate(application.appliedAt)}',
                  style: TextStyle(
                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                  size: 16,
                ),
              ],
            ),

            // Chat Button (if callback provided)
            if (onChat != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onChat,
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: Text(
                    showJobSeeker
                        ? 'Chat with Applicant'
                        : 'Chat with Recruiter',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentBlue,
                    side: const BorderSide(color: AppTheme.accentBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],

            // Review Button (if callback provided and status is COMPLETED)
            if (onReview != null && application.status == ApplicationStatus.COMPLETED) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onReview,
                  icon: const Icon(Icons.star_outline, size: 18),
                  label: Text(
                    showJobSeeker
                        ? 'Review Job Seeker'
                        : 'Review Recruiter',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentYellow,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyIcon() {
    return const Icon(Icons.business, color: AppTheme.accentBlue, size: 24);
  }

  Widget _buildProfileIcon() {
    return const Icon(Icons.person, color: AppTheme.accentBlue, size: 24);
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
}
