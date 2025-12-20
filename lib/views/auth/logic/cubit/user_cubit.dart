import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/me_response.dart';
import '../../data/repositories/user_repository.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository _repository;

  UserCubit(this._repository) : super(UserInitial());

  MeResponse? get currentUser {
    final currentState = state;
    if (currentState is UserLoaded) return currentState.user;
    if (currentState is UserUpdating) return currentState.currentUser;
    if (currentState is UserError) return currentState.previousUser;
    return null;
  }

  /// Fetch the current user profile from API
  Future<void> fetchMe() async {
    emit(UserLoading());
    try {
      final user = await _repository.getMe();

      if (user.isBlocked) {
        emit(const UserError('Your account has been blocked. Please contact support.'));
        return;
      }

      debugPrint('User fetched - Role: ${user.role}, Email: ${user.email}');
      emit(UserLoaded(user));
    } catch (e) {
      debugPrint('Fetch user error: $e');
      emit(UserError(e.toString()));
    }
  }

  /// Update job seeker profile
  Future<void> updateJobSeekerProfile({
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? cvUrl,
    String? profilePictureUrl,
  }) async {
    final previousUser = currentUser;
    if (previousUser != null) {
      emit(UserUpdating(previousUser));
    } else {
      emit(UserLoading());
    }

    try {
      final updatedUser = await _repository.updateJobSeekerProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        cvUrl: cvUrl,
        profilePictureUrl: profilePictureUrl,
      );

      debugPrint('Job seeker profile updated successfully');
      emit(UserLoaded(updatedUser));
    } catch (e) {
      debugPrint('Update job seeker profile error: $e');
      emit(UserError(e.toString(), previousUser: previousUser));
    }
  }

  /// Update recruiter profile
  Future<void> updateRecruiterProfile({
    required String companyName,
    String? website,
    String? companyLogoUrl,
  }) async {
    final previousUser = currentUser;
    if (previousUser != null) {
      emit(UserUpdating(previousUser));
    } else {
      emit(UserLoading());
    }

    try {
      final updatedUser = await _repository.updateRecruiterProfile(
        companyName: companyName,
        website: website,
        companyLogoUrl: companyLogoUrl,
      );

      debugPrint('Recruiter profile updated successfully');
      emit(UserLoaded(updatedUser));
    } catch (e) {
      debugPrint('Update recruiter profile error: $e');
      emit(UserError(e.toString(), previousUser: previousUser));
    }
  }

  /// Clear user state (on logout)
  void clear() {
    emit(UserInitial());
  }
}
