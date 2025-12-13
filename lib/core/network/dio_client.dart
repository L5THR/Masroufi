import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String baseUrl = 'https://0026769ccd56.ngrok-free.app';
  static const String wsUrl = 'wss://0026769ccd56.ngrok-free.app/ws/chat';
}

class DioClient {
  DioClient._({required this.dio});

  static final DioClient _instance = DioClient._internal();
  static DioClient get instance => _instance;

  final Dio dio;

  static const _receiveTimeout = Duration(seconds: 30);
  static const _connectionTimeout = Duration(seconds: 30);

  factory DioClient._internal() {
    final baseOptions = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: _connectionTimeout,
      receiveTimeout: _receiveTimeout,
      contentType: Headers.jsonContentType,
      headers: {'Accept': 'application/json'},
    );

    final dio = Dio(baseOptions);

    dio.interceptors.addAll([
      if (kDebugMode)
        LogInterceptor(requestBody: true, responseBody: true, error: true),
    ]);

    return DioClient._(dio: dio);
  }

  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void removeAuthToken() {
    dio.options.headers.remove('Authorization');
  }
}
