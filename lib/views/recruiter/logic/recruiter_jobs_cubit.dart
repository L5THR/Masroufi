import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/views/jobs/data/repositories/job_repository.dart';
import 'package:flutter_alinfo9/views/quiz/data/repositories/quiz_repository.dart';
import 'recruiter_jobs_state.dart';

class RecruiterJobsCubit extends Cubit<RecruiterJobsState> {
  final JobRepository _jobRepository;
  final QuizRepository _quizRepository;

  RecruiterJobsCubit(this._jobRepository, this._quizRepository) : super(RecruiterJobsInitial());

  Future<void> getMyJobs({int page = 0, int size = 20}) async {
    emit(RecruiterJobsLoading());
    try {
      final jobs = await _jobRepository.getMyJobs(page: page, size: size);
      emit(RecruiterJobsLoaded(jobs));
    } catch (e) {
      emit(RecruiterJobsFailure(e.toString()));
    }
  }

  Future<void> deleteJob(int jobId) async {
    final currentState = state;
    if (currentState is! RecruiterJobsLoaded) return;

    // Store original jobs in case we need to restore
    final originalJobs = currentState.jobs;

    // Find the job to check if it has a quiz
    final job = originalJobs.content.firstWhere(
      (j) => j.id == jobId,
      orElse: () => throw Exception('Job not found'),
    );

    try {
      // If job has a quiz, delete it first
      if (job.requiresQuiz) {
        try {
          final quiz = await _quizRepository.getQuizForJob(jobId);
          await _quizRepository.deleteQuiz(quiz.id);
        } catch (e) {
          // Quiz might not exist yet or already deleted - continue with job deletion
        }
      }

      // Now delete the job
      await _jobRepository.deleteJob(jobId);

      // Remove job from list after successful deletion
      final updatedJobs = originalJobs.content
          .where((job) => job.id != jobId)
          .toList();

      final updatedPaginatedResponse = originalJobs.copyWith(
        content: updatedJobs,
      );

      emit(JobDeleteSuccess(
        deletedJobId: jobId,
        remainingJobs: updatedPaginatedResponse,
      ));
    } catch (e) {
      // Emit failure with original jobs (unchanged)
      emit(JobDeleteFailure(
        error: e.toString(),
        jobs: originalJobs,
      ));
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
