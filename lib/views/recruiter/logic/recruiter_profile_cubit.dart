import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/views/auth/data/repositories/user_repository.dart';
import 'recruiter_profile_state.dart';

class RecruiterProfileCubit extends Cubit<RecruiterProfileState> {
  final UserRepository _userRepository;

  RecruiterProfileCubit(this._userRepository) : super(RecruiterProfileInitial());

  Future<void> getRecruiterProfile() async {
    emit(RecruiterProfileLoading());
    try {
      final profile = await _userRepository.getMe();
      emit(RecruiterProfileLoaded(profile));
    } catch (e) {
      emit(RecruiterProfileFailure(e.toString()));
    }
  }
}
