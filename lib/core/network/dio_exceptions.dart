import 'package:dio/dio.dart';

class AppDioException implements Exception {
  AppDioException.fromDioError(DioException dioError) {
    statusCode = dioError.response?.statusCode;
    requestPath = dioError.requestOptions.path;

    switch (dioError.type) {
      case DioExceptionType.cancel:
        message = "Request was cancelled";
        isRetryable = false;
      case DioExceptionType.connectionTimeout:
        message = "Connection timeout. Please check your internet connection.";
        isRetryable = true;
      case DioExceptionType.receiveTimeout:
        message = "Server is taking too long to respond. Please try again.";
        isRetryable = true;
      case DioExceptionType.badResponse:
        message = _handleError(
          dioError.response?.statusCode,
          dioError.response?.data,
          dioError.requestOptions.path,
        );
      case DioExceptionType.sendTimeout:
        message = "Failed to send request. Please check your connection.";
        isRetryable = true;
      case DioExceptionType.badCertificate:
        message = "Security certificate error";
        isRetryable = false;
      case DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network.';
        isRetryable = true;
      case DioExceptionType.unknown:
        if (dioError.message?.contains("SocketException") ?? false) {
          message = 'No internet connection';
          isRetryable = true;
        } else {
          message = "An unexpected error occurred";
          isRetryable = false;
        }
    }
  }

  late String message;
  late int? statusCode;
  late String requestPath;
  bool isRetryable = false;

  String _handleError(int? statusCode, dynamic error, String path) {
    // Extract error message from backend if available
    String? backendMessage;
    if (error is Map) {
      backendMessage = error['message']?.toString() ??
                      error['error']?.toString() ??
                      error['detail']?.toString();
    }

    switch (statusCode) {
      case 400:
        isRetryable = false;
        return backendMessage ?? 'Invalid request. Please check your input.';

      case 401:
        isRetryable = false;
        return 'Session expired. Please login again.';

      case 403:
        isRetryable = false;
        // Provide specific messages for known 403 scenarios
        if (path.contains('/api/jobs/recruiters/me/jobs')) {
          return 'Access denied. This feature requires recruiter privileges.\n\n'
                 'If you are a recruiter, please contact support.';
        } else if (path.contains('/api/categories')) {
          return 'Unable to load categories. The backend may still be updating.\n\n'
                 'Please try again in a moment.';
        } else if (path.contains('/recruiters/') || path.contains('/admin/')) {
          return 'Access denied. You don\'t have permission to access this resource.';
        }
        return backendMessage ?? 'Access denied. Please check your permissions.';

      case 404:
        isRetryable = false;
        return backendMessage ?? 'The requested resource was not found.';

      case 409:
        isRetryable = false;
        return backendMessage ?? 'This action conflicts with existing data.';

      case 422:
        isRetryable = false;
        return backendMessage ?? 'Unable to process your request. Please check your input.';

      case 429:
        isRetryable = true;
        return 'Too many requests. Please wait a moment and try again.';

      case 500:
        isRetryable = true;
        // Include backend message for debugging (e.g., constraint violations)
        if (backendMessage != null && backendMessage.isNotEmpty) {
          return 'Server error: $backendMessage';
        }
        return 'Server error. Our team has been notified. Please try again later.';

      case 502:
        isRetryable = true;
        return 'Server is temporarily unavailable. Please try again.';

      case 503:
        isRetryable = true;
        return 'Service temporarily unavailable. Please try again in a moment.';

      case 504:
        isRetryable = true;
        return 'Server timeout. Please try again.';

      default:
        isRetryable = false;
        return backendMessage ?? 'An error occurred. Please try again.';
    }
  }

  @override
  String toString() => message;
}
