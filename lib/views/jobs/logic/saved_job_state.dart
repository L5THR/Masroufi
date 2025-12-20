import 'package:equatable/equatable.dart';
import 'package:flutter_alinfo9/views/jobs/data/models/saved_job.dart';
import 'package:flutter_alinfo9/views/jobs/data/models/paginated_response.dart';

abstract class SavedJobState extends Equatable {
  const SavedJobState();

  @override
  List<Object?> get props => [];
}

class SavedJobInitial extends SavedJobState {}

class SavedJobLoading extends SavedJobState {}

class SavedJobsLoaded extends SavedJobState {
  final PaginatedResponse<SavedJob> savedJobs;
  final bool isLoadingMore;

  const SavedJobsLoaded(this.savedJobs, {this.isLoadingMore = false});

  @override
  List<Object?> get props => [savedJobs, isLoadingMore];
}

class SavedJobActionSuccess extends SavedJobState {
  final String message;
  const SavedJobActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class SavedJobError extends SavedJobState {
  final String message;

  const SavedJobError(this.message);

  @override
  List<Object?> get props => [message];
}