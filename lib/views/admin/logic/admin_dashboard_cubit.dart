import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/dashboard_response.dart';
import '../data/models/activity.dart';
import '../data/repositories/admin_repository.dart';

// States
abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();

  @override
  List<Object?> get props => [];
}

class AdminDashboardInitial extends AdminDashboardState {}

class AdminDashboardLoading extends AdminDashboardState {}

class AdminDashboardLoaded extends AdminDashboardState {
  final DashboardResponse stats;
  final List<Activity> activities;
  final bool isLoadingActivities;

  const AdminDashboardLoaded({
    required this.stats,
    required this.activities,
    this.isLoadingActivities = false,
  });

  @override
  List<Object?> get props => [stats, activities, isLoadingActivities];

  AdminDashboardLoaded copyWith({
    DashboardResponse? stats,
    List<Activity>? activities,
    bool? isLoadingActivities,
  }) {
    return AdminDashboardLoaded(
      stats: stats ?? this.stats,
      activities: activities ?? this.activities,
      isLoadingActivities: isLoadingActivities ?? this.isLoadingActivities,
    );
  }
}

class AdminDashboardError extends AdminDashboardState {
  final String message;

  const AdminDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final AdminRepository _repository;

  AdminDashboardCubit({required AdminRepository repository})
      : _repository = repository,
        super(AdminDashboardInitial());

  /// Load dashboard data (stats + activities)
  Future<void> loadDashboard() async {
    emit(AdminDashboardLoading());
    try {
      // Load stats and activities in parallel
      final results = await Future.wait([
        _repository.getDashboardStats(),
        _repository.getActivities(page: 0, size: 10),
      ]);

      final stats = results[0] as DashboardResponse;
      final activitiesData = results[1] as Map<String, dynamic>;
      final activities = activitiesData['activities'] as List<Activity>;

      emit(AdminDashboardLoaded(
        stats: stats,
        activities: activities,
      ));
    } catch (e) {
      emit(AdminDashboardError(e.toString()));
    }
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    await loadDashboard();
  }

  /// Load more activities
  Future<void> loadMoreActivities(int page) async {
    final currentState = state;
    if (currentState is! AdminDashboardLoaded) return;

    emit(currentState.copyWith(isLoadingActivities: true));

    try {
      final result = await _repository.getActivities(page: page, size: 10);
      final newActivities = result['activities'] as List<Activity>;

      emit(currentState.copyWith(
        activities: [...currentState.activities, ...newActivities],
        isLoadingActivities: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingActivities: false));
      // Could emit a snackbar or toast here
    }
  }
}
