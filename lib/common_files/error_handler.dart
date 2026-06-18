import 'package:dio/dio.dart';

import '../model/error_response_model.dart';
import '../network/app_exception.dart';

class ErrorHandler {
  static AppException handle(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response?.data;

        final errorModel = ErrorResponseModel.fromJson(data);

        return AppException(
          message: errorModel.message ?? "",
          errorCode: errorModel.errorCode ?? "",
        );
      }
      if (error.type == DioExceptionType.connectionError) {
        return AppException(
          message: "No internet connection",
          errorCode: "NO_INTERNET",
        );
      }

      return AppException(
        message: "Something went wrong",
        errorCode: "UNKNOWN",
      );
    }

    return AppException(message: "Unexpected error", errorCode: "UNKNOWN");
  }
}
