import 'package:flutter/material.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import 'package:flutter_alinfo9/main.dart';

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
    return Scaffold(
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

  Widget _buildDashboardTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
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
                  value: '1,234',
                  color: AppTheme.accentBlue,
                  trend: '+12%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.work,
                  title: 'Active Jobs',
                  value: '89',
                  color: AppTheme.accentGreen,
                  trend: '+5%',
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
                  value: '456',
                  color: AppTheme.warningYellow,
                  trend: '+8%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.flag,
                  title: 'Reports',
                  value: '12',
                  color: AppTheme.errorRed,
                  trend: '-3%',
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
          _ActivityItem(
            icon: Icons.person_add,
            title: 'New user registered',
            subtitle: 'John Doe joined as Job Seeker',
            time: '5 mins ago',
          ),
          _ActivityItem(
            icon: Icons.work,
            title: 'New job posted',
            subtitle: 'Web Developer by Tech Solutions',
            time: '1 hour ago',
          ),
          _ActivityItem(
            icon: Icons.flag,
            title: 'Report received',
            subtitle: 'Fraudulent job posting reported',
            time: '2 hours ago',
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.all(16),
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
              hintText: 'Search users...',
              border: InputBorder.none,
              icon: Icon(Icons.search, color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _UserManagementCard(
          name: 'John Doe',
          email: 'john@email.com',
          role: 'Job Seeker',
          status: 'Active',
        ),
        _UserManagementCard(
          name: 'Tech Solutions',
          email: 'tech@solutions.com',
          role: 'Recruiter',
          status: 'Active',
        ),
        _UserManagementCard(
          name: 'Jane Smith',
          email: 'jane@email.com',
          role: 'Job Seeker',
          status: 'Blocked',
        ),
      ],
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
  final String name;
  final String email;
  final String role;
  final String status;

  const _UserManagementCard({
    required this.name,
    required this.email,
    required this.role,
    required this.status,
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
                  name[0],
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
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View Details',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              if (status == 'Active')
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Block',
                    style: TextStyle(color: AppTheme.errorRed, fontSize: 12),
                  ),
                )
              else
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Unblock',
                    style: TextStyle(color: AppTheme.accentGreen, fontSize: 12),
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
