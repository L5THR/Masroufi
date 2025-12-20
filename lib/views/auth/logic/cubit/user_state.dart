import 'package:equatable/equatable.dart';
import '../../data/models/me_response.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final MeResponse user;

  const UserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserUpdating extends UserState {
  final MeResponse currentUser;

  const UserUpdating(this.currentUser);

  @override
  List<Object?> get props => [currentUser];
}

class UserError extends UserState {
  final String message;
  final MeResponse? previousUser;

  const UserError(this.message, {this.previousUser});

  @override
  List<Object?> get props => [message, previousUser];
}
