// lib/views/applications/logic/application_cubit.dart

import 'package:flutter_alinfo9/views/applications/data/models/job_application.dart';
import 'package:flutter_alinfo9/views/applications/data/models/application_detail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/application_repository.dart';
import '../data/models/application_status.dart';
import 'application_state.dart';

class ApplicationCubit extends Cubit<ApplicationState> {
  final ApplicationRepository _repository;

  ApplicationCubit(this._repository) : super(const ApplicationInitial());

  // ==================== JOB SEEKER METHODS ====================

  /// Apply to a job
  Future<void> applyToJob(int jobId) async {
    emit(const ApplicationApplyLoading());

    try {
      final application = await _repository.applyToJob(jobId);
      emit(ApplicationApplySuccess(application));
    } catch (e) {
      emit(ApplicationApplyError(e.toString()));
    }
  }

  /// Get my applications
  Future<void> getMyApplications({int page = 0, int size = 20}) async {
    // Show loading only on first page
    if (page == 0) {
      emit(const ApplicationsLoading());
    }

    try {
      final applications = await _repository.getMyApplications(
        page: page,
        size: size,
      );

      if (applications.isEmpty && page == 0) {
        emit(const ApplicationsEmpty());
      } else {
        // If loading more, append to existing list
        final currentState = state;
        final existingApps = currentState is ApplicationsLoaded
            ? currentState.applications
            : <JobApplication>[];

        final allApps = page == 0
            ? applications
            : [...existingApps, ...applications];

        emit(
          ApplicationsLoaded(
            applications: allApps,
            hasMore: applications.length == size,
            currentPage: page,
          ),
        );
      }
    } catch (e) {
      emit(ApplicationsError(e.toString()));
    }
  }

  /// Refresh applications (pull to refresh)
  Future<void> refreshMyApplications() async {
    await getMyApplications(page: 0);
  }

  /// Load more applications (pagination)
  Future<void> loadMoreApplications() async {
    final currentState = state;
    if (currentState is ApplicationsLoaded && currentState.hasMore) {
      await getMyApplications(page: currentState.currentPage + 1);
    }
  }

  // ==================== RECRUITER METHODS ====================

  /// Get applications for a specific job
  Future<void> getJobApplications({
    required int jobId,
    int page = 0,
    int size = 20,
  }) async {
    // Show loading only on first page
    if (page == 0) {
      emit(const JobApplicationsLoading());
    }

    try {
      final applications = await _repository.getJobApplications(
        jobId: jobId,
        page: page,
        size: size,
      );

      if (applications.isEmpty && page == 0) {
        emit(const JobApplicationsEmpty());
      } else {
        // If loading more, append to existing list
        final currentState = state;
        final existingApps = currentState is JobApplicationsLoaded
            ? currentState.applications
            : <JobApplication>[];

        final allApps = page == 0
            ? applications
            : [...existingApps, ...applications];

        emit(
          JobApplicationsLoaded(
            applications: allApps,
            jobId: jobId,
            hasMore: applications.length == size,
            currentPage: page,
          ),
        );
      }
    } catch (e) {
      emit(JobApplicationsError(e.toString()));
    }
  }

  /// Refresh job applications (pull to refresh)
  Future<void> refreshJobApplications(int jobId) async {
    await getJobApplications(jobId: jobId, page: 0);
  }

  /// Load more job applications (pagination)
  Future<void> loadMoreJobApplications() async {
    final currentState = state;
    if (currentState is JobApplicationsLoaded && currentState.hasMore) {
      await getJobApplications(
        jobId: currentState.jobId,
        page: currentState.currentPage + 1,
      );
    }
  }

  /// Update application status
  Future<void> updateApplicationStatus({
    required int applicationId,
    required ApplicationStatus status,
  }) async {
    // Preserve previous state to restore after error
    final previousState = state;

    emit(ApplicationStatusUpdating(applicationId));

    try {
      final updatedApplication = await _repository.updateApplicationStatus(
        applicationId: applicationId,
        status: status,
      );

      emit(ApplicationStatusUpdated(updatedApplication));

      // Refresh the list after successful update
      if (previousState is JobApplicationsLoaded) {
        await refreshJobApplications(previousState.jobId);
      }
    } catch (e) {
      // Emit error first (listener will show snackbar)
      emit(ApplicationStatusUpdateError(e.toString()));

      // Restore previous state so UI doesn't go blank
      // Use Future.delayed to ensure error state is processed first
      await Future.delayed(const Duration(milliseconds: 100));

      if (previousState is JobApplicationsLoaded) {
        emit(JobApplicationsLoaded(
          applications: previousState.applications,
          jobId: previousState.jobId,
          hasMore: previousState.hasMore,
          currentPage: previousState.currentPage,
        ));
      }
    }
  }

  // ==================== APPLICATION DETAIL METHODS ====================

  /// Get application details
  Future<void> getApplicationDetail(int applicationId) async {
    emit(const ApplicationDetailLoading());

    try {
      final application = await _repository.getApplicationDetail(applicationId);
      emit(ApplicationDetailLoaded(application));
    } catch (e) {
      emit(ApplicationDetailError(e.toString()));
    }
  }

  // ==================== JOB COMPLETION METHODS ====================

  /// Start work on an accepted application (Job Seeker)
  Future<void> startWork(int applicationId) async {
    emit(CompletionActionLoading(applicationId, 'start'));

    try {
      final application = await _repository.startWork(applicationId);
      emit(WorkStarted(application));
    } catch (e) {
      emit(CompletionActionError(e.toString(), 'start'));
    }
  }

  /// Request job completion (Either party)
  Future<void> requestCompletion(int applicationId) async {
    emit(CompletionActionLoading(applicationId, 'request'));

    try {
      final application = await _repository.requestCompletion(applicationId);
      emit(CompletionRequested(application));
    } catch (e) {
      emit(CompletionActionError(e.toString(), 'request'));
    }
  }

  /// Confirm job completion (The other party)
  Future<void> confirmCompletion(int applicationId) async {
    emit(CompletionActionLoading(applicationId, 'confirm'));

    try {
      final application = await _repository.confirmCompletion(applicationId);
      emit(CompletionConfirmed(application));
    } catch (e) {
      emit(CompletionActionError(e.toString(), 'confirm'));
    }
  }

  /// Cancel completion request (The requester)
  Future<void> cancelCompletionRequest(int applicationId) async {
    emit(CompletionActionLoading(applicationId, 'cancel'));

    try {
      final application = await _repository.cancelCompletionRequest(applicationId);
      emit(CompletionRequestCancelled(application));
    } catch (e) {
      emit(CompletionActionError(e.toString(), 'cancel'));
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Reset to initial state
  void reset() {
    emit(const ApplicationInitial());
  }

  /// Filter applications by status (client-side)
  List<dynamic> filterByStatus(ApplicationStatus status) {
    final currentState = state;
    if (currentState is ApplicationsLoaded) {
      return currentState.applications
          .where((app) => app.status == status)
          .toList();
    } else if (currentState is JobApplicationsLoaded) {
      return currentState.applications
          .where((app) => app.status == status)
          .toList();
    }
    return [];
  }

  /// Get application statistics
  Map<ApplicationStatus, int> getApplicationStats() {
    final Map<ApplicationStatus, int> stats = {};
    final currentState = state;

    List<dynamic> applications = [];
    if (currentState is ApplicationsLoaded) {
      applications = currentState.applications;
    } else if (currentState is JobApplicationsLoaded) {
      applications = currentState.applications;
    }

    for (final app in applications) {
      stats[app.status] = (stats[app.status] ?? 0) + 1;
    }

    return stats;
  }
}
