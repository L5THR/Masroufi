import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/report.dart';
import '../data/repositories/admin_repository.dart';

// States
abstract class AdminReportsState extends Equatable {
  const AdminReportsState();

  @override
  List<Object?> get props => [];
}

class AdminReportsInitial extends AdminReportsState {}

class AdminReportsLoading extends AdminReportsState {}

class AdminReportsLoaded extends AdminReportsState {
  final List<Report> reports;
  final int totalPages;
  final int totalElements;
  final int currentPage;
  final bool isLoadingMore;
  final String? statusFilter;

  const AdminReportsLoaded({
    required this.reports,
    required this.totalPages,
    required this.totalElements,
    required this.currentPage,
    this.isLoadingMore = false,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [
        reports,
        totalPages,
        totalElements,
        currentPage,
        isLoadingMore,
        statusFilter,
      ];

  AdminReportsLoaded copyWith({
    List<Report>? reports,
    int? totalPages,
    int? totalElements,
    int? currentPage,
    bool? isLoadingMore,
    String? statusFilter,
  }) {
    return AdminReportsLoaded(
      reports: reports ?? this.reports,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class AdminReportsError extends AdminReportsState {
  final String message;

  const AdminReportsError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminReportsActionSuccess extends AdminReportsState {
  final String message;

  const AdminReportsActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class AdminReportsCubit extends Cubit<AdminReportsState> {
  final AdminRepository _repository;

  AdminReportsCubit({required AdminRepository repository})
      : _repository = repository,
        super(AdminReportsInitial());

  /// Load reports list
  Future<void> loadReports({int page = 0, int size = 20}) async {
    emit(AdminReportsLoading());
    try {
      final result = await _repository.getReports(page: page, size: size);

      emit(AdminReportsLoaded(
        reports: result['reports'] as List<Report>,
        totalPages: result['totalPages'] as int,
        totalElements: result['totalElements'] as int,
        currentPage: result['currentPage'] as int,
      ));
    } catch (e) {
      emit(AdminReportsError(e.toString()));
    }
  }

  /// Refresh reports list
  Future<void> refresh() async {
    await loadReports();
  }

  /// Filter reports by status
  void filterByStatus(String? status) {
    final currentState = state;
    if (currentState is! AdminReportsLoaded) return;

    if (status == null || status.isEmpty) {
      // Reset filter
      loadReports();
      return;
    }

    final filtered = currentState.reports
        .where((report) => report.status == status)
        .toList();

    emit(currentState.copyWith(
      reports: filtered,
      statusFilter: status,
    ));
  }

  /// Load more reports (pagination)
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! AdminReportsLoaded) return;
    if (currentState.isLoadingMore) return;
    if (currentState.currentPage >= currentState.totalPages - 1) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final result = await _repository.getReports(page: nextPage, size: 20);

      final newReports = result['reports'] as List<Report>;

      emit(currentState.copyWith(
        reports: [...currentState.reports, ...newReports],
        currentPage: nextPage,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
      // Error loading more, but keep current state
    }
  }

  /// Update report status
  Future<void> updateReportStatus(int reportId, String newStatus) async {
    try {
      await _repository.updateReportStatus(reportId, newStatus);
      emit(AdminReportsActionSuccess('Report status updated to $newStatus'));
      await refresh(); // Reload list
    } catch (e) {
      emit(AdminReportsError('Failed to update report status: $e'));
      // Restore previous state
      final currentState = state;
      if (currentState is AdminReportsLoaded) {
        emit(currentState);
      }
    }
  }

  /// Mark report as under review
  Future<void> markAsUnderReview(int reportId) async {
    await updateReportStatus(reportId, 'UNDER_REVIEW');
  }

  /// Resolve report
  Future<void> resolveReport(int reportId) async {
    await updateReportStatus(reportId, 'RESOLVED');
  }

  /// Dismiss report (same as resolve)
  Future<void> dismissReport(int reportId) async {
    await updateReportStatus(reportId, 'RESOLVED');
  }

  // ==================== JOB REPORT ACTIONS ====================

  /// Get job details to retrieve recruiter info
  Future<Map<String, dynamic>?> getJobDetails(int jobId) async {
    try {
      return await _repository.getJobDetails(jobId);
    } catch (e) {
      emit(AdminReportsError('Failed to fetch job details: $e'));
      return null;
    }
  }

  /// Delete a reported job and resolve the report
  Future<void> deleteJobAndResolve(int reportId, int jobId) async {
    try {
      // Delete the job
      await _repository.deleteJob(jobId);
      // Resolve the report
      await _repository.updateReportStatus(reportId, 'RESOLVED');
      emit(const AdminReportsActionSuccess('Job deleted and report resolved'));
      await refresh();
    } catch (e) {
      emit(AdminReportsError('Failed to delete job: $e'));
    }
  }

  /// Block the recruiter who posted the job and resolve the report
  Future<void> blockRecruiterAndResolve(int reportId, int recruiterId) async {
    try {
      // Block the recruiter
      await _repository.updateUserStatus(recruiterId, 'BLOCKED');
      // Resolve the report
      await _repository.updateReportStatus(reportId, 'RESOLVED');
      emit(const AdminReportsActionSuccess('Recruiter blocked and report resolved'));
      await refresh();
    } catch (e) {
      emit(AdminReportsError('Failed to block recruiter: $e'));
    }
  }

  /// Delete job and block the recruiter, then resolve the report
  Future<void> deleteJobAndBlockRecruiter(int reportId, int jobId, int recruiterId) async {
    try {
      // Delete the job
      await _repository.deleteJob(jobId);
      // Block the recruiter
      await _repository.updateUserStatus(recruiterId, 'BLOCKED');
      // Resolve the report
      await _repository.updateReportStatus(reportId, 'RESOLVED');
      emit(const AdminReportsActionSuccess('Job deleted, recruiter blocked, and report resolved'));
      await refresh();
    } catch (e) {
      emit(AdminReportsError('Failed to take action: $e'));
    }
  }
}
