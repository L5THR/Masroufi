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
  final List<Category>? categories; // Include categories to preserve state

  const JobsLoaded(this.jobs, {this.isLoadingMore = false, this.categories});

  @override
  List<Object?> get props => [jobs, isLoadingMore, categories];
}

class JobLoaded extends JobState {
  final Job job;

  const JobLoaded(this.job);

  @override
  List<Object?> get props => [job];
}

class CategoriesLoaded extends JobState {
  final List<Category> categories;
  final PaginatedResponse<Job>? jobs; // Include jobs to preserve state

  const CategoriesLoaded(this.categories, {this.jobs});

  @override
  List<Object?> get props => [categories, jobs];
}

class JobError extends JobState {
  final String message;

  const JobError(this.message);

  @override
  List<Object?> get props => [message];
}
