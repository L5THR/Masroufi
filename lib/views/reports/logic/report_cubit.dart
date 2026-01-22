// lib/views/reports/logic/report_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/report_repository.dart';
import '../data/models/report.dart';
import '../data/models/my_report.dart';
import 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final ReportRepository _repository;
  int _currentPage = 0;
  bool _isLoadingMore = false;

  ReportCubit(this._repository) : super(ReportInitial());

  /// Create a new report
  Future<void> createReport({
    required int targetId,
    required ReportTargetType targetType,
    required String reason,
  }) async {
    // Validate reason
    if (reason.trim().isEmpty) {
      emit(const ReportFailure(error: 'Please provide a reason for the report'));
      return;
    }

    emit(ReportCreating());

    try {
      final report = await _repository.createReport(
        targetId: targetId,
        targetType: targetType,
        reason: reason,
      );

      emit(ReportCreated(report: report));
    } catch (e) {
      final errorMessage = e.toString();
      String userFriendlyError;

      if (errorMessage.contains('500')) {
        userFriendlyError = 'Server error occurred. Please try again later.';
      } else if (errorMessage.contains('401')) {
        userFriendlyError = 'You are not authorized to create reports.';
      } else if (errorMessage.contains('404')) {
        userFriendlyError = 'Target not found.';
      } else if (errorMessage.contains('400')) {
        userFriendlyError = 'Invalid report data. Please check your inputs.';
      } else if (errorMessage.contains('409')) {
        userFriendlyError = 'You have already reported this.';
      } else {
        userFriendlyError = 'Failed to create report. Please try again.';
      }

      emit(ReportFailure(error: userFriendlyError));
    }
  }

  /// Get my submitted reports
  Future<void> getMyReports({ReportStatus? status}) async {
    _currentPage = 0;
    emit(MyReportsLoading());

    try {
      final response = await _repository.getMyReports(
        page: 0,
        status: status,
      );

      if (response.reports.isEmpty) {
        emit(MyReportsEmpty());
      } else {
        emit(MyReportsLoaded(
          reports: response.reports,
          totalElements: response.totalElements,
          hasMore: response.hasMore,
          currentPage: 0,
        ));
      }
    } catch (e) {
      emit(MyReportsError(message: _getErrorMessage(e.toString())));
    }
  }

  /// Load more reports (pagination)
  Future<void> loadMoreReports({ReportStatus? status}) async {
    if (_isLoadingMore) return;

    final currentState = state;
    if (currentState is! MyReportsLoaded || !currentState.hasMore) return;

    _isLoadingMore = true;
    _currentPage++;

    try {
      final response = await _repository.getMyReports(
        page: _currentPage,
        status: status,
      );

      final allReports = [...currentState.reports, ...response.reports];

      emit(currentState.copyWith(
        reports: allReports,
        hasMore: response.hasMore,
        currentPage: _currentPage,
      ));
    } catch (e) {
      _currentPage--;
      // Don't emit error, just stop loading more
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Refresh reports
  Future<void> refreshMyReports({ReportStatus? status}) async {
    await getMyReports(status: status);
  }

  String _getErrorMessage(String error) {
    if (error.contains('500')) {
      return 'Server error occurred. Please try again later.';
    } else if (error.contains('401')) {
      return 'You are not authorized to view reports.';
    } else {
      return 'Failed to load reports. Please try again.';
    }
  }

  /// Reset to initial state
  void reset() {
    emit(ReportInitial());
  }
}
