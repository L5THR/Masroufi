import 'package:flutter_alinfo9/views/applications/data/models/application_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/views/applications/data/repositories/application_repository.dart';
import 'recruiter_applicants_state.dart';

class RecruiterApplicantsCubit extends Cubit<RecruiterApplicantsState> {
  final ApplicationRepository _applicationRepository;

  RecruiterApplicantsCubit(this._applicationRepository) : super(RecruiterApplicantsInitial());

  Future<void> getApplicantsForRecruiter() async {
    emit(RecruiterApplicantsLoading());
    try {
      final applicants = await _applicationRepository.getApplicantsForRecruiter();
      emit(RecruiterApplicantsLoaded(applicants));
    } catch (e) {
      emit(RecruiterApplicantsFailure(e.toString()));
    }
  }

  Future<void> acceptApplicant(int applicationId) async {
    try {
      await _applicationRepository.updateApplicationStatus(
        applicationId: applicationId,
        status: ApplicationStatus.ACCEPTED,
      );
      getApplicantsForRecruiter();
    } catch (e) {
      // Optionally emit a failure state to show an error message
    }
  }

  Future<void> rejectApplicant(int applicationId) async {
    try {
      await _applicationRepository.updateApplicationStatus(
        applicationId: applicationId,
        status: ApplicationStatus.REJECTED,
      );
      getApplicantsForRecruiter();
    } catch (e) {
      // Optionally emit a failure state to show an error message
    }
  }
}
