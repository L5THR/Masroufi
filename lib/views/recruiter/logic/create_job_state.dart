import 'package:equatable/equatable.dart';
import '../../jobs/data/models/job.dart';

abstract class CreateJobState extends Equatable {
  const CreateJobState();

  @override
  List<Object> get props => [];
}

class CreateJobInitial extends CreateJobState {}

class CreateJobLoading extends CreateJobState {}

class CreateJobSuccess extends CreateJobState {
  final Job job;

  const CreateJobSuccess(this.job);

  @override
  List<Object> get props => [job];
}

class CreateJobFailure extends CreateJobState {
  final String error;

  const CreateJobFailure(this.error);

  @override
  List<Object> get props => [error];
}
