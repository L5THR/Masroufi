import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import 'package:flutter_alinfo9/main.dart';
import 'package:flutter_alinfo9/views/admin/logic/admin_dashboard_cubit.dart';
import 'package:flutter_alinfo9/views/admin/logic/admin_users_cubit.dart';
import 'package:flutter_alinfo9/views/admin/logic/admin_reports_cubit.dart';
import 'package:flutter_alinfo9/views/admin/data/repositories/admin_repository.dart';
import 'package:flutter_alinfo9/views/admin/data/models/user_account.dart';
import 'package:flutter_alinfo9/views/admin/data/models/report.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Admin Dashboard Screen with full BLoC integration
class AdminDashboardIntegrated extends StatelessWidget {
  const AdminDashboardIntegrated({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AdminDashboardCubit(
            repository: AdminRepository(),
          )..loadDashboard(),
        ),
        BlocProvider(
          create: (_) => AdminUsersCubit(
            repository: AdminRepository(),
          )..loadUsers(),
        ),
        BlocProvider(
          create: (_) => AdminReportsCubit(
            repository: AdminRepository(),
          )..loadReports(),
        ),
      ],
      child: const _AdminDashboardContent(),
    );
  }
}

class _AdminDashboardContent extends StatefulWidget {
  const _AdminDashboardContent({Key? key}) : super(key: key);

  @override
  State<_AdminDashboardContent> createState() => _AdminDashboardContentState();
}

