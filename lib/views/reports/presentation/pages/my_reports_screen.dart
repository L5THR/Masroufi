// lib/views/reports/presentation/pages/my_reports_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_theme.dart';
import '../../data/models/report.dart';
import '../../data/models/my_report.dart';
import '../../data/repositories/report_repository.dart';
import '../../logic/report_cubit.dart';
import '../../logic/report_state.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportCubit(ReportRepository())..getMyReports(),
      child: const _MyReportsView(),
    );
  }
}

class _MyReportsView extends StatefulWidget {
  const _MyReportsView();

  @override
  State<_MyReportsView> createState() => _MyReportsViewState();
}

class _MyReportsViewState extends State<_MyReportsView> {
  final ScrollController _scrollController = ScrollController();
  ReportStatus? _selectedFilter;

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
      context.read<ReportCubit>().loadMoreReports(status: _selectedFilter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: BlocBuilder<ReportCubit, ReportState>(
        builder: (context, state) {
          if (state is MyReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MyReportsEmpty) {
            return _buildEmptyState(isDark);
          }

          if (state is MyReportsError) {
            return _buildErrorState(isDark, state.message);
          }

          if (state is MyReportsLoaded) {
            return RefreshIndicator(
              onRefresh: () => context
                  .read<ReportCubit>()
                  .refreshMyReports(status: _selectedFilter),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: state.reports.length + (state.hasMore ? 1 : 0),
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
                    onTap: () => _showReportDetails(context, report),
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 100,
              color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
            ),
            const SizedBox(height: 24),
            Text(
              'No Reports Yet',
              style: TextStyle(
                color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Reports you submit will appear here',
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

  Widget _buildErrorState(bool isDark, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ReportCubit>().getMyReports(status: _selectedFilter);
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

  void _showFilterBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomContext) => Padding(
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
              label: 'All Reports',
              isSelected: _selectedFilter == null,
              onTap: () {
                setState(() => _selectedFilter = null);
                Navigator.pop(bottomContext);
                context.read<ReportCubit>().getMyReports();
              },
            ),
            ...ReportStatus.values.map(
              (status) => _FilterOption(
                label: _getStatusDisplayName(status),
                isSelected: _selectedFilter == status,
                onTap: () {
                  setState(() => _selectedFilter = status);
                  Navigator.pop(bottomContext);
                  context.read<ReportCubit>().getMyReports(status: status);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusDisplayName(ReportStatus status) {
    switch (status) {
      case ReportStatus.PENDING:
        return 'Pending';
      case ReportStatus.UNDER_REVIEW:
        return 'Under Review';
      case ReportStatus.RESOLVED:
        return 'Resolved';
    }
  }

  void _showReportDetails(BuildContext context, MyReport report) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: report.isJobReport
                          ? AppTheme.accentBlue.withValues(alpha: 0.1)
                          : AppTheme.accentYellow.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      report.isJobReport ? Icons.work_outline : Icons.person_outline,
                      color: report.isJobReport
                          ? AppTheme.accentBlue
                          : AppTheme.accentYellow,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${report.targetTypeText} Report',
                          style: TextStyle(
                            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.targetSummary?.displayName ?? 'Unknown',
                          style: TextStyle(
                            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Status
              _DetailRow(
                label: 'Status',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(report.statusColorValue).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    report.statusText,
                    style: TextStyle(
                      color: Color(report.statusColorValue),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Resolution (if resolved)
              if (report.isResolved && report.resolution != null) ...[
                _DetailRow(
                  label: 'Resolution',
                  child: Text(
                    report.resolution!.displayText,
                    style: TextStyle(
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Date Submitted
              _DetailRow(
                label: 'Submitted',
                child: Text(
                  _formatDate(report.createdAt),
                  style: TextStyle(
                    color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date Resolved (if resolved)
              if (report.resolvedAt != null) ...[
                _DetailRow(
                  label: 'Resolved',
                  child: Text(
                    _formatDate(report.resolvedAt!),
                    style: TextStyle(
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Reason
              const SizedBox(height: 8),
              Text(
                'Reason',
                style: TextStyle(
                  color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.primaryBlack : AppTheme.lightGrey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  report.reason,
                  style: TextStyle(
                    color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _ReportCard extends StatelessWidget {
  final MyReport report;
  final VoidCallback onTap;

  const _ReportCard({
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: report.isJobReport
                          ? AppTheme.accentBlue.withValues(alpha: 0.1)
                          : AppTheme.accentYellow.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      report.isJobReport ? Icons.work_outline : Icons.person_outline,
                      color: report.isJobReport
                          ? AppTheme.accentBlue
                          : AppTheme.accentYellow,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.targetSummary?.displayName ?? 'Unknown',
                          style: TextStyle(
                            color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${report.targetTypeText} Report',
                          style: TextStyle(
                            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(report.statusColorValue).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report.statusText,
                      style: TextStyle(
                        color: Color(report.statusColorValue),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Reason Preview
              Text(
                report.reason,
                style: TextStyle(
                  color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Date
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(report.createdAt),
                    style: TextStyle(
                      color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                      fontSize: 12,
                    ),
                  ),
                  if (report.isResolved && report.resolution != null) ...[
                    const Spacer(),
                    Icon(
                      Icons.check_circle_outline,
                      size: 14,
                      color: AppTheme.successGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      report.resolution!.displayText,
                      style: const TextStyle(
                        color: AppTheme.successGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

class _DetailRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _DetailRow({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
