import 'package:equatable/equatable.dart';
import '../data/models/job.dart';
import '../data/models/category.dart';
import '../data/models/paginated_response.dart';

abstract class JobState extends Equatable {
  const JobState();

  @override
  List<Object?> get props => [];
}

class JobInitial extends JobState {}

class JobLoading extends JobState {}

class CategoriesLoading extends JobState {}

class JobsLoaded extends JobState {
  final PaginatedResponse<Job> jobs;
  final bool isLoadingMore;

  const JobsLoaded(this.jobs, {this.isLoadingMore = false});

  @override
  List<Object?> get props => [jobs, isLoadingMore];
}

class JobLoaded extends JobState {
  final Job job;

  const JobLoaded(this.job);

  @override
  List<Object?> get props => [job];
}

class CategoriesLoaded extends JobState {
  final List<Category> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class JobError extends JobState {
  final String message;

  const JobError(this.message);

  @override
  List<Object?> get props => [message];
}
