import 'package:equatable/equatable.dart';
import 'package:flutter_alinfo9/views/auth/data/models/me_response.dart';

abstract class RecruiterProfileState extends Equatable {
  const RecruiterProfileState();

  @override
  List<Object> get props => [];
}

class RecruiterProfileInitial extends RecruiterProfileState {}

class RecruiterProfileLoading extends RecruiterProfileState {}

class RecruiterProfileLoaded extends RecruiterProfileState {
  final MeResponse profile;

  const RecruiterProfileLoaded(this.profile);

  @override
  List<Object> get props => [profile];
}

class RecruiterProfileFailure extends RecruiterProfileState {
  final String error;

  const RecruiterProfileFailure(this.error);

  @override
  List<Object> get props => [error];
}
