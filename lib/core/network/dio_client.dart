import 'package:dio/dio.dart';

class DioClient {
  // Private constructor to prevent instantiation
  DioClient._();

  static final Dio _dio = Dio()
    ..options.baseUrl = "https://meatzo.com/api"
    ..options.headers["Content-Type"] = "application/json";

  static Dio get dio => _dio; // Public getter to access the Dio instance
}
