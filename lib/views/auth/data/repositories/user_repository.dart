import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/endpoints.dart';
import '../models/me_response.dart';

class UserRepository {
  final Dio _dio = DioClient.instance.dio;

  /// GET /api/users/me - Get current user profile
  Future<MeResponse> getMe() async {
    try {
      print('📡 Fetching current user profile...');
      print('📡 Endpoint: ${ApiEndpoints.currentUser}');
      final response = await _dio.get(ApiEndpoints.currentUser);
      print('✅ User profile fetched successfully');
      print('✅ Role: ${response.data['role']}, Email: ${response.data['email']}');
      return MeResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Failed to fetch user profile: ${e.response?.statusCode}');
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
      print('📡 Updating job seeker profile...');
      print('📡 Endpoint: ${ApiEndpoints.updateJobSeekerProfile}');
      print('📡 Data: $data');

      final response = await _dio.put(
        ApiEndpoints.updateJobSeekerProfile,
        data: data,
      );

      print('✅ Job seeker profile updated successfully');
      return MeResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Failed to update job seeker profile: ${e.response?.statusCode}');
      print('❌ Error: ${e.response?.data}');
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
      print('📡 Updating recruiter profile...');
      print('📡 Endpoint: ${ApiEndpoints.updateRecruiterProfile}');
      print('📡 Data: $data');

      final response = await _dio.put(
        ApiEndpoints.updateRecruiterProfile,
        data: data,
      );

      print('✅ Recruiter profile updated successfully');
      return MeResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Failed to update recruiter profile: ${e.response?.statusCode}');
      print('❌ Error: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    print('🔍 Handling error - Type: ${e.type}, Status: ${e.response?.statusCode}');
    print('🔍 Response data type: ${e.response?.data.runtimeType}');
    print('🔍 Response data: ${e.response?.data}');

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
