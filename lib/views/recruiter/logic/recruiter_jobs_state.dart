import 'package:equatable/equatable.dart';
import 'package:flutter_alinfo9/views/jobs/data/models/paginated_response.dart';
import '../../jobs/data/models/job.dart';

abstract class RecruiterJobsState extends Equatable {
  const RecruiterJobsState();

  @override
  List<Object> get props => [];
}

class RecruiterJobsInitial extends RecruiterJobsState {}

class RecruiterJobsLoading extends RecruiterJobsState {}

class RecruiterJobsLoaded extends RecruiterJobsState {
  final PaginatedResponse<Job> jobs;

  const RecruiterJobsLoaded(this.jobs);

  @override
  List<Object> get props => [jobs];
}

class RecruiterJobsFailure extends RecruiterJobsState {
  final String error;

  const RecruiterJobsFailure(this.error);

  @override
  List<Object> get props => [error];
}

/// State emitted when a job is successfully deleted
class JobDeleteSuccess extends RecruiterJobsState {
  final int deletedJobId;
  final PaginatedResponse<Job> remainingJobs;

  const JobDeleteSuccess({required this.deletedJobId, required this.remainingJobs});

  @override
  List<Object> get props => [deletedJobId, remainingJobs];
}

/// State emitted when job deletion fails
class JobDeleteFailure extends RecruiterJobsState {
  final String error;
  final PaginatedResponse<Job> jobs; // Original jobs list (unchanged)

  const JobDeleteFailure({required this.error, required this.jobs});

  @override
  List<Object> get props => [error, jobs];
}
