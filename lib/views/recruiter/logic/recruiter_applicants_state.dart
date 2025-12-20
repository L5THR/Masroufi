import 'package:equatable/equatable.dart';
import 'package:flutter_alinfo9/views/applications/data/models/job_application.dart';

abstract class RecruiterApplicantsState extends Equatable {
  const RecruiterApplicantsState();

  @override
  List<Object> get props => [];
}

class RecruiterApplicantsInitial extends RecruiterApplicantsState {}

class RecruiterApplicantsLoading extends RecruiterApplicantsState {}

class RecruiterApplicantsLoaded extends RecruiterApplicantsState {
  final List<JobApplication> applicants;

  const RecruiterApplicantsLoaded(this.applicants);

  @override
  List<Object> get props => [applicants];
}

class RecruiterApplicantsFailure extends RecruiterApplicantsState {
  final String error;

  const RecruiterApplicantsFailure(this.error);

  @override
  List<Object> get props => [error];
}
