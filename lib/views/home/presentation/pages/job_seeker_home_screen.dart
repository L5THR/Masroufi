// lib/views/home/presentation/pages/job_seeker_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import 'package:flutter_alinfo9/core/utils/auth_guard.dart';
import '../../../../main.dart';
import '../../../jobs/logic/job_cubit.dart';
import '../../../jobs/logic/job_state.dart';
import '../../../jobs/data/models/job.dart';
import '../../../jobs/data/models/category.dart';
import '../../../jobs/data/models/paginated_response.dart';
import '../../../auth/logic/cubit/auth_cubit.dart';
import '../../../auth/logic/cubit/auth_state.dart';
import '../../../applications/logic/application_cubit.dart';
import '../../../applications/logic/application_state.dart';
import '../../../applications/presentation/widgets/application_card.dart';
import '../../../auth/logic/cubit/user_cubit.dart';
import '../../../auth/logic/cubit/user_state.dart';
import '../../../notifications/logic/notification_cubit.dart';
import '../../../notifications/logic/notification_state.dart';
import '../../../notifications/presentation/widgets/notification_badge.dart';
import '../../../chat/logic/chat_cubit.dart';
import '../../../chat/data/repositories/chat_repository.dart';
import '../../../chat/presentation/widgets/conversations_list.dart';
import '../../../reports/presentation/pages/my_reports_screen.dart';

class JobSeekerHomeScreen extends StatefulWidget {
  const JobSeekerHomeScreen({super.key});

  @override
  State<JobSeekerHomeScreen> createState() => _JobSeekerHomeScreenState();
}

