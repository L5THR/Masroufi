import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/job_repository.dart';
import 'job_state.dart';
import '../data/models/paginated_response.dart';
import '../data/models/job.dart';

class JobCubit extends Cubit<JobState> {
  final JobRepository _repository;
  PaginatedResponse<Job>? _currentJobsPage;
  int _currentPage = 0;

  JobCubit(this._repository) : super(JobInitial());

  Future<void> getJobs({
    int page = 0,
    int size = 20,
    int? categoryId,
    String? sort,
    bool loadMore = false,
  }) async {
    if (loadMore && _currentJobsPage != null) {
      emit(JobsLoaded(_currentJobsPage!, isLoadingMore: true));
    } else {
      emit(JobLoading());
    }

    try {
      final jobs = await _repository.getJobs(
        page: page,
        size: size,
        categoryId: categoryId,
        sort: sort,
      );

      if (loadMore && _currentJobsPage != null) {
        // Append new jobs to existing list
        final combinedContent = [..._currentJobsPage!.content, ...jobs.content];
        _currentJobsPage = PaginatedResponse(
          content: combinedContent,
          totalPages: jobs.totalPages,
          totalElements: jobs.totalElements,
          size: jobs.size,
          number: jobs.number,
          first: _currentJobsPage!.first,
          last: jobs.last,
          empty: jobs.empty && _currentJobsPage!.empty,
        );
        emit(JobsLoaded(_currentJobsPage!));
      } else {
        _currentJobsPage = jobs;
        _currentPage = page;
        emit(JobsLoaded(jobs));
      }
    } catch (e) {
      emit(JobError(e.toString()));
    }
  }

  Future<void> loadMoreJobs({int? categoryId, String? sort}) async {
    if (_currentJobsPage != null && !_currentJobsPage!.last) {
      _currentPage++;
      await getJobs(
        page: _currentPage,
        categoryId: categoryId,
        sort: sort,
        loadMore: true,
      );
    }
  }

  Future<void> searchJobs({
    required String query,
    int page = 0,
    int size = 20,
    String? sort,
    bool loadMore = false,
  }) async {
    if (loadMore && _currentJobsPage != null) {
      emit(JobsLoaded(_currentJobsPage!, isLoadingMore: true));
    } else {
      emit(JobLoading());
    }
    try {
      final jobs = await _repository.searchJobs(
        query: query,
        page: page,
        size: size,
        sort: sort,
      );
      if (loadMore && _currentJobsPage != null) {
        // Append new jobs to existing list
        final combinedContent = [..._currentJobsPage!.content, ...jobs.content];
        _currentJobsPage = PaginatedResponse(
          content: combinedContent,
          totalPages: jobs.totalPages,
          totalElements: jobs.totalElements,
          size: jobs.size,
          number: jobs.number,
          first: _currentJobsPage!.first,
          last: jobs.last,
          empty: jobs.empty && _currentJobsPage!.empty,
        );
        emit(JobsLoaded(_currentJobsPage!));
      } else {
        _currentJobsPage = jobs;
        _currentPage = page;
        emit(JobsLoaded(jobs));
      }
    } catch (e) {
      emit(JobError(e.toString()));
    }
  }

  Future<void> getJobById(int jobId) async {
    emit(JobLoading());
    try {
      final job = await _repository.getJobById(jobId);
      emit(JobLoaded(job));
    } catch (e) {
      emit(JobError(e.toString()));
    }
  }

  Future<void> getCategories() async {
    emit(CategoriesLoading());
    try {
      final response = await _repository.getCategories();
      emit(CategoriesLoaded(response.content));
    } catch (e) {
      emit(JobError(e.toString()));
    }
  }

  void reset() {
    _currentJobsPage = null;
    _currentPage = 0;
    emit(JobInitial());
  }
}
