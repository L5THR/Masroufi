import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/views/jobs/data/repositories/saved_job_repository.dart';
import 'package:flutter_alinfo9/views/jobs/data/models/paginated_response.dart';
import 'package:flutter_alinfo9/views/jobs/data/models/saved_job.dart';
import 'saved_job_state.dart'; // Import the new state file

class SavedJobCubit extends Cubit<SavedJobState> {
  final SavedJobRepository _repository;
  PaginatedResponse<SavedJob>? _currentSavedJobsPage;
  int _currentPage = 0;

  SavedJobCubit(this._repository) : super(SavedJobInitial());

  Future<void> getSavedJobs({int page = 0, int size = 10, bool loadMore = false}) async {
    if (loadMore && _currentSavedJobsPage != null) {
      emit(SavedJobsLoaded(_currentSavedJobsPage!, isLoadingMore: true));
    } else {
      emit(SavedJobLoading());
    }

    try {
      final savedJobs = await _repository.getSavedJobs(page: page, size: size);

      if (loadMore && _currentSavedJobsPage != null) {
        final combinedContent = [..._currentSavedJobsPage!.content, ...savedJobs.content];
        _currentSavedJobsPage = PaginatedResponse(
          content: combinedContent,
          totalPages: savedJobs.totalPages,
          totalElements: savedJobs.totalElements,
          size: savedJobs.size,
          number: savedJobs.number,
          first: _currentSavedJobsPage!.first,
          last: savedJobs.last,
          empty: savedJobs.empty && _currentSavedJobsPage!.empty,
        );
        emit(SavedJobsLoaded(_currentSavedJobsPage!));
      } else {
        _currentSavedJobsPage = savedJobs;
        _currentPage = page;
        emit(SavedJobsLoaded(savedJobs));
      }
    } catch (e) {
      emit(SavedJobError(e.toString()));
    }
  }

  Future<void> loadMoreSavedJobs() async {
    if (_currentSavedJobsPage != null && !_currentSavedJobsPage!.last) {
      _currentPage++;
      await getSavedJobs(page: _currentPage, loadMore: true);
    }
  }

  Future<void> saveJob(int jobId) async {
    try {
      await _repository.saveJob(jobId);
      // After saving, ideally update the local list or refetch
      // For now, emit a success message
      emit(const SavedJobActionSuccess('Job saved successfully!'));
      getSavedJobs(); // Refresh the list of saved jobs
    } catch (e) {
      emit(SavedJobError(e.toString()));
    }
  }

  Future<void> unSaveJob(int jobId) async {
    try {
      await _repository.unSaveJob(jobId);
      // After unsaving, ideally update the local list or refetch
      // For now, emit a success message
      emit(const SavedJobActionSuccess('Job unsaved successfully!'));
      getSavedJobs(); // Refresh the list of saved jobs
    } catch (e) {
      emit(SavedJobError(e.toString()));
    }
  }

  // Helper to check if a job is currently saved (locally)
  bool isJobSaved(int jobId) {
    if (_currentSavedJobsPage == null) return false;
    return _currentSavedJobsPage!.content.any((savedJob) => savedJob.job.id == jobId);
  }

  void reset() {
    _currentSavedJobsPage = null;
    _currentPage = 0;
    emit(SavedJobInitial());
  }
}
