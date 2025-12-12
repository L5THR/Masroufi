// lib/views/recruiter/presentation/pages/recruiter_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import 'package:flutter_alinfo9/main.dart';

class RecruiterHomeScreen extends StatefulWidget {
  const RecruiterHomeScreen({Key? key}) : super(key: key);

  @override
  State<RecruiterHomeScreen> createState() => _RecruiterHomeScreenState();
}

class _RecruiterHomeScreenState extends State<RecruiterHomeScreen> {
  int _selectedIndex = 0;

  void _handleLogout() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
        title: Text(
          'Logout',
          style: TextStyle(color: isDark ? AppTheme.textWhite : AppTheme.textBlack),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey),
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
              MasroufiApp.of(context)!.toggleTheme();
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
        backgroundColor: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _JobStatCard(),
        const SizedBox(height: 20),
        Text(
          'Active Jobs',
          style: TextStyle(
            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _RecruiterJobCard(
          title: 'Web Developer',
          applicants: 12,
          status: 'Open',
          postedDate: '2 days ago',
          onEdit: () {
            Navigator.pushNamed(context, '/edit-job');
          },
          onView: () {
            Navigator.pushNamed(context, '/job-details',
                arguments: {'isRecruiter': true});
          },
        ),
        _RecruiterJobCard(
          title: 'Graphic Designer',
          applicants: 8,
          status: 'Open',
          postedDate: '5 days ago',
          onEdit: () {
            Navigator.pushNamed(context, '/edit-job');
          },
          onView: () {
            Navigator.pushNamed(context, '/job-details',
                arguments: {'isRecruiter': true});
          },
        ),
        _RecruiterJobCard(
          title: 'Content Writer',
          applicants: 15,
          status: 'Closed',
          postedDate: '1 week ago',
          onEdit: () {
            Navigator.pushNamed(context, '/edit-job');
          },
          onView: () {
            Navigator.pushNamed(context, '/job-details',
                arguments: {'isRecruiter': true});
          },
        ),
      ],
    );
  }

  Widget _buildApplicantsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => _ApplicantCard(
        name: 'John Doe',
        jobTitle: 'Web Developer',
        appliedDate: '1 day ago',
        rating: 4.5,
        status: index == 0
            ? null
            : index == 1
            ? 'Accepted'
            : 'Rejected',
        onAccept: index == 0
            ? () {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Applicant accepted!'),
                    backgroundColor: AppTheme.accentGreen,
                  ),
                );
              }
            : null,
        onReject: index == 0
            ? () {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Applicant rejected'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
              }
            : null,
      ),
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
            border: Border.all(color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
                child: Icon(Icons.person, color: isDark ? AppTheme.textWhite : AppTheme.textBlack),
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
                    SizedBox(height: 4),
                    Text(
                      'Thank you for considering...',
                      style: TextStyle(color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                '1h ago',
                style: TextStyle(color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 50,
            backgroundColor: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
            child: Icon(Icons.business, size: 50, color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey),
          ),
          const SizedBox(height: 16),
          Text(
            'Tech Solutions',
            style: TextStyle(
              color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'tech@solutions.com',
            style: TextStyle(color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const _ProfileStatItem(label: 'Jobs Posted', value: '24'),
                Container(width: 1, height: 40, color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey),
                const _ProfileStatItem(label: 'Hired', value: '18'),
                Container(width: 1, height: 40, color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey),
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
}

class _JobStatCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          const _StatColumn(label: 'Active Jobs', value: '3'),
          Container(width: 1, height: 40, color: Colors.white30),
          const _StatColumn(label: 'Total Applicants', value: '35'),
          Container(width: 1, height: 40, color: Colors.white30),
          const _StatColumn(label: 'Hired', value: '12'),
        ],
      ),
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
  final String title;
  final int applicants;
  final String status;
  final String postedDate;
  final VoidCallback onEdit;
  final VoidCallback onView;

  const _RecruiterJobCard({
    required this.title,
    required this.applicants,
    required this.status,
    required this.postedDate,
    required this.onEdit,
    required this.onView,
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
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: status == 'Open'
                      ? AppTheme.accentGreen.withOpacity(0.2)
                      : AppTheme.textGrey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'Open'
                        ? AppTheme.accentGreen
                        : AppTheme.textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.people, color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey, size: 16),
              const SizedBox(width: 4),
              Text(
                '$applicants applicants',
                style: TextStyle(color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey, fontSize: 14),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey, size: 16),
              const SizedBox(width: 4),
              Text(
                postedDate,
                style: TextStyle(color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
  final String name;
  final String jobTitle;
  final String appliedDate;
  final double rating;
  final String? status;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const _ApplicantCard({
    required this.name,
    required this.jobTitle,
    required this.appliedDate,
    required this.rating,
    this.status,
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
                    const SizedBox(height: 2),
                    Text(
                      jobTitle,
                      style: TextStyle(
                        color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: AppTheme.warningYellow,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    rating.toString(),
                    style: TextStyle(
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Applied $appliedDate',
            style: TextStyle(color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey, fontSize: 12),
          ),
          if (status != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: status == 'Accepted'
                    ? AppTheme.accentGreen.withOpacity(0.2)
                    : AppTheme.errorRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                status!,
                style: TextStyle(
                  color: status == 'Accepted'
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
          style: TextStyle(color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey, fontSize: 12),
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
        color: isDestructive ? AppTheme.errorRed : (isDark ? AppTheme.textGrey : AppTheme.textDarkGrey),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppTheme.errorRed : (isDark ? AppTheme.textWhite : AppTheme.textBlack),
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
