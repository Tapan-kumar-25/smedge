import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {

    switch (err.response?.statusCode) {

      case 400:
        print("Bad Request");
        break;

      case 401:
        print("Unauthorized");
        break;

      case 403:
        print("Forbidden");
        break;

      case 404:
        print("Not Found");
        break;

      case 500:
        print("Server Error");
        break;

      default:
        print("Something went wrong");
    }

    return handler.next(err);

  }
}