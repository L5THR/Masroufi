// lib/views/applications/logic/application_state.dart

import 'package:equatable/equatable.dart';
import '../data/models/job_application.dart';
import '../data/models/application_detail.dart';

abstract class ApplicationState extends Equatable {
  const ApplicationState();

  @override
  List<Object?> get props => [];
}

// ==================== INITIAL STATE ====================

class ApplicationInitial extends ApplicationState {
  const ApplicationInitial();
}

// ==================== APPLY TO JOB STATES ====================

class ApplicationApplyLoading extends ApplicationState {
  const ApplicationApplyLoading();
}

class ApplicationApplySuccess extends ApplicationState {
  final JobApplication application;

  const ApplicationApplySuccess(this.application);

  @override
  List<Object?> get props => [application];
}

class ApplicationApplyError extends ApplicationState {
  final String message;

  const ApplicationApplyError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== GET MY APPLICATIONS STATES ====================

class ApplicationsLoading extends ApplicationState {
  const ApplicationsLoading();
}

class ApplicationsLoaded extends ApplicationState {
  final List<JobApplication> applications;
  final bool hasMore;
  final int currentPage;

  const ApplicationsLoaded({
    required this.applications,
    this.hasMore = false,
    this.currentPage = 0,
  });

  @override
  List<Object?> get props => [applications, hasMore, currentPage];
}

class ApplicationsError extends ApplicationState {
  final String message;

  const ApplicationsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ApplicationsEmpty extends ApplicationState {
  const ApplicationsEmpty();
}

// ==================== GET JOB APPLICATIONS STATES (RECRUITER) ====================

class JobApplicationsLoading extends ApplicationState {
  const JobApplicationsLoading();
}

class JobApplicationsLoaded extends ApplicationState {
  final List<JobApplication> applications;
  final int jobId;
  final bool hasMore;
  final int currentPage;

  const JobApplicationsLoaded({
    required this.applications,
    required this.jobId,
    this.hasMore = false,
    this.currentPage = 0,
  });

  @override
  List<Object?> get props => [applications, jobId, hasMore, currentPage];
}

class JobApplicationsError extends ApplicationState {
  final String message;

  const JobApplicationsError(this.message);

  @override
  List<Object?> get props => [message];
}

class JobApplicationsEmpty extends ApplicationState {
  const JobApplicationsEmpty();
}

// ==================== UPDATE STATUS STATES ====================

class ApplicationStatusUpdating extends ApplicationState {
  final int applicationId;

  const ApplicationStatusUpdating(this.applicationId);

  @override
  List<Object?> get props => [applicationId];
}

class ApplicationStatusUpdated extends ApplicationState {
  final JobApplication application;

  const ApplicationStatusUpdated(this.application);

  @override
  List<Object?> get props => [application];
}

class ApplicationStatusUpdateError extends ApplicationState {
  final String message;

  const ApplicationStatusUpdateError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== APPLICATION DETAIL STATES ====================

class ApplicationDetailLoading extends ApplicationState {
  const ApplicationDetailLoading();
}

class ApplicationDetailLoaded extends ApplicationState {
  final ApplicationDetail application;

  const ApplicationDetailLoaded(this.application);

  @override
  List<Object?> get props => [application];
}

class ApplicationDetailError extends ApplicationState {
  final String message;

  const ApplicationDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== JOB COMPLETION STATES ====================

class CompletionActionLoading extends ApplicationState {
  final int applicationId;
  final String action;

  const CompletionActionLoading(this.applicationId, this.action);

  @override
  List<Object?> get props => [applicationId, action];
}

class WorkStarted extends ApplicationState {
  final ApplicationDetail application;

  const WorkStarted(this.application);

  @override
  List<Object?> get props => [application];
}

class CompletionRequested extends ApplicationState {
  final ApplicationDetail application;

  const CompletionRequested(this.application);

  @override
  List<Object?> get props => [application];
}

class CompletionConfirmed extends ApplicationState {
  final ApplicationDetail application;

  const CompletionConfirmed(this.application);

  @override
  List<Object?> get props => [application];
}

class CompletionRequestCancelled extends ApplicationState {
  final ApplicationDetail application;

  const CompletionRequestCancelled(this.application);

  @override
  List<Object?> get props => [application];
}

class CompletionActionError extends ApplicationState {
  final String message;
  final String action;

  const CompletionActionError(this.message, this.action);

  @override
  List<Object?> get props => [message, action];
}
