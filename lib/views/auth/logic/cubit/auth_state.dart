import 'package:equatable/equatable.dart';
import 'package:flutter_alinfo9/views/auth/data/models/login_response.dart';
import 'package:flutter_alinfo9/views/auth/data/models/register_response.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoginSuccess extends AuthState {
  final LoginResponse response;

  const AuthLoginSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class AuthRegisterSuccess extends AuthState {
  final RegisterResponse response;

  const AuthRegisterSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
