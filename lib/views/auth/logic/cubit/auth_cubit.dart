import 'package:flutter_alinfo9/views/auth/data/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial());

  // Login
  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final response = await _repository.login(
        email: email,
        password: password,
      );
      emit(AuthLoginSuccess(response));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Register Job Seeker
  Future<void> registerJobSeeker({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    emit(AuthLoading());
    try {
      final response = await _repository.registerJobSeeker(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );
      emit(AuthRegisterSuccess(response));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Register Recruiter
  Future<void> registerRecruiter({
    required String email,
    required String password,
    required String companyName,
    String? website,
  }) async {
    emit(AuthLoading());
    try {
      final response = await _repository.registerRecruiter(
        email: email,
        password: password,
        companyName: companyName,
        website: website,
      );
      emit(AuthRegisterSuccess(response));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void reset() {
    emit(AuthInitial());
  }
}
