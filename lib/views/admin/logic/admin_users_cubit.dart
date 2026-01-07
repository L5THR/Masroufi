import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/user_account.dart';
import '../data/repositories/admin_repository.dart';

// States
abstract class AdminUsersState extends Equatable {
  const AdminUsersState();

  @override
  List<Object?> get props => [];
}

class AdminUsersInitial extends AdminUsersState {}

class AdminUsersLoading extends AdminUsersState {}

class AdminUsersLoaded extends AdminUsersState {
  final List<UserAccount> users;
  final int totalPages;
  final int totalElements;
  final int currentPage;
  final bool isLoadingMore;
  final String? searchQuery;

  const AdminUsersLoaded({
    required this.users,
    required this.totalPages,
    required this.totalElements,
    required this.currentPage,
    this.isLoadingMore = false,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [
        users,
        totalPages,
        totalElements,
        currentPage,
        isLoadingMore,
        searchQuery,
      ];

  AdminUsersLoaded copyWith({
    List<UserAccount>? users,
    int? totalPages,
    int? totalElements,
    int? currentPage,
    bool? isLoadingMore,
    String? searchQuery,
  }) {
    return AdminUsersLoaded(
      users: users ?? this.users,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class AdminUsersError extends AdminUsersState {
  final String message;

  const AdminUsersError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminUsersActionSuccess extends AdminUsersState {
  final String message;

  const AdminUsersActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class AdminUsersCubit extends Cubit<AdminUsersState> {
  final AdminRepository _repository;

  AdminUsersCubit({required AdminRepository repository})
      : _repository = repository,
        super(AdminUsersInitial());

  /// Load users list
  Future<void> loadUsers({int page = 0, int size = 20}) async {
    emit(AdminUsersLoading());
    try {
      final result = await _repository.getUsers(page: page, size: size);

      emit(AdminUsersLoaded(
        users: result['users'] as List<UserAccount>,
        totalPages: result['totalPages'] as int,
        totalElements: result['totalElements'] as int,
        currentPage: result['currentPage'] as int,
      ));
    } catch (e) {
      emit(AdminUsersError(e.toString()));
    }
  }

  /// Refresh users list
  Future<void> refresh() async {
    await loadUsers();
  }

  /// Search users by email
  void searchUsers(String query) {
    final currentState = state;
    if (currentState is! AdminUsersLoaded) return;

    if (query.isEmpty) {
      // Reset search
      loadUsers();
      return;
    }

    final filtered = currentState.users
        .where((user) => user.email.toLowerCase().contains(query.toLowerCase()))
        .toList();

    emit(currentState.copyWith(
      users: filtered,
      searchQuery: query,
    ));
  }

  /// Load more users (pagination)
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! AdminUsersLoaded) return;
    if (currentState.isLoadingMore) return;
    if (currentState.currentPage >= currentState.totalPages - 1) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final result = await _repository.getUsers(page: nextPage, size: 20);

      final newUsers = result['users'] as List<UserAccount>;

      emit(currentState.copyWith(
        users: [...currentState.users, ...newUsers],
        currentPage: nextPage,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
      // Error loading more, but keep current state
    }
  }

  /// Block user
  Future<void> blockUser(int userId) async {
    try {
      await _repository.updateUserStatus(userId, 'BLOCKED');
      emit(const AdminUsersActionSuccess('User blocked successfully'));
      await refresh(); // Reload list
    } catch (e) {
      emit(AdminUsersError('Failed to block user: $e'));
      // Restore previous state
      final currentState = state;
      if (currentState is AdminUsersLoaded) {
        emit(currentState);
      }
    }
  }

  /// Unblock user
  Future<void> unblockUser(int userId) async {
    try {
      await _repository.updateUserStatus(userId, 'ACTIVE');
      emit(const AdminUsersActionSuccess('User unblocked successfully'));
      await refresh(); // Reload list
    } catch (e) {
      emit(AdminUsersError('Failed to unblock user: $e'));
      // Restore previous state
      final currentState = state;
      if (currentState is AdminUsersLoaded) {
        emit(currentState);
      }
    }
  }

  /// Change user role
  Future<void> changeUserRole(int userId, String newRole) async {
    try {
      await _repository.updateUserRole(userId, newRole);
      emit(AdminUsersActionSuccess('User role changed to $newRole'));
      await refresh(); // Reload list
    } catch (e) {
      emit(AdminUsersError('Failed to change user role: $e'));
      // Restore previous state
      final currentState = state;
      if (currentState is AdminUsersLoaded) {
        emit(currentState);
      }
    }
  }

  /// Delete user
  Future<void> deleteUser(int userId) async {
    try {
      await _repository.deleteUser(userId);
      emit(const AdminUsersActionSuccess('User deleted successfully'));
      await refresh(); // Reload list
    } catch (e) {
      emit(AdminUsersError('Failed to delete user: $e'));
      // Restore previous state
      final currentState = state;
      if (currentState is AdminUsersLoaded) {
        emit(currentState);
      }
    }
  }
}
