import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/core/network/file_upload_repository.dart';
import '../../jobs/data/models/job_request.dart';
import '../../jobs/data/repositories/job_repository.dart';
import 'create_job_state.dart';

class CreateJobCubit extends Cubit<CreateJobState> {
  final JobRepository _jobRepository;
  final FileUploadRepository _fileUploadRepository;

  CreateJobCubit(this._jobRepository, this._fileUploadRepository) : super(CreateJobInitial());

  Future<void> createJob(JobRequest jobRequest, {File? imageFile}) async {
    emit(CreateJobLoading());
    try {
      print('Image file: $imageFile');
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _fileUploadRepository.uploadFile(imageFile);
      }
      print('Image URL: $imageUrl');

      final newJobRequest = JobRequest(
        title: jobRequest.title,
        description: jobRequest.description,
        requirements: jobRequest.requirements,
        location: jobRequest.location,
        salary: jobRequest.salary,
        duration: jobRequest.duration,
        categoryId: jobRequest.categoryId,
        requiresQuiz: jobRequest.requiresQuiz,
        imageUrl: imageUrl ?? jobRequest.imageUrl,
        skills: jobRequest.skills,
      );

      print('Job request: ${newJobRequest.toJson()}');

      final job = await _jobRepository.createJob(newJobRequest);
      emit(CreateJobSuccess(job));
    } catch (e) {
      print('Error creating job: $e');
      emit(CreateJobFailure(e.toString()));
    }
  }

  Future<void> updateJob(int jobId, JobRequest jobRequest, {File? imageFile}) async {
    emit(CreateJobLoading());
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _fileUploadRepository.uploadFile(imageFile);
      }

      final newJobRequest = JobRequest(
        title: jobRequest.title,
        description: jobRequest.description,
        requirements: jobRequest.requirements,
        location: jobRequest.location,
        salary: jobRequest.salary,
        duration: jobRequest.duration,
        categoryId: jobRequest.categoryId,
        requiresQuiz: jobRequest.requiresQuiz,
        imageUrl: imageUrl ?? jobRequest.imageUrl,
        skills: jobRequest.skills,
      );

      final job = await _jobRepository.updateJob(jobId, newJobRequest);
      emit(CreateJobSuccess(job));
    } catch (e) {
      emit(CreateJobFailure(e.toString()));
    }
  }
}
