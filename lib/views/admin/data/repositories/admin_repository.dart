import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/endpoints.dart';
import '../models/dashboard_response.dart';
import '../models/user_account.dart';
import '../models/report.dart';
import '../models/activity.dart';
import '../models/update_requests.dart';
import '../../../jobs/data/models/category.dart';

class AdminRepository {
  final Dio _dio = DioClient.instance.dio;

  // ==================== DASHBOARD ====================

  /// Get dashboard statistics
  Future<DashboardResponse> getDashboardStats() async {
    try {
      final response = await _dio.get(ApiEndpoints.adminDashboard);
      return DashboardResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Failed to fetch dashboard stats: $e';
    }
  }

  // ==================== USER MANAGEMENT ====================

  /// Get all users (paginated)
  Future<Map<String, dynamic>> getUsers({
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'size': size.toString(),
        if (sort != null) 'sort': sort,
      };

      final response = await _dio.get(
        ApiEndpoints.adminUsers,
        queryParameters: queryParams,
      );

      final data = response.data;

      // Parse paginated response
      final content = (data['content'] as List)
          .map((json) => UserAccount.fromJson(json))
          .toList();

      return {
        'users': content,
        'totalPages': data['totalPages'],
        'totalElements': data['totalElements'],
        'currentPage': data['number'],
        'isFirst': data['first'],
        'isLast': data['last'],
      };
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Failed to fetch users: $e';
    }
  }

  /// Update user status (ACTIVE/BLOCKED)
  Future<UserAccount> updateUserStatus(int userId, String status) async {
    try {
      final request = UpdateUserStatusRequest(status: status);
      final response = await _dio.put(
        ApiEndpoints.updateUserStatus(userId),
        data: request.toJson(),
      );
      return UserAccount.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Failed to update user status: $e';
    }
  }

  /// Update user role
  Future<UserAccount> updateUserRole(int userId, String role) async {
    try {
      final request = UpdateUserRoleRequest(role: role);
      final response = await _dio.put(
        ApiEndpoints.updateUserRole(userId),
        data: request.toJson(),
      );
      return UserAccount.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Failed to update user role: $e';
    }
  }

  /// Delete user
  Future<void> deleteUser(int userId) async {
    try {
      await _dio.delete(ApiEndpoints.deleteUser(userId));
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Failed to delete user: $e';
    }
  }

  // ==================== JOB MANAGEMENT ====================

  /// Get job details (to retrieve recruiter info)
  Future<Map<String, dynamic>> getJobDetails(int jobId) async {
    try {
      final response = await _dio.get(ApiEndpoints.jobById(jobId));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Failed to fetch job details: $e';
    }
  }

  /// Delete a job (admin action)
  Future<void> deleteJob(int jobId) async {
    try {
      await _dio.delete(ApiEndpoints.adminDeleteJob(jobId));
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Failed to delete job: $e';
    }
  }

  // ==================== REPORT MANAGEMENT ====================

  /// Get all reports (paginated)
  Future<Map<String, dynamic>> getReports({
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'size': size.toString(),
        if (sort != null) 'sort': sort,
      };

      final response = await _dio.get(
        ApiEndpoints.adminReports,
        queryParameters: queryParams,
      );

      final data = response.data;

      // Parse paginated response
      final content = (data['content'] as List)
          .map((json) => Report.fromJson(json))
          .toList();

      return {
        'reports': content,
        'totalPages': data['totalPages'],
        'totalElements': data['totalElements'],
        'currentPage': data['number'],
        'isFirst': data['first'],
        'isLast': data['last'],
      };
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Failed to fetch reports: $e';
    }
  }

  /// Update report status
  Future<Report> updateReportStatus(int reportId, String status) async {
    try {
      final request = UpdateReportStatusRequest(status: status);
      final response = await _dio.put(
        ApiEndpoints.updateReportStatus(reportId),
        data: request.toJson(),
      );
      return Report.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Failed to update report status: $e';
    }
  }

  // ==================== ACTIVITY LOGS ====================

  /// Get activity logs (paginated)
  Future<Map<String, dynamic>> getActivities({
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'size': size.toString(),
        if (sort != null) 'sort': sort,
      };

      final response = await _dio.get(
        ApiEndpoints.adminActivities,
        queryParameters: queryParams,
      );

      final data = response.data;

      // Parse paginated response
      final content = (data['content'] as List)
          .map((json) => Activity.fromJson(json))
          .toList();

      return {
        'activities': content,
        'totalPages': data['totalPages'],
        'totalElements': data['totalElements'],
        'currentPage': data['number'],
        'isFirst': data['first'],
        'isLast': data['last'],
      };
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Failed to fetch activities: $e';
    }
  }

  // ==================== CATEGORY MANAGEMENT ====================

  /// Get all categories (paginated)
  Future<List<Category>> getCategories({
    int page = 0,
    int size = 50,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.categories,
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      final data = response.data;
      final content = data['content'] as List;
      return content.map((json) => Category.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Failed to fetch categories: $e';
    }
  }

  /// Get skills for a category
  Future<List<String>> getCategorySkills(int categoryId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.categorySkills(categoryId),
      );
      return List<String>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Failed to fetch category skills: $e';
    }
  }

  /// Create a new category (Admin only)
  Future<Category> createCategory({
    required String name,
    String? icon,
    List<String> skills = const [],
  }) async {
    try {
      final request = CategoryRequest(
        name: name,
        icon: icon,
        skills: skills,
      );

      final response = await _dio.post(
        ApiEndpoints.adminCategories,
        data: request.toJson(),
      );

      return Category.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Failed to create category: $e';
    }
  }

  /// Update a category (Admin only)
  Future<Category> updateCategory({
    required int categoryId,
    required String name,
    String? icon,
    List<String> skills = const [],
  }) async {
    try {
      final request = CategoryRequest(
        name: name,
        icon: icon,
        skills: skills,
      );

      final response = await _dio.put(
        ApiEndpoints.adminUpdateCategory(categoryId),
        data: request.toJson(),
      );

      return Category.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Failed to update category: $e';
    }
  }

  /// Delete a category (Admin only)
  Future<void> deleteCategory(int categoryId) async {
    try {
      await _dio.delete(ApiEndpoints.adminDeleteCategory(categoryId));
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Failed to delete category: $e';
    }
  }

  // Error handling
  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Unknown error';

        switch (statusCode) {
          case 400:
            return message;
          case 401:
            return 'Unauthorized. Please login again.';
          case 403:
            return 'Access forbidden. Admin privileges required.';
          case 404:
            return 'Resource not found.';
          case 500:
            return 'Server error. Please try again later.';
          default:
            return message;
        }

      case DioExceptionType.cancel:
        return 'Request cancelled.';

      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';

      default:
        return 'An unexpected error occurred.';
    }
  }
}
