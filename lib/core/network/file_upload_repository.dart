import 'dart:io';
import 'package:dio/dio.dart';
import 'dio_client.dart';
import 'package:flutter_alinfo9/core/utils/endpoints.dart';

class FileUploadRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<String> uploadFile(File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });
      final response = await _dio.post(
        ApiEndpoints.uploadFile,
        data: formData,
      );
      return response.data['url'];
    } on DioException catch (e) {
      // You can create a more robust error handling mechanism
      throw e.message ?? 'File upload failed';
    }
  }
}
