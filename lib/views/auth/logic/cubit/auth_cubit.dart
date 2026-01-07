import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../data/models/login_response.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  final UserRepository _userRepository;

  AuthCubit(this._repository, {UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository(),
        super(AuthInitial());

  // ==================== LOGIN ====================
  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final response = await _repository.login(email: email, password: password);
      await _handleAuthSuccess(response, email);
    } catch (e) {
      debugPrint('Login error: $e');
      emit(AuthError(e.toString()));
    }
  }

  // ==================== REGISTER JOB SEEKER ====================
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

      // Registration returns auth tokens directly - no need for separate login
      await _handleAuthSuccess(response, email);
    } catch (e) {
      debugPrint('Registration error: $e');
      emit(AuthError(e.toString()));
    }
  }

  // ==================== REGISTER RECRUITER ====================
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

      // Registration returns auth tokens directly - no need for separate login
      await _handleAuthSuccess(response, email);
    } catch (e) {
      debugPrint('Registration error: $e');
      emit(AuthError(e.toString()));
    }
  }

  // ==================== SHARED AUTH SUCCESS HANDLER ====================
  Future<void> _handleAuthSuccess(LoginResponse response, String email) async {
    if (response.status.toUpperCase() == 'BLOCKED') {
      emit(const AuthError('Your account has been blocked. Please contact support.'));
      return;
    }

    await HiveStorage.saveToken(response.accessToken);
    await HiveStorage.saveRefreshToken(response.refreshToken);
    await HiveStorage.saveUserData({
      'role': response.role,
      'status': response.status,
      'email': email,
    });

    DioClient.instance.setAuthToken(response.accessToken);
    debugPrint('✅ Auth successful - Role: ${response.role}');
    debugPrint('✅ Token saved: ${response.accessToken.substring(0, 20)}...');

    emit(AuthLoginSuccess(response));
  }

  // ==================== LOGOUT ====================
  Future<void> logout() async {
    try {
      // Clear all local data
      await HiveStorage.clearAll();

      // Remove token from Dio
      DioClient.instance.removeAuthToken();

      debugPrint('✅ Logout successful - All data cleared');

      emit(AuthInitial());
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      emit(AuthError('Failed to logout. Please try again.'));
    }
  }

  // ==================== CHECK AUTH STATUS ====================
  /// Check if user is already logged in (useful for splash screen)
  /// Validates token by calling GET /api/users/me
  Future<void> checkAuthStatus() async {
    try {
      final token = await HiveStorage.getToken();
      final refreshToken = await HiveStorage.getRefreshToken();

      if (token == null || token.isEmpty) {
        debugPrint('No token found');
        emit(AuthInitial());
        return;
      }

      // Set token in Dio before making API call
      DioClient.instance.setAuthToken(token);

      // Validate token by fetching user profile
      final meResponse = await _userRepository.getMe();

      // Check if user is blocked
      if (meResponse.isBlocked) {
        debugPrint('User account is blocked');
        await HiveStorage.clearAll();
        DioClient.instance.removeAuthToken();
        emit(const AuthError('Your account has been blocked. Please contact support.'));
        return;
      }

      // Update local storage with fresh data
      await HiveStorage.saveUserData({
        'role': meResponse.role,
        'status': meResponse.status,
        'email': meResponse.email,
      });

      debugPrint('Token validated - Role: ${meResponse.role}');

      final loginResponse = LoginResponse(
        accessToken: token,
        refreshToken: refreshToken ?? '',
        tokenType: 'bearer',
        role: meResponse.role,
        status: meResponse.status,
      );

      emit(AuthLoginSuccess(loginResponse));
    } catch (e) {
      debugPrint('Token validation failed: $e');
      // Token is invalid or expired - clear storage and redirect to login
      await HiveStorage.clearAll();
      DioClient.instance.removeAuthToken();
      emit(AuthInitial());
    }
  }

  // ==================== FORCE CLEAR SESSION (DEV TOOL) ====================
  /// Force clear all session data - useful when token is corrupted/expired
  /// This is a developer tool for debugging auth issues
  Future<void> forceClearSession() async {
    try {
      debugPrint('🔧 [DEV] Force clearing session...');
      await HiveStorage.clearAll();
      DioClient.instance.removeAuthToken();
      emit(AuthInitial());
      debugPrint('✅ [DEV] Session cleared successfully');
    } catch (e) {
      debugPrint('❌ [DEV] Error clearing session: $e');
    }
  }

  // ==================== GET REDIRECT ROUTE ====================
  String getRedirectRoute(String? role) {
    switch (role?.toUpperCase()) {
      case 'JOB_SEEKER':
        return '/job-seeker-home';
      case 'RECRUITER':
        return '/recruiter-home';
      case 'ADMIN':
        return '/admin-dashboard';
      default:
        return '/login';
    }
  }

  // ==================== CONTINUE AS GUEST ====================
  /// Allow user to browse without authentication
  void continueAsGuest() {
    debugPrint('👤 User continuing as guest');
    emit(const AuthGuest());
  }

  // ==================== RESET STATE ====================
  void reset() {
    emit(AuthInitial());
  }

  // ==================== CHECK IF GUEST ====================
  bool get isGuest => state is AuthGuest;

  // ==================== CHECK IF AUTHENTICATED ====================
  bool get isAuthenticated => state is AuthLoginSuccess;
}
