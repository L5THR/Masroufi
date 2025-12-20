import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/views/jobs/data/repositories/job_repository.dart';
import 'recruiter_jobs_state.dart';

class RecruiterJobsCubit extends Cubit<RecruiterJobsState> {
  final JobRepository _jobRepository;

  RecruiterJobsCubit(this._jobRepository) : super(RecruiterJobsInitial());

  Future<void> getMyJobs({int page = 0, int size = 20}) async {
    emit(RecruiterJobsLoading());
    try {
      print('🔍 Fetching recruiter jobs (page: $page, size: $size)...');
      final jobs = await _jobRepository.getMyJobs(page: page, size: size);
      print('✅ Successfully loaded ${jobs.content.length} jobs');
      emit(RecruiterJobsLoaded(jobs));
    } catch (e) {
      print('❌ Error loading recruiter jobs: $e');
      emit(RecruiterJobsFailure(e.toString()));
    }
  }

  Future<void> deleteJob(int jobId) async {
    // Optimistically update UI by removing the job from current state
    final currentState = state;
    if (currentState is RecruiterJobsLoaded) {
      final updatedJobs = currentState.jobs.content
          .where((job) => job.id != jobId)
          .toList();

      final updatedPaginatedResponse = currentState.jobs.copyWith(
        content: updatedJobs,
      );

      emit(RecruiterJobsLoaded(updatedPaginatedResponse));
    }

    try {
      await _jobRepository.deleteJob(jobId);
      // Job already removed from UI optimistically
    } catch (e) {
      // If delete fails, reload the jobs to restore the state
      emit(RecruiterJobsFailure(e.toString()));
      await getMyJobs();
    }
  }

  Future<void> loadMoreJobs({required int page, required int size}) async {
    final currentState = state;
    if (currentState is RecruiterJobsLoaded) {
      try {
        final newJobs = await _jobRepository.getMyJobs(page: page, size: size);
        final allJobs = [
          ...currentState.jobs.content,
          ...newJobs.content,
        ];

        final updatedResponse = newJobs.copyWith(content: allJobs);
        emit(RecruiterJobsLoaded(updatedResponse));
      } catch (e) {
        // Keep current state on error, just show error message
        emit(RecruiterJobsFailure(e.toString()));
        // Restore previous state
        emit(currentState);
      }
    }
  }

  Future<void> refreshJobs() async {
    await getMyJobs();
  }
}
