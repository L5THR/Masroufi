// lib/views/recruiter/presentation/pages/recruiter_home_screen.dart

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_alinfo9/views/applications/data/models/job_application.dart';
import 'package:flutter_alinfo9/views/recruiter/logic/recruiter_applicants_cubit.dart';
import 'package:flutter_alinfo9/views/recruiter/logic/recruiter_applicants_state.dart';
import 'package:flutter_alinfo9/views/jobs/data/models/job.dart';
import 'package:flutter_alinfo9/views/recruiter/logic/recruiter_jobs_cubit.dart';
import 'package:flutter_alinfo9/views/recruiter/logic/recruiter_jobs_state.dart';
import 'package:flutter_alinfo9/views/recruiter/logic/recruiter_profile_cubit.dart';
import 'package:flutter_alinfo9/views/recruiter/logic/recruiter_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_theme.dart';
import '../../../../main.dart';
import '../../../auth/logic/cubit/auth_cubit.dart';

class RecruiterHomeScreen extends StatefulWidget {
  const RecruiterHomeScreen({Key? key}) : super(key: key);

  @override
  State<RecruiterHomeScreen> createState() => _RecruiterHomeScreenState();
}

class _RecruiterHomeScreenState extends State<RecruiterHomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<RecruiterJobsCubit>().getMyJobs();
    context.read<RecruiterApplicantsCubit>().getApplicantsForRecruiter();
    context.read<RecruiterProfileCubit>().getRecruiterProfile();
  }

  void _handleLogout() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppTheme.secondaryBlack
            : AppTheme.secondaryWhite,
        title: Text(
          'Logout',
          style: TextStyle(
            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthCubit>().logout();
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDeleteJob(BuildContext context, int jobId, String jobTitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark
            ? AppTheme.secondaryBlack
            : AppTheme.secondaryWhite,
        title: Text(
          'Delete Job',
          style: TextStyle(
            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$jobTitle"? This action cannot be undone.',
          style: TextStyle(
            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<RecruiterJobsCubit>().deleteJob(jobId);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Job "$jobTitle" deleted successfully'),
                  backgroundColor: AppTheme.successGreen,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('MASROUFI Recruiter'),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () {
              MasroufiApp.of(context)?.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/create-job');
              },
              icon: const Icon(Icons.add),
              label: const Text('Post Job'),
              backgroundColor: AppTheme.accentBlue,
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: isDark
            ? AppTheme.secondaryBlack
            : AppTheme.secondaryWhite,
        selectedItemColor: AppTheme.accentBlue,
        unselectedItemColor: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'My Jobs'),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Applicants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildMyJobsTab();
      case 1:
        return _buildApplicantsTab();
      case 2:
        return _buildMessagesTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildMyJobsTab();
    }
  }

  Widget _buildMyJobsTab() {
    return BlocBuilder<RecruiterJobsCubit, RecruiterJobsState>(
      builder: (context, state) {
        if (state is RecruiterJobsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is RecruiterJobsFailure) {
          log('Error loading jobs: ${state.error}');
          return Center(child: Text(state.error));
        }
        if (state is RecruiterJobsLoaded) {
          if (state.jobs.content.isEmpty) {
            return const Center(
              child: Text('You have not posted any jobs yet.'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<RecruiterJobsCubit>().getMyJobs();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _JobStatCard(jobs: state.jobs.content),
                const SizedBox(height: 20),
                Text(
                  'Active Jobs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ...state.jobs.content.map(
                  (job) => _RecruiterJobCard(
                    job: job,
                    onEdit: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/edit-job',
                        arguments: {'jobId': job.id},
                      );
                      if (result == true) {
                        // Refresh jobs list after successful edit
                        context.read<RecruiterJobsCubit>().refreshJobs();
                      }
                    },
                    onView: () {
                      Navigator.pushNamed(
                        context,
                        '/job-details',
                        arguments: {'isRecruiter': true, 'jobId': job.id},
                      );
                    },
                    onViewApplications: () {
                      Navigator.pushNamed(
                        context,
                        '/application-management',
                        arguments: {'jobId': job.id, 'jobTitle': job.title},
                      );
                    },
                    onDelete: () =>
                        _handleDeleteJob(context, job.id, job.title),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildApplicantsTab() {
    return BlocBuilder<RecruiterApplicantsCubit, RecruiterApplicantsState>(
      builder: (context, state) {
        if (state is RecruiterApplicantsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is RecruiterApplicantsFailure) {
          return Center(child: Text(state.error));
        }
        if (state is RecruiterApplicantsLoaded) {
          if (state.applicants.isEmpty) {
            return const Center(child: Text('You have no applicants yet.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<RecruiterApplicantsCubit>()
                  .getApplicantsForRecruiter();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.applicants.length,
              itemBuilder: (context, index) {
                final applicant = state.applicants[index];
                return _ApplicantCard(
                  application: applicant,
                  onAccept: () {
                    context.read<RecruiterApplicantsCubit>().acceptApplicant(
                      applicant.id,
                    );
                  },
                  onReject: () {
                    context.read<RecruiterApplicantsCubit>().rejectApplicant(
                      applicant.id,
                    );
                  },
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMessagesTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/chat');
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isDark
                    ? AppTheme.tertiaryGrey
                    : AppTheme.lightGrey,
                child: Icon(
                  Icons.person,
                  color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jane Smith',
                      style: TextStyle(
                        color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Thank you for considering...',
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.textGrey
                            : AppTheme.textDarkGrey,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                '1h ago',
                style: TextStyle(
                  color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return BlocBuilder<RecruiterProfileCubit, RecruiterProfileState>(
      builder: (context, state) {
        if (state is RecruiterProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is RecruiterProfileFailure) {
          return Center(child: Text(state.error));
        }
        if (state is RecruiterProfileLoaded) {
          final profile = state.profile;
          final recruiterProfile = profile.recruiterProfile;
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: recruiterProfile?.companyLogoUrl != null
                      ? NetworkImage(recruiterProfile!.companyLogoUrl!)
                      : null,
                  child: recruiterProfile?.companyLogoUrl == null
                      ? Icon(
                          Icons.business,
                          size: 50,
                          color: Theme.of(context).colorScheme.secondary,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  recruiterProfile?.companyName ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const _ProfileStatItem(label: 'Jobs Posted', value: '24'),
                      Container(
                        width: 1,
                        height: 40,
                        color: Theme.of(context).dividerColor,
                      ),
                      const _ProfileStatItem(label: 'Hired', value: '18'),
                      Container(
                        width: 1,
                        height: 40,
                        color: Theme.of(context).dividerColor,
                      ),
                      const _ProfileStatItem(label: 'Rating', value: '4.9'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _ProfileMenuItem(
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.pushNamed(context, '/edit-recruiter-profile');
                  },
                ),
                _ProfileMenuItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: _handleLogout,
                  isDestructive: true,
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ==================== WIDGETS ====================

class _JobStatCard extends StatelessWidget {
  final List<Job> jobs;
  const _JobStatCard({required this.jobs});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecruiterApplicantsCubit, RecruiterApplicantsState>(
      builder: (context, state) {
        int totalApplicants = 0;
        if (state is RecruiterApplicantsLoaded) {
          totalApplicants = state.applicants.length;
        }
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.accentBlue, Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatColumn(
                label: 'Active Jobs',
                value: jobs.where((j) => j.status == 'OPEN').length.toString(),
              ),
              Container(width: 1, height: 40, color: Colors.white30),
              _StatColumn(
                label: 'Total Applicants',
                value: totalApplicants.toString(),
              ),
              Container(width: 1, height: 40, color: Colors.white30),
              const _StatColumn(
                label: 'Hired',
                value: '0',
              ), // This is dummy data
            ],
          ),
        );
      },
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

class _RecruiterJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onEdit;
  final VoidCallback onView;
  final VoidCallback onViewApplications;
  final VoidCallback onDelete;

  const _RecruiterJobCard({
    required this.job,
    required this.onEdit,
    required this.onView,
    required this.onViewApplications,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  job.title,
                  style: TextStyle(
                    color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: job.status == 'OPEN'
                          ? AppTheme.accentGreen.withOpacity(0.2)
                          : AppTheme.textGrey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      job.status,
                      style: TextStyle(
                        color: job.status == 'OPEN'
                            ? AppTheme.accentGreen
                            : AppTheme.textGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                    ),
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete,
                              color: AppTheme.errorRed,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Delete Job',
                              style: TextStyle(color: AppTheme.errorRed),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          BlocBuilder<RecruiterApplicantsCubit, RecruiterApplicantsState>(
            builder: (context, state) {
              int applicantCount = 0;
              if (state is RecruiterApplicantsLoaded) {
                applicantCount = state.applicants
                    .where((element) => element.job.id == job.id)
                    .length;
              }
              return Row(
                children: [
                  Icon(
                    Icons.people,
                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$applicantCount applicants',
                    style: TextStyle(
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    job.createdAt.toString().substring(0, 10),
                    style: TextStyle(
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // ✅ NEW: Applications Button
          BlocBuilder<RecruiterApplicantsCubit, RecruiterApplicantsState>(
            builder: (context, state) {
              int applicantCount = 0;
              if (state is RecruiterApplicantsLoaded) {
                applicantCount = state.applicants
                    .where((element) => element.job.id == job.id)
                    .length;
              }
              return OutlinedButton.icon(
                onPressed: onViewApplications,
                icon: const Icon(Icons.people_outline),
                label: Text('View Applications ($applicantCount)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accentBlue,
                  side: const BorderSide(color: AppTheme.accentBlue),
                  minimumSize: const Size(double.infinity, 40),
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // Edit and View Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.accentBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onView,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('View'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final JobApplication application;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const _ApplicantCard({
    required this.application,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isDark
                    ? AppTheme.tertiaryGrey
                    : AppTheme.lightGrey,
                child: Text(
                  application.jobSeeker.firstName[0],
                  style: TextStyle(
                    color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${application.jobSeeker.firstName} ${application.jobSeeker.lastName}',
                      style: TextStyle(
                        color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      application.job.title,
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
          const SizedBox(height: 12),
          Text(
            'Applied ${application.appliedAt.toString().substring(0, 10)}',
            style: TextStyle(
              color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
              fontSize: 12,
            ),
          ),
          if (application.status.toApiString() != 'PENDING') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: application.status == 'ACCEPTED'
                    ? AppTheme.accentGreen.withOpacity(0.2)
                    : AppTheme.errorRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                application.status.toApiString(),
                style: TextStyle(
                  color: application.status == 'ACCEPTED'
                      ? AppTheme.accentGreen
                      : AppTheme.errorRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.errorRed),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Reject',
                      style: TextStyle(color: AppTheme.errorRed),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileStatItem extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive
            ? AppTheme.errorRed
            : (isDark ? AppTheme.textGrey : AppTheme.textDarkGrey),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive
              ? AppTheme.errorRed
              : (isDark ? AppTheme.textWhite : AppTheme.textBlack),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}