class _JobSeekerHomeScreenState extends State<JobSeekerHomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // Load jobs and categories when screen loads
    // Explicitly pass categoryId: null to fetch all jobs (matching "All" filter)
    context.read<JobCubit>().getJobs(categoryId: null);
    context.read<JobCubit>().getCategories();
    // Load user profile for profile tab
    final authState = context.read<AuthCubit>().state;
    if (authState.isAuthenticated) {
      context.read<UserCubit>().fetchMe();
      // Load applications to filter out already-applied jobs
      context.read<ApplicationCubit>().getMyApplications();
    }
  }

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
                  '/onboarding',
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

  void _handleSearch(String query) {
    if (query.trim().isEmpty) {
      // If search is empty, load all jobs
      context.read<JobCubit>().getJobs(categoryId: _selectedCategoryId);
    } else {
      // Search jobs
      context.read<JobCubit>().searchJobs(query: query);
    }
  }

  void _handleCategoryFilter(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    context.read<JobCubit>().getJobs(categoryId: categoryId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false, // Disable back button
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MASROUFI'),
          automaticallyImplyLeading: false, // Remove back button from AppBar
          actions: [
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              ),
              onPressed: () {
                MasroufiApp.of(context)?.toggleTheme();
              },
            ),
            BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                int unreadCount = 0;
                if (state is NotificationLoaded) {
                  unreadCount = state.unreadCount;
                }

                return IconButton(
                  icon: NotificationBadge(
                    count: unreadCount,
                    child: const Icon(Icons.notifications_outlined),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/notifications');
                  },
                );
              },
            ),
          ],
        ),
        drawer: _buildDrawer(),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildSavedJobsTab();
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

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<JobCubit>().getJobs(categoryId: _selectedCategoryId);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search jobs...',
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.search,
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _handleSearch('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {}); // Rebuild to show/hide clear button
                  },
                  onSubmitted: _handleSearch,
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
                  BlocBuilder<JobCubit, JobState>(
                    builder: (context, state) {
                      List<Category> categories = [];

                      if (state is CategoriesLoaded) {
                        categories = state.categories;
                      } else if (state is JobsLoaded && state.categories != null) {
                        categories = state.categories!;
                      }

                      return SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            // "All" category
                            _CategoryCard(
                              icon: Icons.apps,
                              label: 'All',
                              count: null,
                              isSelected: _selectedCategoryId == null,
                              onTap: () => _handleCategoryFilter(null),
                            ),
                            // Real categories from API
                            ...categories.map((category) => _CategoryCard(
                                  icon: _getCategoryIcon(category.icon),
                                  label: category.name,
                                  count: null,
                                  isSelected: _selectedCategoryId == category.id,
                                  onTap: () => _handleCategoryFilter(category.id),
                                )),
                          ],
                        ),
                      );
                    },
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
                    _searchController.text.isNotEmpty
                        ? 'Search Results'
                        : 'Recent Jobs',
                    style: TextStyle(
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_selectedCategoryId != null || _searchController.text.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        _handleCategoryFilter(null);
                      },
                      child: const Text('Clear Filters'),
                    ),
                ],
              ),
            ),

            // Jobs List - Filter out applied jobs
            BlocBuilder<ApplicationCubit, ApplicationState>(
              builder: (context, appState) {
                // Get list of applied job IDs
                final Set<int> appliedJobIds = {};
                if (appState is ApplicationsLoaded) {
                  for (final app in appState.applications) {
                    appliedJobIds.add(app.job.id);
                  }
                }

                return BlocBuilder<JobCubit, JobState>(
                  builder: (context, state) {
                    if (state is JobLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (state is JobError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load jobs',
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
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<JobCubit>().getJobs(
                                    categoryId: _selectedCategoryId,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentBlue,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Handle both JobsLoaded and CategoriesLoaded (which now includes jobs)
                    PaginatedResponse<Job>? jobsData;
                    if (state is JobsLoaded) {
                      jobsData = state.jobs;
                    } else if (state is CategoriesLoaded && state.jobs != null) {
                      jobsData = state.jobs;
                    }

                    if (jobsData != null) {
                      // Filter out jobs the user has already applied to
                      final jobs = jobsData.content
                          .where((job) => !appliedJobIds.contains(job.id))
                          .toList();

                      if (jobs.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.work_off_outlined,
                                  size: 64,
                                  color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  appliedJobIds.isNotEmpty
                                      ? 'No new jobs found'
                                      : 'No jobs found',
                                  style: TextStyle(
                                    color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchController.text.isNotEmpty
                                      ? 'Try a different search term'
                                      : appliedJobIds.isNotEmpty
                                          ? 'You\'ve applied to all available jobs!'
                                          : 'Check back later for new opportunities!',
                                  style: TextStyle(
                                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: jobs.length,
                        itemBuilder: (context, index) {
                          final job = jobs[index];
                          return _JobCard(
                            job: job,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/job-details',
                                arguments: {
                                  'isRecruiter': false,
                                  'jobId': job.id,
                                },
                              );
                            },
                            onBookmark: () {
                              if (!AuthGuard.requireAuth(
                                context,
                                title: 'Login to Save Jobs',
                                message: 'Create an account or login to save jobs for later.',
                              )) {
                                return;
                              }

                              // TODO: Implement save job functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Job saved!'),
                                  backgroundColor: AppTheme.successGreen,
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedJobsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use BlocBuilder to reactively check auth state
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {

        // Check if user is authenticated
        if (!authState.isAuthenticated) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 64,
                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Login to View Applications',
                    style: TextStyle(
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create an account or login to track your job applications.',
                    style: TextStyle(
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/role-selection');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentBlue,
                    ),
                    child: const Text('Login / Sign Up'),
                  ),
                ],
              ),
            ),
          );
        }

        return BlocBuilder<ApplicationCubit, ApplicationState>(
      builder: (context, state) {
        if (state is ApplicationInitial) {
          context.read<ApplicationCubit>().getMyApplications();
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ApplicationsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ApplicationsError) {
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
                    'Failed to Load Applications',
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
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ApplicationCubit>().getMyApplications();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentBlue,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is ApplicationsEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 64,
                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Applications Yet',
                    style: TextStyle(
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start applying to jobs to track your applications here',
                    style: TextStyle(
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0; // Switch to Home tab
                      });
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Browse Jobs'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentBlue,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is ApplicationsLoaded) {
          final applications = state.applications;

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<ApplicationCubit>().refreshMyApplications();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final application = applications[index];
                return ApplicationCard(
                  application: application,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/job-details',
                      arguments: {
                        'isRecruiter': false,
                        'jobId': application.job.id,
                      },
                    );
                  },
                  // Chat removed - access via dedicated Messages tab for better UX
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
      },
    );
  }

  Widget _buildMessagesTab() {
    return BlocProvider(
      create: (context) => ChatCubit(ChatRepository())..loadConversations(),
      child: const ConversationsList(),
    );
  }

  Widget _buildProfileTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<UserCubit, UserState>(
      builder: (context, userState) {
        final authState = context.read<AuthCubit>().state;

        String displayName = 'Guest User';
        String displaySubtitle = 'Browse jobs without an account';
        String? profileImageUrl;

        if (authState.isAuthenticated && userState is UserLoaded) {
          final profile = userState.user.jobSeekerProfile;
          if (profile != null) {
            displayName = '${profile.firstName} ${profile.lastName}';
            displaySubtitle = userState.user.email;
            profileImageUrl = profile.profilePictureUrl;
          }
        } else if (authState.isAuthenticated) {
          displayName = 'Loading...';
          displaySubtitle = '';
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 50,
                backgroundColor: isDark
                    ? AppTheme.tertiaryGrey
                    : AppTheme.lightGrey,
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl)
                    : null,
                child: profileImageUrl == null
                    ? Icon(
                        Icons.person,
                        size: 50,
                        color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                displayName,
                style: TextStyle(
                  color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displaySubtitle,
                style: TextStyle(
                  color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              _ProfileStats(),
              const SizedBox(height: 24),
              if (authState.isAuthenticated)
                _ProfileMenuItem(
                  icon: Icons.person,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.pushNamed(context, '/edit-job-seeker-profile');
                  },
                ),
              _ProfileMenuItem(
                icon: Icons.description,
                title: 'My Applications',
                onTap: () {
                  Navigator.pushNamed(context, '/my-applications');
                },
              ),
              if (authState.isAuthenticated)
                _ProfileMenuItem(
                  icon: Icons.flag_outlined,
                  title: 'My Reports',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyReportsScreen(),
                      ),
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
              if (authState.isAuthenticated)
                _ProfileMenuItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: _handleLogout,
                  isDestructive: true,
                )
              else
                _ProfileMenuItem(
                  icon: Icons.login,
                  title: 'Login / Sign Up',
                  onTap: () {
                    Navigator.pushNamed(context, '/role-selection');
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark
          ? AppTheme.secondaryBlack
          : AppTheme.secondaryWhite,
      child: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            String displayName = 'Guest User';

            if (authState is AuthLoginSuccess) {
              displayName = 'Job Seeker';
            }

            return Column(
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
                  displayName,
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
                    Icons.bookmark,
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
                    setState(() => _selectedIndex = 1);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.description,
                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                  ),
                  title: Text(
                    'My Applications',
                    style: TextStyle(
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/my-applications');
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
            );
          },
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
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.description),
          label: 'Applications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'flutter':
      case 'code':
      case 'tech':
        return Icons.code;
      case 'food':
      case 'restaurant':
        return Icons.restaurant;
      case 'delivery':
      case 'shipping':
        return Icons.local_shipping;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'education':
        return Icons.school;
      default:
        return Icons.work;
    }
  }
}

// Widget classes
class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.label,
    this.count,
    this.isSelected = false,
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
          color: isSelected
              ? AppTheme.accentBlue
              : (isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppTheme.accentBlue, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.textWhite
                  : AppTheme.accentBlue,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppTheme.textWhite
                    : (isDark ? AppTheme.textWhite : AppTheme.textBlack),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (count != null)
              Text(
                '$count jobs',
                style: TextStyle(
                  color: isSelected
                      ? AppTheme.textWhite.withValues(alpha: 0.8)
                      : (isDark ? AppTheme.textGrey : AppTheme.textDarkGrey),
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
  final Job job;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _JobCard({
    required this.job,
    this.isSaved = false,
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
                        job.title,
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
                        job.recruiter?.companyName ?? 'N/A',
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
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved
                        ? AppTheme.accentBlue
                        : (isDark ? AppTheme.textGrey : AppTheme.textDarkGrey),
                  ),
                  onPressed: onBookmark,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.attach_money,
                  label: '${job.salary?.toStringAsFixed(0) ?? "N/A"} DT',
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.location_on,
                  label: job.location ?? 'Remote',
                ),
                const SizedBox(width: 8),
                if (job.requiresQuiz)
                  _InfoChip(
                    icon: Icons.quiz,
                    label: 'Quiz',
                  ),
              ],
            ),
            if (job.skills != null && job.skills!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: job.skills!
                    .take(3)
                    .map((tag) => _TagChip(label: tag))
                    .toList(),
              ),
            ],
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
        color: AppTheme.accentBlue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppTheme.accentBlue, fontSize: 12),
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
          const _StatItem(label: 'Applied', value: '-'),
          Container(
            width: 1,
            height: 40,
            color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
          ),
          const _StatItem(label: 'Saved', value: '-'),
          Container(
            width: 1,
            height: 40,
            color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
          ),
          const _StatItem(label: 'Rating', value: '-'),
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
