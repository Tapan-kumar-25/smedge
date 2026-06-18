import 'package:dio/dio.dart';
import 'package:smedge/common_files/utils.dart';
import 'package:uuid/uuid.dart';

class AuthInterceptor extends Interceptor {

  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      )async{
     await Utils.getAccessToken();
     String token = Utils.accessToken;
    String deviceIntegrity = "1";
    String requestId = const Uuid().v4();
    options.headers.addAll({
      "Authorization": "Bearer $token",
      "X-Device-Integrity": deviceIntegrity,
      "X-Request-ID": requestId,
    });
    return handler.next(options);
  }

}