class _AdminDashboardContentState extends State<_AdminDashboardContent> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor:
              isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen to action success states for snackbars
    return MultiBlocListener(
      listeners: [
        BlocListener<AdminUsersCubit, AdminUsersState>(
          listener: (context, state) {
            if (state is AdminUsersActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.accentGreen,
                ),
              );
            } else if (state is AdminUsersError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.errorRed,
                ),
              );
            }
          },
        ),
        BlocListener<AdminReportsCubit, AdminReportsState>(
          listener: (context, state) {
            if (state is AdminReportsActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.accentGreen,
                ),
              );
            } else if (state is AdminReportsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.errorRed,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(
                isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              onPressed: () {
                MasroufiApp.of(context)!.toggleTheme();
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
          ],
        ),
        body: _buildBody(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 4) {
              _handleLogout();
            } else {
              setState(() => _selectedIndex = index);
            }
          },
          backgroundColor:
              isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
          selectedItemColor: AppTheme.accentBlue,
          unselectedItemColor:
              isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.people), label: 'Users'),
            BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
            BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Reports'),
            BottomNavigationBarItem(
                icon: Icon(Icons.logout), label: 'Logout'),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildUsersTab();
      case 2:
        return _buildJobsTab();
      case 3:
        return _buildReportsTab();
      default:
        return _buildDashboardTab();
    }
  }

  // ==================== DASHBOARD TAB ====================

  Widget _buildDashboardTab() {
    return BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
      builder: (context, state) {
        if (state is AdminDashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminDashboardError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 64, color: AppTheme.errorRed),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<AdminDashboardCubit>().refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is AdminDashboardLoaded) {
          return RefreshIndicator(
            onRefresh: () => context.read<AdminDashboardCubit>().refresh(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsSection(state),
                  const SizedBox(height: 24),
                  _buildActivitiesSection(state),
                ],
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildStatsSection(AdminDashboardLoaded state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.people,
                title: 'Total Users',
                value: state.stats.totalUsers.toString(),
                color: AppTheme.accentBlue,
                trend: '+${state.stats.totalUsers}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.work,
                title: 'Active Jobs',
                value: state.stats.activeJobs.toString(),
                color: AppTheme.accentGreen,
                trend: '+${state.stats.activeJobs}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.check_circle,
                title: 'Completed',
                value: state.stats.completedJobs.toString(),
                color: AppTheme.warningYellow,
                trend: '+${state.stats.completedJobs}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.flag,
                title: 'Reports',
                value: state.stats.reports.toString(),
                color: AppTheme.errorRed,
                trend: state.stats.reports > 0 ? '+${state.stats.reports}' : '0',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivitiesSection(AdminDashboardLoaded state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (state.activities.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'No recent activities',
                style: TextStyle(
                  color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                ),
              ),
            ),
          )
        else
          ...state.activities.map((activity) {
            return _ActivityItem(
              icon: _getIconForActivityType(activity.type),
              title: activity.type,
              subtitle: activity.message,
              time: timeago.format(activity.createdAt),
            );
          }),
      ],
    );
  }

  IconData _getIconForActivityType(String type) {
    switch (type.toUpperCase()) {
      case 'USER_REGISTERED':
        return Icons.person_add;
      case 'JOB_POSTED':
        return Icons.work;
      case 'REPORT_CREATED':
        return Icons.flag;
      case 'APPLICATION_SUBMITTED':
        return Icons.send;
      default:
        return Icons.info_outline;
    }
  }

  // ==================== USERS TAB ====================

  Widget _buildUsersTab() {
    return BlocBuilder<AdminUsersCubit, AdminUsersState>(
      builder: (context, state) {
        if (state is AdminUsersLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminUsersError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 64, color: AppTheme.errorRed),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<AdminUsersCubit>().refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is AdminUsersLoaded) {
          return RefreshIndicator(
            onRefresh: () => context.read<AdminUsersCubit>().refresh(),
            child: Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: state.users.isEmpty
                      ? const Center(child: Text('No users found'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.users.length +
                              (state.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.users.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final user = state.users[index];
                            return _UserManagementCard(
                              user: user,
                              onBlock: () => _confirmBlockUser(context, user),
                              onUnblock: () =>
                                  _confirmUnblockUser(context, user),
                              onDelete: () => _confirmDeleteUser(context, user),
                              onChangeRole: () =>
                                  _showChangeRoleDialog(context, user),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search users by email...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<AdminUsersCubit>().searchUsers('');
                  },
                )
              : null,
          filled: true,
          fillColor: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (query) {
          context.read<AdminUsersCubit>().searchUsers(query);
        },
      ),
    );
  }

  // ==================== JOBS TAB ====================

  Widget _buildJobsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          'Jobs management coming soon...\n\nYou can view all jobs using the existing job list endpoint.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
          ),
        ),
      ),
    );
  }

  // ==================== REPORTS TAB ====================

  Widget _buildReportsTab() {
    return BlocBuilder<AdminReportsCubit, AdminReportsState>(
      builder: (context, state) {
        if (state is AdminReportsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminReportsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 64, color: AppTheme.errorRed),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<AdminReportsCubit>().refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is AdminReportsLoaded) {
          return RefreshIndicator(
            onRefresh: () => context.read<AdminReportsCubit>().refresh(),
            child: state.reports.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle,
                            size: 64, color: AppTheme.accentGreen),
                        SizedBox(height: 16),
                        Text('No reports found'),
                        SizedBox(height: 8),
                        Text('All clear!',
                            style: TextStyle(color: AppTheme.textGrey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.reports.length +
                        (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.reports.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final report = state.reports[index];
                      return _ReportCard(
                        report: report,
                        onDismiss: () => _confirmDismissReport(context, report),
                        onTakeAction: () =>
                            _showReportActionDialog(context, report),
                      );
                    },
                  ),
          );
        }

        return const SizedBox();
      },
    );
  }

  // ==================== DIALOGS ====================

  void _confirmBlockUser(BuildContext context, UserAccount user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Block User'),
        content: Text('Are you sure you want to block ${user.email}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminUsersCubit>().blockUser(user.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _confirmUnblockUser(BuildContext context, UserAccount user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unblock User'),
        content: Text('Are you sure you want to unblock ${user.email}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminUsersCubit>().unblockUser(user.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
            ),
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, UserAccount user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to permanently delete ${user.email}?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminUsersCubit>().deleteUser(user.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showChangeRoleDialog(BuildContext context, UserAccount user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change User Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Job Seeker'),
              onTap: () {
                Navigator.pop(ctx);
                context
                    .read<AdminUsersCubit>()
                    .changeUserRole(user.id, 'JOB_SEEKER');
              },
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Recruiter'),
              onTap: () {
                Navigator.pop(ctx);
                context
                    .read<AdminUsersCubit>()
                    .changeUserRole(user.id, 'RECRUITER');
              },
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Admin'),
              onTap: () {
                Navigator.pop(ctx);
                context
                    .read<AdminUsersCubit>()
                    .changeUserRole(user.id, 'ADMIN');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDismissReport(BuildContext context, Report report) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dismiss Report'),
        content: const Text('Mark this report as resolved?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminReportsCubit>().dismissReport(report.id);
            },
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  void _showReportActionDialog(BuildContext context, Report report) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report Actions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility, color: AppTheme.accentBlue),
              title: const Text('Mark as Under Review'),
              onTap: () {
                Navigator.pop(ctx);
                context
                    .read<AdminReportsCubit>()
                    .markAsUnderReview(report.id);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.check_circle, color: AppTheme.accentGreen),
              title: const Text('Resolve Report'),
              onTap: () {
                Navigator.pop(ctx);
                context.read<AdminReportsCubit>().resolveReport(report.id);
              },
            ),
            const Divider(),
            if (report.isJobReport)
              ListTile(
                leading: const Icon(Icons.work),
                title: Text('View Job #${report.targetId}'),
                onTap: () {
                  Navigator.pop(ctx);
                  // TODO: Navigate to job details
                },
              ),
            if (report.isUserReport)
              ListTile(
                leading: const Icon(Icons.person),
                title: Text('View User #${report.targetId}'),
                onTap: () {
                  Navigator.pop(ctx);
                  // TODO: Navigate to user details
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ==================== WIDGETS ====================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final String trend;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
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
            title,
            style: TextStyle(
                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            trend,
            style: const TextStyle(
              color: AppTheme.accentGreen,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
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
            color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.accentBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _UserManagementCard extends StatelessWidget {
  final UserAccount user;
  final VoidCallback onBlock;
  final VoidCallback onUnblock;
  final VoidCallback onDelete;
  final VoidCallback onChangeRole;

  const _UserManagementCard({
    required this.user,
    required this.onBlock,
    required this.onUnblock,
    required this.onDelete,
    required this.onChangeRole,
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
            color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
                child: Text(
                  user.email[0].toUpperCase(),
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
                      user.email,
                      style: TextStyle(
                        color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Role: ${user.role}',
                      style: TextStyle(
                        color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: user.isActive
                      ? AppTheme.accentGreen.withValues(alpha: 0.2)
                      : AppTheme.errorRed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  user.status,
                  style: TextStyle(
                    color: user.isActive
                        ? AppTheme.accentGreen
                        : AppTheme.errorRed,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onChangeRole,
                  child: const Text('Change Role', style: TextStyle(fontSize: 12)),
                ),
              ),
              if (user.isActive)
                Expanded(
                  child: TextButton(
                    onPressed: onBlock,
                    child: const Text(
                      'Block',
                      style: TextStyle(color: AppTheme.errorRed, fontSize: 12),
                    ),
                  ),
                )
              else
                Expanded(
                  child: TextButton(
                    onPressed: onUnblock,
                    child: const Text(
                      'Unblock',
                      style:
                          TextStyle(color: AppTheme.accentGreen, fontSize: 12),
                    ),
                  ),
                ),
              Expanded(
                child: TextButton(
                  onPressed: onDelete,
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: AppTheme.errorRed, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback onDismiss;
  final VoidCallback onTakeAction;

  const _ReportCard({
    required this.report,
    required this.onDismiss,
    required this.onTakeAction,
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
            color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  report.targetType,
                  style: const TextStyle(
                    color: AppTheme.errorRed,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                timeago.format(report.createdAt),
                style: TextStyle(
                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                    fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            report.reason,
            style: TextStyle(
              color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Reported by: ${report.reporter.email}',
            style: TextStyle(
                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'Status: ${report.status}',
            style: TextStyle(
                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDismiss,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.textGrey),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Dismiss'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onTakeAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentBlue,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Take Action'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
