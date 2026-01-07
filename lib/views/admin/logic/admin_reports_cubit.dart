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
}
