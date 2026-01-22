import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import 'package:flutter_alinfo9/main.dart';
import '../../logic/admin_dashboard_cubit.dart';
import '../../logic/admin_users_cubit.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/models/activity.dart';
import '../../data/models/user_account.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AdminDashboardCubit(
            repository: AdminRepository(),
          )..loadDashboard(), // Load data on init
        ),
        BlocProvider(
          create: (context) => AdminUsersCubit(
            repository: AdminRepository(),
          )..loadUsers(), // Load users on init
        ),
      ],
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
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
        backgroundColor: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
        selectedItemColor: AppTheme.accentBlue,
        unselectedItemColor: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
      ),
      ), // Scaffold
    ); // MultiBlocProvider
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

  Widget _buildDashboardTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
      builder: (context, state) {
        if (state is AdminDashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminDashboardError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load dashboard',
                    style: TextStyle(
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<AdminDashboardCubit>().loadDashboard();
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
        }

        if (state is AdminDashboardLoaded) {
          return RefreshIndicator(
            onRefresh: () => context.read<AdminDashboardCubit>().refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
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
                          trend: '+12%', // TODO: Add trend to backend
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.work,
                          title: 'Active Jobs',
                          value: state.stats.activeJobs.toString(),
                          color: AppTheme.accentGreen,
                          trend: '+5%', // TODO: Add trend to backend
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
                          trend: '+8%', // TODO: Add trend to backend
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.flag,
                          title: 'Reports',
                          value: state.stats.reports.toString(),
                          color: AppTheme.errorRed,
                          trend: '-3%', // TODO: Add trend to backend
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
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
                          'No recent activity',
                          style: TextStyle(
                            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    ...state.activities.map((activity) => _ActivityItem(
                      icon: _getActivityIcon(activity.type),
                      title: activity.type,
                      subtitle: activity.message,
                      time: _formatActivityTime(activity.createdAt),
                    )),
                ],
              ),
            ),
          );
        }

        // Initial state - show loading
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type.toUpperCase()) {
      case 'USER_REGISTERED':
        return Icons.person_add;
      case 'JOB_POSTED':
        return Icons.work;
      case 'REPORT_CREATED':
        return Icons.flag;
      case 'APPLICATION_SUBMITTED':
        return Icons.assignment;
      default:
        return Icons.notifications;
    }
  }

  String _formatActivityTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildUsersTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AdminUsersCubit, AdminUsersState>(
      listener: (context, state) {
        if (state is AdminUsersActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.accentGreen,
            ),
          );
        }

        if (state is AdminUsersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      },
      child: BlocBuilder<AdminUsersCubit, AdminUsersState>(
        builder: (context, state) {
          if (state is AdminUsersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminUsersError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load users',
                      style: TextStyle(
                        color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: TextStyle(
                        color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<AdminUsersCubit>().loadUsers();
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
          }

          if (state is AdminUsersLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<AdminUsersCubit>().refresh(),
              child: Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Management',
                          style: TextStyle(
                            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search users by email...',
                              border: InputBorder.none,
                              icon: Icon(
                                Icons.search,
                                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                              ),
                            ),
                            onChanged: (query) {
                              context.read<AdminUsersCubit>().searchUsers(query);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Users list
                  Expanded(
                    child: state.users.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 64,
                                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    state.searchQuery != null && state.searchQuery!.isNotEmpty
                                        ? 'No users found'
                                        : 'No users yet',
                                    style: TextStyle(
                                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    state.searchQuery != null && state.searchQuery!.isNotEmpty
                                        ? 'Try a different search term'
                                        : 'Users will appear here once they register',
                                    style: TextStyle(
                                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: state.users.length + (state.isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == state.users.length) {
                                // Load more indicator
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final user = state.users[index];
                              return _UserManagementCard(
                                user: user,
                                name: user.email?.split('@')[0] ?? 'User #${user.id}', // Use email prefix as name
                                email: user.displayName,
                                role: _formatRole(user.role ?? 'Unknown'),
                                status: user.status ?? 'ACTIVE',
                                isBlocked: user.status == 'BLOCKED',
                                onBlock: () => _confirmBlockUser(context, user),
                                onUnblock: () => _confirmUnblockUser(context, user),
                                onDelete: () => _confirmDeleteUser(context, user),
                                onChangeRole: () => _showChangeRoleDialog(context, user),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          }

          // Initial state - show loading
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  String _formatRole(String role) {
    switch (role.toUpperCase()) {
      case 'JOB_SEEKER':
        return 'Job Seeker';
      case 'RECRUITER':
        return 'Recruiter';
      case 'ADMIN':
        return 'Admin';
      default:
        return role;
    }
  }

  // User action dialog methods
  void _confirmBlockUser(BuildContext context, UserAccount user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
        title: Text(
          'Block User',
          style: TextStyle(
            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
          ),
        ),
        content: Text(
          'Are you sure you want to block ${user.displayName}?\n\n'
          'This user will not be able to access the platform.',
          style: TextStyle(
            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
          ),
        ),
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
            child: const Text('Block User'),
          ),
        ],
      ),
    );
  }

  void _confirmUnblockUser(BuildContext context, UserAccount user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
        title: Text(
          'Unblock User',
          style: TextStyle(
            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
          ),
        ),
        content: Text(
          'Unblock ${user.displayName}?',
          style: TextStyle(
            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
          ),
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
        title: Text(
          'Delete User',
          style: TextStyle(
            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
          ),
        ),
        content: Text(
          '⚠️ WARNING: This action cannot be undone!\n\n'
          'Are you sure you want to permanently delete ${user.displayName}?\n\n'
          'All associated data (applications, jobs, messages) will be removed.',
          style: TextStyle(
            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
          ),
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
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  void _showChangeRoleDialog(BuildContext context, UserAccount user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
        title: Text(
          'Change User Role',
          style: TextStyle(
            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current role: ${_formatRole(user.role ?? 'Unknown')}',
              style: TextStyle(
                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person, color: AppTheme.accentBlue),
              title: const Text('Job Seeker'),
              subtitle: const Text('Can apply to jobs'),
              onTap: () {
                Navigator.pop(ctx);
                context.read<AdminUsersCubit>().changeUserRole(user.id, 'JOB_SEEKER');
              },
            ),
            ListTile(
              leading: const Icon(Icons.business, color: AppTheme.accentGreen),
              title: const Text('Recruiter'),
              subtitle: const Text('Can post jobs'),
              onTap: () {
                Navigator.pop(ctx);
                context.read<AdminUsersCubit>().changeUserRole(user.id, 'RECRUITER');
              },
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: AppTheme.warningYellow),
              title: const Text('Admin'),
              subtitle: const Text('Full platform access'),
              onTap: () {
                Navigator.pop(ctx);
                context.read<AdminUsersCubit>().changeUserRole(user.id, 'ADMIN');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Job Management',
          style: TextStyle(
            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _AdminJobCard(
          title: 'Web Developer',
          company: 'Tech Solutions',
          status: 'Active',
          applicants: 12,
        ),
        _AdminJobCard(
          title: 'Graphic Designer',
          company: 'Creative Agency',
          status: 'Flagged',
          applicants: 8,
        ),
        _AdminJobCard(
          title: 'Content Writer',
          company: 'Media Co',
          status: 'Active',
          applicants: 15,
        ),
      ],
    );
  }

  Widget _buildReportsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Reports & Flags',
          style: TextStyle(
            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _ReportCard(
          reportedBy: 'John Doe',
          reportType: 'Fraudulent Job',
          targetTitle: 'Fake Web Developer Position',
          status: 'Pending',
          date: '1 day ago',
        ),
        _ReportCard(
          reportedBy: 'Jane Smith',
          reportType: 'Inappropriate Behavior',
          targetTitle: 'User: Tech Solutions',
          status: 'Under Review',
          date: '3 days ago',
        ),
      ],
    );
  }
}

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
        border: Border.all(color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
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
            style: TextStyle(color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            trend,
            style: TextStyle(
              color: trend.startsWith('+')
                  ? AppTheme.accentGreen
                  : AppTheme.errorRed,
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
        border: Border.all(color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey),
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
            style: TextStyle(color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _UserManagementCard extends StatelessWidget {
  final UserAccount user;
  final String name;
  final String email;
  final String role;
  final String status;
  final bool isBlocked;
  final VoidCallback onBlock;
  final VoidCallback onUnblock;
  final VoidCallback onDelete;
  final VoidCallback onChangeRole;

  const _UserManagementCard({
    required this.user,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.isBlocked,
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
        border: Border.all(color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
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
                      name,
                      style: TextStyle(
                        color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      email,
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
                  color: !isBlocked
                      ? AppTheme.accentGreen.withOpacity(0.2)
                      : AppTheme.errorRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isBlocked ? 'Blocked' : 'Active',
                  style: TextStyle(
                    color: !isBlocked
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
                child: Text(
                  'Role: $role',
                  style: TextStyle(
                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                    fontSize: 13,
                  ),
                ),
              ),
              // Change Role button
              TextButton(
                onPressed: onChangeRole,
                child: const Text(
                  'Change Role',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              // Block/Unblock button
              if (!isBlocked)
                TextButton(
                  onPressed: onBlock,
                  child: const Text(
                    'Block',
                    style: TextStyle(color: AppTheme.errorRed, fontSize: 12),
                  ),
                )
              else
                TextButton(
                  onPressed: onUnblock,
                  child: const Text(
                    'Unblock',
                    style: TextStyle(color: AppTheme.accentGreen, fontSize: 12),
                  ),
                ),
              // Delete button
              TextButton(
                onPressed: onDelete,
                child: const Text(
                  'Delete',
                  style: TextStyle(color: AppTheme.errorRed, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminJobCard extends StatelessWidget {
  final String title;
  final String company;
  final String status;
  final int applicants;

  const _AdminJobCard({
    required this.title,
    required this.company,
    required this.status,
    required this.applicants,
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
        border: Border.all(color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company,
                      style: TextStyle(
                        color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                        fontSize: 14,
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
                  color: status == 'Active'
                      ? AppTheme.accentGreen.withOpacity(0.2)
                      : AppTheme.errorRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'Active'
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
          Text(
            '$applicants applicants',
            style: TextStyle(color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton(onPressed: () {}, child: const Text('View')),
              ),
              if (status == 'Flagged')
                Expanded(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: AppTheme.errorRed),
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
  final String reportedBy;
  final String reportType;
  final String targetTitle;
  final String status;
  final String date;

  const _ReportCard({
    required this.reportedBy,
    required this.reportType,
    required this.targetTitle,
    required this.status,
    required this.date,
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
        border: Border.all(color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey),
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
                  color: AppTheme.errorRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  reportType,
                  style: const TextStyle(
                    color: AppTheme.errorRed,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                date,
                style: TextStyle(color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            targetTitle,
            style: TextStyle(
              color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Reported by: $reportedBy',
            style: TextStyle(color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
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
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorRed,
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
