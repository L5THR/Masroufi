import 'package:equatable/equatable.dart';
import '../../../auth/data/models/login_response.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

/// User is browsing as a guest (not authenticated)
class AuthGuest extends AuthState {
  const AuthGuest();
}

class AuthLoginSuccess extends AuthState {
  final LoginResponse response;

  const AuthLoginSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Extension to easily check auth status
extension AuthStateExtension on AuthState {
  bool get isAuthenticated => this is AuthLoginSuccess;
  bool get isGuest => this is AuthGuest;
  bool get isLoading => this is AuthLoading;

  String? get userRole {
    if (this is AuthLoginSuccess) {
      return (this as AuthLoginSuccess).response.role;
    }
    return null;
  }
}
