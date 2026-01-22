// lib/views/applications/presentation/pages/my_applications_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_theme.dart';
import '../../logic/application_cubit.dart';
import '../../logic/application_state.dart';
import '../../data/repositories/application_repository.dart';
import '../widgets/application_card.dart';
import '../widgets/application_detail_sheet.dart';
import '../../data/models/application_status.dart';
import '../../../reviews/presentation/widgets/create_review_dialog.dart';
import '../../../chat/data/repositories/chat_repository.dart';
import '../../../chat/logic/chat_cubit.dart';
import '../../../chat/presentation/pages/chat_screen.dart';

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ApplicationCubit(ApplicationRepository())..getMyApplications(),
      child: const _MyApplicationsView(),
    );
  }
}

class _MyApplicationsView extends StatefulWidget {
  const _MyApplicationsView();

  @override
  State<_MyApplicationsView> createState() => _MyApplicationsViewState();
}

class _MyApplicationsViewState extends State<_MyApplicationsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<ApplicationCubit>().loadMoreApplications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
        ],
      ),
      body: BlocConsumer<ApplicationCubit, ApplicationState>(
        listener: (context, state) {
          if (state is ApplicationsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ApplicationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ApplicationsEmpty) {
            return _buildEmptyState();
          }

          if (state is ApplicationsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<ApplicationCubit>().refreshMyApplications();
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: state.applications.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.applications.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final application = state.applications[index];
                  // Get recruiter user ID for chat
                  final recruiterUserId = application.job.recruiter?.userId ??
                                          application.job.recruiter?.user?.id;
                  final recruiterName = application.job.recruiter?.companyName ?? 'Recruiter';

                  return ApplicationCard(
                    application: application,
                    onTap: () {
                      showJobSeekerApplicationDetail(
                        context,
                        application,
                        () => context.read<ApplicationCubit>().refreshMyApplications(),
                      );
                    },
                    // Chat button - allows job seeker to chat with recruiter
                    onChat: recruiterUserId != null
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) => ChatCubit(ChatRepository()),
                                  child: ChatScreen(
                                    userId: recruiterUserId,
                                    userName: recruiterName,
                                    userRole: 'RECRUITER',
                                  ),
                                ),
                              ),
                            );
                          }
                        : null,
                    // Review button - shows only for COMPLETED applications
                    onReview: application.status == ApplicationStatus.COMPLETED
                        ? () async {
                            await showCreateReviewDialog(
                              context: context,
                              jobApplicationId: application.id,
                              applicantName: application.job.recruiter?.companyName ?? 'Recruiter',
                            );
                            // Refresh applications after review
                            if (context.mounted) {
                              context.read<ApplicationCubit>().refreshMyApplications();
                            }
                          }
                        : null,
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 100,
              color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
            ),
            const SizedBox(height: 24),
            Text(
              'No Applications Yet',
              style: TextStyle(
                color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start applying to jobs to see your applications here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/job-seeker-home');
              },
              icon: const Icon(Icons.search),
              label: const Text('Browse Jobs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark
          ? AppTheme.secondaryBlack
          : AppTheme.secondaryWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Status',
              style: TextStyle(
                color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _FilterOption(label: 'All', onTap: () {}),
            _FilterOption(label: 'Pending', onTap: () {}),
            _FilterOption(label: 'Viewed', onTap: () {}),
            _FilterOption(label: 'Accepted', onTap: () {}),
            _FilterOption(label: 'Rejected', onTap: () {}),
            _FilterOption(label: 'Hired', onTap: () {}),
            _FilterOption(label: 'Completed', onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterOption({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
