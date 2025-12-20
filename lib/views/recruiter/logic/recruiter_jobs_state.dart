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
