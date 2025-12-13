import 'package:dio/dio.dart';

class AppDioException implements Exception {
  AppDioException.fromDioError(DioException dioError) {
    statusCode = dioError.response?.statusCode;
    switch (dioError.type) {
      case DioExceptionType.cancel:
        message = "Request to API server was cancelled";
      case DioExceptionType.connectionTimeout:
        message = "Connection timeout with API server";
      case DioExceptionType.receiveTimeout:
        message = "Receive timeout in connection with API server";
      case DioExceptionType.badResponse:
        message = _handleError(
          dioError.response?.statusCode,
          dioError.response?.data,
        );
      case DioExceptionType.sendTimeout:
        message = "Send timeout in connection with API server";
      case DioExceptionType.unknown:
        if (dioError.message?.contains("SocketException") ?? false) {
          message = 'No Internet';
          break;
        }
        message = "Unexpected error occurred";
      default:
        message = "Something went wrong";
    }
  }
  late String message;
  late int? statusCode;

  String _handleError(int? statusCode, dynamic error) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return error['message'].toString();
      case 500:
        return 'Internal server error';
      case 502:
        return 'Bad gateway';
      default:
        return 'Oops something went wrong';
    }
  }

  @override
  String toString() => message;
}
