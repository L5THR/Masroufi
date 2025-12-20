import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/endpoints.dart';
import '../models/login_response.dart';

class AuthRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Register returns AuthResponse (same as login) per API spec
  Future<LoginResponse> registerJobSeeker({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.registerJobSeeker,
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
        },
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Register returns AuthResponse (same as login) per API spec
  Future<LoginResponse> registerRecruiter({
    required String email,
    required String password,
    required String companyName,
    String? website,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.registerRecruiter,
        data: {
          'email': email,
          'password': password,
          'companyName': companyName,
          if (website != null) 'website': website,
        },
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message =
            e.response?.data['message'] ?? e.response?.data['error'];

        if (statusCode == 400) {
          return message ?? 'Invalid request. Please check your input.';
        } else if (statusCode == 401) {
          return message ?? 'Invalid email or password.';
        } else if (statusCode == 409) {
          return message ?? 'Email already exists.';
        } else if (statusCode == 500) {
          return 'Server error. Please try again later.';
        }
        return message ?? 'An error occurred. Please try again.';

      case DioExceptionType.cancel:
        return 'Request cancelled.';

      default:
        return 'Network error. Please check your connection.';
    }
  }
}
