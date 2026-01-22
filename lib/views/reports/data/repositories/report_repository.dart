// lib/views/reports/data/repositories/report_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter_alinfo9/core/network/dio_client.dart';
import 'package:flutter_alinfo9/core/network/dio_exceptions.dart';
import 'package:flutter_alinfo9/core/utils/endpoints.dart';
import '../models/report.dart';
import '../models/my_report.dart';

class ReportRepository {
  final Dio _dio = DioClient.instance.dio;

  /// Create a new report
  /// POST /api/reports
  Future<Report> createReport({
    required int targetId,
    required ReportTargetType targetType,
    required String reason,
  }) async {
    try {
      final request = ReportRequest(
        targetId: targetId,
        targetType: targetType,
        reason: reason,
      );

      if (!request.isValid) {
        throw Exception('Invalid report data. Reason cannot be empty.');
      }

      final response = await _dio.post(
        ApiEndpoints.reports,
        data: request.toJson(),
      );

      return Report.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error creating report: ${e.message}');
      throw AppDioException.fromDioError(e);
    }
  }

  /// Get my submitted reports
  /// GET /api/reports/me
  Future<MyReportsResponse> getMyReports({
    int page = 0,
    int size = 20,
    ReportStatus? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };

      if (status != null) {
        queryParams['status'] = status.toJson();
      }

      final response = await _dio.get(
        ApiEndpoints.myReports,
        queryParameters: queryParams,
      );

      return MyReportsResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error fetching my reports: ${e.message}');
      throw AppDioException.fromDioError(e);
    }
  }
}

/// Paginated response for my reports
class MyReportsResponse {
  final List<MyReport> reports;
  final int totalPages;
  final int totalElements;
  final int currentPage;
  final bool hasMore;

  MyReportsResponse({
    required this.reports,
    required this.totalPages,
    required this.totalElements,
    required this.currentPage,
    required this.hasMore,
  });

  factory MyReportsResponse.fromJson(Map<String, dynamic> json) {
    final content = json['content'] as List<dynamic>? ?? [];
    final currentPage = json['number'] ?? 0;
    final totalPages = json['totalPages'] ?? 1;

    return MyReportsResponse(
      reports: content.map((e) => MyReport.fromJson(e)).toList(),
      totalPages: totalPages,
      totalElements: json['totalElements'] ?? 0,
      currentPage: currentPage,
      hasMore: currentPage < totalPages - 1,
    );
  }
}
