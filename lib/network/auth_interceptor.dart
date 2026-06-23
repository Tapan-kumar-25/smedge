import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import 'api_constants.dart';
import '../common_files/utils.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    try {
      if (options.path == ApiConstants.refreshToken) {
        return handler.next(options);
      }

      await Utils.getAccessToken();

      final String token = Utils.accessToken;
      final String requestId = const Uuid().v4();

      options.headers["X-Device-Integrity"] = "1";
      options.headers["X-Request-ID"] = requestId;

      if (token.isNotEmpty) {
        options.headers["Authorization"] = "Bearer $token";
      }

      handler.next(options);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: e,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }
}