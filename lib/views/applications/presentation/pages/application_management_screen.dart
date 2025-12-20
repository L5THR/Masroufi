// lib/views/applications/presentation/pages/application_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_theme.dart';
import '../../logic/application_cubit.dart';
import '../../logic/application_state.dart';
import '../../data/repositories/application_repository.dart';
import '../../data/models/application_status.dart';
import '../widgets/application_card.dart';

class ApplicationManagementScreen extends StatelessWidget {
  final int jobId;
  final String jobTitle;

  const ApplicationManagementScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ApplicationCubit(ApplicationRepository())
            ..getJobApplications(jobId: jobId),
      child: _ApplicationManagementView(jobId: jobId, jobTitle: jobTitle),
    );
  }
}

class _ApplicationManagementView extends StatefulWidget {
  final int jobId;
  final String jobTitle;

  const _ApplicationManagementView({
    required this.jobId,
    required this.jobTitle,
  });

  @override
  State<_ApplicationManagementView> createState() =>
      _ApplicationManagementViewState();
}

class _ApplicationManagementViewState
    extends State<_ApplicationManagementView> {
  final ScrollController _scrollController = ScrollController();
  ApplicationStatus? _selectedFilter;

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
      context.read<ApplicationCubit>().loadMoreJobApplications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Applications', style: TextStyle(fontSize: 18)),
            Text(
              widget.jobTitle,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: BlocConsumer<ApplicationCubit, ApplicationState>(
        listener: (context, state) {
          if (state is JobApplicationsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          } else if (state is ApplicationStatusUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Status updated successfully!'),
                backgroundColor: AppTheme.successGreen,
              ),
            );
          } else if (state is ApplicationStatusUpdateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is JobApplicationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is JobApplicationsEmpty) {
            return _buildEmptyState();
          }

          if (state is JobApplicationsLoaded) {
            final applications = _selectedFilter == null
                ? state.applications
                : state.applications
                      .where((app) => app.status == _selectedFilter)
                      .toList();

            if (applications.isEmpty) {
              return _buildEmptyFilterState();
            }

            return Column(
              children: [
                // Stats Bar
                _buildStatsBar(state.applications),
                // Applications List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await context
                          .read<ApplicationCubit>()
                          .refreshJobApplications(widget.jobId);
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: applications.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == applications.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final application = applications[index];
                        return ApplicationCard(
                          application: application,
                          showJobSeeker: true,
                          onTap: () =>
                              _showApplicationDetails(context, application),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatsBar(List<dynamic> applications) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final stats = <ApplicationStatus, int>{};
    for (final app in applications) {
      stats[app.status] = (stats[app.status] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'Total',
            value: applications.length.toString(),
            color: AppTheme.accentBlue,
          ),
          _StatItem(
            label: 'Pending',
            value: (stats[ApplicationStatus.PENDING] ?? 0).toString(),
            color: Color(ApplicationStatus.PENDING.colorValue),
          ),
          _StatItem(
            label: 'Accepted',
            value: (stats[ApplicationStatus.ACCEPTED] ?? 0).toString(),
            color: Color(ApplicationStatus.ACCEPTED.colorValue),
          ),
          _StatItem(
            label: 'Rejected',
            value: (stats[ApplicationStatus.REJECTED] ?? 0).toString(),
            color: Color(ApplicationStatus.REJECTED.colorValue),
          ),
        ],
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
              Icons.people_outline,
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
              'Applications for this job will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_alt_off,
              size: 80,
              color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'No applications match this filter',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() => _selectedFilter = null);
              },
              child: const Text('Clear Filter'),
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
            _FilterOption(
              label: 'All Applications',
              isSelected: _selectedFilter == null,
              onTap: () {
                setState(() => _selectedFilter = null);
                Navigator.pop(context);
              },
            ),
            ...ApplicationStatus.values.map(
              (status) => _FilterOption(
                label: status.displayName,
                isSelected: _selectedFilter == status,
                onTap: () {
                  setState(() => _selectedFilter = status);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApplicationDetails(BuildContext context, dynamic application) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark
          ? AppTheme.secondaryBlack
          : AppTheme.secondaryWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: isDark
                        ? AppTheme.tertiaryGrey
                        : AppTheme.lightGrey,
                    child: const Icon(
                      Icons.person,
                      color: AppTheme.accentBlue,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.jobSeeker.fullName,
                          style: TextStyle(
                            color: isDark
                                ? AppTheme.textWhite
                                : AppTheme.textBlack,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          application.jobSeeker.phoneNumber ?? 'No phone',
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
              const SizedBox(height: 24),

              // Status Section
              Text(
                'Application Status',
                style: TextStyle(
                  color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ApplicationStatus.values
                    .map(
                      (status) => _StatusChip(
                        status: status,
                        isSelected: application.status == status,
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          context
                              .read<ApplicationCubit>()
                              .updateApplicationStatus(
                                applicationId: application.id,
                                status: status,
                              );
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),

              // CV Section
              if (application.jobSeeker.cvUrl != null) ...[
                Text(
                  'CV / Resume',
                  style: TextStyle(
                    color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    // Open CV
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening CV...')),
                    );
                  },
                  icon: const Icon(Icons.file_download),
                  label: const Text('View CV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentBlue,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(bottomSheetContext);
                        Navigator.pushNamed(context, '/chat');
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text('Message'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppTheme.accentBlue)
          : null,
      onTap: onTap,
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ApplicationStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(status.colorValue);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
        ),
        child: Text(
          status.displayName,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
