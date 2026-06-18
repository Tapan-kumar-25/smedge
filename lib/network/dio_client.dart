import 'package:dio/dio.dart';
import 'package:smedge/network/api_constants.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:smedge/network/auth_interceptor.dart';
import 'package:smedge/network/error_interceptor.dart';

class DioClient {
  static final DioClient _dioClient = DioClient._internal();

  factory DioClient() => _dioClient;
  late Dio dio;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseTestUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {"Content-Type": "application/json"},
      ),
    );
    dio.interceptors.add(AuthInterceptor());
    dio.interceptors.add(ErrorInterceptor());
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
      ),
    );
  }
}
