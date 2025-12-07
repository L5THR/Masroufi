// lib/views/home/presentation/pages/job_seeker_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import '../../../../main.dart';

class JobSeekerHomeScreen extends StatefulWidget {
  const JobSeekerHomeScreen({super.key});

  @override
  State<JobSeekerHomeScreen> createState() => _JobSeekerHomeScreenState();
}

class _JobSeekerHomeScreenState extends State<JobSeekerHomeScreen> {
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
        title: const Text('MASROUFI'),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
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
      drawer: _buildDrawer(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildApplicationsTab();
      case 2:
        return _buildMessagesTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search jobs...',
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.search,
                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                  ),
                ),
                onSubmitted: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Searching for: $value')),
                  );
                },
              ),
            ),
          ),
          // Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Categories',
                  style: TextStyle(
                    color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _CategoryCard(
                        icon: Icons.computer,
                        label: 'Tech',
                        count: 12,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Showing Tech jobs')),
                          );
                        },
                      ),
                      _CategoryCard(
                        icon: Icons.restaurant,
                        label: 'Food',
                        count: 8,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Showing Food jobs')),
                          );
                        },
                      ),
                      _CategoryCard(
                        icon: Icons.local_shipping,
                        label: 'Delivery',
                        count: 15,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Showing Delivery jobs'),
                            ),
                          );
                        },
                      ),
                      _CategoryCard(
                        icon: Icons.cleaning_services,
                        label: 'Cleaning',
                        count: 6,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Showing Cleaning jobs'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Recent Jobs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Jobs',
                  style: TextStyle(
                    color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Showing all jobs')),
                    );
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            itemBuilder: (context, index) => _JobCard(
              title: 'Web Developer',
              company: 'Tech Solutions',
              price: '50 DT',
              location: 'Tunis',
              tags: const ['Flutter', 'UI/UX'],
              onTap: () {
                Navigator.pushNamed(context, '/job-details');
              },
              onBookmark: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Job saved!'),
                    backgroundColor: AppTheme.successGreen,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) => _ApplicationCard(
        title: 'Mobile App Development',
        company: 'StartupX',
        status: index == 0
            ? 'Accepted'
            : index == 1
            ? 'Pending'
            : 'Rejected',
        appliedDate: '2 days ago',
        onTap: () {
          Navigator.pushNamed(context, '/job-details');
        },
      ),
    );
  }

  Widget _buildMessagesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) => _MessagePreviewCard(
        name: 'Tech Solutions',
        message: 'Thank you for your application...',
        time: '2h ago',
        unread: index < 2,
        onTap: () {
          Navigator.pushNamed(context, '/chat');
        },
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
            backgroundColor: isDark
                ? AppTheme.tertiaryGrey
                : AppTheme.lightGrey,
            child: Icon(
              Icons.person,
              size: 50,
              color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'John Doe',
            style: TextStyle(
              color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'john.doe@email.com',
            style: TextStyle(
              color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          _ProfileStats(),
          const SizedBox(height: 24),
          _ProfileMenuItem(
            icon: Icons.person,
            title: 'Edit Profile',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profile coming soon!')),
              );
            },
          ),
          _ProfileMenuItem(
            icon: Icons.work,
            title: 'My Skills',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Skills management coming soon!')),
              );
            },
          ),
          _ProfileMenuItem(
            icon: Icons.history,
            title: 'Job History',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Job history coming soon!')),
              );
            },
          ),
          _ProfileMenuItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
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

  Widget _buildDrawer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark
          ? AppTheme.secondaryBlack
          : AppTheme.secondaryWhite,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundColor: isDark
                  ? AppTheme.tertiaryGrey
                  : AppTheme.lightGrey,
              child: Icon(
                Icons.person,
                size: 40,
                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'John Doe',
              style: TextStyle(
                color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Divider(
              height: 32,
              color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
            ),
            ListTile(
              leading: Icon(
                Icons.home,
                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
              ),
              title: Text(
                'Home',
                style: TextStyle(
                  color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 0);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.work,
                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
              ),
              title: Text(
                'Saved Jobs',
                style: TextStyle(
                  color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved jobs coming soon!')),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.help,
                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
              ),
              title: Text(
                'Help & Support',
                style: TextStyle(
                  color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help & Support coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
      },
      backgroundColor: isDark
          ? AppTheme.secondaryBlack
          : AppTheme.secondaryWhite,
      selectedItemColor: AppTheme.accentBlue,
      unselectedItemColor: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
      type: BottomNavigationBarType.fixed,
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        const BottomNavigationBarItem(
          icon: Icon(Icons.description),
          label: 'Applications',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble),
          label: 'Messages',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

// ADD THESE WIDGET CLASSES TO THE BOTTOM OF job_seeker_home_screen.dart

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.accentBlue, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$count jobs',
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

class _JobCard extends StatelessWidget {
  final String title;
  final String company;
  final String price;
  final String location;
  final List<String> tags;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _JobCard({
    required this.title,
    required this.company,
    required this.price,
    required this.location,
    required this.tags,
    required this.onTap,
    required this.onBookmark,
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
                          color: isDark
                              ? AppTheme.textWhite
                              : AppTheme.textBlack,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        company,
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
                IconButton(
                  icon: Icon(
                    Icons.bookmark_border,
                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                  ),
                  onPressed: onBookmark,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoChip(icon: Icons.attach_money, label: price),
                const SizedBox(width: 8),
                _InfoChip(icon: Icons.location_on, label: location),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) => _TagChip(label: tag)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppTheme.accentBlue, fontSize: 12),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final String title;
  final String company;
  final String status;
  final String appliedDate;
  final VoidCallback onTap;

  const _ApplicationCard({
    required this.title,
    required this.company,
    required this.status,
    required this.appliedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color statusColor = status == 'Accepted'
        ? AppTheme.successGreen
        : status == 'Pending'
        ? AppTheme.warningYellow
        : AppTheme.errorRed;

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
                          color: isDark
                              ? AppTheme.textWhite
                              : AppTheme.textBlack,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        company,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Applied $appliedDate',
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

class _MessagePreviewCard extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final bool unread;
  final VoidCallback onTap;

  const _MessagePreviewCard({
    required this.name,
    required this.message,
    required this.time,
    required this.unread,
    required this.onTap,
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
          color: unread
              ? (isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey)
              : (isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: unread
                ? AppTheme.accentBlue.withOpacity(0.3)
                : (isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isDark
                  ? AppTheme.tertiaryGrey
                  : AppTheme.lightGrey,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.textWhite
                              : AppTheme.textBlack,
                          fontSize: 16,
                          fontWeight: unread
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.textGrey
                              : AppTheme.textDarkGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                      fontSize: 14,
                      fontWeight: unread ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const _StatItem(label: 'Applied', value: '12'),
          Container(
            width: 1,
            height: 40,
            color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
          ),
          const _StatItem(label: 'Completed', value: '8'),
          Container(
            width: 1,
            height: 40,
            color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
          ),
          const _StatItem(label: 'Rating', value: '4.8'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

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
