import 'dart:io';

import 'package:smedge/common_files/utils.dart';

import '../../../common_files/error_handler.dart';
import '../auth_api_service/auth_api_service.dart';
import '../model/resume_sign_up_model.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService apiService;

  AuthRepositoryImpl(this.apiService);

  @override
  Future<dynamic> refreshToken(String refreshToken) async {
    try {
      final response = await apiService.refreshToken({
        "refresh_token": refreshToken,
        "device_token": Utils.deviceId,
      });
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<dynamic> checkEmail(String email) async {
    try {
      final response = await apiService.checkEmail({"email": email});
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<dynamic> checkPhone(String phone) async {
    try {
      final response = await apiService.checkPhone({"phone_number": phone});
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<dynamic> register(Map<String, dynamic> body) async {
    try {
      final response = await apiService.register(body);
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<dynamic> verifyEmail(Map<String, dynamic> body) async {
    try {
      final response = await apiService.emailVerify(body);
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<dynamic> verifyPhone(Map<String, dynamic> body) async {
    try {
      final response = await apiService.phoneVerify(body);
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<dynamic> initiateKyc({required String signupSessionToken}) async {
    try {
      final response = await apiService.initiateKyc({
        "signup_session_token": signupSessionToken,
      }, "1",
        "test-device-fp-001",
        platform,);
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<dynamic> kycComplete(Map<String, dynamic> body) async {
    try {
      final response = await apiService.kycComplete(body, "1",
        "test-device-fp-001",
        platform,);
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<dynamic> skipKyc({required String signupSessionToken}) async {
    try {
      final response = await apiService.kycSkip({
        "signup_session_token": signupSessionToken,
      });
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<dynamic> saveCompany({required Map<String, dynamic> body}) async {
    try {
      final response = await apiService.saveCompany(body);
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<ResumeSignupModel> resumeSignup({
    required String signupSessionToken,
  }) async {
    try {
      final response = await apiService.resumeSignup(signupSessionToken);
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<dynamic> resendOtp({
    required String signupSessionToken,
    required String channel,
  }) async {
    try {
      final response = await apiService.resendOtp({
        "signup_session_token": signupSessionToken,
        "channel": channel,
      });
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<dynamic> signIn({required Map<String, dynamic> body}) async {
    try {
      final response = await apiService.signIn(body);
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<dynamic> signInOtpVerify({required Map<String, dynamic> body}) async {
    try {
      final response = await apiService.signInOtpVerify(body);
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<dynamic> signInOtpResend({required Map<String, dynamic> body}) async {
    try {
      final response = await apiService.signInOtpVResend(body);
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  final platform = Platform.isAndroid ? "android" : "ios";

  @override
  Future<dynamic> signupWithUaePass({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await apiService.signUpWithUAEPass(
        body,
        "1",
        "test-device-fp-001",
        platform,
      );
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<dynamic> signupWithUaePassCompleted({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await apiService.signUpWithUAEPassCompleted(
        body,
        "1",
        "test-device-fp-001",
        platform,
      );
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
  @override
  Future<dynamic> signUpUaePassSetPassword({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await apiService.setSignUpUaePassPassword(body);
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }


  @override
  Future<dynamic> signInWithUaePass({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await apiService.signInWithUAEPass(
        body,
        "1",
        "test-device-fp-001",
        platform,
      );
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<dynamic> signInWithUaePassCompleted({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await apiService.signInWithUAEPassCompleted(
        body,
        "1",
        "test-device-fp-001",
        platform,
      );
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
