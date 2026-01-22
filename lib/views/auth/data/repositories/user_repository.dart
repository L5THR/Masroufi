import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/endpoints.dart';
import '../models/me_response.dart';

class UserRepository {
  final Dio _dio = DioClient.instance.dio;

  /// GET /api/users/me - Get current user profile
  Future<MeResponse> getMe() async {
    try {
      final response = await _dio.get(ApiEndpoints.currentUser);
      return MeResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /api/users/me/job-seeker-profile - Update job seeker profile
  Future<MeResponse> updateJobSeekerProfile({
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? cvUrl,
    String? profilePictureUrl,
  }) async {
    try {
      final data = {
        'firstName': firstName,
        'lastName': lastName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (cvUrl != null) 'cvUrl': cvUrl,
        if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
      };

      final response = await _dio.put(
        ApiEndpoints.updateJobSeekerProfile,
        data: data,
      );

      return MeResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /api/users/me/recruiter-profile - Update recruiter profile
  Future<MeResponse> updateRecruiterProfile({
    required String companyName,
    String? website,
    String? companyLogoUrl,
  }) async {
    try {
      final data = {
        'companyName': companyName,
        if (website != null) 'website': website,
        if (companyLogoUrl != null) 'companyLogoUrl': companyLogoUrl,
      };

      final response = await _dio.put(
        ApiEndpoints.updateRecruiterProfile,
        data: data,
      );

      return MeResponse.fromJson(response.data);
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
        final data = e.response?.data;

        // Handle different response data types
        String? message;
        if (data is Map) {
          message = data['message']?.toString() ?? data['error']?.toString();
        } else if (data is String) {
          message = data;
        }

        if (statusCode == 401) {
          return 'Session expired. Please login again.';
        } else if (statusCode == 403) {
          return message ?? 'You do not have permission to perform this action.';
        } else if (statusCode == 404) {
          return 'User not found.';
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
